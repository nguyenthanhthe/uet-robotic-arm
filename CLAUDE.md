# CLAUDE.md — Quy ước & Chỉ dẫn cho Coding Agent (Claude / AI Agents)

> **Dự án:** Cánh tay robot 5-DOF + Gripper song song (Phỏng theo KUKA KR 3 R540, tỷ lệ scale $0.49$).  
> **Khoa Cơ điện tử — Trường Đại học Công nghệ (VNU-UET).**  
> **Vật liệu in 3D chính:** **PETG** (chịu nhiệt $\ge 60^\circ\text{C}$, kháng dão nhiệt từ servo, độ dẻo và bám dính lớp cao).  
> **Điều khiển:** Arduino Uno R3 + Shield PWM PCA9685 (I2C) + 5x Servo TowerPro MG996R (kim loại) + 1x SG90/MG90S (Gripper).

---

## 1. QUY TẮC RÀNG BUỘC VỚI SLASH COMMANDS

### 📌 Giao thức `/plan` (Lập kế hoạch trước khi can thiệp)
Khi người dùng kích hoạt `/plan` hoặc bắt đầu một nhiệm vụ kỹ thuật mới (thiết kế chi tiết CAD mới, refactor, đổi kích thước, sửa động học):
1. **Nghiên cứu & Đối chiếu (Research First):**
   - Đọc kỹ thông số kỹ thuật trong `docs/yeu-cau-ky-thuat.md` và `docs/thong-so-dong-hoc.md`.
   - Dùng SolidWorks MCP (`analyze_assembly`, `analyze_model`) để đọc tọa độ, kích thước, và các ràng buộc (mates) hiện có trước khi sửa đổi.
2. **Soạn thảo Bản kế hoạch Thực thi (Implementation Plan):**
   - Tạo file artifact hoặc tài liệu kế hoạch rõ ràng: Mục tiêu, Rủi ro va chạm hình học, Thông số kích thước cụ thể (mm), Danh sách tính năng (Features) cần tạo.
   - **BẮT BUỘC** xin ý kiến hoặc xác nhận của người dùng trước khi thực hiện các lệnh chỉnh sửa phá hủy (destructive edits) hoặc thay đổi kích thước gốc.
3. **Thẩm định & Báo cáo kết quả (Walkthrough):**
   - Sau khi hoàn thành, kiểm tra va chạm, kiểm tra đồng tâm trục xoay, và tổng hợp kết quả cụ thể.

### 📌 Giao thức `/goal` (Chạy tự hành đường dài / Overnight)
Khi người dùng kích hoạt `/goal` (thường vào ban đêm hoặc ủy thác dài hạn):
1. **Tự hành triệt để (Autonomous Execution):**
   - Không dừng lại giữa chừng để hỏi những câu hỏi hiển nhiên. Tự giải quyết các lỗi hình học, lỗi mate, lỗi lệnh cắt dựa trên các quy tắc kỹ thuật chuẩn đã định nghĩa.
2. **Kiểm tra chéo & Đảm bảo tính toàn vẹn (Continuous Verification):**
   - Mỗi khi tạo xong feature hoặc mate trong SolidWorks: Gọi ngay `analyze_model` hoặc `analyze_assembly` để xác minh khối lượng, số mặt, trạng thái lỗi (không để lại dấu X đỏ hoặc cảnh báo vàng).
   - Kiểm tra chuỗi kích thước (tolerance stack-up) và khe hở luồn dây điện.
3. **Kết thúc mục tiêu:**
   - Chỉ khi toàn bộ yêu cầu của `/goal` được giải quyết hoàn tất, sạch sẽ, đã lưu file (`save_document`) và đẩy lên git, mới xuất thẻ `<!-- GOAL_COMPLETE -->`.

---

## 2. QUY TẮC RÀNG BUỘC VỚI SOLIDWORKS MCP

Coding Agent làm việc với SolidWorks thông qua MCP Server `solidworks`. Tuân thủ nghiêm ngặt các quy tắc sau:

