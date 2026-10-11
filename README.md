# Cánh tay robot 5-DOF UET (KUKA KR 3 R540 Scale 0.49)

> **Đồ án môn học:** Các cơ cấu chấp hành robot — Khoa Cơ điện tử, Trường Đại học Công nghệ, ĐHQGHN (VNU-UET).  
> **Mục tiêu:** Thiết kế, mô phỏng và chế tạo cánh tay robot 5 bậc tự do (5-DOF) kèm tay gắp song song (Parallel Gripper) phỏng theo hình dáng công nghiệp của robot KUKA KR 3 R540 (thu nhỏ tỷ lệ $\approx 0.49$).  
> **Nhiệm vụ:** Nhận diện, gắp phân loại các khối hình học (tròn, vuông, sao...) và thả chính xác vào ô tương ứng.

---

## 1. Thông số Kỹ thuật & Phần cứng

| Hạng mục | Thông số kỹ thuật | Ghi chú |
|---|---|---|
| **Số bậc tự do** | 5-DOF + 1-DOF Gripper | $J_1$ (Base), $J_2$ (Shoulder), $J_3$ (Elbow), $J_4$ (Wrist Pitch), $J_5$ (Wrist Roll) |
| **Tầm với (Reach)** | $\approx 342\text{ mm}$ | Đạt và vượt yêu cầu tối thiểu $200\text{ mm}$ của môn học |
| **Tải trọng nâng** | $\ge 50\text{ g}$ | Theo yêu cầu môn học; khớp vai dùng servo số $25\text{ kg}\cdot\text{cm}$ |
| **Động cơ truyền động** | 2x MG996R ($J_1$, $J_3$) + 1x servo số $25\text{ kg}\cdot\text{cm}$, $180^\circ$ ($J_2$) + 3x MG90S ($J_4$, $J_5$, tay gắp) | Servo cỡ chuẩn dùng chung hốc $40 \times 20\text{ mm}$ và trục 25T |
| **Vòng bi đỡ khớp** | 698ZZ ($\varnothing 19 \times \varnothing 8 \times 6\text{ mm}$) | Đỡ phụ khớp vai $J_2$ và khớp khuỷu $J_3$ ở tai đối diện servo; khớp đế $J_1$ dùng ổ trượt nhựa (ngõng trục và vành chân turret trên mặt đế) |
| **Khớp nối đĩa** | Đĩa tròn kim loại 25T (Axixi Servo Disc) | Bắt 4 ốc M3 trên PCD $14\text{ mm}$: turret vào đĩa sừng $J_1$, cánh tay trên vào đĩa sừng $J_2$ |
| **Bộ điều khiển** | Arduino Uno R3 + shield PWM PCA9685 cắm chồng | Đặt trong đế; I2C 16 kênh PWM, nguồn riêng 6V từ 8A cho servo |
| **Vật liệu in 3D** | **PETG** | Chịu nhiệt $\ge 60^\circ\text{C}$ (chống dão nhiệt từ servo), chịu va đập cao |

---

## 2. Tiến độ Dự án

- [x] **Khảo sát & Chọn mẫu:** Quyết định chọn dáng công nghiệp KUKA KR 3 R540 scale 0.49 thay thế mẫu đồ chơi cũ.
- [x] **Cụm Đế J1 (`01_Base_SubAssembly.SLDASM`):**
  - [x] Bịt kín hốc cũ, khoét hốc trụ $\varnothing 77\text{ mm}$ chuẩn xác.
  - [x] Định vị servo MG996R đồng tâm tuyệt đối $(0,0)$ với trục xoay đế.
  - [x] Thiết kế gờ đỡ tai servo chuẩn DFM (sàn dày, vát dốc $45^\circ$, có rãnh thoát dây điện).
  - [x] Bổ sung 4 lỗ cấy ren nhiệt đồng M3 ($\varnothing 4.2\text{ mm} \times 5.5\text{ mm}$).
  - [x] Chân đế tự thiết kế `01_Base_Pedestal` không còn dùng trong cụm lắp chính (thay bằng `01_Base_Kuka`).
  - [x] Mặt bích $95 \times 95 \times 5\text{ mm}$ bo góc $R10$ với 4 lỗ bắt bàn theo lưới $73.5 \times 73.5\text{ mm}$; 24 rãnh thoát khí dọc trên vách tháp.
