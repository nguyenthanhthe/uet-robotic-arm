// Báo cáo bài tập lớn: Cánh tay robot công nghiệp 5-DOF (kiểu UET, Typst)
#import "uet-report.typ": *
#import "kinematics.typ": kinematics-chapter

// ---- Thiết lập trang & font (tương đương geometry của uetgraduation.cls) ----
#set page(
  paper: "a4",
  margin: (left: 3cm, right: 2cm, top: 2.5cm, bottom: 2cm),
)
#set text(font: "Liberation Serif", lang: "vi", size: 11pt)
#set par(justify: true)
#set heading(numbering: "1.1")

// ---- Trang bìa ----
#uet-cover1(
  title: "Thiết kế và chế tạo cánh tay robot có tay gắp",
  document-type: "BÀI TẬP LỚN",
  major: "Công nghệ kỹ thuật điều khiển và tự động hoá",
  year: 2026,
  members: (
    ("Nguyễn Thanh Thế", "24022911"),
    ("Điền tên thành viên 2", "2402____"),
    ("Điền tên thành viên 3", "2402____"),
  ),
)

#uet-cover2(
  title: "Thiết kế và chế tạo cánh tay robot có tay gắp",
  document-type: "BÀI TẬP LỚN",
  major: "Công nghệ kỹ thuật điều khiển và tự động hoá",
  supervisor: "TS. Nguyễn Văn Hướng dẫn",
  year: 2026,
  members: (
    ("Nguyễn Thanh Thế", "24022911"),
    ("Điền tên thành viên 2", "2402____"),
    ("Điền tên thành viên 3", "2402____"),
  ),
)

// ---- Mục lục ----
#outline(title: "Mục lục", depth: 2)

// ---- Nội dung ----
= Giới thiệu
Mục tiêu, phạm vi và nhiệm vụ gắp–thả vật đa hình dạng (sao, vuông, tròn) vào lỗ tương ứng trên bảng lắp ghép. Hệ thống được thiết kế dạng cánh tay robot công nghiệp thu nhỏ (phong cách KUKA/ABB) với chuỗi động học hở 5 bậc tự do nối tiếp kết hợp tay gắp bánh răng song song.

= Yêu cầu kỹ thuật
#table(
  columns: (2fr, 1.2fr, 3fr),
  [*Thông số*], [*Giá trị thiết kế*], [*Ghi chú*],
  [Tầm với tối đa], [$265 "mm"$], [Hiệu dụng vùng gắp thả $200 - 220 "mm"$ ($>= 200 "mm"$)],
  [Tải trọng nâng], [$>= 50 "g"$], [Tại tư thế vươn ngang xa nhất với hệ số an toàn $S F approx 3.2$],
  [Độ lặp lại], [$<= plus.minus 0.5 "mm"$], [Thử nghiệm 10 chu kỳ liên tục theo tiêu chuẩn tinh gọn],
  [Backlash khớp], [$<= 0.5 degree$], [Servo nhông kim loại + gối đỡ ổ bi đối xứng 608ZZ/625ZZ],
  [Số bậc tự do (DOF)], [$5 + 1$], [Base / Shoulder / Elbow / Wrist Pitch / Wrist Roll + Gripper],
  [Chu kỳ gắp–thả], [$<= 15 "s"$], [Tiếp cận $\to$ gắp $\to$ chuyển vùng $\to$ xoay hướng $\to$ thả $\to$ về vị trí chờ],
)

#kinematics-chapter

= Chọn truyền động và cơ điện tử
Hệ thống sử dụng chiến lược phối hợp động cơ tối ưu mômen và trọng lượng (Hybrid Actuation):
- *Khớp 1 ($J_1$ - Base)*: Servo MG996R (nhông kim loại, $11 "kg" dot "cm"$).
- *Khớp 2 ($J_2$ - Shoulder)*: Servo MG996R (nhông kim loại, $11 "kg" dot "cm"$). Khớp gánh lực chính của toàn bộ cánh tay.
- *Khớp 3 ($J_3$ - Elbow)*: Servo MG90S (nhông kim loại, $2.2 "kg" dot "cm"$).
- *Khớp 4 ($J_4$ - Wrist Pitch)*: Servo MG90S (nhông kim loại, $2.2 "kg" dot "cm"$).
- *Khớp 5 ($J_5$ - Wrist Roll)*: Servo MG90S (nhông kim loại, $2.2 "kg" dot "cm"$). Định hướng góc vật thể hình sao/vuông.
- *Khâu kẹp (Gripper)*: Servo MG90S dẫn động cụm bánh răng – thanh răng song song (Dual Rack & Pinion).

