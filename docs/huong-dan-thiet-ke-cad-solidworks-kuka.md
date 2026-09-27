# CẨM NANG THIẾT KẾ CAD 3D ROBOT KUKA KR 3 R540 TRÊN SOLIDWORKS
**Dự án:** Cánh tay robot 5-DOF + Khâu kẹp song song (UET Robotics Arm)  
**Tác giả:** Nhóm đồ án UET & Antigravity Copilot  
**Phần mềm:** SolidWorks (Phiên bản 2026 / 2022+ tương thích hoàn toàn)  
**Tiêu chuẩn chế tạo:** In 3D FDM (nhựa PLA/PETG), dùng vòng bi 698ZZ, ốc M3, vít tự ren M2, đĩa sừng nhôm 25T.

---

## I. CÁC THÔNG SỐ ĐỘNG HỌC & QUY CHUẨN CƠ KHÍ BẮT BUỘC

### 1. Bảng kích thước động học bất biến (D-H Invariants)
Tất cả kích thước hình học dưới đây bắt buộc phải tuân thủ nghiêm ngặt để khớp $100\%$ với mô hình toán học trong thuyết minh và code điều khiển:

| Ký hiệu | Ý nghĩa hình học | Giá trị thiết kế | Ghi chú vị trí |
| :--- | :--- | :--- | :--- |
| **$h_0$** | Chiều cao trục quay vai $J_2$ so với mặt bàn | **$80.0\text{ mm}$** | Chân đế $46\text{ mm}$ + Chiều cao tâm chữ U Turret $34\text{ mm}$ |
| **$L_1$** | Chiều dài cánh tay trên (Upper Arm - Link 1) | **$110.0\text{ mm}$** | Khoảng cách tâm khớp vai $J_2 \to$ tâm khớp khuỷu $J_3$ |
| **$L_2$** | Chiều dài cẳng tay (Forearm - Link 2) | **$100.0\text{ mm}$** | Khoảng cách tâm khớp khuỷu $J_3 \to$ tâm cổ tay gập $J_4$ |
| **$L_3$** | Chiều dài cụm cổ tay & kẹp (Wrist & End-Effector) | **$55.0\text{ mm}$** | Tâm $J_4 \to$ tâm điểm gắp của đầu ngón kẹp |

### 2. Quy chuẩn dung sai in 3D (DFM for 3D Printing)
* **Tuyệt đối không vẽ ren xoắn trên CAD:** Đầu phun in 3D $0.4\text{ mm}$ không in được bước ren $0.5\text{ mm}$. Tất cả các lỗ trên CAD đều là **LỖ TRÒN TRƠN**.
* **Ổ đỡ vòng bi 698ZZ ($OD=19.0, ID=8.0, B=6.0\text{ mm}$):** Lỗ CAD vẽ $\varnothing 19.10\text{ mm}$, sâu $6.2\text{ mm}$ (dư $0.1\text{ mm}$ bù co ngót nhựa, ấn nhẹ vào khít cứng).
* **Trục cắm vào vòng bi 698ZZ:** Vẽ $\varnothing 8.0\text{ mm}$ dài $5.5 - 6.0\text{ mm}$ (trục lọt trơn khít vào ca trong vòng bi).
* **Lỗ xỏ ốc M3 qua thân nhựa:** Vẽ $\varnothing 3.2\text{ mm}$ (khi in ra lỗ tự co về $\approx 3.0\text{ mm}$ xỏ vừa khít thân ốc).
* **Lỗ mồi vít tự ren tai servo MG90S/SG90:** Vẽ $\varnothing 2.0\text{ mm}$, sâu $8.0\text{ mm}$ (vít nhọn theo hộp servo tự cán ren vào nhựa).
* **Lỗ chân đế bắt bàn gỗ M4:** Vẽ $\varnothing 4.3\text{ mm}$ xỏ bulong M4.

---

## II. QUÁ TRÌNH THIẾT KẾ TỪNG CHI TIẾT TRÊN SOLIDWORKS

---