- [x] **Đế dáng KUKA (`01_Base_Kuka` + `01_Base_Tray`):** thân đế KUKA khoét rỗng, servo MG996R $J_1$ bắt dưới trần, khay đáy đỡ Arduino Uno + shield PWM 16 kênh, cổng USB và giắc nguồn mở ra mặt sau.
- [ ] **Cụm lắp toàn bộ cánh tay (`00_Robot_J1J2_Assembly.SLDASM`, 28 component, 35 mate):** thiết kế xong, Interference Detection chỉ còn mối ghép then hoa đĩa sừng; chưa in thử.
  - [x] Turret liền khối `02_Turret_ForkKuka`: thân cột xoay KUKA đặt trực tiếp lên đế (ngõng trục $\varnothing 49$ + vành chân $\varnothing 92$), hốc đĩa sừng $J_1$ với 4 ốc M3, hốc servo MG996R nghiêng $15^\circ$ trong tai $+Y$, ổ bi 698ZZ trong tai $-Y$; trục $J_2$ cao $169.05\text{ mm}$, lệch $9.8\text{ mm}$ trước trục $J_1$.
  - [ ] In thử, lắp servo $J_2$ và kiểm tra khe hở.
- [ ] **Cánh tay chính & Khuỷu tay J3 (`03_UpperArm`, `04_Forearm`):** Đang tiến hành.
  - [x] Cánh tay trên `03_UpperArmKuka` ($L_1 = 127.4\text{ mm}$): thân cánh tay KUKA, đầu $J_2$ bắt đĩa sừng và bu-lông M8 qua vòng bi, tai $+Y$ đầu $J_3$ giữ servo MG996R nghiêng $15^\circ$, tai $-Y$ có ổ bi 698ZZ; lắp trong `00_Robot_J1J2_Assembly.SLDASM`, khớp $J_2$ quay tự do từ $-45^\circ$ đến $+165^\circ$.
  - [x] Cẳng tay ($L_2 = 127.8\text{ mm}$): khối khuỷu `04_Forearm_ElbowKuka`, thân càng `04_Forearm_ForkKuka` giữ servo MG90S $J_4$, hai tấm ốp `04_Forearm_CoverPivot` / `04_Forearm_CoverServo` và chốt xoay `04_J4_PivotPin`.
- [ ] **Cổ tay & Tay gắp song song J4 - J5 + Gripper:** Đang tiến hành.
  - [x] Cổ tay `05_WristKuka`: trục $J_4$ và $J_5$ cắt nhau tại tâm mũi cổ tay, servo MG90S $J_5$ nằm trong mũi.
  - [x] Tay gắp bánh răng – thanh răng (`06_Gripper_Base`, `06_Gripper_Guide`, `06_Gripper_Pinion`, 2 × `06_Gripper_Jaw`), tâm gắp cách trục $J_4$ $L_3 = 86.8\text{ mm}$.
  - [ ] Đo đĩa sừng MG90S thật và in mẫu thử cụm tay gắp.
- [ ] **Mô phỏng động học MATLAB & Thuyết minh Typst:** Đang cập nhật.

---

## 3. Cấu trúc Thư mục

```
uet-robotic-arm/
├── cad/
│   ├── assemblies/         # Cụm lắp ráp SolidWorks (01_Base_SubAssembly.SLDASM...)
│   ├── parts/              # Chi tiết in 3D thiết kế riêng (01_Base_Kuka, 02_Turret...)
│   ├── exports/            # File xuất STEP, STL cho xưởng in 3D
│   └── reference/          # Ảnh chụp tham chiếu viewport CAD
├── firmware/
│   └── v2rad_code/         # Sketch tham khảo v2 R.A.D. cho Arduino Nano ESP32 (.ino)
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
├── .agents/skills/         # Kỹ năng định tuyến dự án (routing skills)
├── CLAUDE.md               # Adapter trỏ về AGENTS.md
├── AGENTS.md               # Nguồn chỉ dẫn & định tuyến duy nhất
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
- Xem **[AGENTS.md](AGENTS.md)** — nguồn chỉ dẫn & định tuyến duy nhất của dự án (giao thức `/plan`, `/goal`, SolidWorks MCP, DFM PETG).
- **[CLAUDE.md](CLAUDE.md)** là adapter mỏng trỏ về `AGENTS.md`.
- Bản đồ thư mục & tra cứu nhanh theo công việc nằm trong các routing skill tại **[.agents/skills/](.agents/skills/)** (`robot-cad`, `robot-hardware`, `robot-firmware`, `robot-simulation`, `project-docs`).