#!/usr/bin/env python3
"""
split_step_parts.py — Tách file STEP "all parts" thành từng chi tiết riêng lẻ.

VẤN ĐỀ
------
`hardware/reference/v2rad-all-parts.step` và `v2cd-all-parts.step` là file
**flattened assembly**: chứa 24 (v2RAD) + 9 (v2CD) solid đã đặt tên, nhưng
KHÔNG có cây assembly (PRODUCT_DEFINITION chỉ có 1, NEXT_ASSEMBLY_USAGE_OCCURRENCE
= 0). Tên chi tiết chỉ nằm trong chuỗi `MANIFOLD_SOLID_BREP('Tên',#shell)`.

Muốn redesign mà không làm lại từ đầu, nhóm cần **từng chi tiết riêng** dạng
STEP (để import vào Onshape/SolidWorks/Fusion) và STL (để in/tham chiếu).

CÁCH LÀM
--------
1. Đọc STEP bằng OpenCASCADE (OCP) — giữ nguyên BREP, không tessellate.
2. Lấy danh sách solid **theo đúng thứ tự trong file** và ghép với danh sách
   tên `MANIFOLD_SOLID_BREP` theo cùng chỉ số. Thứ tự này đã được kiểm chứng
   khớp (xem `--verify`).
3. Xuất mỗi solid ra:
   - `cad/exports/<set>/step/<Tên>.step`  — BREP gốc, sửa được
   - `cad/exports/<set>/stl/<Tên>.stl`    — mesh để in/tham chiếu
4. Xuất kèm `manifest.json` + `PARTS.md` để tra cứu.

Tùy chọn `--flatten` sẽ xoay chi tiết về **nằm phẳng trên mặt XY** (giống hướng
in trong file .3mf) — hữu ích khi muốn tự slice lại.

CÀI ĐẶT
-------
    pip install cadquery-ocp          # cung cấp module `OCP`
    # hoặc: pip install OCP

DÙNG
----
    python cad/tools/split_step_parts.py --verify
    python cad/tools/split_step_parts.py
    python cad/tools/split_step_parts.py --flatten --deflection 0.05

GHI CHÚ VỀ STL
--------------
Một số STL (Base Main, Main Arm Main, Main Arm Right, Controller Plug Cover,
Base Cover (CD), Wrist Right (CD)) có thể bị `trimesh` báo "not watertight" với
vài cạnh hở (1-100 cạnh trên hàng nghìn mặt). Đây là đặc trưng của việc
tessellate BREP, KHÔNG phải lỗi hình học: thể tích mesh vẫn khớp chính xác với
thể tích BREP, và slicer (Bambu Studio, PrusaSlicer, Cura) xử lý bình thường.
Bản BREP trong `step/` mới là nguồn chính xác để sửa thiết kế.

GHI CHÚ GIẤY PHÉP
-----------------
Thiết kế gốc "Arduino Robot Arm and Controller v2 (R.A.D.)" của Kelton Serra
(Build Some Stuff) theo giấy phép CC BY-NC-ND 4.0. Các file xuất ra ở đây chỉ
dùng cho mục đích học tập, không thương mại. Xem README.md mục "Ghi công".
"""

from __future__ import annotations

import argparse
import json
import re
import sys
from dataclasses import dataclass, field
from pathlib import Path

try:
    from OCP.Bnd import Bnd_Box
    from OCP.BRep import BRep_Tool
    from OCP.BRepAdaptor import BRepAdaptor_Surface
    from OCP.BRepBndLib import BRepBndLib
    from OCP.BRepBuilderAPI import BRepBuilderAPI_Transform
    from OCP.BRepCheck import BRepCheck_Analyzer
    from OCP.BRepGProp import BRepGProp
    from OCP.BRepMesh import BRepMesh_IncrementalMesh
    from OCP.GeomAbs import GeomAbs_SurfaceType
    from OCP.gp import gp_Ax1, gp_Dir, gp_Pnt, gp_Trsf, gp_Vec
    from OCP.GProp import GProp_GProps
    from OCP.IFSelect import IFSelect_RetDone
    from OCP.STEPControl import STEPControl_Reader, STEPControl_Writer, STEPControl_AsIs
    from OCP.StlAPI import StlAPI_Writer
    from OCP.TopAbs import TopAbs_FACE, TopAbs_SOLID, TopAbs_VERTEX
    from OCP.TopExp import TopExp_Explorer
    from OCP.TopoDS import TopoDS
