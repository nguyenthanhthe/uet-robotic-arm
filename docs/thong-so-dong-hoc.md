# Bảng Thông Số Động Học & Động Lực Học — Cánh Tay Robot 5-DOF UET

> **Kiến trúc cơ sở:** KUKA KR 3 R540 (tỉ lệ 0.49, dùng trực tiếp các khối thân KUKA)  
> **Cấu hình khớp:** 5 Bậc tự do (5-DOF) Articulated + 1 Khâu kẹp song song (Gripper)  
> **Phần cứng điều khiển:** Arduino Uno R3 + shield PCA9685 16 kênh PWM + nguồn riêng 6.0V từ 8A cho servo

---

## 1. Kích Thước Hình Học Chuẩn Hóa Khung Robot (CAD Redesign)

Dựa trên đế `01_Base_Kuka` và tỷ lệ chuẩn KUKA KR3 R540:

| Ký hiệu | Thông số cơ học | Giá trị thiết kế | Mô tả & Bằng chứng CAD |
|---|---|:---:|---|
| $D_{\text{base}}$ | Đường kính ngoài trụ đế | **$\varnothing 90\text{ mm}$** | Trụ đế KUKA, lòng khoét $\varnothing 81\text{ mm}$; hộp sau rộng $74\text{ mm}$, chân đế phủ $121 \times 91\text{ mm}$ |
| $H_{\text{base}}$ | Chiều cao đế | **$90.45\text{ mm}$** | Đế `01_Base_Kuka` (thân đế KUKA khoét rỗng), mặt tựa turret ở $90.45\text{ mm}$ |
| $h_0$ | Đáy bàn $\to$ Trục khớp vai $J_2$ | **$169.05\text{ mm}$** | Đúng cao độ trục vai của KUKA KR 3 R540 ở tỉ lệ $0.49$: đế `01_Base_Kuka` cao $90.45\text{ mm}$, turret `02_Turret_ForkKuka` đặt trực tiếp lên đế |
| $a_1$ | Trục đế $J_1$ $\to$ Trục vai $J_2$ (phương ngang) | **$9.8\text{ mm}$** | Trục $J_2$ lệch về phía trước trục $J_1$ như KUKA KR 3 |
| $L_1$ | Trục vai $J_2$ $\to$ Trục khuỷu $J_3$ | **$127.4\text{ mm}$** | Khâu Upper Arm (Cánh tay dưới) |
| $L_2$ | Trục khuỷu $J_3$ $\to$ Trục cổ tay $J_4$ | **$127.8\text{ mm}$** | Khâu Forearm (Cẳng tay trên); đo trên assembly từ $J_3$ tại $(9.8, 296.45)$ tới $J_4$ tại $(137.2, 306.23)$, đường nối hai trục lệch $4.39^\circ$ so với trục thân cẳng tay |
| $L_3$ | Trục cổ tay $J_4$ $\to$ Tâm ngón gắp | **$86.8\text{ mm}$** | Cụm cổ tay 2 trục + Tay gắp song song; tâm gắp là rãnh chữ V của ngón kẹp trên trục $J_5$ (mút ngón cách $J_4$ $107.8\text{ mm}$) |
| $R_{\max}$ | Tầm với duỗi thẳng cực đại | **$342.0\text{ mm}$** | $L_1 + L_2 + L_3 = 127.4 + 127.8 + 86.8$ (Vượt yêu cầu $\ge 200\text{ mm}$) |
| $R_{\text{eff}}$ | Tầm với hiệu dụng khi gắp đứng | **$255.2\text{ mm}$** | $L_1 + L_2 = 127.4 + 127.8$ (Bao phủ hoàn toàn bàn làm việc) |

---

## 2. Bảng Tham Số Denavit–Hartenberg (D-H Tiêu Chuẩn)

Hệ toạ độ đặt theo chuẩn KUKA/ABB công nghiệp:
- Trục $z_0$: Trục quay đế (Base Yaw), hướng thẳng đứng lên trên.
- Trục $x_1, x_2, x_3$: Vuông góc với trục khớp, song song mặt phẳng gập của vai và khuỷu.