#table(
  columns: (auto, 1fr, 1fr, 2fr),
  [*STT*], [*Linh kiện*], [*Số lượng*], [*Quy cách kỹ thuật*],
  [1], [Servo MG996R], [2], [Nhông kim loại, $11 - 13 "kg" dot "cm"$, góc quay $180 degree$],
  [2], [Servo MG90S], [4], [Nhông kim loại, $2.2 "kg" dot "cm"$, góc quay $180 degree$],
  [3], [Vòng bi 608ZZ], [2], [Kích thước $8 times 22 times 7 "mm"$, đỡ trục $J_1, J_2$],
  [4], [Vòng bi 625ZZ], [3], [Kích thước $5 times 16 times 5 "mm"$, đỡ trục $J_3, J_4$],
  [5], [Đai ốc nhiệt ren thau M3], [30], [Đường kính ngoài $4.6 "mm"$, chiều dài $5 "mm"$],
  [6], [Ốc lục giác chìm M3], [1 bộ], [Các cỡ chiều dài: $8, 12, 16, 20, 25 "mm"$],
  [7], [Búp servo nhôm 25T], [2], [Dạng đĩa tròn bắt 4 ốc cho MG996R],
  [8], [Mạch đệm PWM PCA9685], [1], [16 kênh 12-bit PWM giao tiếp $I^2 C$],
  [9], [Vi điều khiển], [1], [Arduino Nano / ESP32 DevKit V1],
  [10], [Nguồn ngoài 5V-6V], [1], [Nguồn xung $5"V" - 6"V" >= 4"A"$ tách riêng cho servo],
)

= Thiết kế cơ khí trên Autodesk Fusion 360
Toàn bộ cánh tay robot được thiết kế theo phương pháp *Top-Down Skeleton*:
1. *Master Sketch 2D*: Xác định khung xương động học và tham số $h_0, L_1, L_2, L_3$ trong `User Parameters`.
2. *Lắp ghép COTS*: Đưa các mô hình 3D chuẩn của động cơ servo và vòng bi vào đúng các nút tâm trục.
3. *Vỏ bọc công nghiệp*: Thiết kế thân dạng vỏ rỗng (độ dày thành $2.8 "mm"$) dạng hai nửa vỏ sò (Clamshell) lắp ghép bằng ốc M3 và ren cấy nhiệt, luồn dây điện ngầm bên trong.
4. *Cơ cấu kẹp*: Thiết kế cụm ngón kẹp đối xứng có rãnh chữ V dẫn động qua cơ cấu thanh răng – bánh răng.
5. *Mô phỏng chuyển động (Motion Study)*: Gán các khớp xoay Revolute Joints và kích hoạt kiểm tra va chạm hình học (Interference Detection).

= Hệ thống Điện & Điều khiển
Kiến trúc điều khiển phân tầng Master - Slave:
- *Tầng Master (PC)*: Ứng dụng giao diện 3D (Digital Twin) viết bằng Python (PyQt/CustomTkinter) hoặc MATLAB App Designer. Tự động giải thuật toán động học ngược (IK) giải tích theo thời gian thực và xuất dữ liệu góc khớp qua cổng Serial UART.
- *Tầng Slave (Vi điều khiển)*: Nhận dữ liệu góc qua Serial, truyền tín hiệu điều khiển góc đến các kênh của mạch đệm PCA9685 qua $I^2 C$, thực hiện thuật toán làm mượt quỹ đạo nội suy chống rung giật.

= Phân công công việc
#table(
  columns: (1fr, 1.5fr, 3fr),
  [*Thành viên*], [*Vai trò*], [*Nhiệm vụ cụ thể*],
  [Nguyễn Thanh Thế], [Cơ khí & Thiết kế CAD], [Thiết kế 3D trên Fusion 360, in 3D, lắp ráp cơ cấu khớp & tay gắp],
  [Điền tên TV 2], [Điện tử & Firmware], [Sơ đồ nguyên lý mạch, nguồn PCA9685, nạp firmware điều khiển khớp],
  [Điền tên TV 3], [Phần mềm & Tích hợp], [Giao diện điều khiển 3D trên PC, giải thuật IK, đo kiểm và báo cáo],
)

= Kết luận
Bản thiết kế cánh tay robot công nghiệp 5-DOF đã giải quyết trọn vẹn bài toán kỹ thuật đặt ra: đảm bảo tầm với vượt chuẩn $265 "mm"$, hệ số an toàn mômen $S F = 3.23$, cơ cấu cổ tay 2 bậc tự do linh hoạt xử lý mọi góc xoay của vật thể hình sao và hình vuông, đồng thời sở hữu kiểu dáng công nghiệp hiện đại và tính khả thi chế tạo cao bằng công nghệ in 3D FDM.

#v(20pt)
#align(center)[-- Hết --]