### CHI TIẾT 1: `01_Base_Pedestal.SLDPRT` (Chân đế tĩnh $J_1$ tích hợp Hộp mạch Arduino)
*Nhiệm vụ: Cố định cánh tay xuống bàn làm việc, chứa thân servo MG996R quay đế $J_1$, đỡ vòng bi 698ZZ chịu lực dọc trục, và tích hợp khoang kỹ thuật chứa trọn vẹn bo mạch Arduino Uno R3 + Shield PCA9685.*

1. **Khối mặt bích đế (Flange):**
   * Mở Sketch trên `Top Plane`.
   * Lệnh `Center Rectangle`: kích thước $90.0 \times 90.0\text{ mm}$.
   * Bo 4 góc: Lệnh `Fillet` bán kính $R = 10.0\text{ mm}$.
   * 4 lỗ bắt bàn: Lệnh `Circle`, vẽ 4 lỗ $\varnothing 4.3\text{ mm}$ tại tâm của 4 góc bo (khoảng cách tâm $72 \times 72\text{ mm}$).
   * Tab **Features** $\rightarrow$ `Extruded Boss/Base` đùn lên cao: **$10.0\text{ mm}$**.
2. **Khối trụ thân tháp:**
   * Mở Sketch trên mặt trên của bích đế vừa tạo.
   * Lệnh `Circle`, tâm trùng Origin, đường kính $\varnothing 72.0\text{ mm}$.
   * Tab **Features** $\rightarrow$ `Extruded Boss/Base` đùn lên cao: **$36.0\text{ mm}$** (Tổng chiều cao = $10 + 36 = 46.0\text{ mm}$).
3. **Hốc servo MG996R (Khoét từ đáy lên):**
   * Xoay góc nhìn nhìn vào mặt đáy dưới cùng của đế. Mở Sketch trên mặt đáy.
   * Vẽ đường tròn tâm Origin đường kính $\varnothing 64.0\text{ mm}$.
   * Tab **Features** $\rightarrow$ `Extruded Cut` sâu **$36.0\text{ mm}$** (chừa lại trần trên cùng dày $10\text{ mm}$).
4. **Ổ chứa vòng bi 698ZZ ở đỉnh tháp:**
   * Mở Sketch trên mặt phẳng tròn trên cùng của trụ $\varnothing 72\text{ mm}$.
   * Vẽ 2 đường tròn đồng tâm:
     * Vòng ngoài: $\varnothing 19.10\text{ mm}$ (ổ đỡ vòng bi 698ZZ).
     * Vòng trong: $\varnothing 12.0\text{ mm}$ (lỗ thoát trục servo).
   * Tab **Features** $\rightarrow$ `Extruded Cut`:
     * Với vòng $\varnothing 19.10\text{ mm}$: Cắt sâu **$6.2\text{ mm}$** (tạo gờ vai chặn vòng bi).
     * Với vòng trong $\varnothing 12.0\text{ mm}$: Cắt `Through All` thông thẳng xuống hốc servo.
5. **Khoang hộp kỹ thuật chứa Arduino Uno R3 + Shield PCA9685 (Phía sau đế):**
   * Mở Sketch trên mặt sau của bích đế (hoặc `Top Plane` bắt cạnh sau của bích $90\text{ mm}$).
   * Vẽ hình chữ nhật kích thước ngoài: Rộng $75.0\text{ mm} \times$ Dài nhô ra sau $60.0\text{ mm}$.
   * `Extruded Boss/Base` đùn lên cao bằng độ cao tháp: **$35.0\text{ mm}$**.
   * Khoét rỗng hộp: `Shell` hoặc `Extruded Cut` tạo lòng trong $69.0 \times 54.0\text{ mm}$ sâu $31.0\text{ mm}$ (thành dày $3.0\text{ mm}$, đáy dày $4.0\text{ mm}$).
   * **4 trụ bắt ốc Arduino Uno:** Đùn 4 trụ tròn $\varnothing 6.0\text{ mm}$ cao $4.0\text{ mm}$, lỗ trong $\varnothing 2.8\text{ mm}$ bắt vít M3 tại các tọa độ chuẩn của Arduino ($50.8 \times 27.9\text{ mm}$).
   * **Cửa sổ cổng USB Type-B:** Cắt lỗ chữ nhật $13.0 \times 12.0\text{ mm}$ ở thành hông/sau để cắm cáp USB vào laptop.
   * **Cửa sổ giắc nguồn DC 5V-6V:** Cắt lỗ $\varnothing 10.0\text{ mm}$ (hoặc rãnh cọc ốc $12.0 \times 10.0\text{ mm}$) để cắm nguồn ngoài cấp cho servo.
   * **Rãnh luồn dây ngầm:** Cắt rãnh $15.0 \times 8.0\text{ mm}$ thông từ khoang hộp vào lòng trụ $\varnothing 64\text{ mm}$ của khớp $J_1$.

