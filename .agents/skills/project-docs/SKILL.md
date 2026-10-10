---
name: project-docs
description: Use when reading or writing the project's technical documentation — the Typst report, technical requirements, D-H kinematics notes, CAD/SolidWorks and MCU guides, AI-control plan, wiring images, reference videos, or the root README and goal. Covers docs/ plus the root README.md and goal.md.
---

# Project Documentation & Report (Typst, guides, media)

Scope: every maintained file under `docs/`, plus the root-level `README.md` and
`goal.md`. This tree holds the written engineering deliverables: the official Typst
report, technical requirement/kinematics specifications, how-to guides, planning
notes, and the reference images/videos used in the report.

## Folder → owner map

| Path | Contents |
|---|---|
| `docs/typst/` | Official report sources (compiles to PDF via `typst compile`) |
| `docs/yeu-cau-ky-thuat.md`, `docs/thong-so-dong-hoc.md` | Requirements and D-H kinematics specs |
| `docs/*.md` guides | CAD workflow, SolidWorks MCP, KUKA design, MCU, AI control |
| `docs/archive/` | Historical rebranding notes (not active routing) |
| `docs/images/`, `docs/media/` | Wiring/illustration images, reference video and extracted frames |
| `README.md`, `goal.md` (root) | Project overview and course deliverable requirements |

## Task → first file

| You want to… | Open first | Also |
|---|---|---|
| Change the technical requirements | `docs/yeu-cau-ky-thuat.md` | `goal.md` |
| Look up D-H parameters / joint axes | `docs/thong-so-dong-hoc.md` | `matlab/kuka_robot_model.m` |
| Edit the technical report | `docs/typst/thuyet-minh.typ` | `docs/typst/kinematics.typ` |
| Adjust report cover/style | `docs/typst/uet-report.typ` | `docs/typst/assets/uet-logo.pdf` |
| Follow the CAD design workflow | `docs/WORKFLOW-CAD.md` | `docs/huong-dan-solidworks-mcp.md` |
| Plan the MCU or AI-control change | `docs/chuyen-mcu-esp32-stm32.md` | `docs/ke-hoach-dieu-khien-ai-robot.md` |
| Update the project overview/progress | `README.md` | `goal.md` |

Compile: `typst compile docs/typst/thuyet-minh.typ docs/typst/out/thuyet-minh.pdf`.

Full file inventory: [references/files.json](references/files.json).
Related: `robot-cad`, `robot-hardware`, `robot-firmware`, `robot-simulation`.
