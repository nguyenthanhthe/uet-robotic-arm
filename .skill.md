---
name: solidworks-robotics-skill
description: Comprehensive workflow for parametric 3D CAD robotics engineering using SolidWorks MCP, /plan, /goal, and DFM for 3D printing.
---

# SolidWorks Robotics CAD & Multi-Agent Skill (`.skill.md`)

Use this skill when designing mechanical components, Top-Down robot arm assemblies, automated SolidWorks modeling via MCP, or preparing parts for additive manufacturing (PETG 3D printing).

---

## 1. SolidWorks MCP Toolchain Guidelines

### Core Tool Map
| Task | SolidWorks MCP Tool | Parameters & Key Rules |
|---|---|---|
| **Health Check** | `ensure_ready` | Verifies COM attachment and active document. |
| **Switch Context** | `activate_document` | `title`: e.g. `'01_Base_SubAssembly.SLDASM'` or `'bergE5F4F25F1bc4[3].SLDPRT'`. |
| **Inspect Part** | `analyze_model` | `analysis_type`: `'features'`, `'faces'`, `'edges'`. |
| **Inspect Assembly**| `analyze_assembly` | `analysis_type`: `'components'`, `'mates'`. |
| **Create Sketch** | `create_sketch` | On plane: `plane="Front Plane"`. On model face: `on_face=True`, `face_index=<int>`. |
| **Draw Profile** | `add_sketch_entity`<br>`add_sketch_entities` | Entity types: `'rectangle'`, `'circle'`, `'line'`, `'arc'`. **Coordinates in METERS (SI)**! |
| **Extrude Feature** | `extrude_feature` | `feature_type`: `'boss'` or `'cut'`. `depth`: in METERS. `through`: True for through-all. |
| **Assembly Mates** | `add_mate` | Types: `'concentric'`, `'coincident'`, `'parallel'`, `'distance'`. |
| **Save to Disk** | `save_document` | Flushes active document changes to disk. |

### Critical Execution Rules
1. **SI Units Contract**: Always pass dimensions in **meters** ($1\text{ mm} = 0.001\text{ m}$).
2. **No External COM Scripts**: Never launch standalone python scripts using `win32com.client.Dispatch` while SolidWorks is active to prevent COM exclusive-lock deadlocks.
3. **Face ID Preservation**: Prefer modifying feature dimensions (`modify_dimension` or updating feature depth) over deleting and recreating features to prevent broken downstream mates.
4. **Post-Action Verification**: Always call `analyze_model` or `analyze_assembly` after feature/mate creation to verify zero errors.

---

## 2. Slash Command Workflows (`/plan` and `/goal`)

### When `/plan` is Invoked
1. **Analyze First**: Run read-only MCP queries (`analyze_assembly`, `analyze_model`) and study kinematics in `docs/thong-so-dong-hoc.md`.
2. **Draft Plan Artifact**: Create a clear technical design document with:
   - Target component & coordinate frame.
   - Exact numerical dimensions and tolerances.
   - Identified geometric clash risks.
   - DFM and printability assessment.
3. **Seek Approval**: Request explicit user confirmation before executing structural edits.

### When `/goal` is Invoked
1. **Autonomous Drive**: Work continuously through multi-step engineering tasks without asking trivial questions.
2. **Active Self-Correction**:
   - If a mate turns red (e.g. missing face reference after a feature move), investigate immediately with `analyze_assembly(analysis_type='mates')` and resolve the invalid entity.
   - If an extrude-cut fails with "does not intersect model", check sketch plane offset and depth.
3. **Completion Criteria**:
   - All components mated cleanly (0 red X errors).
   - Tolerances and wire tunnels verified.
   - Files saved via `save_document`.
   - Git repository clean and pushed.
   - Conclude with `<!-- GOAL_COMPLETE -->`.

---

## 3. Robot Arm Specifications & DFM (KUKA KR 3 R540 Scale 0.49)

### Kinematics & Scale
- Scale factor: $\lambda = 0.49$ relative to industrial KUKA KR 3 R540.
- Joint 1 (Base Rotation): Vertical Z-axis rotation $\pm 170^\circ$, driven by TowerPro MG996R metal-gear servo.
- Joint 2 (Shoulder): Horizontal pitch axis, driven by MG996R.
- Joint 3 (Elbow): Horizontal pitch axis, driven by MG996R.
- Joint 4 & 5 (Wrist Pitch & Roll): Driven by MG996R / MG90S.
- Gripper: Parallel rack & pinion driven by micro servo (MG90S/SG90).

### Mechanical Load Path
- **Thrust & Radial Load**: Supported $100\%$ by industrial 698ZZ miniature deep-groove ball bearings ($\varnothing 19 \times \varnothing 8 \times 6\text{ mm}$).
- **Torsion Drive**: Transmitted via 25T round metal servo horns (`Axixi Servo Disc`, flange $\varnothing 20 - 24.5\text{ mm}$, hub $\varnothing 7.5 - 8.0\text{ mm}$).
- **Load Isolation Rule**: The rotating arm body bolts directly to the 4x M3 holes of the metal servo horn. The horn rests flat on the bearing inner ring. The bearing outer ring rests in the base cap. The servo motor output shaft experiences pure rotational torque only.

### 3D Printing DFM (PETG)
- **Overhang Rule**: Max $45^\circ$ slope for zero-support printing.
- **M3 Heat-Set Insert Holes**: $\varnothing 4.2\text{ mm}$ bore, $5.0 - 5.5\text{ mm}$ depth with closed bottom floor.
- **Slicing Parameters**: 4 wall perimeters (minimum $1.6\text{ mm}$ shell), 30% gyroid infill, 5 top layers, 4 bottom layers.