---

### CHI TIẾT 2: `02_Base_Turret.SLDPRT` (Mâm xoay chữ U $J_1 \to J_2$)
*Nhiệm vụ: Xoay tròn quanh trục đứng $Z_0$, làm giá đỡ chữ U ôm lấy khớp vai $J_2$, một bên bắt servo MG996R, một bên lắp vòng bi 698ZZ.*

1. **Khối đĩa mâm và phôi thân:**
   * Mở Sketch trên `Top Plane`. Vẽ đường tròn $\varnothing 68.0\text{ mm}$.
   * `Extruded Boss/Base` đùn lên cao **$50.0\text{ mm}$**.
2. **Trục lồi cắm vào vòng bi đế:**
   * Mở Sketch ở mặt đáy dưới cùng của đĩa mâm.
   * Vẽ đường tròn tâm Origin $\varnothing 8.0\text{ mm}$.
   * `Extruded Boss/Base` đùn xuống dưới **$5.5\text{ mm}$** (trục này cắm ngập vào ca trong vòng bi 698ZZ của Chi tiết 1).
3. **Khoét rãnh chữ U (U-Fork Cutout):**
   * Mở Sketch trên `Front Plane` (mặt phẳng đi qua tâm đối xứng).
   * Dùng `Corner Rectangle` hoặc `Line`: Vẽ hình chữ nhật khoét bỏ phần giữa:
     * Bề rộng lọt lòng khe: **$44.0\text{ mm}$** (đối xứng đều 2 bên tâm, mỗi bên $22.0\text{ mm}$).
     * Chiều sâu khoét từ trên xuống: **$34.0\text{ mm}$** (tính từ đỉnh $50\text{ mm}$ xuống còn cao $16\text{ mm}$ tính từ đáy).
   * Tab **Features** $\rightarrow$ `Extruded Cut` chọn `Through All - Both`.
   * Lệnh `Fillet`: Bo tròn đáy rãnh chữ U bán kính $R = 10.0\text{ mm}$ và bo vòm tròn 2 tai trên $R = 5.0\text{ mm}$.
4. **Trục khớp vai $J_2$ (Cách đáy đĩa mâm đúng $34.0\text{ mm}$):**
   * Mở Sketch trên mặt ngoài của một tai chữ U.
   * Vẽ đường tròn $\varnothing 8.5\text{ mm}$ tại vị trí cách đáy đĩa mâm đúng **$34.0\text{ mm}$** ($h_0 = 46 + 34 = 80.0\text{ mm}$ tuyệt đối).
   * `Extruded Cut` chọn `Through All` xuyên qua cả 2 tai.
5. **Ổ đỡ vòng bi 698ZZ tai trái:**
   * Mở Sketch trên mặt TRONG của tai trái.
   * Bắt đúng tâm lỗ $\varnothing 8.5\text{ mm}$, vẽ đường tròn $\varnothing 19.10\text{ mm}$.
   * `Extruded Cut` sâu **$6.2\text{ mm}$** (để lại bậc chặn giữ vòng bi không bị trượt ra ngoài).

---

### CHI TIẾT 3: `03_UpperArm_Frame.SLDPRT` (Cánh tay chính Link 1 $J_2 \to J_3$)
*Nhiệm vụ: Cánh tay chịu lực lớn nhất của robot, nối từ vai lên khuỷu, chiều dài hình học $L_1 = 110.0\text{ mm}$.*

