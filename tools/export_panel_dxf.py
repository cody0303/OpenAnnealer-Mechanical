#!/usr/bin/env python3
"""Write a flat (laser/waterjet-cut) part as a DXF.

OpenSCAD's own DXF export is malformed (an R10 header over R14-only
LWPOLYLINE entities, and every hole tessellated into a polygon), and cutting
services such as SendCutSend reject it. This asks OpenSCAD for the part's
feature list and writes a plain AutoCAD R12 DXF made of true LINE, ARC and
CIRCLE entities. Units are mm.

Works on any flat part that follows the cad/cabinetFlat/ convention:
  - a function panelFeatures() returning the part's edges as a list of
    ["rrect", x, y, w, h, r], ["rect", x, y, w, h], ["slot", cx, cy, s, r]
    (along x), ["vslot", cx, cy, s, r] (along y) and ["circle", cx, cy, d]
    -- the first is the outline, the rest are cut
    out of it (the part should draw itself from the same list);
  - a top-level `echoFeatures` flag that, when true, does
    echo(panelFeatures = panelFeatures());

    python tools/export_panel_dxf.py [SCAD] [-o OUT.dxf] [--openscad PATH]

SCAD defaults to cad/cabinetFlat/sidePanel.scad; OUT defaults to the SCAD's
name with .dxf. Standard library only (Python 3.6+). The OpenSCAD binary
defaults to $OPENSCAD, then `openscad` on the PATH; it must be a nightly
build, like the rest of this repo, since --enable=import-function is always
passed (catchnhole needs it, for parts that use it).
"""

import argparse
import json
import os
import subprocess
import sys
from pathlib import Path

REPO = Path(__file__).resolve().parent.parent
DEFAULT_SCAD = REPO / "cad" / "cabinetFlat" / "sidePanel.scad"


def panel_features(openscad, scad):
    """Run OpenSCAD in echo mode and return the part's panelFeatures().

    The echo goes to stdout (`-o -`) rather than a temp file: OpenSCAD is
    often a snap (it is on the release runner), and snaps get a private /tmp,
    so a file written there by OpenSCAD never shows up for this script.
    """
    run = subprocess.run(
        [openscad, "--enable=import-function", "-D", "echoFeatures=true",
         "--export-format", "echo", "-o", "-", str(scad)],
        stdout=subprocess.PIPE, stderr=subprocess.PIPE,
        universal_newlines=True)
    if run.returncode != 0:
        sys.stderr.write(run.stdout + run.stderr)
        sys.exit("OpenSCAD failed on {}".format(scad))
    prefix = "ECHO: panelFeatures = "
    for line in (run.stdout + "\n" + run.stderr).splitlines():
        if line.startswith(prefix):
            return json.loads(line[len(prefix):])
    sys.stderr.write(run.stdout + run.stderr)
    sys.exit("{} didn't echo panelFeatures -- does it define panelFeatures() "
             "and an echoFeatures flag?".format(scad))


class R12:
    """Just enough of the R12 ASCII DXF format for flat cut profiles."""

    def __init__(self):
        self.entities = []
        self.xs, self.ys = [], []

    def _pt(self, x, y, code=10):
        self.xs.append(x)
        self.ys.append(y)
        return [code, f"{x:.6f}", code + 10, f"{y:.6f}", code + 20, "0.0"]

    def line(self, x1, y1, x2, y2):
        self.entities.append(["0", "LINE", 8, "0", *self._pt(x1, y1), *self._pt(x2, y2, 11)])

    def arc(self, cx, cy, r, start, end):
        """Counter-clockwise from start to end, in degrees."""
        self.entities.append(["0", "ARC", 8, "0", *self._pt(cx, cy),
                              40, f"{r:.6f}", 50, f"{start:.6f}", 51, f"{end:.6f}"])
        self.xs += [cx - r, cx + r]
        self.ys += [cy - r, cy + r]

    def circle(self, cx, cy, r):
        self.entities.append(["0", "CIRCLE", 8, "0", *self._pt(cx, cy), 40, f"{r:.6f}"])
        self.xs += [cx - r, cx + r]
        self.ys += [cy - r, cy + r]

    def text(self):
        rows = ["0", "SECTION", "2", "HEADER",
                "9", "$ACADVER", "1", "AC1009",
                "9", "$INSUNITS", "70", "4",                  # millimetres
                "9", "$EXTMIN", "10", f"{min(self.xs):.6f}", "20", f"{min(self.ys):.6f}", "30", "0.0",
                "9", "$EXTMAX", "10", f"{max(self.xs):.6f}", "20", f"{max(self.ys):.6f}", "30", "0.0",
                "0", "ENDSEC",
                "0", "SECTION", "2", "ENTITIES"]
        for e in self.entities:
            rows += [str(v) for v in e]
        rows += ["0", "ENDSEC", "0", "EOF"]
        # group codes are right-aligned to 3 characters, as AutoCAD writes them
        out = []
        for i, v in enumerate(rows):
            out.append(f"{v:>3}" if i % 2 == 0 else v)
        return "\r\n".join(out) + "\r\n"