| Khớp $i$ | Tên khớp | Biến khớp $\theta_i$ | $d_i$ (mm) | $a_i$ (mm) | $\alpha_i$ (rad) | Giới hạn góc quay |
|:---:|---|:---:|:---:|:---:|:---:|:---:|
| **1** | Base Yaw (Xoay thân) | $\theta_1^*$ | $h_0 = 169.05$ | $a_1 = 9.8$ | $+\pi/2$ | $-90^\circ \to +90^\circ$ |
| **2** | Shoulder Pitch (Gập vai) | $\theta_2^*$ | $0$ | $L_1 = 127.4$ | $0$ | $-45^\circ \to +105^\circ$ |
| **3** | Elbow Pitch (Gập khuỷu) | $\theta_3^*$ | $0$ | $L_2 = 127.8$ | $0$ | $-90^\circ \to +75^\circ$ |
| **4** | Wrist Pitch (Gập cổ tay) | $\theta_4^*$ | $0$ | $0$ | $+\pi/2$ | $-90^\circ \to +90^\circ$ |
| **5** | Wrist Roll (Xoay đầu gắp) | $\theta_5^*$ | $L_3 = 86.8$ | $0$ | $0$ | $-90^\circ \to +90^\circ$ |

---

## 3. Động Học Thuận & Động Học Ngược (Kinematics Solvers)

### 3.1. Phương trình Động học Thuận (Forward Kinematics)
Toạ độ tâm điểm gắp phôi $(x_e, y_e, z_e)$ trong không gian Descartes:
$$r_e = a_1 + L_1 \cos\theta_2 + L_2 \cos(\theta_2 + \theta_3) + L_3 \cos(\theta_2 + \theta_3 + \theta_4)$$
$$\begin{cases}
x_e = r_e \cos\theta_1 \\
y_e = r_e \sin\theta_1 \\
z_e = h_0 + L_1 \sin\theta_2 + L_2 \sin(\theta_2 + \theta_3) + L_3 \sin(\theta_2 + \theta_3 + \theta_4)
\end{cases}$$

### 3.2. Động học Ngược Giải tích (Closed-form Analytical Inverse Kinematics)
Với góc tiếp cận phôi thẳng đứng từ trên xuống ($\theta_{\text{pitch}} = -90^\circ$):
1. **Góc xoay đế:** $\theta_1 = \text{atan2}(y, x)$
2. **Tách tâm cổ tay ($r_w, z_w$):**
   $$r_w = \sqrt{x^2 + y^2} - a_1 - L_3 \cos(\theta_{\text{pitch}})$$
   $$z_w = z - h_0 - L_3 \sin(\theta_{\text{pitch}})$$
   $$D^2 = r_w^2 + z_w^2$$
3. **Góc khuỷu $\theta_3$:**
   $$\cos\theta_3 = \frac{D^2 - L_1^2 - L_2^2}{2 L_1 L_2} \implies \theta_3 = -\arccos(\cos\theta_3)$$
4. **Góc vai $\theta_2$:**
   $$\theta_2 = \text{atan2}(z_w, r_w) + \text{atan2}(L_2 \sin(-\theta_3), L_1 + L_2 \cos(-\theta_3))$$
5. **Góc cổ tay $\theta_4$:**
   $$\theta_4 = \theta_{\text{pitch}} - (\theta_2 + \theta_3)$$

---

## 4. Tĩnh Học & Phân Bổ Động Cơ (Torque & Actuator Selection)

### 4.1. Tính toán mô-men xoắn xấu nhất tại Khớp Vai (J2 - Shoulder)
Xét tư thế nguy hiểm nhất khi toàn bộ cánh tay vươn dài nằm ngang song song mặt bàn ($R_{\max} = 0.342\text{ m}$):
- Tải trọng gắp vật mẫu ($m_{\text{payload}} = 50\text{ g} = 0.05\text{ kg}$):
  $$T_{\text{payload}} = 0.05 \times 9.81 \times 0.342 \approx 0.168\text{ N}\cdot\text{m} \approx \mathbf{1.71\text{ kg}\cdot\text{cm}}$$
- Khối lượng phần chuyển động sau trục vai ($m_{\text{arm}} \approx 0.554\text{ kg}$, trọng tâm chung tại $r_{\text{cg}} \approx 0.161\text{ m}$):
  $$T_{\text{arm}} = 0.554 \times 9.81 \times 0.161 \approx 0.874\text{ N}\cdot\text{m} \approx \mathbf{8.91\text{ kg}\cdot\text{cm}}$$
- Tổng mô-men tĩnh: $T_{\text{static}} = 1.71 + 8.91 = \mathbf{10.62\text{ kg}\cdot\text{cm}}$.
- Mô-men động học cần thiết (kèm hệ số gia tốc $k = 1.8$):
  $$T_{\text{dynamic}} = 10.62 \times 1.8 \approx \mathbf{19.12\text{ kg}\cdot\text{cm}}$$

