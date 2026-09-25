#!/usr/bin/env python3
"""
rebrand_remove_text.py — Xoá chữ khắc branding khỏi Base Cover (v2RAD).

CHỮ CẦN XOÁ (khắc chìm trên mặt đáy Base Cover, Z = -75.93 mm)
--------------------------------------------------------------
    KELTON SERRA
    DESIGNED BY
    v2 R.A.D.

Branding tác giả gốc (Kelton Serra / Build Some Stuff). Không phải text entity
STEP mà là hình học khắc chìm -> phải xử lý bằng hình học.

CẤU TRÚC HÌNH HỌC (khảo sát Base Cover: 722 mặt, 1 shell, 7.5 % đặc)
-------------------------------------------------------------------
Base Cover là một **nắp rỗng** (thể tích solid 25.07 cm³ / hộp bao 335 cm³).
Chữ khắc 2 mm vào mặt đáy ngoài:

    Z = -75.93   276 mặt   (mặt đáy ngoài 8330 mm², 38 wire = 1 bao ngoài
                            + 37 đường bao glyph, và 275 mặt nhỏ của rãnh)
    Z = -74.93    29 mặt   (thành rãnh khắc)
    Z = -73.93    28 mặt   (đáy rãnh = mặt trong của nắp, sâu 2 mm)
    Z >= -73.68            tính năng thật (gân, lỗ, vát) -> PHẢI GIỮ

CÁCH XOÁ (đã kiểm chứng)
------------------------
Dùng **boolean FUSE với một pad phẳng**: dựng một hộp chữ nhật phủ đúng vùng
chữ, từ dưới mặt đáy (Z = -76.2) lên tới đáy rãnh (Z = -73.93), rồi hợp nhất
vào solid. Pad lấp mọi rãnh chữ và tạo mặt đáy phẳng.

Vì sao không dùng cách khác:
  - Cắt (boolean cut) một hộp bao vùng chữ  -> tạo HỐ, mất ~7 cm³. SAI.
  - Xoá mặt rồi ghép lại (sewing)           -> shell không kín, solid invalid.
  - Ép từng mặt rãnh rồi fuse               -> mặt rãnh bị phân mảnh, fuse lỗi.

Kết quả kiểm chứng: solid hợp lệ, 1 solid, +1542 mm³ (đắp chỗ chữ); mặt đáy
Z=-75.93 từ 276 mặt / 38 wire -> 1 mặt / 10 wire, không còn đường bao glyph.

KHUYẾN NGHỊ THÊM
----------------
Nếu muốn rebrand (khắc tên nhóm) thay vì chỉ xoá: sau khi chạy script này, mở
`cad/exports/rebranded/Base-Cover-rebranded.step` trong Onshape/Fusion và khắc
chữ mới lên mặt đáy.

DÙNG
----
    python cad/tools/rebrand_remove_text.py --dry-run
    python cad/tools/rebrand_remove_text.py
"""

from __future__ import annotations

import argparse
import json
import sys
from pathlib import Path

sys.stdout.reconfigure(encoding="utf-8")

from OCP.BRep import BRep_Tool
from OCP.BRepAdaptor import BRepAdaptor_Surface
from OCP.BRepAlgoAPI import BRepAlgoAPI_Fuse
from OCP.BRepCheck import BRepCheck_Analyzer
from OCP.BRepGProp import BRepGProp
from OCP.BRepPrimAPI import BRepPrimAPI_MakeBox
from OCP.GeomAbs import GeomAbs_SurfaceType
from OCP.GProp import GProp_GProps
from OCP.IFSelect import IFSelect_RetDone
from OCP.STEPControl import STEPControl_AsIs, STEPControl_Reader, STEPControl_Writer
from OCP.TopAbs import TopAbs_FACE, TopAbs_SOLID, TopAbs_VERTEX, TopAbs_WIRE
from OCP.TopExp import TopExp_Explorer
from OCP.TopoDS import TopoDS
from OCP.gp import gp_Pnt

REPO = Path(__file__).resolve().parents[2]
SRC = REPO / "hardware" / "reference" / "v2rad-all-parts.step"
OUT_DIR = REPO / "cad" / "exports" / "rebranded"

TARGET_SOLID = 23
BASE_Z = -75.93

# Vùng XY bao chữ (đo từ đường bao glyph, nới 2 mm)
PAD_X0, PAD_X1 = -27.5, 27.5
PAD_Y0, PAD_Y1 = -19.5, 48.5
# Pad ăn từ dưới mặt đáy lên tới đáy rãnh (sâu 2 mm)
PAD_Z0 = -76.20
PAD_Z1 = -73.93