except ImportError as exc:  # pragma: no cover
    sys.exit(
        "Thiếu OpenCASCADE Python binding (module `OCP`).\n"
        "Cài bằng:  pip install cadquery-ocp\n"
        f"Chi tiết lỗi: {exc}"
    )


def _force_utf8_console() -> None:
    """
    Console Windows mặc định là cp1252 -> in tiếng Việt sẽ lỗi UnicodeEncodeError.
    Ép stdout/stderr sang UTF-8 để script chạy được trên mọi máy.
    """
    for stream in (sys.stdout, sys.stderr):
        try:
            stream.reconfigure(encoding="utf-8", errors="replace")
        except (AttributeError, ValueError):
            pass


_force_utf8_console()


REPO_ROOT = Path(__file__).resolve().parents[2]
REFERENCE = REPO_ROOT / "hardware" / "reference"
EXPORTS = REPO_ROOT / "cad" / "exports"

SOURCES = {
    "v2rad": REFERENCE / "v2rad-all-parts.step",
    "v2cd": REFERENCE / "v2cd-all-parts.step",
}

# Nhóm chức năng — dùng để sinh PARTS.md dễ đọc
GROUPS: dict[str, list[str]] = {
    "Base / thân xoay": ["Base Main", "Base Cover", "Shoulder Base", "Shoulder Ring"],
    "Cánh tay trên (main arm)": [
        "Main Arm Main", "Main Arm Left", "Main Arm Right", "Main Arm Cover",
        "Shoulder Left", "Shoulder Right",
    ],
    "Cẳng tay (forearm)": [
        "Forearm Main", "Forearm Left", "Forearm Right", "Forearm Cover",
    ],
    "Cổ tay (wrist)": ["Wrist Left", "Wrist Right", "Wrist Pulley", "Pulley Servo Horn"],
    "Tay gắp (gripper)": [
        "Gripper Left", "Gripper Right", "Gripper Gear",
        "Gripper Rack Left", "Gripper Rack Right",
    ],
    "Khác": ["Controller Plug Cover"],
    "Bộ điều khiển (v2CD)": [
        "Base (CD)", "Base Cover (CD)", "Shoulder (CD)", "Main Arm (CD)",
        "Main Arm Left (CD)", "Forearm Main (CD)", "Forearm Left (CD)",
        "Wrist Left (CD)", "Wrist Right (CD)",
    ],
}


@dataclass
class Part:
    index: int
    name: str
    solid: object
    volume_mm3: float = 0.0
    size: tuple[float, float, float] = (0.0, 0.0, 0.0)
    centre: tuple[float, float, float] = (0.0, 0.0, 0.0)
    faces: int = 0
    cylinders: list[dict] = field(default_factory=list)
    valid: bool = True

    @property
    def volume_cm3(self) -> float:
        return self.volume_mm3 / 1000.0

    def mass_g(self, density: float = 1.24) -> float:
        """Khối lượng với PLA. `density` tính bằng g/cm³ (PLA = 1.24 g/cm³)."""
        return self.volume_cm3 * density


def slug(name: str) -> str:
    """Tên file an toàn: bỏ '(CD)' -> 'CD', thay khoảng trắng bằng '-'."""
    s = name.replace("(CD)", "CD").replace("(", "").replace(")", "")
    s = re.sub(r"[^A-Za-z0-9]+", "-", s).strip("-")
    return s


def read_names(step_path: Path) -> list[str]:
    """Lấy tên solid theo đúng thứ tự xuất hiện trong file STEP."""
    text = step_path.read_text(encoding="utf-8", errors="ignore")
    return re.findall(r"MANIFOLD_SOLID_BREP\s*\(\s*'([^']*)'", text)