1. **Khối thân dạng khúc xương (Dog-bone Beam):**
   * Mở Sketch trên `Front Plane`.
   * Vẽ đường tròn dưới: tâm tại $(0,0)$, đường kính $\varnothing 40.0\text{ mm}$.
   * Vẽ đường tròn trên: tâm tại $(0, 110.0)$, đường kính $\varnothing 32.0\text{ mm}$.
   * Vẽ 2 đường thẳng tiếp tuyến (`Tangent`) nối 2 đường tròn.
   * Dùng `Trim Entities` (`Trim to closest`) cắt bỏ 2 cung tròn bên trong.
   * Tab **Features** $\rightarrow$ `Extruded Boss/Base`: chọn **`Mid Plane`**, chiều dày **$43.0\text{ mm}$** (khe Turret là $44\text{ mm}$, làm $43\text{ mm}$ để hở $0.5\text{ mm}$ mỗi bên quay trơn tru).
2. **Khớp vai $J_2$ - Mặt sau (Khớp đĩa sừng nhôm 25T):**
   * Mở Sketch trên mặt phẳng lớn phía sau tại đầu $\varnothing 40\text{ mm}$.
   * Vẽ hốc đĩa sừng: Đường tròn $\varnothing 21.5\text{ mm}$ đồng tâm $(0,0)$ $\rightarrow$ `Extruded Cut` sâu **$2.5\text{ mm}$**.
   * Mở Sketch trên mặt đáy hốc vừa cắt:
     * Vẽ lỗ tâm $\varnothing 6.0\text{ mm}$ (xỏ tuốc-nơ-vít siết ốc trục).
     * Vẽ vòng tròn chia tâm PCD $\varnothing 14.0\text{ mm}$ (chọn `For construction`).
     * Vẽ 4 lỗ $\varnothing 3.2\text{ mm}$ cách đều $90^\circ$ bằng lệnh `Circular Sketch Pattern`.
     * `Extruded Cut` chọn **`Blind: 10.0 mm`** (chỉ cắt sâu $10\text{ mm}$, không cắt xuyên qua mặt bên kia).
3. **Khớp vai $J_2$ - Mặt trước (Trục lồi cắm vòng bi 698ZZ):**
   * Mở Sketch trên mặt phẳng lớn phía trước tại đầu $\varnothing 40\text{ mm}$.
   * Bắt tâm $(0,0)$, vẽ đường tròn $\varnothing 8.0\text{ mm}$.
   * `Extruded Boss/Base` đùn nhô ra **$6.0\text{ mm}$** (cắm khít vào vòng bi 698ZZ của Turret).
4. **Khớp khuỷu $J_3$ - Mặt trước (Hốc servo MG90S):**
   * Mở Sketch trên mặt phẳng lớn phía trước tại đầu $\varnothing 32\text{ mm}$.
   * Vẽ khung chữ nhật thân servo: Rộng ngang $12.8\text{ mm}$, Dài dọc $23.5\text{ mm}$.
   * Định vị: Mép trên cách tâm cung tròn $(0, 110)$ đúng **$6.0\text{ mm}$**, mép dưới cách tâm **$17.5\text{ mm}$** (đảm bảo trục răng MG90S trùng tuyệt đối tâm $(0, 110)$).
   * `Extruded Cut` sâu **$18.0\text{ mm}$**.
   * Mở Sketch trên mặt phẳng này, vẽ 2 lỗ mồi $\varnothing 2.0\text{ mm}$ bắt vít tai servo: 1 lỗ cách mép trên $2.6\text{ mm}$, 1 lỗ cách mép dưới $2.6\text{ mm}$ $\rightarrow$ `Extruded Cut` sâu **$8.0\text{ mm}$**.

---

### CHI TIẾT 4: `04_Forearm_Body.SLDPRT` (Cẳng tay Link 2 $J_3 \to J_4$)
*Nhiệm vụ: Nối từ khuỷu tay đến cổ tay, chiều dài hình học $L_2 = 100.0\text{ mm}$, gắn lệch bên (Offset layout KUKA), mang theo servo MG90S thứ hai cho khớp cổ tay $J_4$.*

