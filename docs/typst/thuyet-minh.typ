#set text(lang: "vi", font: "New Computer Modern", size: 11pt)
#set par(justify: true)
#set heading(numbering: "1.1")

#align(center)[
  #text(20pt, weight: "bold")[CÁC CƠ CẤU CHẤP HÀNH ROBOT]\
  #v(4pt)
  #text(16pt)[*Thuyết minh thiết kế cánh tay robot có tay gắp*]
  #v(8pt)
  #text(12pt)[Nhóm: _điền tên_ — Khoa CN, Đại học Công nghệ, ĐHQG HN]
]

#v(12pt)
#outline(title: "Mục lục", depth: 2)

= Giới thiệu
Mục tiêu, phạm vi và nhiệm vụ gắp–thả vật đa hình dạng (sao, vuông, tròn) vào lỗ tương ứng.
Chi tiết yêu cầu xem `docs/yêu-cầu-kỹ-thuật.md`.

= Yêu cầu kỹ thuật
#table(
  columns: (2fr, 1fr, 3fr),
  [Thông số], [Giá trị mục tiêu], [Ghi chú],
  [Tầm với], [>= 200 mm], [đo từ trục đế đến tâm đầu gắp],
  [Tải trọng], [>= 50 g], [ở tư thế duỗi thẳng ngang],
  [Độ lặp lại], ["+-0.5 mm"], [đo 10 chu kỳ, ISO 9283 tinh gọn],
  [Backlash khớp], ["<= 0.5 deg"], [servo răng kim loại + ổ bi],
  [Số DOF], [4 + 1], [base/shoulder/elbow/wrist + gripper],
  [Chu kỳ gắp–thả], ["<= 15 s"], [mục tiêu demo],
)

= Động học và định kích thước
WIP: thông số link từ tầm với 200 mm, sơ đồ workspace, forward kinematics.

= Chọn truyền động và servo
WIP: tính mô-men khớp tư thế xấu nhất, hệ số an toàn, bảng BOM (tham khảo `docs/BOM.csv`).

= Thiết kế cơ khí (CAD)
WIP: thiết kế trên Onshape (công cụ MCP `onshape`), file export tại `cad/exports/`.

= Điện & firmware
WIP: Arduino Nano + nguồn servo tách, điều khiển serial/nút bấm, Teaching Mode.

= Lắp ráp, hiệu chuẩn và đo kiểm
WIP: homing, offset servo, bảng đo repeatability (`docs/test-report.md`).

= Phân công công việc
#table(
  columns: (1fr, 1.5fr, 3fr),
  [Thành viên], [Vai trò], [Nhiệm vụ],
  [_điền tên_], [Cơ khí / CAD], [In 3D, lắp ráp, khớp, gripper],
  [_điền tên_], [Điện – firmware], [Mạch, nguồn, Arduino, Teaching Mode],
  [_điền tên_], [Tích hợp – kiểm thử], [Camera (tùy chọn), đo kiểm, video, tài liệu],
)

= Kết luận
WIP.

#v(20pt)
#align(center)[-- Hết --]