1. **Tuyệt đối KHÔNG chạy script Python ngoài để chiếm COM:**
   - SolidWorks trên Windows sử dụng giao tiếp đơn luồng COM (`SldWorks.Application`).
   - SolidWorks MCP Server đã kết nối sẵn vào cổng COM này. Việc chạy script Python bên ngoài (`win32com.client.Dispatch`) sẽ bị xung đột khóa (exclusive lock), gây lỗi `Operation unavailable` hoặc làm đơ SolidWorks.
   - **Mọi thao tác CAD PHẢI gọi trực tiếp qua các tool của SolidWorks MCP:**
     - `ensure_ready`: Kiểm tra trạng thái kết nối.
     - `activate_document`: Chuyển đổi giữa Assembly và Part đang mở.
     - `analyze_model`: Đọc Feature tree, kích thước, danh sách mặt phẳng (faces), cạnh (edges).
     - `analyze_assembly`: Đọc danh sách linh kiện (components) và ràng buộc (mates).
     - `create_sketch`: Tạo sketch trên mặt phẳng chuẩn hoặc trên mặt của khối (`on_face=True`, dùng `face_index`).
     - `add_sketch_entity` / `add_sketch_entities`: Vẽ hình chữ nhật, đường tròn, đường thẳng với tọa độ chuẩn SI (**Mét**).
     - `extrude_feature`: Tạo khối đùn (`feature_type='boss'`) hoặc cắt rãnh (`feature_type='cut'`).
     - `add_mate`: Tạo ràng buộc lắp ráp (`concentric`, `coincident`, `distance`, `parallel`).
     - `save_document`: Lưu file vào đĩa.
2. **Quy ước đơn vị trong SolidWorks MCP:**
   - Trong SolidWorks UI: Hiển thị hệ **MMGS** (milimét, gam, giây).
   - Trong các tham số truyền vào MCP (`depth`, `radius`, `x1`, `y1`...): **BẮT BUỘC DÙNG ĐƠN VỊ MÉT (SI)**!
     - Ví dụ: Khoét sâu $9.5\text{ mm} \rightarrow \mathbf{0.0095}$.
     - Đường kính $\varnothing 4.2\text{ mm} \rightarrow \text{radius} = \mathbf{0.0021}$.
     - Chiều dày $5\text{ mm} \rightarrow \mathbf{0.005}$.
3. **Quy tắc bảo tồn References & Mates:**
   - Tránh xóa các Feature gốc nếu có thể sửa kích thước (`modify_dimension` hoặc sửa độ sâu). Việc xóa feature sẽ làm mất Face ID và sinh lỗi hàng loạt cho các Feature và Mate phụ thuộc (con cái).
   - Khi chỉnh sửa độ sâu hốc hoặc gờ, luôn kiểm tra các mate liên quan để không bị lỗi "Missing Face Reference".

---

## 3. QUY TẮC THIẾT KẾ CƠ KHÍ & DFM (DESIGN FOR 3D PRINTING - PETG)

1. **Quy tắc Đồng tâm Trục Xoay (Joint Concentricity Rule):**
   - Trục quay của tất cả các khớp ($J_1 \to J_5$) **BẮT BUỘC PHẢI TRÙNG TÂM $(0,0)$** với ổ bi đỡ và trục ra của động cơ servo.
   - Tuyệt đối không dời tâm ổ bi để "chữa cháy" cho việc đặt lệch servo. Servo phải được định vị sao cho trục bánh răng vàng đồng tâm tuyệt đối với ổ bi.
2. **Quy tắc Vát dốc $45^\circ$ (Zero-Support Overhang):**
   - Máy in FDM in nhựa PETG chỉ in cầu (bridge) tốt giữa 2 vách đối diện. Không thể in "ban công" phẳng ngang $90^\circ$ lơ lửng một phía mà không có support.
   - Mọi gờ đỡ, đáy hốc nhô ra phải được **vát nghiêng $45^\circ$ (Chamfer / Gusset)** dốc xuống thành vách để in $100\%$ không cần support và tăng độ bền chống gãy lớp layer lên gấp 5 lần.
