# AGENTS.md — Hướng dẫn Đóng góp & Quy tắc Đa Tác Nhân (Multi-Agent System)

> **Dự án:** Thiết kế & Chế tạo Cánh tay Robot 5-DOF + Gripper song song UET.  
> **Cơ sở tham chiếu:** KUKA KR 3 R540 (Scale 0.49).  
> **Bộ điều khiển:** Arduino Uno R3 + PCA9685 16-Channel PWM I2C Shield.  
> **Động cơ truyền động:** 5x Servo TowerPro MG996R (Bánh răng kim loại) + 1x Micro Servo SG90/MG90S (Gripper).

---

## 1. Chuỗi Công cụ & Tích hợp MCP (Toolchains)

| Công việc | Công cụ / MCP Server | Quy ước & Vai trò |
|---|---|---|
| **Thiết kế 3D Parametric & Assembly** | **SolidWorks MCP** (COM API) | Mô hình 3D SolidWorks (.SLDPRT, .SLDASM); kiểm tra va chạm, đo đạc, tạo khối và lắp ráp trực tiếp. |
| **Giao thức Kế hoạch & Mục tiêu** | **`/plan`** và **`/goal`** | Ràng buộc phân tích kỹ thuật, lập kế hoạch chi tiết trước khi sửa đổi và tự hành xử lý mục tiêu đường dài. |
| **Thuyết minh & Báo cáo đồ án** | **Typst CLI** (`typst compile`) | Soạn thảo báo cáo kỹ thuật chuẩn học thuật UET trong `docs/typst/`, xuất file PDF vào `docs/typst/out/`. |
| **Mô phỏng Động học & MATLAB** | **MATLAB MCP** | Kiểm tra ma trận Denavit-Hartenberg (D-H), động học thuận (FK), động học nghịch (IK). |
| **Firmware Điều khiển** | **Arduino C++ / PlatformIO** | Mã nguồn trong `firmware/v2rad_code/v2rad_code.ino`, giao tiếp I2C điều khiển PCA9685. |

---

## 2. Quy tắc Ràng buộc Nghiêm ngặt (Strict Agent Rules)

### 🔴 Quy tắc 1: Làm việc an toàn với SolidWorks MCP
- **Không tự ý chạy script Python độc lập để kết nối COM:** Tiến trình SolidWorks COM (`SldWorks.Application`) trên Windows chỉ cho phép một kết nối duy nhất. SolidWorks MCP đã kết nối sẵn; chạy script ngoài sẽ gây xung đột khóa (exclusive lock).
- **Luôn dùng SI units (Mét) khi gọi MCP:** Mọi giá trị độ dài, bán kính, độ sâu trong tham số tool MCP phải tính bằng mét ($1\text{ mm} = 0.001\text{ m}$).
- **Xác thực sau mỗi Feature / Mate:** Sau khi gọi lệnh tạo khối, cắt hốc, hoặc thêm mate, luôn gọi `analyze_model` hoặc `analyze_assembly` để kiểm tra `result_geometry` và trạng thái lỗi. Không bao giờ để lại mate đỏ (Missing Reference).
- **Lưu file thường xuyên:** Luôn gọi `save_document` sau khi hoàn thành một cụm tính năng logic.

### 🔴 Quy tắc 2: Tuân thủ quy trình `/plan` và `/goal`
- Khi người dùng yêu cầu `/plan`:
  1. Khảo sát hiện trạng bằng tool đọc (Read-only tools).
  2. Tạo bản kế hoạch chi tiết (Implementation Plan) nêu rõ mục tiêu, rủi ro hình học, tọa độ cụ thể.
  3. Chỉ bắt tay vào sửa đổi khi kế hoạch đã được phê duyệt rõ ràng.
- Khi người dùng yêu cầu `/goal`:
  1. Tự động hóa quá trình kiểm tra, thử nghiệm, khắc phục lỗi mà không dừng lại hỏi những câu hiển nhiên.
  2. Tự động kiểm tra chéo (self-auditing) đảm bảo tính toàn vẹn của mô hình cơ khí.
  3. Kết thúc mục tiêu bằng thẻ `<!-- GOAL_COMPLETE -->`.

### 🔴 Quy tắc 3: Chuẩn Cơ khí & DFM In 3D (PETG)
- **Vật liệu:** Nhựa **PETG** chịu nhiệt $\ge 60^\circ\text{C}$, dẻo dai, chống biến dạng nhiệt do servo tỏa ra.
- **Quy tắc Vát dốc $45^\circ$ (Zero Support):** Tất cả các gờ đỡ, mặt trần hốc nhô ra phải được vát nghiêng $45^\circ$ dốc xuống vách thành để máy in FDM in hoàn toàn không cần support.
- **Lỗ ốc cấy ren nhiệt M3 (Brass Inserts):** Chuẩn hóa đường kính lỗ in 3D là **$\varnothing 4.2\text{ mm}$**, độ sâu cắt mù (Blind) **$5.0\text{ mm} - 5.5\text{ mm}$** có sàn chặn đáy để không rơi ốc khi cấy hàn nhiệt.
- **Đồng tâm Tuyệt đối Khớp Xoay:** Trục răng vàng servo, ổ bi 698ZZ và đĩa xoay kim loại **bắt buộc phải đồng tâm $(0,0)$** với đường tròn đế/khớp xoay.
- **Xếp lớp truyền lực:** Thân robot $\to$ Đĩa kim loại 25T $\to$ Vòng trong ổ bi 698ZZ $\to$ Nắp đế. Ổ bi gánh toàn bộ tải trọng; servo chỉ truyền mô-men xoắn xoay.

---

## 3. Cấu trúc Dự án (Repository Architecture)

```
uet-robotic-arm/
├── cad/
│   ├── assemblies/         # Cụm lắp ráp SolidWorks (01_Base_SubAssembly.SLDASM...)
│   ├── parts/              # Chi tiết in 3D (01_Base_Pedestal, 01_Base_TopCap, 02_Turret...)
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
├── CLAUDE.md               # Quy tắc cho Claude Code / AI Agents
├── AGENTS.md               # Quy tắc chung cho toàn bộ Agent
├── goal.md                 # Tôn chỉ và mục tiêu tối thượng của dự án
└── README.md               # Tổng quan dự án
```

---

## 4. Biên dịch Thuyết minh Báo cáo (Typst)

1. Thuyết minh chính: `docs/typst/thuyet-minh.typ`.
2. Biểu mẫu bìa UET: `docs/typst/uet-report.typ`.
3. Chương động học toán: `docs/typst/kinematics.typ`.
4. Lệnh biên dịch từ thư mục gốc:
   ```bash
   typst compile docs/typst/thuyet-minh.typ docs/typst/out/thuyet-minh.pdf
   ```
5. Font chữ tiêu chuẩn: **Liberation Serif** (tương thích $100\%$ Times New Roman, hiển thị tiếng Việt hoàn hảo).