1. **Khối thân dầm cẳng tay:**
   * Mở Sketch trên `Front Plane`.
   * Vòng tròn gốc khuỷu ($J_3$): tâm tại $(0,0)$, đường kính $\varnothing 30.0\text{ mm}$.
   * Vòng tròn đầu cổ tay ($J_4$): tâm tại $(100.0, 0)$, đường kính $\varnothing 24.0\text{ mm}$ (Smart Dimension khoảng cách tâm đúng **$100.00\text{ mm}$**).
   * Vẽ 2 đường tiếp tuyến nối 2 vòng tròn $\rightarrow$ Dùng `Trim` cắt 2 cung trong thành hình dầm thon gọn.
   * `Extruded Boss/Base` đùn dày **$18.0\text{ mm}$**.
2. **Đầu khuỷu $J_3$ (Mặt trong - Lắp vào trục servo MG90S của Link 1):**
   * Mở Sketch trên mặt phẳng trong tại tâm $(0,0)$.
   * Vẽ hốc chứa **Cánh sừng chữ thập hoặc sừng đôi MG90S**:
     * Khoét rãnh âm sâu **$2.0\text{ mm}$** ôm vừa khít cánh sừng nylon của MG90S.
     * Vẽ lỗ xuyên tâm $\varnothing 4.0\text{ mm}$ xỏ lọt ốc M2.5 khóa sừng vào trục servo.
3. **Đầu cổ tay $J_4$ (Mặt ngoài - Chứa servo MG90S điều khiển gập cổ tay):**
   * Mở Sketch trên mặt ngoài tại tâm $(100, 0)$.
   * Vẽ hốc chữ nhật $12.8 \times 23.5\text{ mm}$ sâu **$16.0\text{ mm}$**.
   * Tâm trục răng của servo đặt trùng đúng tọa độ $(100.0, 0)$.
   * Khoét 2 lỗ mồi $\varnothing 2.0\text{ mm}$ sâu $6.0\text{ mm}$ bắt tai servo.

---

### CHI TIẾT 5: `05_Wrist_Pitch.SLDPRT` (Khớp lật cổ tay $J_4 \to J_5$)
*Nhiệm vụ: Nhận truyền động từ servo $J_4$ để gập lên/xuống (Pitch), đồng thời mang servo micro thứ ba (SG90/MG90S) xoay tròn cổ tay (Roll).*

1. **Khối bản lề khớp lật:**
   * Dạng tai kẹp (L-bracket hoặc C-clevis) dày $15 - 18\text{ mm}$.
   * Một mặt khoét hốc âm gắn sừng servo MG90S của khớp $J_4$.
2. **Ổ đỡ trục xoay cổ tay $J_5$:**
   * Trục xoay $J_5$ vuông góc với trục $J_4$.
   * Khoét hốc vuông hoặc hốc tròn lắp servo $J_5$ có trục hướng thẳng dọc ra phía trước đầu kẹp.
   * Khoảng cách từ tâm $J_4$ đến mặt bích kẹp: thiết kế chuẩn **$35.0\text{ mm}$**.

---

### CHI TIẾT 6: `06_Parallel_Gripper.SLDPRT` (Khâu kẹp song song tích hợp Ngàm Camera LeRobot)
*Nhiệm vụ: Gắp thả vật thể (khối lập phương, tròn, sao tải trọng $\le 50\text{g}$), đồng thời tích hợp ngàm gá Webcam USB mini góc nhìn thứ nhất (Eye-in-Hand kiểu LeRobot).*

1. **Đế kẹp (Gripper Palm):**
   * Lắp trực tiếp vào đĩa sừng của servo $J_5$.
   * Khe trượt dẫn hướng (Dovetail hoặc rãnh chữ T) cho 2 ngón kẹp chạy trơn tru song song.
2. **Ngàm gá Webcam USB mini (Wrist Camera kiểu Hugging Face LeRobot):**
   * Đúc liền 1 mấu gá nghiêng một góc **$35^\circ - 45^\circ$** ngay phía trên đế kẹp.
   * Kích thước ngàm: Lòng trong $30.0 \times 30.0\text{ mm}$ (vừa vặn module camera USB mạch trần không vỏ, nặng $\approx 8\text{g}$).
   * 2 lỗ ren M2/M2.5 để bắt chặt bo mạch camera hướng mắt nhìn chúc chéo đúng vào khoảng giữa 2 đầu ngón kẹp.