BRANDING_LINES = ["KELTON SERRA", "DESIGNED BY", "v2 R.A.D."]


def load_solids(path: Path):
    r = STEPControl_Reader()
    if r.ReadFile(str(path)) != IFSelect_RetDone:
        raise RuntimeError(f"Không đọc được STEP: {path}")
    r.TransferRoots()
    out = []
    ex = TopExp_Explorer(r.OneShape(), TopAbs_SOLID)
    while ex.More():
        out.append(TopoDS.Solid_s(ex.Current()))
        ex.Next()
    return out


def volume(s) -> float:
    p = GProp_GProps()
    BRepGProp.VolumeProperties_s(s, p)
    return p.Mass()


def bottom_face_stats(solid, z: float = BASE_Z):
    """
    Trả về (diện tích mặt đáy lớn nhất, số wire của nó, số mặt ở cao độ đó).

    Số wire > 1 là dấu hiệu chữ khắc: mặt đáy có 1 wire bao ngoài + N wire là
    đường bao của các glyph.
    """
    best, nw, cnt = 0.0, 0, 0
    fx = TopExp_Explorer(solid, TopAbs_FACE)
    while fx.More():
        f = TopoDS.Face_s(fx.Current())
        ad = BRepAdaptor_Surface(f)
        if ad.GetType() == GeomAbs_SurfaceType.GeomAbs_Plane:
            if abs(ad.Plane().Axis().Location().Z() - z) < 0.05:
                cnt += 1
                p = GProp_GProps()
                BRepGProp.SurfaceProperties_s(f, p)
                if p.Mass() > best:
                    best = p.Mass()
                    nw = 0
                    we = TopExp_Explorer(f, TopAbs_WIRE)
                    while we.More():
                        nw += 1
                        we.Next()
        fx.Next()
    return best, nw, cnt


def count_glyph_like_wires(solid, z: float = BASE_Z) -> int:
    """
    Đếm số wire trên mặt đáy có kích thước GIỐNG GLYPH chữ.

    Glyph chữ cao 7-12 mm, rộng 0.4-4.5 mm. Wire bao ngoài (~88x111 mm), wire
    của pad (55x68 mm) và các wire suy biến 0x0 (điểm vít ở góc) không tính.

    Trả về 0 nghĩa là chữ đã được xoá sạch.
    """
    n = 0
    fx = TopExp_Explorer(solid, TopAbs_FACE)
    while fx.More():
        f = TopoDS.Face_s(fx.Current())
        ad = BRepAdaptor_Surface(f)
        if ad.GetType() == GeomAbs_SurfaceType.GeomAbs_Plane:
            if abs(ad.Plane().Axis().Location().Z() - z) < 0.05:
                we = TopExp_Explorer(f, TopAbs_WIRE)
                while we.More():
                    w = TopoDS.Wire_s(we.Current())
                    xs, ys = [], []
                    ve = TopExp_Explorer(w, TopAbs_VERTEX)
                    while ve.More():
                        p = BRep_Tool.Pnt_s(TopoDS.Vertex_s(ve.Current()))
                        xs.append(p.X())
                        ys.append(p.Y())
                        ve.Next()
                    if xs:
                        dx = max(xs) - min(xs)
                        dy = max(ys) - min(ys)
                        # glyph: cả hai chiều trong khoảng 0.3 .. 15 mm
                        if 0.3 <= dx <= 15.0 and 0.3 <= dy <= 15.0:
                            n += 1
                    we.Next()
        fx.Next()
    return n