Khối lượng từng khâu lấy từ thể tích và trọng tâm đo trên `00_Robot_J1J2_Assembly`, quy đổi theo thông số in PETG ($1.27\text{ g/cm}^3$, 4 lớp thành, infill $20\%$ cho khối thân lớn và $35\%$ cho chi tiết nhỏ), cộng khối lượng servo theo datasheet; chưa gồm ốc vít và dây điện:

| Khâu | Thành phần | Khối lượng | Trọng tâm tính từ trục đầu khâu |
|---|---|:---:|:---:|
| $J_2 \to J_3$ | `03_UpperArmKuka` + MG996R của $J_3$ | $243\text{ g}$ | $72.8\text{ mm}$ |
| $J_3 \to J_4$ | Hai nửa cẳng tay, hai tấm ốp, đĩa sừng $J_3$, MG90S của $J_4$ | $180\text{ g}$ | $58.4\text{ mm}$ |
| $J_4 \to$ tâm gắp | `05_WristKuka`, tay gắp, MG90S của $J_5$ và của tay gắp | $131\text{ g}$ | $36.3\text{ mm}$ |

Cùng tư thế đó, mô-men tĩnh tại khuỷu $J_3$ là $4.26\text{ kg}\cdot\text{cm}$ và tại cổ tay $J_4$ là $0.91\text{ kg}\cdot\text{cm}$. Phép tính đầy đủ nằm trong `matlab/kuka_robot_model.m`.

### 4.2. Lựa chọn Động cơ & Hệ số An toàn (Safety Factor)

Mô-men yêu cầu của $J_2$, $J_3$, $J_4$ là mô-men động ($k = 1.8$) ở tư thế duỗi ngang; hệ số an toàn tính trên mô-men động đó.

| Khớp | Động cơ khuyến nghị | Mô-men xoắn danh định (ở 6.0V) | Mô-men yêu cầu | Hệ số an toàn (SF) | Đánh giá |
|:---:|---|:---:|:---:|:---:|---|
| **J1 (Đế)** | **TowerPro MG996R** | $11.0 - 13.0\text{ kg}\cdot\text{cm}$ | $\approx 3.0\text{ kg}\cdot\text{cm}$ (ma sát trượt) | $\text{SF} > 3.5$ | Dư tải lớn, xoay nhẹ nhàng |
| **J2 (Vai)** | **Servo Digital 25KG-180°** (cỡ vỏ $40 \times 20$, trục 25T) | **$\approx 22\text{ kg}\cdot\text{cm}$ ở 6.0V** | $19.12\text{ kg}\cdot\text{cm}$ (tĩnh $10.62$) | **$\text{SF} \approx 1.15$** (tĩnh $2.07$) | **Giữ tư thế duỗi ngang dư tải gấp đôi nhưng biên động mỏng: giới hạn gia tốc khi duỗi hết tầm. MG996R ($11\text{ kg}\cdot\text{cm}$) chỉ vừa bằng mô-men tĩnh nên không dùng được** |
| **J3 (Khuỷu)**| **TowerPro MG996R** | $11.0 - 13.0\text{ kg}\cdot\text{cm}$ | $7.68\text{ kg}\cdot\text{cm}$ (tĩnh $4.26$) | $\text{SF} \approx 1.43$ (tĩnh $2.58$) | Đáp ứng |
| **J4 (Cổ tay)**| **MG90S** | $2.2\text{ kg}\cdot\text{cm}$ | $1.63\text{ kg}\cdot\text{cm}$ (tĩnh $0.91$) | $\text{SF} \approx 1.35$ (tĩnh $2.42$) | Đáp ứng |
| **J5 (Xoay)** | **MG90S** | $2.2\text{ kg}\cdot\text{cm}$ | $\approx 0.3\text{ kg}\cdot\text{cm}$ | $\text{SF} > 5$ | Rất nhẹ tải |
| **Gripper** | **MG90S** | $2.2\text{ kg}\cdot\text{cm}$ | $\approx 0.5\text{ kg}\cdot\text{cm}$ | $\text{SF} > 3.0$ | Kẹp chắc vật thể 20–40mm |

> **Khả năng tương thích cơ khí:** Servo Digital 25KG và TowerPro MG996R đều dùng chung **kích thước vỏ Standard ($40 \times 20 \times 40.5\text{ mm}$)** và **trục đĩa răng 25T**. Bản vẽ CAD hốc lắp hoàn toàn đồng nhất, có thể hoán đổi tùy ý lúc lắp ráp mà không cần sửa mô hình 3D!