3. **Cơ cấu truyền động kẹp:**
   * Dùng 1 servo micro MG90S kéo cơ cấu đòn bẩy kép (Four-bar linkage) hoặc thanh răng - bánh răng (Rack & Pinion).
   * Chiều dài ngón kẹp: **$20.0\text{ mm}$** (đảm bảo $L_3 = 35 + 20 = 55.0\text{ mm}$ chuẩn toán học).
   * Đầu ngón dán đệm cao su silicon tăng ma sát gắp vật.

---

## III. QUY TRÌNH LẮP RÁP TỔNG THỂ TRÊN SOLIDWORKS (`KUKA_Assembly.SLDASM`)

### 1. Nguyên tắc cố định gốc:
* Chèn chi tiết đầu tiên: `01_Base_Pedestal.SLDPRT`. Click chuột phải chọn **`Fix`** (gắn chặt vào gốc tọa độ Assembly).

### 2. Thiết lập các ràng buộc (Mates) chuẩn động học:
1. **Khớp xoay $J_1$ (Base Turret xoay trên Pedestal):**
   * `Concentric Mate`: Trục lồi $\varnothing 8\text{ mm}$ của Turret đồng tâm với lỗ $\varnothing 19.10\text{ mm}$ của Pedestal.
   * `Coincident Mate`: Mặt đáy đĩa mâm Turret tiếp xúc mặt trên của Pedestal.
2. **Khớp vai $J_2$ (Upper Arm xoay trong lòng Turret):**
   * `Concentric Mate`: Trục lồi $\varnothing 8\text{ mm}$ của Link 1 đồng tâm với lỗ ổ bi bên tai trái Turret.
   * `Distance Mate` (hoặc `Width Mate`): Căn đều khoảng hở $0.5\text{ mm}$ mỗi bên giữa Link 1 ($43\text{ mm}$) và lòng Turret ($44\text{ mm}$).
3. **Khớp khuỷu $J_3$ (Forearm Link 2 xoay trên Link 1):**
   * `Concentric Mate`: Trục răng MG90S ở Link 1 đồng tâm với hốc sừng của Link 2.
   * `Coincident Mate`: Mặt trong Link 2 ốp sát mặt ngoài Link 1.
4. **Khớp cổ tay $J_4, J_5$ & Bộ kẹp:**
   * Tương tự thiết lập các liên kết đồng trục và ốp mặt.

### 3. Kiểm tra va chạm & Góc quay vật lý (Limit Angle Mate):
* Sử dụng công cụ **`Evaluate` $\rightarrow$ `Interference Detection`** để kiểm tra không bị cấn nhựa giữa các khớp.
* Giới hạn góc quay bằng `Advanced Mate` $\rightarrow$ `Angle Mate`:
  * $J_1$: $-90^\circ \to +90^\circ$ (hoặc $0 \to 180^\circ$).
  * $J_2$: $-30^\circ \to +90^\circ$.
  * $J_3$: $-110^\circ \to +10^\circ$.
  * $J_4$: $-90^\circ \to +90^\circ$.
  * $J_5$: $-90^\circ \to +90^\circ$.

---

## IV. BẢN XUẤT FILE ĐỂ CHẾ TẠO IN 3D

Khi hoàn thiện mỗi file `.SLDPRT`, thực hiện xuất 2 định dạng vào thư mục `cad/exports/`:
1. **File STEP (`.step` / `.stp` - AP214):** Định dạng chuẩn lưu trữ mô hình khối trơn chất lượng cao.
2. **File STL (`.stl`):** Đặt độ mịn `Options` $\rightarrow$ `Deviation Tolerance = 0.01 mm`, `Angle Tolerance = 5 deg` để các cung tròn in ra không bị đa giác góc cạnh.
3. Thiết lập thông số cắt lớp (Slicer - Cura / OrcaSlicer):
   * Độ dày lớp (Layer Height): $0.2\text{ mm}$.
   * Độ dày thành (Walls / Perimeters): **4 lớp** ($1.6\text{ mm}$) để bắt ốc vít không bị toác thành.
   * Mật độ độn (Infill): **$30\% - 40\%$ Gyroid** (chịu lực xoắn và uốn cực tốt).
   * Lớp trên/dưới (Top/Bottom layers): 5 lớp.