def main() -> int:
    ap = argparse.ArgumentParser()
    ap.add_argument("--dry-run", action="store_true")
    args = ap.parse_args()

    if not SRC.exists():
        print(f"! Không thấy {SRC}", file=sys.stderr)
        return 1

    base = load_solids(SRC)[TARGET_SOLID]
    v0 = volume(base)
    a0, w0, c0 = bottom_face_stats(base)
    print(f"Base Cover: {v0 / 1000:.4f} cm³")
    print(f"Chữ khắc: {' | '.join(BRANDING_LINES)}")
    print(f"Mặt đáy Z={BASE_Z}: {c0} mặt, mặt lớn nhất {a0:.0f} mm² / {w0} wire")
    print(f"  ({w0 - 1} wire là đường bao glyph -> dấu hiệu chữ khắc)")

    if w0 <= 1:
        print("\nMặt đáy chỉ có 1 wire — chữ có thể đã được xoá rồi.")
        return 0

    print(
        f"\nPad đắp: X[{PAD_X0},{PAD_X1}] Y[{PAD_Y0},{PAD_Y1}] Z[{PAD_Z0},{PAD_Z1}]"
    )

    if args.dry_run:
        print("\n--dry-run: không ghi file.")
        return 0

    pad = BRepPrimAPI_MakeBox(
        gp_Pnt(PAD_X0, PAD_Y0, PAD_Z0),
        gp_Pnt(PAD_X1, PAD_Y1, PAD_Z1),
    ).Shape()

    fuse = BRepAlgoAPI_Fuse(base, pad)
    fuse.Build()
    if not fuse.IsDone():
        print("! Boolean fuse thất bại", file=sys.stderr)
        return 1

    result = None
    n_sol = 0
    best_v = -1.0
    ex = TopExp_Explorer(fuse.Shape(), TopAbs_SOLID)
    while ex.More():
        s = TopoDS.Solid_s(ex.Current())
        n_sol += 1
        v = volume(s)
        if v > best_v:
            best_v, result = v, s
        ex.Next()

    if result is None:
        print("! Không trích được solid", file=sys.stderr)
        return 1

    v1 = volume(result)
    ok = BRepCheck_Analyzer(result).IsValid()
    a1, w1, c1 = bottom_face_stats(result)
    print(f"\nSolid kết quả: {n_sol} solid, hợp lệ = {ok}")
    print(f"Thể tích: {v0 / 1000:.4f} -> {v1 / 1000:.4f} cm³  (+{(v1 - v0):.1f} mm³)")
    print(f"Mặt đáy sau: {c1} mặt, mặt lớn nhất {a1:.0f} mm² / {w1} wire")

    if not ok:
        print("\n! Solid không hợp lệ.", file=sys.stderr)
        return 1

    # Kiểm chứng chữ đã xoá hết:
    # Trên mặt đáy sau khi đắp, các wire còn lại phải là:
    #   - wire bao ngoài (kích thước lớn, ~88 x 111 mm)
    #   - wire của pad vừa đắp (đúng bằng hộp pad)
    #   - các wire suy biến 0x0 tại 8 điểm vít ở 4 góc
    # KHÔNG được còn wire nào có kích thước cỡ glyph (1-12 mm) trong vùng chữ.
    leftovers = count_glyph_like_wires(result)
    print(f"Wire cỡ glyph còn lại trong vùng chữ: {leftovers}")
    if leftovers > 0:
        print(f"\n! Còn {leftovers} wire cỡ glyph — chữ CHƯA xoá hết.", file=sys.stderr)
        return 1

    print("\n=> Đã xoá sạch chữ khắc (không còn đường bao glyph trên mặt đáy).")

    OUT_DIR.mkdir(parents=True, exist_ok=True)
    out_step = OUT_DIR / "Base-Cover-rebranded.step"
    wr = STEPControl_Writer()
    wr.Transfer(result, STEPControl_AsIs)
    wr.Write(str(out_step))

    from OCP.BRepMesh import BRepMesh_IncrementalMesh
    from OCP.StlAPI import StlAPI_Writer

    BRepMesh_IncrementalMesh(result, 0.05, False, 0.5, True)
    out_stl = OUT_DIR / "Base-Cover-rebranded.stl"
    sw = StlAPI_Writer()
    sw.ASCIIMode = False
    sw.Write(result, str(out_stl))

    (OUT_DIR / "rebrand-report.json").write_text(
        json.dumps(
            {
                "source": str(SRC.relative_to(REPO)).replace("\\", "/"),
                "target_part": "Base Cover",
                "method": "boolean fuse voi pad phang lap ranh chu",
                "removed_text": BRANDING_LINES,
                "base_plane_z_mm": BASE_Z,
                "pad_box_mm": {
                    "x": [PAD_X0, PAD_X1],
                    "y": [PAD_Y0, PAD_Y1],
                    "z": [PAD_Z0, PAD_Z1],
                },
                "bottom_wires_before": w0,
                "bottom_wires_after": w1,
                "bottom_faces_before": c0,
                "bottom_faces_after": c1,
                "volume_before_cm3": round(v0 / 1000, 4),
                "volume_after_cm3": round(v1 / 1000, 4),
                "material_added_mm3": round(v1 - v0, 3),
                "brep_valid": bool(ok),
                "outputs": {"step": out_step.name, "stl": out_stl.name},
            },
            indent=2,
            ensure_ascii=False,
        ),
        encoding="utf-8",
    )
    print(f"\nĐã ghi: {out_step.relative_to(REPO)}")
    print(f"Đã ghi: {out_stl.relative_to(REPO)}")
    print("Đã ghi: rebrand-report.json")
    return 0


if __name__ == "__main__":
    raise SystemExit(main())
