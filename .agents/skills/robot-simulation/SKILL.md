---
name: robot-simulation
description: Use when working on the MATLAB kinematics simulation or control GUI — Denavit-Hartenberg model, forward/inverse kinematics, torque checks, the 3D digital-twin GUI, or serial link to the Arduino. Covers the matlab/ tree.
---

# Robot Simulation & Control GUI (MATLAB)

Scope: every maintained file under `matlab/`. This tree holds the host-side MATLAB
work: the rigid-body kinematics/torque model and the interactive 3D digital-twin GUI
that also opens a serial link to the MCU.

## Folder → owner map

| Path | Contents |
|---|---|
| `matlab/kuka_robot_model.m` | Kinematic model, FK/IK and torque calculations |
| `matlab/kuka_gui_control.m` | 3D digital-twin GUI with joint sliders and serial output |

## Task → first file

| You want to… | Open first | Also |
|---|---|---|
| Adjust link lengths / D-H parameters | `matlab/kuka_robot_model.m` | `docs/thong-so-dong-hoc.md` |
| Verify FK or IK results | `matlab/kuka_robot_model.m` | `cad/tools/verify_kinematics_5dof.py` |
| Change the GUI or serial control | `matlab/kuka_gui_control.m` | `firmware/README.md` |
| Recompute joint torques | `matlab/kuka_robot_model.m` | `docs/yeu-cau-ky-thuat.md` |

Full file inventory: [references/files.json](references/files.json).
Related: `robot-cad` (numeric FK/IK check), `robot-firmware` (MCU side of the link).