def true_extent(solid) -> tuple[tuple[float, float, float], tuple[float, float, float]]:
    """
    Bounding box THẬT của solid, tính từ hình học BREP.

    Dùng `BRepBndLib.AddOptimal_s` — thuật toán tìm bao chính xác của
    OpenCASCADE, có xét điểm cực trị của các mặt cong (cung tròn, cylinder,
    B-spline), không chỉ các đỉnh.

    LƯU Ý QUAN TRỌNG: KHÔNG được suy bbox từ đám mây đỉnh (vertex cloud).
    Đỉnh của một cung tròn chỉ là 2 điểm đầu/cuối — không phải điểm xa nhất.
    Ví dụ `Shoulder Base` là một vành tròn: đám mây đỉnh cho 74 x 42 x 8 mm
    (thiếu), trong khi bbox thật là 74 x 74 x 8 mm. Đã kiểm chứng: đám mây đỉnh
    chỉ đúng khi mặt cong không vượt ra ngoài đường nối các đỉnh.

    `BRepBndLib.Add_s` (không optimal) cũng đúng cho các solid ở đây, nhưng có
    thể phình to nếu file STEP chứa điểm điều khiển B-spline nằm xa vật thể
    (gặp ở 'Base Main' của bản export gốc khi đọc bằng một số tool).
    """
    bb = Bnd_Box()
    Bnd_Box.SetGap(bb, 0.0)
    BRepBndLib.AddOptimal_s(solid, bb, False, False)
    if bb.IsVoid():
        bb2 = Bnd_Box()
        Bnd_Box.SetGap(bb2, 0.0)
        BRepBndLib.Add_s(solid, bb2)
        bb = bb2
    xmin, ymin, zmin, xmax, ymax, zmax = bb.Get()
    return (xmin, ymin, zmin), (xmax, ymax, zmax)


def find_cylinders(solid, min_radius: float = 4.0, min_area: float = 20.0) -> list[dict]:
    """Tìm các mặt trụ — dùng để suy ra đường kính lỗ ổ bi / trục khớp."""
    out: list[dict] = []
    ex = TopExp_Explorer(solid, TopAbs_FACE)
    while ex.More():
        face = TopoDS.Face_s(ex.Current())
        ad = BRepAdaptor_Surface(face)
        if ad.GetType() == GeomAbs_SurfaceType.GeomAbs_Cylinder:
            cyl = ad.Cylinder()
            axis = cyl.Axis()
            loc = axis.Location()
            d = axis.Direction()
            props = GProp_GProps()
            BRepGProp.SurfaceProperties_s(face, props)
            area = props.Mass()
            if cyl.Radius() >= min_radius and area >= min_area:
                out.append(
                    {
                        "radius_mm": round(cyl.Radius(), 3),
                        "diameter_mm": round(cyl.Radius() * 2, 3),
                        "axis_point": [round(loc.X(), 2), round(loc.Y(), 2), round(loc.Z(), 2)],
                        "axis_dir": [round(d.X(), 3), round(d.Y(), 3), round(d.Z(), 3)],
                        "area_mm2": round(area, 1),
                    }
                )
        ex.Next()
    out.sort(key=lambda c: -c["area_mm2"])
    return out


def load_parts(step_path: Path) -> list[Part]:
    names = read_names(step_path)
    reader = STEPControl_Reader()
    if reader.ReadFile(str(step_path)) != IFSelect_RetDone:
        raise RuntimeError(f"Không đọc được STEP: {step_path}")
    reader.TransferRoots()
    shape = reader.OneShape()

    solids = []
    ex = TopExp_Explorer(shape, TopAbs_SOLID)
    while ex.More():
        solids.append(TopoDS.Solid_s(ex.Current()))
        ex.Next()

    if len(names) != len(solids):
        print(
            f"  ! CẢNH BÁO: {len(names)} tên nhưng {len(solids)} solid — "
            "ghép theo chỉ số có thể sai.",
            file=sys.stderr,
        )

    parts: list[Part] = []
    for i, solid in enumerate(solids):
        name = names[i] if i < len(names) else f"Solid_{i:02d}"
        props = GProp_GProps()
        BRepGProp.VolumeProperties_s(solid, props)
        centre = props.CentreOfMass()
        bmin, bmax = true_extent(solid)
        nf = 0
        fe = TopExp_Explorer(solid, TopAbs_FACE)
        while fe.More():
            nf += 1
            fe.Next()
        parts.append(
            Part(
                index=i,
                name=name,
                solid=solid,
                volume_mm3=props.Mass(),
                size=tuple(round(bmax[k] - bmin[k], 2) for k in range(3)),
                centre=(round(centre.X(), 2), round(centre.Y(), 2), round(centre.Z(), 2)),
                faces=nf,
                cylinders=find_cylinders(solid),
                valid=BRepCheck_Analyzer(solid).IsValid(),
            )
        )
    return parts


