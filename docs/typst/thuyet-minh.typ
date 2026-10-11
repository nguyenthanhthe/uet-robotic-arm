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
  [Tầm với tối đa], [$342 "mm"$], [Hiệu dụng vùng gắp thả $200 - 220 "mm"$ ($>= 200 "mm"$)],
  [Tải trọng nâng], [$>= 50 "g"$], [Tại tư thế vươn ngang xa nhất, khớp vai dùng servo số 25 kg],
  [Độ chính xác định vị], [$plus.minus 3 "mm"$ (sơ bộ)], [Giới hạn bởi bước xung PCA9685 ở 50 Hz và độ rơ bánh răng servo],
  [Gối đỡ khớp], [698ZZ + ổ trượt], [Vòng bi 698ZZ đỡ phụ ở $J_2$, $J_3$; khớp đế $J_1$ dùng ổ trượt nhựa trên mặt đế],
  [Số bậc tự do (DOF)], [$5 + 1$], [Base / Shoulder / Elbow / Wrist Pitch / Wrist Roll + Gripper],
  [Chu kỳ gắp–thả], [$<= 15 "s"$], [Tiếp cận $\to$ gắp $\to$ chuyển vùng $\to$ xoay hướng $\to$ thả $\to$ về vị trí chờ],
)

#kinematics-chapter

= Chọn truyền động và cơ điện tử
Hệ thống sử dụng chiến lược phối hợp động cơ tối ưu mômen và trọng lượng (Hybrid Actuation):
- *Khớp 1 ($J_1$ - Base)*: Servo MG996R (nhông kim loại, $11 "kg" dot "cm"$), treo dưới trần đế.
- *Khớp 2 ($J_2$ - Shoulder)*: Servo số cỡ chuẩn $40 times 20 "mm"$, trục 25T, $25 "kg" dot "cm"$, góc quay $180 degree$. Khớp gánh lực chính của toàn bộ cánh tay.
- *Khớp 3 ($J_3$ - Elbow)*: Servo MG996R (nhông kim loại, $11 "kg" dot "cm"$).
- *Khớp 4 ($J_4$ - Wrist Pitch)*: Servo MG90S (nhông kim loại, $2.2 "kg" dot "cm"$).
- *Khớp 5 ($J_5$ - Wrist Roll)*: Servo MG90S (nhông kim loại, $2.2 "kg" dot "cm"$). Định hướng góc vật thể hình sao/vuông.
- *Khâu kẹp (Gripper)*: Servo MG90S dẫn động cụm bánh răng – thanh răng song song (Dual Rack & Pinion).

#table(
  columns: (auto, 1fr, 1fr, 2fr),
  [*STT*], [*Linh kiện*], [*Số lượng*], [*Quy cách kỹ thuật*],
  [1], [Servo MG996R], [2], [Nhông kim loại, $11 "kg" dot "cm"$, góc quay $180 degree$, cho $J_1$ và $J_3$],
  [2], [Servo số 25 kg], [1], [Cỡ vỏ $40 times 20 "mm"$, trục 25T, cho $J_2$],
  [3], [Servo MG90S], [3], [Nhông kim loại, $2.2 "kg" dot "cm"$, cho $J_4$, $J_5$ và tay gắp],
  [4], [Vòng bi 698ZZ], [2], [Kích thước $8 times 19 times 6 "mm"$, đỡ phụ trục $J_2$, $J_3$],
  [5], [Đai ốc nhiệt ren thau M3], [30], [Lỗ in $4.2 times 5.5 "mm"$],
  [6], [Ốc lục giác chìm M3], [1 bộ], [Các cỡ chiều dài: $8, 10, 12, 16 "mm"$],
  [7], [Đĩa sừng kim loại 25T], [3], [Dạng đĩa tròn bắt 4 ốc M3 trên PCD $14 "mm"$],
  [8], [Shield PWM PCA9685], [1], [16 kênh 12-bit PWM giao tiếp $I^2 C$, cắm chồng lên Uno],
  [9], [Vi điều khiển], [1], [Arduino Uno R3],
  [10], [Nguồn ngoài 6V], [1], [Nguồn $6"V" >= 8"A"$ tách riêng cho servo],
)

= Thiết kế cơ khí trên SolidWorks
Cánh tay là bản sao KUKA KR 3 R540 ở tỉ lệ $0.49$:
1. *Khối thân KUKA*: Mỗi khâu (đế, turret, cánh tay trên) lấy trực tiếp một khối của mô hình KUKA, giữ nguyên dáng ngoài và hệ toạ độ.
2. *Khoét chỗ cho phần cứng*: Hốc servo cỡ chuẩn $40 times 20 "mm"$ đặt nghiêng $15 degree$ theo dáng tai, lỗ ren cấy nhiệt M3, ổ vòng bi 698ZZ, hốc đĩa sừng 25T.
3. *Đế chứa mạch*: Đế khoét rỗng, servo $J_1$ treo dưới trần, Arduino Uno và shield PCA9685 nằm trên khay đáy; cổng USB mở ra mặt sau.
4. *Khớp đế*: Turret tựa trên mặt đế bằng ngõng trục $phi 49$ và vành chân $phi 92$ (ổ trượt nhựa), mô-men xoắn truyền qua đĩa sừng 25T.
5. *Kiểm tra va chạm*: Xuất lưới STL từng chi tiết và kiểm tra bằng số, kết hợp Interference Detection của SolidWorks.

= Hệ thống Điện & Điều khiển
Kiến trúc điều khiển phân tầng Master - Slave:
- *Tầng Master (PC)*: Ứng dụng giao diện 3D (Digital Twin) viết bằng Python (PyQt/CustomTkinter) hoặc MATLAB App Designer. Tự động giải thuật toán động học ngược (IK) giải tích theo thời gian thực và xuất dữ liệu góc khớp qua cổng Serial UART.
- *Tầng Slave (Vi điều khiển)*: Nhận dữ liệu góc qua Serial, truyền tín hiệu điều khiển góc đến các kênh của mạch đệm PCA9685 qua $I^2 C$, thực hiện thuật toán làm mượt quỹ đạo nội suy chống rung giật.

= Phân công công việc
#table(
  columns: (1fr, 1.5fr, 3fr),
  [*Thành viên*], [*Vai trò*], [*Nhiệm vụ cụ thể*],
  [Nguyễn Thanh Thế], [Cơ khí & Thiết kế CAD], [Thiết kế 3D trên SolidWorks, in 3D, lắp ráp cơ cấu khớp & tay gắp],
  [Điền tên TV 2], [Điện tử & Firmware], [Sơ đồ nguyên lý mạch, nguồn PCA9685, nạp firmware điều khiển khớp],
  [Điền tên TV 3], [Phần mềm & Tích hợp], [Giao diện điều khiển 3D trên PC, giải thuật IK, đo kiểm và báo cáo],
)

= Kết luận
Bản thiết kế cánh tay robot công nghiệp 5-DOF đã giải quyết trọn vẹn bài toán kỹ thuật đặt ra: đảm bảo tầm với vượt chuẩn $342 "mm"$, khớp vai dùng servo số 25 kg, cơ cấu cổ tay 2 bậc tự do linh hoạt xử lý mọi góc xoay của vật thể hình sao và hình vuông, đồng thời sở hữu kiểu dáng công nghiệp hiện đại và tính khả thi chế tạo cao bằng công nghệ in 3D FDM.

#v(20pt)
#align(center)[-- Hết --]