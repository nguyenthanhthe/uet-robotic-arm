// Động học và Động lực học cánh tay robot 5-DOF — viết bằng ký hiệu toán Typst
// Kiến trúc KUKA/ABB công nghiệp: Base Yaw -> Shoulder Pitch -> Elbow Pitch -> Wrist Pitch -> Wrist Roll
// Thông số hình học thiết kế mới: L1 = 127.4 mm, L2 = 127.8 mm, L3 = 86.8 mm, h0 = 169.05 mm, a1 = 9.8 mm

#let kinematics-chapter = [
  = Động học cánh tay robot 5-DOF

  == Ký hiệu và tham số Denavit–Hartenberg (D-H)

  Cánh tay robot công nghiệp được thiết kế theo cấu hình chuỗi động học hở nối tiếp (Serial Open Chain) gồm 5 bậc tự do ($5$-DOF) và $1$ cơ cấu kẹp chấp hành cuối:
  - Khớp 1 ($J_1$): xoay thân quanh trục thẳng đứng (*Base Yaw*), biến khớp $theta_1$.
  - Khớp 2 ($J_2$): khớp vai gập/ngửa trong mặt phẳng đứng (*Shoulder Pitch*), biến khớp $theta_2$.
  - Khớp 3 ($J_3$): khớp khuỷu gập trong mặt phẳng đứng (*Elbow Pitch*), biến khớp $theta_3$.
  - Khớp 4 ($J_4$): khớp cổ tay nâng/hạ (*Wrist Pitch*), biến khớp $theta_4$.
  - Khớp 5 ($J_5$): khớp cổ tay xoay trục đối xứng (*Wrist Roll*), biến khớp $theta_5$.

  Biến khớp: $theta_1, theta_2, theta_3, theta_4, theta_5$. Chiều dài các khâu: $h_0$ (chiều cao từ đáy đế đến trục vai), $L_1$ (khâu vai), $L_2$ (khâu cẳng tay), $L_3$ (từ trục cổ tay đến tâm kẹp). Ký hiệu viết gọn: $c_i = cos theta_i$, $s_i = sin theta_i$, $c_"ij" = cos (theta_i + theta_j)$, $s_"ijk" = sin(theta_i + theta_j + theta_k)$.

  Bảng thông số kích thước hình học chính của cánh tay:

  #table(
    columns: (auto, 1fr, 2fr),
    align: (left, center, left),
    table.header([*Ký hiệu*], [*Kích thước*], [*Định nghĩa cơ học*]),
    [$h_0$], [$169.05$ mm], [Mặt đáy bàn $\to$ Tâm trục khớp vai ($J_2$)],
    [$L_1$], [$127.40$ mm], [Khoảng cách trục khớp vai ($J_2$) $\to$ Trục khớp khuỷu ($J_3$)],
    [$L_2$], [$127.80$ mm], [Khoảng cách trục khớp khuỷu ($J_3$) $\to$ Trục khớp cổ tay ($J_4$)],
    [$L_3$], [$86.80$ mm], [Khoảng cách trục khớp cổ tay ($J_4$) $\to$ Tâm điểm gắp phôi],
    [$R_max$], [$342.00$ mm], [Tổng tầm với tối đa khi duỗi thẳng hoàn toàn],
  )

  Bảng tham số Denavit–Hartenberg tiêu chuẩn:

  #table(
    columns: (1fr, 1fr, 1fr, 1fr, 1fr),
    align: center,
    table.header([*Khớp* $i$], [$theta_i$], [$d_i$], [$a_i$], [$alpha_i$]),
    [$1$], [$theta_1^*$], [$h_0 = 169.05$ mm], [$a_1 = 9.8$ mm], [$pi\/2$],
    [$2$], [$theta_2^*$], [$0$], [$L_1 = 127.4$ mm], [$0$],
    [$3$], [$theta_3^*$], [$0$], [$L_2 = 127.8$ mm], [$0$],
    [$4$], [$theta_4^*$], [$0$], [$0$], [$pi\/2$],
    [$5$], [$theta_5^*$], [$L_3 = 86.8$ mm], [$0$], [$0$],
  )

  == Động học thuận (Forward Kinematics)

  Ma trận biến đổi thuần nhất tổng quát giữa hệ toạ độ $i-1$ và $i$:

  $ A_i = mat(
    c_i, -s_i c_alpha, s_i s_alpha, a_i c_i;
    s_i, c_i c_alpha, -c_i s_alpha, a_i s_i;
    0, s_alpha, c_alpha, d_i;
    0, 0, 0, 1
  ) $

  Ma trận biến đổi từ gốc toạ độ $O_0$ đến khâu chấp hành cuối $O_5$:

  $ T_0^5 = A_1 A_2 A_3 A_4 A_5 $

  Do các trục khớp 2, 3, 4 song song nhau trong cùng mặt phẳng đứng, toạ độ điểm gắp $(x_e, y_e, z_e)$ rút gọn về dạng giải tích hình học:

  $ r_e &= a_1 + L_1 c_2 + L_2 c_23 + L_3 c_234 \
    x_e &= r_e cos theta_1 \
    y_e &= r_e sin theta_1 \
    z_e &= h_0 + L_1 s_2 + L_2 s_23 + L_3 s_234 $

  Góc chúc hướng gắp (*Pitch angle*) và góc xoay hướng phôi (*Roll angle*):

  $ theta_"pitch" &= theta_2 + theta_3 + theta_4 \
    theta_"roll"  &= theta_5 $

  == Động học ngược (Inverse Kinematics)

  Cho trước vị trí điểm gắp mong muốn $p = (x, y, z)$, góc chúc $theta_"pitch"$ (thường đặt $-90 degree$ khi tiếp cận thẳng đứng từ trên xuống) và góc xoay $theta_"roll"$:

  === 1. Góc quay thân (Base Yaw)
  $ theta_1 = op("atan2")(y, x) $
  Bán kính phẳng: $r = sqrt(x^2 + y^2)$.

  === 2. Tách toạ độ tâm cổ tay (Wrist Center Decoupling)
  $ r_w &= r - a_1 - L_3 cos(theta_"pitch") \
    z_w &= z - h_0 - L_3 sin(theta_"pitch") \
    D^2 &= r_w^2 + z_w^2 $

  === 3. Khớp khuỷu (Elbow Pitch)
  Áp dụng định luật hàm cos trên tam giác tạo bởi $L_1, L_2, D$:
  $ cos theta_3 &= (D^2 - L_1^2 - L_2^2) / (2 L_1 L_2) \
    theta_3 &= - arccos(cos theta_3) quad ("chọn nghiệm khuỷu gập trên") $

  === 4. Khớp vai (Shoulder Pitch)
  $ alpha &= op("atan2")(z_w, r_w) \
    beta  &= op("atan2")(L_2 sin(-theta_3), L_1 + L_2 cos(-theta_3)) \
    theta_2 &= alpha + beta $

  === 5. Khớp cổ tay (Wrist Pitch & Roll)
  $ theta_4 &= theta_"pitch" - (theta_2 + theta_3) \
    theta_5 &= theta_"roll" $

  Hệ phương trình giải tích trên luôn cho nghiệm duy nhất và xác định tức thời mà không cần lặp ma trận Jacobian, đảm bảo tốc độ phản hồi thời gian thực trên vi điều khiển.

  == Kiểm chứng tầm với và Tĩnh học Mômen tải

  === Kiểm tra tầm với làm việc
  - Tầm với cực đại duỗi thẳng: $R_max = L_1 + L_2 + L_3 = 127.4 + 127.8 + 86.8 = 342.0 "mm"$.
  - Tầm với hiệu dụng trong vùng gắp thẳng đứng ($theta_"pitch" = -90 degree$):
    $R_"effective" = L_1 + L_2 = 127.4 + 127.8 = 255.2 "mm"$.
  - Kết luận: $255.2 "mm" >= 200 "mm"$, hoàn toàn đáp ứng và bao quát toàn bộ vùng gắp phôi và lỗ thả mà không rơi vào điểm kỳ dị biên.

  === Tính toán tĩnh học mômen tại khớp vai (Khớp chịu tải lớn nhất)
  Xét tư thế nguy hiểm nhất: toàn bộ cánh tay vươn thẳng ngang song song mặt bàn.
  - Tải trọng phôi: $m_"payload" = 50 "g" = 0.05 "kg"$, cánh tay đòn $r_"payload" = 0.342 "m"$:
    $ T_"payload" = 0.05 times 9.81 times 0.342 approx 0.168 "N" dot "m" approx 1.71 "kg" dot "cm" $
  - Khối lượng phần chuyển động sau trục vai, gồm cánh tay trên, cẳng tay, cổ tay, tay gắp và các servo $J_3, J_4, J_5$, tay gắp ($m_"arm" approx 0.554 "kg"$, trọng tâm chung tại $r_"cg" approx 0.161 "m"$). Khối lượng lấy từ thể tích đo trên mô hình lắp ráp, quy đổi theo thông số in PETG (4 lớp thành, infill $20%$ cho khối thân lớn và $35%$ cho chi tiết nhỏ):
    $ T_"arm" = 0.554 times 9.81 times 0.161 approx 0.874 "N" dot "m" approx 8.91 "kg" dot "cm" $
  - Tổng mômen tĩnh yêu cầu tại trục khớp vai $J_2$:
    $ T_"total" = T_"payload" + T_"arm" approx 1.71 + 8.91 = 10.62 "kg" dot "cm" $
  - Khả năng chịu tải của servo số 25 kg chọn cho khớp vai (ở 6 V):
    $ T_"servo" = 22.0 "kg" dot "cm" $
  - Hệ số an toàn tĩnh (Safety Factor):
    $ "SF" = T_"servo" / T_"total" = 22.0 / 10.62 approx 2.07 > 1.5 $
  - Khi tính thêm hệ số gia tốc $k = 1.8$, mômen yêu cầu là $19.12 "kg" dot "cm"$ và hệ số an toàn còn $1.15$.

  Hệ số an toàn tĩnh $2.07$ cho thấy servo giữ được tải $50"g"$ ở tầm với tối đa; biên động $1.15$ đòi hỏi giới hạn gia tốc khớp vai khi cánh tay duỗi hết tầm. Cùng tư thế đó, khuỷu $J_3$ chịu $4.26 "kg" dot "cm"$ (MG996R $11 "kg" dot "cm"$, hệ số tĩnh $2.58$) và cổ tay $J_4$ chịu $0.91 "kg" dot "cm"$ (MG90S $2.2 "kg" dot "cm"$, hệ số tĩnh $2.42$).
]