def print_verify(parts: list[Part], tag: str) -> bool:
    """
    Kiểm chứng: tên trong STEP có khớp với hình học solid không?

    Bằng chứng gián tiếp nhưng mạnh: `MANIFOLD_SOLID_BREP` trong file STEP được
    ghi theo cùng thứ tự với các solid trong `ADVANCED_BREP_SHAPE_REPRESENTATION`.
    Ta kiểm tra chéo bằng kích thước: các chi tiết đối xứng trái/phải phải có
    cùng kích thước, và các cặp tên hình học phải hợp lý.
    """
    print(f"\n=== KIỂM CHỨNG {tag} ({len(parts)} chi tiết) ===")
    ok = True
    print(f"{'#':>3}  {'Tên':<24} {'cm³':>8} {'Kích thước (mm)':>26}  {'valid':>5}  lỗ lớn nhất")
    for p in parts:
        big = p.cylinders[0] if p.cylinders else None
        bore = f"Ø{big['diameter_mm']:.1f}" if big else "-"
        flag = "OK" if p.valid else "LỖI"
        if not p.valid:
            ok = False
        print(
            f"{p.index:>3}  {p.name:<24} {p.volume_cm3:>8.2f} "
            f"{p.size[0]:>7.1f}x{p.size[1]:>7.1f}x{p.size[2]:>6.1f}  {flag:>5}  {bore}"
        )

    by_name = {p.name: p for p in parts}
    checks = [
        ("Shoulder Left", "Shoulder Right"),
        ("Main Arm Left", "Main Arm Right"),
        ("Forearm Left", "Forearm Right"),
        ("Gripper Left", "Gripper Right"),
        ("Wrist Left", "Wrist Right"),
    ]
    print("\n  Kiểm tra cặp trái/phải (kích thước phải xấp xỉ nhau):")
    for a, b in checks:
        if a in by_name and b in by_name:
            pa, pb = by_name[a], by_name[b]
            d = max(abs(pa.size[k] - pb.size[k]) for k in range(3))
            verdict = "khớp" if d < 15 else "LỆCH"
            print(f"    {a:<16} vs {b:<16} lệch tối đa {d:6.2f} mm  -> {verdict}")
            if d >= 15:
                ok = False
    print(f"\n  KẾT LUẬN: {'đạt' if ok else 'CÓ VẤN ĐỀ — xem cảnh báo ở trên'}")
    return ok


