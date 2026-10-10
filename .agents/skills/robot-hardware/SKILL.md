---
name: robot-hardware
description: Use when working with the hardware/ tree — COTS component 3D models (MG996R, MG90S, 698ZZ bearing, Arduino Uno, M3 inserts, servo horns), KUKA/ABB reference robot libraries, the v2RAD reference parts, or the FDM 3D-print guide. Covers sourcing, print settings, and reference geometry.
---

# Robot Hardware (COTS models, references & print guide)

Scope: every maintained file under `hardware/`. This tree holds third-party and
reference assets the design depends on — COTS component models, robot-arm reference
libraries used for proportions, the older v2RAD reference parts, and the FDM print
guide. Most files here are binary CAD/mesh assets, not edited source.

## Folder → owner map

| Path | Contents |
|---|---|
| `hardware/reference/cots_parts/` | COTS component 3D models (servos, bearing, board, inserts, horns) |
| `hardware/reference/kuka_kr3_r540/` | KUKA KR3 R540 datasheet, URDF and meshes (primary reference) |
| `hardware/reference/kuka_kr6_r700/` | KUKA KR6 R700 collision/visual meshes |
| `hardware/reference/abb_irb120_urdf/` | ABB IRB120 URDF + meshes |
| `hardware/reference/cults3d_kuka/` | KUKA-style STL reference parts (Cults3D) |
| `hardware/reference/v2rad_parts/` | Older v2 R.A.D. arm/controller reference parts + pre-sliced project |
| `hardware/reference/kuka scale 0.49/` | Scaled KUKA sub-assembly reference |
| `hardware/HUONG-DAN-IN-3D.md` | FDM print guide for the reference parts |

## Task → first file

| You want to… | Open first | Also |
|---|---|---|
| Check a COTS part's fit/envelope | `hardware/reference/cots_parts/servoMotorMG996R.SLDPRT` | `hardware/reference/cots_parts/698zz Bearing.SLDPRT` |
| Find the M3 heat-set insert hole size | `hardware/reference/cots_parts/m3-insert-m3x574-insert.step` | `AGENTS.md` §4 (⌀4.2 mm bore, 5.0–5.5 mm blind) |
| Compare against the KUKA reference | `hardware/reference/kuka_kr3_r540/KR3 datesheet.pdf` | `hardware/reference/kuka_kr3_r540/urdf/kr3r540.xacro` |
| Look up print plates / slicer settings | `hardware/HUONG-DAN-IN-3D.md` | `hardware/reference/v2rad_parts/v2rad-and-v2cd-printgcode.3mf` |
| Trace an old v2RAD part | `hardware/reference/v2rad_parts/v2rad-all-parts.step` | `cad/exports/v2rad/PARTS.md` |

Full file inventory: [references/files.json](references/files.json).
Related: `robot-cad` (designed parts), `project-docs` (design specs).
