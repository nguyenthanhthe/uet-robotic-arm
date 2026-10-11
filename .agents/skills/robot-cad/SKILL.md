---
name: robot-cad
description: Use when working on the SolidWorks 3D model of the UET 5-DOF robot arm — base pedestal, turret, upper-arm/forearm links, gripper, assemblies, STEP/STL exports, or the Python CAD tooling under cad/tools. Covers the cad/ tree.
---

# Robot CAD (SolidWorks model & tooling)

Scope: every maintained file under `cad/`. This is the mechanical design source of
truth for the arm (SolidWorks `.SLDPRT` / `.SLDASM`), plus reference viewport
screenshots and the Python scripts that split reference STEP files, render engraved
text, and verify kinematics.

## Folder → owner map

| Path | Contents |
|---|---|
| `cad/parts/` | Designed SolidWorks parts, working `.SLDASM` assemblies and imported KUKA KR3 R540 reference solids |
| `cad/reference/` | Viewport / Fusion screenshots used as visual references |
| `cad/tools/` | Python (OCP/OpenCASCADE) CAD tooling scripts and SolidWorks macros |
| `cad/exports/` | **Generated** STEP/STL for the print shop — see exclusions in AGENTS.md |
| `cad/featurescript/` | Empty placeholder (`.gitkeep` only) |

## Task → first file

| You want to… | Open first | Also |
|---|---|---|
| Edit the J1 base (servo seat, electronics bay) | `cad/parts/01_Base_Kuka.SLDPRT` | `cad/parts/01_Base_Tray.SLDPRT` |
| Work the one-piece turret (J1 horn seat, skirt, J2 servo mount) | `cad/parts/02_Turret_ForkKuka.SLDPRT` | `cad/parts/02_Turret_ForkKuka_SubAssembly.SLDASM` |
| Work the upper arm / J3 servo mount | `cad/parts/03_UpperArmKuka.SLDPRT` | `cad/parts/03_J2_BearingSpacer.SLDPRT` |
| Work the forearm elbow block (J3 horn / bearing interface) | `cad/parts/04_Forearm_ElbowKuka.SLDPRT` | `cad/parts/03_UpperArmKuka.SLDPRT` |
| Work the forearm fork body (joint to the elbow block, wrist pocket) | `cad/parts/04_Forearm_ForkKuka.SLDPRT` | `cad/parts/04_Forearm_ElbowKuka.SLDPRT` |
| Work the wrist body (J4 horn recess / pivot, J5 servo pocket) | `cad/parts/05_WristKuka.SLDPRT` | `cad/parts/04_Forearm_ForkKuka.SLDPRT` |
| Work the forearm side covers or the J4 pivot pin | `cad/parts/04_Forearm_CoverPivot.SLDPRT`, `cad/parts/04_Forearm_CoverServo.SLDPRT`, `cad/parts/04_J4_PivotPin.SLDPRT` | `cad/parts/04_Forearm_ForkKuka.SLDPRT`, `cad/parts/05_WristKuka.SLDPRT` |
| Work the gripper (base on the J5 horn, pinion, rack jaws, rack guide) | `cad/parts/06_Gripper_Base.SLDPRT`, `cad/parts/06_Gripper_Pinion.SLDPRT`, `cad/parts/06_Gripper_Jaw.SLDPRT`, `cad/parts/06_Gripper_Guide.SLDPRT` | `cad/parts/05_WristKuka.SLDPRT` |
| Open the full J1–J2 assembly | `cad/parts/00_Robot_J1J2_Assembly.SLDASM` | `cad/parts/02_Turret_ForkKuka_SubAssembly.SLDASM` |
| Test-print the servo fit | `cad/parts/02_Turret_ForkKuka_TestSlice.SLDPRT` | `cad/parts/02_Turret_Fork.SLDPRT` |
| Inspect the unused pedestal / cap / separate disc | `cad/parts/01_Base_Pedestal.SLDPRT` | `cad/parts/01_Base_TopCap.SLDPRT` |
| Inspect the KUKA column halves (styling reference) | `cad/parts/Body2.SLDPRT` | `cad/parts/Body3.SLDPRT` |
| Remove author engraving / rebrand | `cad/tools/rebrand_remove_text.py` | `cad/tools/render_engraving.py` |
| Split a reference "all parts" STEP | `cad/tools/split_step_parts.py` | `cad/exports/v2rad/manifest.json` |
| Check an assembly for interference | `cad/tools/check_interference_stl.py` | `cad/parts/00_Robot_J1J2_Assembly.SLDASM` |
| Make the gripper jaws movable within the rack travel | `cad/tools/gripper_motion_mates.swb` | `cad/parts/00_Robot_J1J2_Assembly.SLDASM` |
| Colour the printed parts in the assembly (KUKA orange / black / silver, glossy) | `cad/tools/robot_appearance.swb` | `cad/parts/00_Robot_J1J2_Assembly.SLDASM` |
| Numerically check 5-DOF FK/IK | `cad/tools/verify_kinematics_5dof.py` | see `robot-simulation` |
| Open the scaled KUKA reference assembly | `cad/parts/kuka scaled.SLDASM` | `cad/parts/KR3 R540.SLDPRT` |
| Look at the KUKA rotating-column shape reference | `cad/parts/02_Base_Turret.SLDPRT` | `cad/parts/KR3 R540.SLDPRT` |

Full file inventory: [references/files.json](references/files.json).
Related: `robot-hardware` (COTS models & references), `robot-simulation` (kinematics).