def rect(dxf, x, y, w, h):
    corners = [(x, y), (x + w, y), (x + w, y + h), (x, y + h)]
    for (x1, y1), (x2, y2) in zip(corners, corners[1:] + corners[:1]):
        dxf.line(x1, y1, x2, y2)


def rrect(dxf, x, y, w, h, r):
    if r <= 0:
        return rect(dxf, x, y, w, h)
    dxf.line(x + r, y, x + w - r, y)                 # bottom
    dxf.line(x + w, y + r, x + w, y + h - r)         # right
    dxf.line(x + w - r, y + h, x + r, y + h)         # top
    dxf.line(x, y + h - r, x, y + r)                 # left
    dxf.arc(x + w - r, y + r, r, 270, 360)
    dxf.arc(x + w - r, y + h - r, r, 0, 90)
    dxf.arc(x + r, y + h - r, r, 90, 180)
    dxf.arc(x + r, y + r, r, 180, 270)


def slot(dxf, cx, cy, s, r):
    dxf.line(cx - s, cy - r, cx + s, cy - r)
    dxf.line(cx + s, cy + r, cx - s, cy + r)
    dxf.arc(cx + s, cy, r, 270, 90)
    dxf.arc(cx - s, cy, r, 90, 270)


def vslot(dxf, cx, cy, s, r):
    dxf.line(cx + r, cy - s, cx + r, cy + s)
    dxf.line(cx - r, cy + s, cx - r, cy - s)
    dxf.arc(cx, cy + s, r, 0, 180)
    dxf.arc(cx, cy - s, r, 180, 360)


def main():
    ap = argparse.ArgumentParser(description=__doc__.splitlines()[0])
    ap.add_argument("scad", nargs="?", default=str(DEFAULT_SCAD),
                    help="flat part to export (default: cad/cabinetFlat/sidePanel.scad)")
    ap.add_argument("-o", "--out", help="output DXF (default: the SCAD's name with .dxf)")
    ap.add_argument("--openscad", default=os.environ.get("OPENSCAD", "openscad"))
    args = ap.parse_args()
    out = args.out or Path(args.scad).with_suffix(".dxf").name

    dxf = R12()
    features = panel_features(args.openscad, args.scad)
    for f in features:
        kind, *v = f
        if kind == "rrect":
            rrect(dxf, *v)
        elif kind == "rect":
            rect(dxf, *v)
        elif kind == "slot":
            slot(dxf, *v)
        elif kind == "vslot":
            vslot(dxf, *v)
        elif kind == "circle":
            dxf.circle(v[0], v[1], v[2] / 2)
        else:
            sys.exit(f"unknown panel feature {kind!r} in {args.scad} -- teach this script about it")

    Path(out).write_bytes(dxf.text().encode("ascii"))
    w = max(dxf.xs) - min(dxf.xs)
    h = max(dxf.ys) - min(dxf.ys)
    print(f"wrote {out}: {len(features)} features, {len(dxf.entities)} entities, "
          f"{w:.2f} x {h:.2f} mm ({w / 25.4:.3f} x {h / 25.4:.3f} in)")


if __name__ == "__main__":
    main()
