# AGENTS.md — Hướng dẫn Đóng góp & Định tuyến Dự án (UET 5-DOF Robot Arm)

> **Dự án:** Thiết kế & Chế tạo Cánh tay Robot 5-DOF + Gripper song song UET.
> **Cơ sở tham chiếu:** KUKA KR 3 R540 (Scale 0.49).
> **Bộ điều khiển:** Arduino Uno R3 + PCA9685 16-Channel PWM I2C Shield.
> **Động cơ:** 2x TowerPro MG996R (J1, J3) + 1x servo số 25 kg·cm 180° cỡ MG996R (J2) + 3x MG90S (J4, J5, Gripper).
> **Vật liệu in 3D:** PETG.

This file is the single source of truth for project instructions and routing. It is
intentionally thin: it points to the owning routing skill for each work area. File
inventories live in each skill's `references/files.json`.

---

## 1. Skill Catalog (Routing Skills)

| Skill | Purpose | SKILL.md |
|---|---|---|
| `robot-cad` | SolidWorks parts/assemblies and Python CAD tooling (`cad/`) | [.agents/skills/robot-cad/SKILL.md](.agents/skills/robot-cad/SKILL.md) |
| `robot-hardware` | COTS models, KUKA/ABB reference libraries, print guide (`hardware/`) | [.agents/skills/robot-hardware/SKILL.md](.agents/skills/robot-hardware/SKILL.md) |
| `robot-firmware` | Arduino/MCU control code and electronics plan (`firmware/`) | [.agents/skills/robot-firmware/SKILL.md](.agents/skills/robot-firmware/SKILL.md) |
| `robot-simulation` | MATLAB kinematics model and control GUI (`matlab/`) | [.agents/skills/robot-simulation/SKILL.md](.agents/skills/robot-simulation/SKILL.md) |
| `project-docs` | Typst report, requirements, guides, media (`docs/`, root docs) | [.agents/skills/project-docs/SKILL.md](.agents/skills/project-docs/SKILL.md) |

## 2. Folder / Task → Skill Router

| Path or request | Owning skill |
|---|---|
| `cad/parts/`, `cad/tools/`, `cad/reference/`, editing a `.SLDPRT`/`.SLDASM` | `robot-cad` |
| `hardware/reference/`, COTS fit, print settings, KUKA/ABB reference data | `robot-hardware` |
| `firmware/`, `.ino` sketch, servo/PWM/serial, pin mapping | `robot-firmware` |
| `matlab/`, FK/IK, D-H model, torque, digital-twin GUI | `robot-simulation` |
| `docs/`, `docs/typst/`, `README.md`, `goal.md`, report or spec text | `project-docs` |

## 3. Read Before Work

Before editing anything: pick the owning skill from the router above, read its
`SKILL.md`, then open the exact files its task table and `references/files.json`
indicate. Read only those files first; broaden the search only when the routed files
are insufficient.

## 4. Project Engineering Rules (preserved)

**SolidWorks MCP safety.** The SolidWorks COM server (`SldWorks.Application`) allows a
single connection; the MCP server already holds it. Never run a standalone Python COM
script (`win32com.client.Dispatch`) while SolidWorks is open — it deadlocks the COM
lock. Perform all CAD actions through the SolidWorks MCP tools. After every feature or
mate, verify with `analyze_model` / `analyze_assembly` and never leave a red
(missing-reference) mate. Save with `save_document` after each logical group.

**Units.** Discuss and print in millimetres. Parameters passed to SolidWorks MCP tools
must be in **metres (SI)** — e.g. 9.5 mm → `0.0095`, ⌀4.2 mm → `radius 0.0021`.

**`/plan` and `/goal`.** For `/plan`: investigate read-only first, produce a concrete
plan (targets, geometry risks, coordinates), and get approval before destructive edits.
For `/goal`: work autonomously, self-verify continuously, and only emit
`<!-- GOAL_COMPLETE -->` when everything is done, saved, and pushed.

**DFM (PETG, zero-support).** PETG, ≥60 °C service. Chamfer all overhangs to 45° so
FDM prints without support. M3 heat-set insert holes: ⌀4.2 mm bore, 5.0–5.5 mm blind
depth with a bottom floor. All joint axes, bearing bores and servo shafts must be
concentric at (0,0). J1 load path: the one-piece turret
(`02_Turret_ForkKuka`) seats on the 25T metal horn of the J1 MG996R, which hangs under the
roof of the hollow KUKA base (`01_Base_Kuka`), for torque and axial load; its ⌀49 spigot
and ⌀92 foot ring run on the base top as a plain bearing that takes the tilting moment;
J1 has no ball bearing. J2 load path: upper arm → 25T horn →
MG996R in the fork's servo ear, with a 698ZZ support bearing in the opposite ear.

**Report build.** `typst compile docs/typst/thuyet-minh.typ docs/typst/out/thuyet-minh.pdf`
(Font: Liberation Serif). See `project-docs`.

## 5. Inventory Exclusions

These paths are **not** application inventory and must not appear in any
`references/files.json`:

- Routing infrastructure: `AGENTS.md`, `CLAUDE.md`, `.agents/skills/**`.
- Generated output: `cad/exports/**` (produced by `cad/tools/split_step_parts.py`),
  `docs/typst/out/**` (Typst build).
- Vendored external tool: `tools/solidworks-mcp/**` (third-party git clone).
- Caches/binaries: `__pycache__/`, `*.pyc`, `.venv/`, and SolidWorks lock files `~$*`.
- Ignore rules: `.gitignore`, `.zcodeignore`.

## 6. Maintenance

**CRITICAL — Update routing after every change.** Before completing any task that adds, edits, renames, moves or deletes project files, folders or any symbols referenced by routing, review and update the affected folder maps, file inventories, descriptions, task routes and links. Include relevant untracked files and remove deleted paths.

Update the owning skill/inventory for file-level knowledge. Update AGENTS.md when project-wide routing, ownership or available skills change. Keep CLAUDE.md as an adapter.

Do not assume every change belongs to an existing skill. Whenever a task adds a feature, file or folder, or refactors ownership boundaries, reassess whether the routing still has the right skill set. Create and catalog a new skill when the change establishes a durable independently navigable work area with distinct future task triggers or entrypoints. Keep a new path in an existing skill when it clearly remains part of that owner's scope; do not create one skill per file.

When creating, merging or retiring a skill, keep exactly one primary owner for every maintained application file. Update the affected SKILL.md files and references/files.json inventories, the AGENTS.md skill catalog and folder/task router, and all adjacent-skill links in the same task.

Document only the current state. Replace obsolete information in place. Do not append history, dated discoveries, previous names, “formerly”, “renamed from”, migration notes or future plans to active routing.

If abc becomes xyz and abc no longer exists, retain only xyz in every affected active routing file. Search the entire active routing tree for the obsolete name/path and remove stale references. Do not erase a compatibility symbol that still exists. Do not rewrite Git history or intentional product changelogs.

A task is incomplete while affected routing is stale. If no documented fact changed, verify that explicitly instead of making meaningless documentation edits.