3. **Kích thước Lỗ cho Ốc Cấy Nhiệt Ren Đồng M3 (Heat-Set Inserts):**
   - Vật liệu **PETG** có độ co ngót nhiệt khi in lỗ tròn:
     - **Đường kính lỗ in 3D:** $\mathbf{\varnothing 4.2\text{ mm}}$ (dành cho ốc cấy M3 đường kính ngoài khía $4.6\text{ mm}$).
     - **Độ sâu lỗ:** Tối thiểu **$5.0\text{ mm} - 5.5\text{ mm}$** (chừa sàn đáy $\ge 1.0\text{ mm}$ chặn đáy để khi dí mỏ hàn không bao giờ bị rơi tuột con ren).
4. **Cơ cấu Chịu Lực Khớp Quay (Load Isolation):**
   - Servo MG996R chỉ chịu mô-men xoắn thuần túy (Pure Torsion).
   - Toàn bộ lực dọc trục (trọng lượng cánh tay) và lực uốn ngang **BẮT BUỘC phải truyền qua ổ bi 698ZZ** ($\varnothing 19 \times \varnothing 8 \times 6\text{ mm}$) tựa lên nắp và thân đế robot.
   - Đĩa kim loại 25T (Servo Horn) phải nằm trên cùng, tựa lên vòng trong của ổ bi, lộ 4 lỗ ốc M3 lên mặt trên để bắt chặt vào thân trên (Turret J1).

---

## 4. CẤU TRÚC THƯ MỤC CHUẨN CỦA DỰ ÁN

```
uet-robotic-arm/
├── cad/
│   ├── assemblies/         # Cụm lắp ráp chính (01_Base_SubAssembly.SLDASM...)
│   ├── parts/              # Các chi tiết in 3D thiết kế riêng (01_Base, 02_Turret...)
│   ├── exports/            # File xuất STEP, STL chuẩn bị in 3D
│   └── reference/          # Ảnh chụp tham chiếu, góc nhìn viewport CAD
├── firmware/
│   └── v2rad_code/         # Mã nguồn nạp Arduino Uno / Nano (.ino)
├── hardware/
│   ├── reference/
│   │   ├── cots_parts/     # Mô hình 3D linh kiện chuẩn COTS (Servo MG996R, 698ZZ, Arduino Uno...)
│   │   ├── cults3d_kuka/   # File STL tham chiếu cánh tay KUKA từ Cults3D
│   │   ├── kuka_kr3_r540/  # Datasheet và bản vẽ chuẩn KUKA KR3
│   │   └── v2rad_parts/    # Các chi tiết tham chiếu cơ cấu cũ
│   └── HUONG-DAN-IN-3D.md  # Hướng dẫn chi tiết thông số in FDM
├── docs/
│   ├── yeu-cau-ky-thuat.md # Yêu cầu kỹ thuật toàn diện của đồ án
│   ├── thong-so-dong-hoc.md# Bảng thông số D-H và tọa độ các khớp
│   ├── typst/              # Thuyết minh báo cáo chính thức (Typst -> PDF)
│   ├── images/             # Sơ đồ mạch, hình ảnh minh họa
│   └── media/              # Video tham chiếu và trích xuất khung hình
├── matlab/                 # Mô phỏng động học, GUI điều khiển robot
├── CLAUDE.md               # Chỉ dẫn cho Claude Code / Coding Agents
├── AGENTS.md               # Quy ước chung đa tác nhân
├── goal.md                 # Mục tiêu tối thượng của dự án
└── README.md               # Trang giới thiệu tổng quan repo
```

---

## 5. LỆNH THƯỜNG DÙNG

```bash
# Kiểm tra trạng thái Git
git status

# Biên dịch tài liệu thuyết minh Typst sang PDF
typst compile docs/typst/thuyet-minh.typ docs/typst/out/thuyet-minh.pdf

# Kiểm tra cú pháp Typst
typst query docs/typst/thuyet-minh.typ "<heading>"
```
