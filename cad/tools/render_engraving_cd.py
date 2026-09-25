"""render_engraving_cd.py — Vẽ mặt khắc chữ trên bộ điều khiển (v2CD)."""

from __future__ import annotations

import sys

import numpy as np

sys.stdout.reconfigure(encoding="utf-8")

from OCP.BRep import BRep_Tool
from OCP.BRepAdaptor import BRepAdaptor_Surface
from OCP.GeomAbs import GeomAbs_SurfaceType
from OCP.STEPControl import STEPControl_Reader
from OCP.TopAbs import TopAbs_EDGE, TopAbs_FACE, TopAbs_SOLID, TopAbs_VERTEX, TopAbs_WIRE
from OCP.TopExp import TopExp_Explorer
from OCP.TopoDS import TopoDS

REPO = r"D:\Project\uet robotic arm"
STEP = rf"{REPO}\hardware\reference\v2cd-all-parts.step"
OUT = rf"{REPO}\cad\exports\v2cd\engraving-check.png"


class ByRef:
    def __init__(self, v=0.0):
        self.value = v


def curve_bounds(edge):
    try:
        a, b = ByRef(), ByRef()
        c = BRep_Tool.Curve_s(edge, a, b)
        if c is not None:
            return c, a.value, b.value
    except Exception:
        pass
    try:
        from OCP.TopLoc import TopLoc_Location

        a, b = ByRef(), ByRef()
        c = BRep_Tool.Curve_s(edge, TopLoc_Location(), a, b)
        if c is not None:
            return c, a.value, b.value
    except Exception:
        pass
    return None, 0.0, 0.0


def polyline(edge, n=24):
    c, t0, t1 = curve_bounds(edge)
    if c is not None and t1 > t0:
        out = []
        for k in range(n + 1):
            p = c.Value(t0 + (t1 - t0) * k / n)
            out.append((p.X(), p.Y()))
        return out
    out = []
    ve = TopExp_Explorer(edge, TopAbs_VERTEX)
    while ve.More():
        p = BRep_Tool.Pnt_s(TopoDS.Vertex_s(ve.Current()))
        out.append((p.X(), p.Y()))
        ve.Next()
    return out


def main() -> int:
    r = STEPControl_Reader()
    r.ReadFile(STEP)
    r.TransferRoots()

    solids = []
    ex = TopExp_Explorer(r.OneShape(), TopAbs_SOLID)
    while ex.More():
        solids.append(TopoDS.Solid_s(ex.Current()))
        ex.Next()

    all_segs = []
    for idx, s in enumerate(solids):
        fx = TopExp_Explorer(s, TopAbs_FACE)
        while fx.More():
            f = TopoDS.Face_s(fx.Current())
            ad = BRepAdaptor_Surface(f)
            nw = 0
            we = TopExp_Explorer(f, TopAbs_WIRE)
            while we.More():
                nw += 1
                we.Next()
            if ad.GetType() == GeomAbs_SurfaceType.GeomAbs_Plane and nw > 6:
                z = ad.Plane().Axis().Location().Z()
                segs = []
                we2 = TopExp_Explorer(f, TopAbs_WIRE)
                while we2.More():
                    ee = TopExp_Explorer(TopoDS.Wire_s(we2.Current()), TopAbs_EDGE)
                    while ee.More():
                        p = polyline(TopoDS.Edge_s(ee.Current()))
                        if len(p) >= 2:
                            segs.append(p)
                        ee.Next()
                    we2.Next()
                print(f"  solid[{idx}] wires={nw} Z={z:.2f}  segments={len(segs)}")
                all_segs.append((idx, nw, segs))

    import matplotlib

    matplotlib.use("Agg")
    import matplotlib.pyplot as plt

    n = len(all_segs)
    if n == 0:
        print("Khong tim thay mat khac chu nao.")
        return 0

    fig, axes = plt.subplots(1, n, figsize=(9 * n, 9))
    if n == 1:
        axes = [axes]
    for ax, (idx, nw, segs) in zip(axes, all_segs):
        for p in segs:
            a = np.array(p)
            ax.plot(a[:, 0], a[:, 1], "k-", linewidth=0.8)
        ax.set_aspect("equal")
        ax.set_title(f"v2CD solid[{idx}] — {nw} wires (nhin tu duoi, X lat)")
        ax.grid(True, alpha=0.25)
    fig.savefig(OUT, dpi=120, bbox_inches="tight")
    print("Da luu:", OUT)
    return 0


if __name__ == "__main__":
    raise SystemExit(main())