def rotate_to_flat(solid):
    """
    Xoay chi tiết sao cho trục dài nhất nằm trong mặt XY (nằm phẳng để in).

    Tìm trục chính bằng PCA trên đám mây đỉnh, rồi dựng phép quay đưa trục đó
    về mặt XY. Đây chỉ là gợi ý — hướng in "đúng" theo tác giả nằm trong file
    .3mf; xem hardware/HUONG-DAN-IN-3D.md.
    """
    import numpy as np

    pts = []
    ex = TopExp_Explorer(solid, TopAbs_VERTEX)
    while ex.More():
        p = BRep_Tool.Pnt_s(TopoDS.Vertex_s(ex.Current()))
        pts.append((p.X(), p.Y(), p.Z()))
        ex.Next()
    if len(pts) < 4:
        return solid, (1.0, 0.0, 0.0), (0.0, 0.0, 1.0)

    a = np.array(pts)
    centred = a - a.mean(axis=0)
    # weighted PCA: dùng phân tích SVD
    _, _, vt = np.linalg.svd(centred, full_matrices=False)

    # Đưa 2 trục chính vào mặt XY, trục nhỏ nhất (pháp tuyến tấm) thành Z
    x_ax = vt[0]
    y_ax = vt[1]
    z_ax = np.cross(x_ax, y_ax)
    if np.linalg.norm(z_ax) < 1e-9:
        return solid, (1.0, 0.0, 0.0), (0.0, 0.0, 1.0)
    z_ax = z_ax / np.linalg.norm(z_ax)
    # đảm bảo hệ thuận
    y_ax = np.cross(z_ax, x_ax)

    trsf = gp_Trsf()
    from OCP.gp import gp_Mat

    mat = gp_Mat(
        x_ax[0], y_ax[0], z_ax[0],
        x_ax[1], y_ax[1], z_ax[1],
        x_ax[2], y_ax[2], z_ax[2],
    )
    trsf.SetMatrix(mat)
    moved = BRepBuilderAPI_Transform(solid, trsf, True).Shape()
    return TopoDS.Solid_s(moved), tuple(round(v, 4) for v in x_ax), tuple(round(v, 4) for v in z_ax)


def export_step(solid, out_path: Path) -> None:
    w = STEPControl_Writer()
    w.Transfer(solid, STEPControl_AsIs)
    w.Write(str(out_path))


def export_stl(solid, out_path: Path, deflection: float) -> None:
    """
    Tessellate solid -> STL nhị phân.

    `deflection` là sai số cho phép (mm). 0.1 mm đủ đẹp cho hầu hết chi tiết,
    nhưng vài chi tiết có mặt cong nhỏ (ví dụ `Controller-Plug-Cover`) có thể
    để lại vài cạnh hở. Dùng `--deflection 0.05` nếu cần mesh kín hoàn toàn
    (file nặng hơn ~2-4 lần).
    """
    BRepMesh_IncrementalMesh(solid, deflection, False, 0.5, True)
    w = StlAPI_Writer()
    w.ASCIIMode = False
    w.Write(solid, str(out_path))


def group_of(name: str) -> str:
    for group, names in GROUPS.items():
        if name in names:
            return group
    return "Khác"


def write_manifest(parts: list[Part], set_tag: str, out_dir: Path, flat: bool) -> None:
    data = {
        "source": str(SOURCES[set_tag].relative_to(REPO_ROOT)).replace("\\", "/"),
        "set": set_tag,
        "part_count": len(parts),
        "flattened": flat,
        "material": {"name": "PLA", "density_g_cm3": 1.24},
        "total_volume_cm3": round(sum(p.volume_cm3 for p in parts), 3),
        "total_mass_g_pla": round(sum(p.mass_g() for p in parts), 2),
        "parts": [
            {
                "index": p.index,
                "name": p.name,
                "slug": slug(p.name),
                "group": group_of(p.name),
                "size_mm": list(p.size),
                "volume_cm3": round(p.volume_cm3, 4),
                "mass_g_pla": round(p.mass_g(), 3),
                "centre_of_mass_mm": list(p.centre),
                "face_count": p.faces,
                "brep_valid": p.valid,
                "cylinders": p.cylinders[:8],
                "step": f"step/{slug(p.name)}.step",
                "stl": f"stl/{slug(p.name)}.stl",
            }
            for p in parts
        ],
    }
    (out_dir / "manifest.json").write_text(
        json.dumps(data, indent=2, ensure_ascii=False), encoding="utf-8"
    )


