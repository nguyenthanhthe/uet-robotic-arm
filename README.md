# Cánh tay robot 5-DOF UET (KUKA KR 3 R540 Scale 0.49)

> **Đồ án môn học:** Các cơ cấu chấp hành robot — Khoa Cơ điện tử, Trường Đại học Công nghệ, ĐHQGHN (VNU-UET).  
> **Mục tiêu:** Thiết kế, mô phỏng và chế tạo cánh tay robot 5 bậc tự do (5-DOF) kèm tay gắp song song (Parallel Gripper) phỏng theo hình dáng công nghiệp của robot KUKA KR 3 R540 (thu nhỏ tỷ lệ $\approx 0.49$).  
> **Nhiệm vụ:** Nhận diện, gắp phân loại các khối hình học (tròn, vuông, sao...) và thả chính xác vào ô tương ứng.

---

## 1. Thông số Kỹ thuật & Phần cứng

| Hạng mục | Thông số kỹ thuật | Ghi chú |
|---|---|---|
| **Số bậc tự do** | 5-DOF + 1-DOF Gripper | $J_1$ (Base), $J_2$ (Shoulder), $J_3$ (Elbow), $J_4$ (Wrist Pitch), $J_5$ (Wrist Roll) |
| **Tầm với (Reach)** | $\approx 265\text{ mm}$ | Đạt và vượt yêu cầu tối thiểu $200\text{ mm}$ của môn học |
| **Tải trọng nâng** | $100\text{ g} - 250\text{ g}$ | Vượt yêu cầu tối thiểu $50\text{ g}$ |
| **Động cơ truyền động** | 5x TowerPro MG996R + 1x SG90/MG90S | Bánh răng kim loại, mô-men xoắn $11\text{ kg}\cdot\text{cm}$ |
| **Vòng bi đỡ khớp** | 698ZZ ($\varnothing 19 \times \varnothing 8 \times 6\text{ mm}$) | Đỡ toàn bộ tải trọng dọc trục và uốn ngang, giải phóng lực cho servo |
| **Khớp nối đĩa** | Đĩa tròn kim loại 25T (Axixi Servo Disc) | Bắt 4 ốc M3 trực tiếp lên thân trên (Turret J1) |
| **Bộ điều khiển** | Arduino Uno R3 + Shield PWM PCA9685 | Giao tiếp I2C 16 kênh PWM, nguồn riêng 5V-6V 10A cho servo |
| **Vật liệu in 3D** | **PETG** | Chịu nhiệt $\ge 60^\circ\text{C}$ (chống dão nhiệt từ servo), chịu va đập cao |

---

## 2. Tiến độ Dự án

- [x] **Khảo sát & Chọn mẫu:** Quyết định chọn dáng công nghiệp KUKA KR 3 R540 scale 0.49 thay thế mẫu đồ chơi cũ.
- [x] **Cụm Đế J1 (`01_Base_SubAssembly.SLDASM`):**
  - [x] Bịt kín hốc cũ, khoét hốc trụ $\varnothing 77\text{ mm}$ chuẩn xác.
  - [x] Định vị servo MG996R đồng tâm tuyệt đối $(0,0)$ với trục xoay đế.
  - [x] Thiết kế gờ đỡ tai servo chuẩn DFM (sàn dày, vát dốc $45^\circ$, có rãnh thoát dây điện).
  - [x] Bổ sung 4 lỗ cấy ren nhiệt đồng M3 ($\varnothing 4.2\text{ mm} \times 5.5\text{ mm}$).
  - [x] Nắp đế (`01_Base_TopCap` dày $5\text{ mm}$) tích hợp ổ bi 698ZZ đỡ tải trọng.
  - [x] Đĩa nhôm 25T nổi phẳng phiu trên đỉnh ổ bi, sẵn sàng đón thân trên.
  - [x] Khoét khoang chứa bo mạch Arduino Uno $65\text{ mm} \times 56\text{ mm} \times 60\text{ mm}$ ở lưng đế, cổng USB và nguồn quay ra sau.
- [ ] **Khớp xoay Turret J1 - J2 (`02_Base_Turret`):** Đang tiến hành.
- [ ] **Cánh tay chính & Khuỷu tay J3 (`03_UpperArm`, `04_Forearm`):** Kế hoạch tiếp theo.
- [ ] **Cổ tay & Tay gắp song song J4 - J5 + Gripper:** Kế hoạch tiếp theo.
- [ ] **Mô phỏng động học MATLAB & Thuyết minh Typst:** Đang cập nhật.

---

## 3. Cấu trúc Thư mục

```
uet-robotic-arm/
├── cad/
│   ├── assemblies/         # Cụm lắp ráp SolidWorks (01_Base_SubAssembly.SLDASM...)
│   ├── parts/              # Chi tiết in 3D thiết kế riêng (01_Base_Pedestal, 02_Turret...)
│   ├── exports/            # File xuất STEP, STL cho xưởng in 3D
│   └── reference/          # Ảnh chụp tham chiếu viewport CAD
├── firmware/
│   └── v2rad_code/         # Mã nguồn Arduino Uno / Nano (.ino)
├── hardware/
│   ├── reference/
│   │   ├── cots_parts/     # Thư viện 3D linh kiện chuẩn COTS (MG996R, 698ZZ, Arduino...)
│   │   ├── cults3d_kuka/   # STL tham chiếu KUKA KR3 từ Cults3D
│   │   ├── kuka_kr3_r540/  # Tài liệu kỹ thuật, bản vẽ kích thước chuẩn KUKA
│   │   └── v2rad_parts/    # Các chi tiết tham chiếu cơ cấu cũ
│   └── HUONG-DAN-IN-3D.md  # Cẩm nang thông số in FDM slicer
├── docs/
│   ├── yeu-cau-ky-thuat.md # Yêu cầu kỹ thuật toàn diện đồ án
│   ├── thong-so-dong-hoc.md# Bảng thông số D-H và tọa độ các trục
│   ├── typst/              # Mã nguồn Typst báo cáo chính thức (xuất PDF)
│   ├── images/             # Sơ đồ mạch điện, sơ đồ nguyên lý
│   └── media/              # Video tham chiếu và trích xuất khung hình
├── matlab/                 # Script mô phỏng động học, GUI điều khiển robot
├── CLAUDE.md               # Quy ước cho Claude Code / AI Agents
├── AGENTS.md               # Quy tắc đa tác nhân (Multi-agent System)
├── .skill.md               # Kỹ năng SolidWorks Robotics CAD & DFM
├── goal.md                 # Tôn chỉ và mục tiêu tối thượng của dự án
└── README.md               # Tổng quan dự án
```

---

## 4. Biên dịch Thuyết minh Đồ án (Typst)

Tài liệu báo cáo chính thức được soạn thảo bằng **Typst**:

```bash
# Biên dịch file PDF thuyết minh đồ án UET
typst compile docs/typst/thuyet-minh.typ docs/typst/out/thuyet-minh.pdf
```

---

## 5. Quy ước Đóng góp cho AI Coding Agents

Dự án được cấu hình sẵn cho các AI Coding Agent (Antigravity, Claude Code, Cursor, Copilot):
- Xem **[CLAUDE.md](CLAUDE.md)** và **[AGENTS.md](AGENTS.md)** để biết chi tiết về giao thức `/plan`, `/goal` và kết nối SolidWorks MCP.
- Xem **[.skill.md](.skill.md)** để tra cứu thông số kỹ thuật DFM in 3D PETG và kích thước chuẩn linh kiện COTS.