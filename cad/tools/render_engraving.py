"""
render_engraving.py — Trích và vẽ mặt khắc chữ "v2 R.A.D." trên Base Cover.

MỤC ĐÍCH
--------
Chữ "v2 R.A.D." trong ảnh chụp chi tiết KHÔNG phải là text entity của STEP
(file STEP không chứa DRAUGHTING/ANNOTATION nào). Nó được **khắc thành hình học
solid** — các glyph là những wire kín trên một mặt phẳng.

Cách nhận diện: mặt phẳng khắc chữ có rất nhiều wire (38) so với các mặt phẳng
thường (1-2 wire). Script này tìm mặt đó, trích mọi cạnh, và vẽ ra PNG để đọc.
Kết quả dùng để xác định CHÍNH XÁC vùng cần xoá khi rebrand.

DÙNG
----
    python cad/tools/render_engraving.py
"""

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
STEP = rf"{REPO}\hardware\reference\v2rad-all-parts.step"
OUT = rf"{REPO}\cad\exports\v2rad\engraving-Base-Cover.png"

# Chi tiết chứa chữ khắc (theo danh sách solid trong v2rad-all-parts.step)
TARGET_SOLID_INDEX = 23  # Base Cover


def get_curve_bounds(edge):
    """Lấy (curve, t0, t1) của một cạnh, hỗ trợ nhiều biến thể API của OCP."""
    from OCP.TopLoc import TopLoc_Location

    # OCP 7.9: Curve_s(E, First, Last) với First/Last là tham số ra (by-ref float)
    try:
        first = _ByRef(0.0)
        last = _ByRef(0.0)
        curve = BRep_Tool.Curve_s(edge, first, last)
        if curve is not None:
            return curve, first.value, last.value
    except Exception:
        pass

    # Biến thể có Location
    try:
        loc = TopLoc_Location()
        first = _ByRef(0.0)
        last = _ByRef(0.0)
        curve = BRep_Tool.Curve_s(edge, loc, first, last)
        if curve is not None:
            return curve, first.value, last.value
    except Exception:
        pass

    return None, 0.0, 0.0


class _ByRef:
    """Tham số ra by-reference cho binding OpenCASCADE."""

    def __init__(self, v=0.0):
        self.value = v


def edge_polyline(edge, n: int = 24):
    """Rời rạc hoá một cạnh thành danh sách điểm (x, y)."""
    curve, t0, t1 = get_curve_bounds(edge)
    if curve is not None and t1 > t0:
        pts = []
        for k in range(n + 1):
            t = t0 + (t1 - t0) * k / n
            p = curve.Value(t)
            pts.append((p.X(), p.Y()))
        return pts
    # Fallback: chỉ có 2 đỉnh
    out = []
    ve = TopExp_Explorer(edge, TopAbs_VERTEX)
    while ve.More():
        p = BRep_Tool.Pnt_s(TopoDS.Vertex_s(ve.Current()))
        out.append((p.X(), p.Y()))
        ve.Next()
    return out


def main() -> int:
    reader = STEPControl_Reader()
    reader.ReadFile(STEP)
    reader.TransferRoots()

    target = None
    ex = TopExp_Explorer(reader.OneShape(), TopAbs_SOLID)
    i = 0
    while ex.More():
        if i == TARGET_SOLID_INDEX:
            target = TopoDS.Solid_s(ex.Current())
            break
        i += 1
        ex.Next()
    if target is None:
        print("Khong tim thay solid", file=sys.stderr)
        return 1

    # Tìm mặt phẳng có nhiều wire nhất = mặt khắc chữ
    best = None
    best_n = 0
    best_z = None
    fx = TopExp_Explorer(target, TopAbs_FACE)
    while fx.More():
        f = TopoDS.Face_s(fx.Current())
        ad = BRepAdaptor_Surface(f)
        if ad.GetType() == GeomAbs_SurfaceType.GeomAbs_Plane:
            nw = 0
            we = TopExp_Explorer(f, TopAbs_WIRE)
            while we.More():
                nw += 1
                we.Next()
            if nw > best_n:
                pl = ad.Plane()
                loc = pl.Axis().Location()
                best_n, best, best_z = nw, f, loc.Z()
        fx.Next()

    print(f"Mat khac chu: {best_n} wire,  Z = {best_z:.2f} mm")

    segs = []
    we = TopExp_Explorer(best, TopAbs_WIRE)
    while we.More():
        w = TopoDS.Wire_s(we.Current())
        ee = TopExp_Explorer(w, TopAbs_EDGE)
        while ee.More():
            pts = edge_polyline(TopoDS.Edge_s(ee.Current()))
            if len(pts) >= 2:
                segs.append(pts)
            ee.Next()
        we.Next()

    print(f"Tong so doan: {len(segs)}")

    # ---- Vẽ ----
    import matplotlib
    matplotlib.use("Agg")
    import matplotlib.pyplot as plt

    fig, ax = plt.subplots(figsize=(13, 15))
    for pts in segs:
        a = np.array(pts)
        ax.plot(a[:, 0], a[:, 1], "k-", linewidth=0.8)

    ax.set_aspect("equal")
    ax.set_xlabel("X (mm)")
    ax.set_ylabel("Y (mm)")
    ax.set_title(
        f"Base Cover — mat khac chu o Z={best_z:.1f} mm\n"
        "(nhin tu duoi len; lat truc X de doc dung chieu)"
    )
    ax.grid(True, alpha=0.25)
    fig.savefig(OUT, dpi=130, bbox_inches="tight")
    print("Da luu:", OUT)

    # ---- Nhóm glyph thành dòng ----
    glyphs = []
    for pts in segs:
        a = np.array(pts)
        dx = a[:, 0].max() - a[:, 0].min()
        dy = a[:, 1].max() - a[:, 1].min()
        if dx > 0.4 and dy > 0.4:
            glyphs.append((a[:, 1].min(), a[:, 1].max(), a[:, 0].min(), a[:, 0].max()))

    glyphs.sort(key=lambda g: (-g[1], g[2]))
    lines: dict[float, list] = {}
    for ymin, ymax, x0, x1 in glyphs:
        key = round(ymin / 5) * 5
        lines.setdefault(key, []).append((x0, x1, ymax - ymin))

    print("\nCAC DONG CHU (theo Y giam dan):")
    for key in sorted(lines, reverse=True):
        gl = sorted(lines[key])
        if len(gl) < 2:
            continue
        print(
            f"  Y~{key:6.1f}  {len(gl):2} glyph  cao~{gl[0][2]:.1f}mm  "
            f"X {gl[0][0]:.1f}..{gl[-1][1]:.1f}  rong={[round(g[1]-g[0],1) for g in gl]}"
        )
    return 0


if __name__ == "__main__":
    raise SystemExit(main())