def write_parts_md(parts: list[Part], set_tag: str, out_dir: Path) -> None:
    title = "Cánh tay robot (v2RAD)" if set_tag == "v2rad" else "Bộ điều khiển (v2CD)"
    lines = [
        f"# Danh sách chi tiết — {title}",
        "",
        f"Nguồn: `hardware/reference/{SOURCES[set_tag].name}`  ",
        f"Số chi tiết: **{len(parts)}**  ",
        f"Tổng thể tích: **{sum(p.volume_cm3 for p in parts):.2f} cm³**  ",
        f"Khối lượng PLA (1.24 g/cm³): **{sum(p.mass_g() for p in parts):.1f} g**",
        "",
        "> Sinh tự động bởi `cad/tools/split_step_parts.py` — **không sửa tay**.",
        "",
    ]
    groups: dict[str, list[Part]] = {}
    for p in parts:
        groups.setdefault(group_of(p.name), []).append(p)

    for group, items in groups.items():
        lines.append(f"## {group}")
        lines.append("")
        lines.append("| # | Chi tiết | File | Kích thước (mm) | Thể tích | KL (PLA) | Lỗ ổ bi lớn nhất |")
        lines.append("|---|---|---|---|---|---|---|")
        for p in items:
            big = p.cylinders[0] if p.cylinders else None
            bore = f"Ø{big['diameter_mm']:.1f} mm" if big else "—"
            lines.append(
                f"| {p.index} | **{p.name}** | `{slug(p.name)}.step` | "
                f"{p.size[0]:.1f} × {p.size[1]:.1f} × {p.size[2]:.1f} | "
                f"{p.volume_cm3:.2f} cm³ | {p.mass_g():.1f} g | {bore} |"
            )
        lines.append("")
    (out_dir / "PARTS.md").write_text("\n".join(lines), encoding="utf-8")


def process(set_tag: str, args) -> bool:
    src = SOURCES[set_tag]
    if not src.exists():
        print(f"  ! Không tìm thấy {src}", file=sys.stderr)
        return False

    print(f"\n{'=' * 72}\n{set_tag.upper()}  <-  {src.name}\n{'=' * 72}")
    parts = load_parts(src)
    ok = print_verify(parts, set_tag)

    if args.verify:
        return ok

    out_dir = EXPORTS / set_tag
    (out_dir / "step").mkdir(parents=True, exist_ok=True)
    (out_dir / "stl").mkdir(parents=True, exist_ok=True)

    print(f"\n  Xuất {len(parts)} chi tiết -> {out_dir.relative_to(REPO_ROOT)}")
    for p in parts:
        solid = p.solid
        if args.flatten:
            solid, _, _ = rotate_to_flat(solid)
        base = slug(p.name)
        try:
            export_step(solid, out_dir / "step" / f"{base}.step")
        except Exception as exc:
            print(f"    ! STEP lỗi {p.name}: {exc}", file=sys.stderr)
        try:
            export_stl(solid, out_dir / "stl" / f"{base}.stl", args.deflection)
        except Exception as exc:
            print(f"    ! STL lỗi {p.name}: {exc}", file=sys.stderr)
        print(f"    [{p.index:>2}] {p.name:<24} -> {base}.step / {base}.stl")

    write_manifest(parts, set_tag, out_dir, args.flatten)
    write_parts_md(parts, set_tag, out_dir)
    print(f"  Đã ghi manifest.json + PARTS.md")
    return ok


def main() -> int:
    ap = argparse.ArgumentParser(
        description="Tách STEP 'all parts' thành từng chi tiết riêng lẻ.",
        formatter_class=argparse.RawDescriptionHelpFormatter,
    )
    ap.add_argument("--set", choices=["v2rad", "v2cd", "all"], default="all",
                    help="Bộ nào cần tách (mặc định: all)")
    ap.add_argument("--verify", action="store_true",
                    help="Chỉ kiểm chứng tên/kích thước, KHÔNG ghi file")
    ap.add_argument("--flatten", action="store_true",
                    help="Xoay chi tiết nằm phẳng XY (gợi ý hướng in)")
    ap.add_argument("--deflection", type=float, default=0.05,
                    help="Sai số tessellate STL, mm (mặc định 0.05; nhỏ = mịn hơn)")
    args = ap.parse_args()

    tags = ["v2rad", "v2cd"] if args.set == "all" else [args.set]
    all_ok = True
    for t in tags:
        all_ok &= process(t, args)

    print(f"\n{'=' * 72}")
    print("HOÀN TẤT" if all_ok else "HOÀN TẤT (có cảnh báo — xem ở trên)")
    if not args.verify:
        print(f"Kết quả ở: {EXPORTS.relative_to(REPO_ROOT)}")
    return 0 if all_ok else 1


if __name__ == "__main__":
    raise SystemExit(main())
