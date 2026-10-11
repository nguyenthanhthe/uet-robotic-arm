# CẨM NANG THIẾT KẾ CAD 3D ROBOT KUKA KR 3 R540 TRÊN SOLIDWORKS
**Dự án:** Cánh tay robot 5-DOF + Khâu kẹp song song (UET Robotics Arm)  
**Tác giả:** Nhóm đồ án UET & Antigravity Copilot  
**Phần mềm:** SolidWorks (Phiên bản 2026 / 2022+ tương thích hoàn toàn)  
**Tiêu chuẩn chế tạo:** In 3D FDM (nhựa PETG), vòng bi 698ZZ đỡ phụ ở khớp vai $J_2$ và khớp khuỷu $J_3$, ren cấy nhiệt và ốc M3, đĩa sừng kim loại 25T.

---

## I. CÁC THÔNG SỐ ĐỘNG HỌC & QUY CHUẨN CƠ KHÍ BẮT BUỘC

### 1. Bảng kích thước động học bất biến (D-H Invariants)
Tất cả kích thước hình học dưới đây bắt buộc phải tuân thủ nghiêm ngặt để khớp $100\%$ với mô hình toán học trong thuyết minh và code điều khiển:

| Ký hiệu | Ý nghĩa hình học | Giá trị thiết kế | Ghi chú vị trí |
| :--- | :--- | :--- | :--- |
| **$h_0$** | Chiều cao trục quay vai $J_2$ so với mặt bàn | **$169.05\text{ mm}$** | Cao độ trục vai của khối KUKA tỉ lệ $0.49$; trục $J_2$ lệch $a_1 = 9.8\text{ mm}$ về phía trước trục $J_1$ |
| **$L_1$** | Chiều dài cánh tay trên (Upper Arm - Link 1) | **$127.4\text{ mm}$** | Khoảng cách tâm khớp vai $J_2 \to$ tâm khớp khuỷu $J_3$ |
| **$L_2$** | Chiều dài cẳng tay (Forearm - Link 2) | **$127.8\text{ mm}$** | Khoảng cách tâm khớp khuỷu $J_3 \to$ tâm cổ tay gập $J_4$ |
| **$L_3$** | Chiều dài cụm cổ tay & kẹp (Wrist & End-Effector) | **$86.8\text{ mm}$** | Tâm $J_4 \to$ tâm gắp tại rãnh chữ V của ngón kẹp ($x = 224$ trong hệ tay gắp) |

### 2. Quy chuẩn dung sai in 3D (DFM for 3D Printing)
* **Tuyệt đối không vẽ ren xoắn trên CAD:** Đầu phun in 3D $0.4\text{ mm}$ không in được bước ren $0.5\text{ mm}$. Tất cả các lỗ trên CAD đều là **LỖ TRÒN TRƠN**.
* **Ổ đỡ vòng bi 698ZZ ($OD=19.0, ID=8.0, B=6.0\text{ mm}$):** Lỗ CAD vẽ $\varnothing 19.10\text{ mm}$, sâu $6.2\text{ mm}$ (dư $0.1\text{ mm}$ bù co ngót nhựa, ấn nhẹ vào khít cứng).
* **Trục qua vòng bi 698ZZ:** Bu-lông M8 × 25 xuyên từ mặt ngoài tai qua vòng bi, có vòng đệm $\varnothing 11 / \varnothing 8.3\text{ mm}$ tì vào vòng trong.
* **Lỗ xỏ ốc M3 qua thân nhựa:** Vẽ $\varnothing 3.2\text{ mm}$ (khi in ra lỗ tự co về $\approx 3.0\text{ mm}$ xỏ vừa khít thân ốc).
* **Hốc servo cỡ chuẩn (MG996R, servo số 25 kg):** ô thân $40.5 \times 20.7\text{ mm}$; 4 lỗ ren cấy nhiệt M3 $\varnothing 4.2 \times 5.5\text{ mm}$ có đáy theo lưới $49.42 \times 9.85\text{ mm}$; rãnh né gân tai servo rộng $2.0$, sâu $2.0\text{ mm}$; nóc hộp số servo cao $8.5\text{ mm}$ trên mặt tai.
* **Lỗ mồi vít tự ren tai servo MG90S:** Vẽ $\varnothing 2.0\text{ mm}$, sâu $8.0\text{ mm}$ (vít nhọn theo hộp servo tự cán ren vào nhựa).
* **Lỗ chân đế bắt bàn gỗ M4:** Vẽ $\varnothing 4.3\text{ mm}$ xỏ bulong M4.

---

## II. QUÁ TRÌNH THIẾT KẾ TỪNG CHI TIẾT TRÊN SOLIDWORKS

---

### CHI TIẾT 1: `01_Base_Kuka.SLDPRT` + `01_Base_Tray.SLDPRT` (Đế tĩnh $J_1$ và khay điện tử)
*Nhiệm vụ: Cố định cánh tay xuống bàn, giữ servo MG996R của khớp đế $J_1$ dưới trần đế và chứa Arduino Uno cùng shield PWM 16 kênh. Mặt trên đế là ổ trượt đỡ turret: vành chân turret tựa trên vành đế nên đế nhận mô-men lật, servo $J_1$ truyền mô-men xoắn qua đĩa sừng 25T.*
*Hệ tọa độ của khối KUKA: $+Z$ lên (mặt bàn tại $z = 0$), $+X$ là hướng vươn, trục $J_1$ là trục $Z$ qua gốc; hộp sau nằm phía $-X$.*

**A. Thân đế `01_Base_Kuka`**
1. **Khối gốc:** Thân đế của mô hình KUKA KR 3 R540 tỉ lệ $0.49$: trụ $\varnothing 90\text{ mm}$ cao $90.16\text{ mm}$, hộp sau tới $x = -75\text{ mm}$, bốn chân bắt bàn với lỗ tại $(\pm 37, \pm 37)\text{ mm}$, hốc ngõng trục $\varnothing 49 \times 4.9\text{ mm}$ ở mặt trên.
2. **Lòng trụ:** Trên `Front Plane`, đường tròn $\varnothing 81.0\text{ mm}$, cắt lên **$77.0\text{ mm}$**. Mặt trần $z = 77$ là mặt tựa tai bắt vít của servo $J_1$.
3. **Lòng hộp sau:** Phần dưới: chữ nhật $x \in [-71.5, -20]$, $y = \pm 27$, cắt từ đáy lên $52\text{ mm}$. Phần trên: chữ nhật $x \in [-69.5, -28]$, $y = \pm 33$, cắt từ $z = 52$ lên $z = 85$.
4. **Chỗ lắp servo $J_1$ (trên mặt trần $z = 77$, servo luồn từ dưới lên, thân hướng về $+X$):** ô thân $40.5 \times 20.7\text{ mm}$ ($x \in [-10.15, 30.35]$) cắt lên $9.5\text{ mm}$; 4 lỗ cấy ren $\varnothing 4.2 \times 5.5\text{ mm}$ tại $(34.811, \pm 4.925)$ và $(-14.611, \pm 4.925)$; 2 rãnh né gân rộng $2.0$, sâu $2.0\text{ mm}$ dọc tâm tai.
5. **Mặt trên:** Nới hốc ngõng trục thành $\varnothing 49.5\text{ mm}$; thêm vành tựa $\varnothing 51 \to \varnothing 88$ cao $0.29\text{ mm}$ (mặt tựa turret tại $z = 90.45$).
6. **Trụ bắt khay:** 2 trụ $\varnothing 10\text{ mm}$ tại $(28, \pm 28)$ từ $z = 8.5$ lên trần, mỗi trụ có lỗ cấy ren $\varnothing 4.2 \times 5.5\text{ mm}$ ở mặt dưới.
7. **Lỗ mặt sau (cắt từ mặt phẳng $x = -80$ vào $12\text{ mm}$):** cổng USB $13 \times 12.2\text{ mm}$ tại $y \in [4.9, 17.9]$, $z \in [19.6, 31.8]$; giắc nguồn $10 \times 12.2\text{ mm}$ tại $y \in [-24, -14]$; lỗ ốc giữ khay $\varnothing 3.4$ tại $(y, z) = (-5, 12.5)$; lỗ dây nguồn servo $\varnothing 8$ tại $(0, 42)$. Dưới cổng USB, rãnh cùng bề rộng $y \in [4.9, 17.9]$ chạy thẳng xuống đáy đế ($z = 0 \to 19.6$) để cổng USB trượt lên khi đưa khay từ dưới vào.
8. **Lỗ dây servo:** $\varnothing 10\text{ mm}$ xuyên trần hộp sau tại $(x, y) = (-56.5, 0)$.
9. **Bỏ hai cọc đầu nối trên nóc hộp sau:** Trên mặt phẳng $z = 89.9\text{ mm}$, chữ nhật $x \in [-63.5, -44.5]$, $y = \pm 21$, cắt lên trên. Mép trước của turret (bán kính $58.4\text{ mm}$, đáy ở $z = 90.65$) quét qua vùng này khi $J_1$ quay.

**B. Khay điện tử `01_Base_Tray`** (dựng trong cùng hệ tọa độ với đế)
1. Tấm dày $2.5\text{ mm}$ ($z = 6 \to 8.5$): đĩa $\varnothing 80.4\text{ mm}$ hợp với chữ nhật $x \in [-71.2, -20]$, $y = \pm 26.7$; lắp từ dưới lên vào lòng đế.
2. 4 trụ đỡ Arduino Uno $\varnothing 5 \times 10\text{ mm}$ với tâm trụ tại $(-54.2, -24.17)$, $(-53.0, 24.13)$, $(-2.2, -19.07)$, $(-2.2, 8.93)$; lỗ mồi $\varnothing 2.5\text{ mm}$ lệch tâm trụ $0.2\text{ mm}$ về phía $-y$, tại $(-54.2, -24.37)$, $(-53.0, 23.93)$, $(-2.2, -19.27)$, $(-2.2, 8.73)$, để khối chân cắm của shield cách thân servo $J_1$ $0.12\text{ mm}$ (mép mạch cách vách khoang $0.13\text{ mm}$; vách đế phía này chỉ dày $0.6$–$2\text{ mm}$ ở phần thấp nên không nới khoang được); mặt dưới mạch Uno ở $z = 18.5$, cạnh có cổng USB quay về phía sau tại $x = -68.2$.
3. 2 lỗ $\varnothing 3.4$ tại $(28, \pm 28)$ bắt lên trụ của đế; vấu sau $5.8 \times 8 \times 8\text{ mm}$ với lỗ cấy ren ngang nhận ốc M3 từ mặt sau đế.
4. Lưỡi bịt rãnh USB: khối $x \in [-74.5, -70.5]$, $y \in [5.1, 17.7]$, từ $z = 6$ lên $z = 19.3\text{ mm}$, liền với mép sau khay; khi khay vào vị trí, lưỡi lấp kín rãnh dưới cổng USB của đế.

---

### CHI TIẾT 2: `02_Turret_ForkKuka.SLDPRT` (Turret liền khối $J_1 \to J_2$)
*Nhiệm vụ: Một chi tiết liền từ mặt đế tới khớp vai. Chân turret đặt lên mặt trên đế `01_Base_Kuka` và bắt vào đĩa sừng 25T của servo $J_1$; tai $+Y$ giữ servo MG996R của khớp vai $J_2$, tai $-Y$ giữ vòng bi 698ZZ đỡ phụ.*

**A. Thân turret** (hệ tọa độ của khối KUKA, trùng với hệ của đế: $+Z$ lên, $+X$ là hướng vươn, trục $J_1$ là trục $Z$ qua gốc, trục $J_2$ song song $Y$ tại $x = 9.8$, $z = 169.05\text{ mm}$)
1. **Khối gốc:** Thân cột xoay của mô hình KUKA KR 3 R540 tỉ lệ $0.49$ (một khối liền, chân tròn $\varnothing 92\text{ mm}$ với mặt chân tại $z = 90.65$ và ngõng trục $\varnothing 49\text{ mm}$, hai tai dày khoảng $22$ và $26\text{ mm}$, khe giữa hai tai $49.2\text{ mm}$ từ $y = -26.46$ đến $y = +22.74$).
2. **Rút ngắn ngõng trục:** Mặt phẳng song song `Front Plane` tại $z = 86.1\text{ mm}$, `Extruded Cut` bỏ phần phía dưới để ngõng trục hở nóc servo $J_1$ $0.6\text{ mm}$.

**B. Các nguyên công**
1. **Hốc đĩa sừng $J_1$:** Mặt phẳng $z = 91.85\text{ mm}$ là mặt tựa vành đĩa sừng. Đường tròn $\varnothing 20.4\text{ mm}$, cắt xuống hết ngõng trục.
2. **Lỗ ốc đĩa sừng:** 4 lỗ $\varnothing 3.4\text{ mm}$ trên PCD $14\text{ mm}$ từ $z = 91.85$ lên $z = 95.95$ (sàn dày $4.0\text{ mm}$).
3. **Giếng vặn ốc:** Trên mặt phẳng $z = 95.85\text{ mm}$, đường tròn $\varnothing 22.0\text{ mm}$ cắt xuyên lên sàn khe giữa hai tai (sâu khoảng $44\text{ mm}$); 4 ốc M3 × 8 vặn từ trên xuống bằng lục giác dài trước khi lắp cánh tay.
4. **Ổ trượt $J_1$:** Ngõng trục $\varnothing 49$ nằm trong hốc $\varnothing 49.5$ của đế; mặt chân turret ($z = 90.65$) hở $0.2\text{ mm}$ trên vành tựa của đế ($z = 90.45$).
5. **Lấp hốc tròn tai servo ($+Y$):** Trên mặt phẳng $y = 22.736$, đường tròn $\varnothing 36.75\text{ mm}$ tâm trục $J_2$, đùn **$4.9\text{ mm}$** về phía $+Y$ để mặt trong tai phẳng.
6. **Hốc tai servo:** Mặt phẳng $y = 30.85\text{ mm}$ là mặt tựa tai bắt vít (tính cho servo DS3225: đỉnh trục cách mặt trên tai bắt vít $15.2\text{ mm}$). Servo đặt dọc theo tai, thân nghiêng $15^\circ$ về phía sau so với phương thẳng đứng. Chữ nhật $55.35 \times 20.7\text{ mm}$ (từ $17.95\text{ mm}$ phía trên đến $37.4\text{ mm}$ phía dưới trục $J_2$ dọc thân servo), `Extruded Cut` xuyên ra mặt ngoài tai.
7. **Ô thân servo:** Cùng mặt phẳng, chữ nhật $41.1 \times 20.7\text{ mm}$ (từ $10.75\text{ mm}$ phía trên đến $30.35\text{ mm}$ phía dưới trục), cắt sâu **$10.6\text{ mm}$** về phía khe. Ô này dành cho servo DS3225 (thân $40.1 \times 20\text{ mm}$, trục cách đầu thân $10.33\text{ mm}$); MG996R có trục ngắn hơn $1.35\text{ mm}$ nên không dùng chung mặt tựa này.
8. **Lỗ cấy ren giữ servo:** 4 lỗ $\varnothing 4.2\text{ mm}$ trên mặt $y = 30.85$ tại $(x, z) = (18.339, 181.888)$, $(8.824, 184.438)$, $(5.547, 134.151)$, $(-3.967, 136.700)$, cắt sâu **$5.5\text{ mm}$** (đáy dày $2.6\text{ mm}$; lỗ tai servo DS3225 lệch tâm lỗ cấy ren khoảng $0.4\text{ mm}$, vẫn bắt được ốc M3). Trên cùng mặt này có 2 rãnh rộng $2.0\text{ mm}$, sâu **$2.0\text{ mm}$**, chạy dọc tâm tai bắt vít từ mép ô thân servo ra hết tai, để né gân tăng cứng của tai servo.
9. **Ổ vòng bi 698ZZ (tai $-Y$):** Trên đáy hốc tròn mặt trong tai ($y = -31.36$), đường tròn $\varnothing 19.1\text{ mm}$ tâm trục $J_2$ cắt sâu **$6.2\text{ mm}$** ra phía ngoài; lỗ thông $\varnothing 14.0\text{ mm}$ xuyên ra mặt ngoài tai. Vòng bi lắp từ phía trong khe.
10. **Cao độ lắp:** Turret dùng chung hệ tọa độ với đế nên trục $J_2$ cao $169.05\text{ mm}$ so với mặt bàn ($h_0$) và lệch $9.8\text{ mm}$ về phía trước trục $J_1$ ($a_1$).
11. **Lỗ xỏ dây ở vấu lưng:** vấu chữ nhật của khối KUKA ở lưng turret ($x = -56.8 \to -46.5$, $y = \pm 5.5$, $z = 100.2 \to 110.5$) được khoét lỗ thẳng đứng $x \in [-54.8, -47.3]$, $y = \pm 4$. Khi $J_1 = 0^\circ$ lỗ nằm ngay trên lỗ dây servo $\varnothing 10$ của nóc hộp sau đế. Bó 5 dây (4 dây từ ống dẫn của cánh tay và dây servo $J_2$) đi qua lỗ này rồi xuống đế.

**C. Lắp servo $J_2$ (`02_Turret_ForkKuka_SubAssembly.SLDASM`)**
* Servo luồn từ mặt ngoài tai $+Y$ vào cho tới khi mặt trên của tai bắt vít áp vào mặt $y = 30.85$; bắt 4 ốc M3 vào lỗ cấy ren. Trục ra hướng vào khe, dây điện ra ở đầu trên của servo.
* Đỉnh trục then hoa ở $y = 15.65\text{ mm}$; mặt ngoài vành đĩa sừng ở $y = 14.65\text{ mm}$; đáy thân servo DS3225 ở $y = 59.6\text{ mm}$.
* Ổ trục cánh tay nằm giữa mặt vành đĩa sừng ($y = 14.65$) và mặt trong tai ổ bi ($y = -26.46$); sàn khe thấp hơn trục $J_2$ từ $29$ đến $32\text{ mm}$.

**D. Càng khung đơn giản `02_Turret_Fork` (mẫu in thử lắp servo)**
* Sàn $\varnothing 82 \times 6\text{ mm}$, tai servo dạng tấm dày $7\text{ mm}$ với ô $40.6 \times 20.7\text{ mm}$ và 4 lỗ cấy ren, tai ổ bi dày $8\text{ mm}$, khe $44\text{ mm}$; trục $J_2$ cao $27.95\text{ mm}$ trên mặt đáy càng. Cụm lắp kèm: `02_Turret_SubAssembly.SLDASM`. Chi tiết này không nằm trong cụm lắp chính.

---

### CHI TIẾT 3: `03_UpperArmKuka.SLDPRT` (Cánh tay chính Link 1 $J_2 \to J_3$)
*Nhiệm vụ: Nối khớp vai với khớp khuỷu, $L_1 = 127.4\text{ mm}$; bắt vào đĩa sừng 25T của servo $J_2$, tựa lên vòng bi 698ZZ ở tai đối diện và mang servo MG996R của khớp $J_3$.*
*Hệ tọa độ chi tiết trùng với hệ của càng `02_Turret_ForkKuka` khi cánh tay dựng đứng: trục $J_2$ tại $x = 9.8$, $z = 169.05$; trục $J_3$ tại $x = 9.8$, $z = 296.45\text{ mm}$, cả hai song song $Y$.*

1. **Khối gốc:** Thân cánh tay của mô hình KUKA KR 3 R540 tỉ lệ $0.49$ (một khối liền): đầu dưới là ổ trục đặc nằm giữa hai tai càng, đầu trên là càng chữ U có hai tai dày khoảng $18\text{ mm}$, khe $48.5\text{ mm}$.
2. **Mặt bắt đĩa sừng $J_2$:** Trên mặt phẳng $y = 20.5\text{ mm}$, đường tròn $\varnothing 60.4\text{ mm}$ tâm trục $J_2$, `Extruded Cut` bỏ phần phía $+Y$ (hở $0.55\text{ mm}$ với nắp trên servo DS3225, hở $2.2\text{ mm}$ với mặt trong tai servo). Trên mặt phẳng $y = 14.65\text{ mm}$, đường tròn $\varnothing 21.2\text{ mm}$ cắt xuyên về $+Y$ thành hốc chìm sâu $5.85\text{ mm}$ cho đĩa sừng; đáy hốc áp vào mặt vành đĩa sừng.
3. **Bỏ vấu tròn phía ổ bi:** Trên mặt phẳng $y = -25.97\text{ mm}$, đường tròn $\varnothing 42\text{ mm}$ tâm trục $J_2$, cắt bỏ phần phía $-Y$ để cánh tay luồn được vào giữa hai tai càng.
4. **Khoang bắt ốc:** Sketch trên mặt phẳng $x = 29.5\text{ mm}$, chữ nhật $y \in [-17.97, 7.65]$, $z \in [156.05, 182.05]$, `Extruded Cut` xuyên về phía $-X$. Khoang chỉ mở ở mặt sau ổ trục; mặt trước còn vách dày từ $3.4\text{ mm}$. Còn lại tấm bắt sừng dày $7.0\text{ mm}$ và tấm ổ bi dày $8.0\text{ mm}$; đai ốc M8 đưa vào qua miệng sau của khoang.
5. **Lỗ tại $J_2$:** Tấm bắt sừng: lỗ tâm $\varnothing 7.0\text{ mm}$ và 4 lỗ $\varnothing 3.2\text{ mm}$ trên PCD $14\text{ mm}$ (ốc M3 × 8 đầu trụ vặn vào ren của đĩa sừng). Tấm ổ bi: lỗ $\varnothing 8.4\text{ mm}$ và hốc lục giác đối cạnh $13.3\text{ mm}$ sâu $4.0\text{ mm}$ ở mặt trong giữ đai ốc M8; 4 lỗ $\varnothing 6\text{ mm}$ trên PCD $14\text{ mm}$, thẳng hàng với 4 ốc đĩa sừng: ốc đưa qua các lỗ này trên đầu lục giác và siết thẳng từ mặt ngoài $-Y$ khi cánh tay còn nằm ngoài càng.
6. **Hốc servo $J_3$ (tai $+Y$):** Lấp hốc tròn mặt trong tai (đường tròn $\varnothing 39.4\text{ mm}$ trên mặt phẳng $y = 23.96$, đùn $5.06\text{ mm}$). Mặt tựa tai bắt vít là mặt phẳng $y = 30.7\text{ mm}$; servo nghiêng $15^\circ$, thân hướng về $J_2$. Các biên dạng giống hốc servo của càng, tịnh tiến $+127.4\text{ mm}$ theo $Z$: hốc tai $54.6 \times 20.7\text{ mm}$ cắt xuyên ra mặt ngoài, ô thân $40.5 \times 20.7\text{ mm}$ cắt sâu $9.2\text{ mm}$ về phía khe, 4 lỗ cấy ren $\varnothing 4.2 \times 5.5\text{ mm}$ tại $(x, z) = (18.339, 309.288)$, $(8.824, 311.838)$, $(5.547, 261.551)$, $(-3.967, 264.100)$, 2 rãnh né gân rộng $2.0$, sâu $2.0\text{ mm}$.
7. **Ổ vòng bi $J_3$ (tai $-Y$):** Trên đáy hốc tròn mặt trong tai ($y = -29.4$), đường tròn $\varnothing 19.1\text{ mm}$ cắt sâu $6.2\text{ mm}$ ra phía ngoài và lỗ thông $\varnothing 14.0\text{ mm}$.
8. **Lắp ráp:** Vòng đệm `03_J2_BearingSpacer` ($\varnothing 11 / \varnothing 8.3 \times 5.55\text{ mm}$, hở dọc trục $0.045\text{ mm}$) đặt giữa vòng trong của vòng bi $J_2$ và tấm ổ bi; bu-lông M8 × 25 xuyên từ mặt ngoài tai $-Y$ của càng qua vòng bi, vòng đệm, tấm ổ bi vào đai ốc M8. Đáy thân servo $J_3$ ở $y = 61.4\text{ mm}$ (nhô khoảng $13\text{ mm}$ khỏi mặt ngoài tai).
9. **Ống dẫn dây ở lưng cánh tay:** trên mặt phẳng $y = 0$, cắt đối xứng rộng $9\text{ mm}$ một dải dày $6\text{ mm}$ chạy song song mặt lưng, cách mặt lưng $1.9 \to 2.5\text{ mm}$: thành ngoài đi qua $(x, z) = (-17.8, 180)$, $(-23.4, 217)$, $(-24.6, 243)$. Đầu dưới thông vào khoang bắt ốc ($z = 182$), đầu trên mở ra mặt vát phía trên lưng ($z \approx 245$). Một khe rộng $3\text{ mm}$ tại $y = 0$ cắt từ mặt lưng vào ống suốt chiều dài: từng dây servo dẹt được ấn nghiêng qua khe, không cần luồn đầu cắm. Ống chứa được 4 dây servo (của $J_3$, $J_4$, $J_5$ và tay gắp).

---

### CHI TIẾT 4: `04_Forearm_ElbowKuka.SLDPRT` (Khối khuỷu của cẳng tay, quanh trục $J_3$)

*Hệ tọa độ của khối KUKA, tư thế cẳng tay nằm ngang hướng $+X$; trục $J_3$ song song $Y$ tại $x = 9.8$, $z = 296.45\text{ mm}$.*

1. **Khối gốc:** Thân khuỷu của mô hình KUKA KR 3 R540 tỉ lệ $0.49$ ($x$ từ $-21$ đến $70\text{ mm}$, rộng $y = \pm 24\text{ mm}$, hai vấu tròn hai bên tại trục $J_3$).
2. **Mặt phía servo:** Trên mặt phẳng $y = 21.7\text{ mm}$, đường tròn $\varnothing 60.4\text{ mm}$ tâm trục $J_3$, `Extruded Cut` bỏ phần phía $+Y$ (hở $0.5\text{ mm}$ với nóc hộp số servo $J_3$ ở $y = 22.2$).
3. **Hốc đĩa sừng:** Trên mặt phẳng $y = 15.85\text{ mm}$, đường tròn $\varnothing 21.2\text{ mm}$ cắt xuyên về $+Y$ (hốc sâu $5.85\text{ mm}$); lỗ tâm $\varnothing 7.0$ và 4 lỗ $\varnothing 3.2$ trên PCD $14\text{ mm}$ cắt sâu $7.2\text{ mm}$ về $-Y$.
4. **Khoang bắt ốc:** Trên mặt phẳng $x = 29.5\text{ mm}$, chữ nhật $y \in [-16.0, 8.85]$, $z \in [283.45, 309.45]$, cắt xuyên về $-X$ (mở ở mặt sau khuỷu). Tấm bắt sừng dày $7.0\text{ mm}$, tấm ổ bi dày $8.0\text{ mm}$.
5. **Mặt phía ổ bi:** Trên mặt phẳng $y = -24.0\text{ mm}$, đường tròn $\varnothing 42\text{ mm}$ cắt bỏ vấu phía $-Y$. Trên cùng mặt: lỗ $\varnothing 8.4\text{ mm}$ và 4 lỗ $\varnothing 6\text{ mm}$ trên PCD $14\text{ mm}$, cắt sâu $8.2\text{ mm}$; ốc đĩa sừng M3 × 8 đầu trụ đưa qua các lỗ này trên đầu lục giác và siết thẳng từ mặt ngoài $-Y$. Hốc lục giác đối cạnh $13.3\text{ mm}$ sâu $4.0\text{ mm}$ ở mặt trong ($y = -16.0$) giữ đai ốc M8.
6. **Mặt ghép với thân càng:** Hốc tròn $\varnothing 43.2\text{ mm}$ ở mặt trước, đáy tại $x = 65.268\text{ mm}$, tâm $(y, z) = (0, 306.25)$. Các lỗ trên đáy hốc phải cắt từ mặt phẳng $x = 65.25$ về cả hai phía, nếu không sẽ còn một màng $0.018\text{ mm}$ bịt miệng lỗ. Trên đáy hốc: 4 lỗ cấy ren $\varnothing 4.2 \times 5.5\text{ mm}$ tại $(\pm 9, 304)$ và $(\pm 9, 314.5)$; lỗ đi dây $\varnothing 10\text{ mm}$ tại $(0, 304.5)$ xuyên vào khoang bắt ốc.
7. **Lắp:** giống khớp vai. Vòng bi 698ZZ nằm trong tai $-Y$ của cánh tay (mặt trong vòng bi ở $y = -29.6$), vòng đệm `03_J2_BearingSpacer` dài $5.55\text{ mm}$ dùng lại cho $J_3$; khe giữa khối khuỷu và tai ổ bi $0.5\text{ mm}$.

### CHI TIẾT 5: `04_Forearm_ForkKuka.SLDPRT` (Thân càng của cẳng tay)

*Cùng hệ tọa độ với khối khuỷu. Khối gốc: thân cẳng tay `Solid1[1]` của KUKA, $x$ từ $67$ đến $156\text{ mm}$: khối sau dài $39\text{ mm}$ và một nhánh càng phía $+Y$.*

1. **Vành định tâm:** Trên mặt phẳng $x = 65.25\text{ mm}$, đường tròn $\varnothing 42.9\text{ mm}$ tâm $(y, z) = (0, 306.25)$, đùn $5.5\text{ mm}$ về $+X$. Vành lọt vào hốc $\varnothing 43.2$ của khối khuỷu và tựa lên đáy hốc; khe $0.55\text{ mm}$ còn lại ở vai ngoài.
2. **Khoang dây:** Trên mặt phẳng $y = -21\text{ mm}$, chữ nhật $x \in [74.5, 103.5]$, $z \in [300.5, 320]$, cắt $33\text{ mm}$ về $+Y$ (tới $y = 12$). Khoang mở ở mặt $-Y$, được tấm ốp bên che lại; đáy khoang ở $z = 300.5$ để còn thành $\ge 1.5\text{ mm}$ phía trên rãnh khuyết của khối KUKA.
3. **Lỗ ghép:** Trên vách sau ($x = 74.5 \to 65.25$): 4 lỗ $\varnothing 3.4\text{ mm}$ tại $(\pm 9, 304)$ và $(\pm 9, 314.5)$ cho ốc M3 × 14 đầu trụ; lỗ đi dây $\varnothing 10\text{ mm}$ tại $(0, 304.5)$.
4. **Lỗ luồn lục giác:** Trên vách trước (từ $x = 103.5$ ra mặt trước), 4 lỗ $\varnothing 6\text{ mm}$ thẳng hàng với 4 ốc ghép, nằm trọn trên mặt phẳng trước ($x \approx 109.7$); ốc được siết bằng lục giác thẳng luồn từ hốc cổ tay, trước khi lắp cổ tay. Dây servo cổ tay cũng đi qua các lỗ này.
5. **Cửa sổ servo $J_4$:** Trên mặt ngoài nhánh càng ($y = 28.4\text{ mm}$), chữ nhật $x \in [120.05, 143.45]$, $z \in [299.83, 312.63]$ ($23.4 \times 12.8\text{ mm}$), cắt xuyên nhánh càng về $-Y$. Servo MG90S đưa vào từ ngoài, trục hướng $-Y$ trùng trục $J_4$ tại $(x, z) = (137.2, 306.23)$, thân kéo dài về $-X$.
6. **Hốc tai servo $J_4$:** chữ nhật $x \in [115.3, 148.2]$, $z \in [299.83, 312.63]$, sâu $2.7\text{ mm}$ (đáy ở $y = 25.7$). Tai servo chìm ngang mặt ngoài nhánh càng; nóc hộp số ở $y = 18.2$, đỉnh trục ở $y = 14.2$, đáy servo nhô tới $y = 46.7\text{ mm}$.
7. **Lỗ mồi vít tai servo $J_4$:** 2 lỗ $\varnothing 1.7\text{ mm}$ tại $x = 145.75$ và $x = 117.75$, $z = 306.23$, cắt $8\text{ mm}$ từ mặt $y = 28.4$ (đáy lỗ ở $y = 20.4$).
8. **Lỗ cấy ren cho tấm ốp chốt (mặt $-Y$):** 3 lỗ $\varnothing 4.2 \times 7\text{ mm}$ từ mặt $y = -20.09$ tại $(x, z) = (80, 291.5)$, $(101, 291.5)$, $(90, 324.5)$.
9. **Lỗ cho tấm ốp servo (mặt $+Y$):** 2 lỗ cấy ren $\varnothing 4.2 \times 5.5\text{ mm}$ tại $(100, 318)$ và $(112, 294.5)$; 1 lỗ mồi $\varnothing 1.7 \times 6\text{ mm}$ tại $(152, 306.23)$ cho vít tự ren M2.
10. **Khe dây servo $J_4$:** chữ nhật $x \in [96, 100.5]$, $z \in [301.7, 310.7]$ cắt từ mặt $y = 28.4$ xuyên vào khoang dây (tới $y = 11.8$); đầu cắm 3 chân của servo lọt qua khe $9 \times 4.5\text{ mm}$ này.

### CHI TIẾT 6: `05_WristKuka.SLDPRT` (Thân cổ tay, chứa servo $J_5$)

*Cùng hệ tọa độ với cẳng tay. Khối gốc: thân cổ tay `[21]` của KUKA ($x$ từ $111.5$ đến $168.6\text{ mm}$).*

* **Trục $J_4$ (gập):** song song $Y$ tại $x = 137.2$, $z = 306.23\text{ mm}$, đúng tâm hai vấu tròn của khối KUKA. Đặt trục lệch khỏi tâm này thì lưng cổ tay kẹt vào vách thân càng sau khoảng $10^\circ$; đặt đúng tâm thì cổ tay gập $\pm 110^\circ$ không chạm thân càng và hai tấm ốp.
* **Trục $J_5$ (xoay):** song song $X$ tại $y = 0$, $z = 306.23\text{ mm}$, cắt trục $J_4$ và đi qua tâm mũi tròn của cổ tay KUKA. Trục ra của MG90S lệch $5.45\text{ mm}$ so với tâm thân nên thân servo nằm lệch xuống dưới: đầu thân sát bụng cổ tay và một tai servo ló ra dưới bụng.
* **Servo $J_4$** không nằm trong cổ tay: nó lắp trên nhánh càng $+Y$ từ phía ngoài, trục cắm vào đĩa sừng nằm trong mặt bên cổ tay.

Kích thước MG90S dùng để cắt (đo trên `M90S_ali.step`): thân $22.8 \times 12.2\text{ mm}$, tai rộng $32.3\text{ mm}$ dày $2.7\text{ mm}$, mặt dưới tai (phía đáy servo) cách đáy $18.3\text{ mm}$, nóc hộp số cao hơn mặt dưới tai $10.2\text{ mm}$, đỉnh trục cao hơn $14.2\text{ mm}$, trục cách đầu thân $5.95\text{ mm}$, hai lỗ tai cách trục $8.55$ và $19.45\text{ mm}$. Đĩa sừng hai cánh (đo trên `MG90S Servo Horn (2 spork).step`): dài $31\text{ mm}$, moay-ơ $\varnothing 6.8 \times 4.7\text{ mm}$, cánh dày $2.1\text{ mm}$, rộng $5.2\text{ mm}$ ở gốc và $3.6\text{ mm}$ ở đầu.

1. **Gọt vấu $+Y$:** Trên mặt phẳng $y = 18.7\text{ mm}$, đường tròn $\varnothing 38\text{ mm}$ tâm trục $J_4$, cắt bỏ phần phía $+Y$ (hở $0.41\text{ mm}$ với mặt trong nhánh càng ở $y = 19.11$).
2. **Gọt vấu $-Y$:** Trên mặt phẳng $y = -19.6\text{ mm}$, đường tròn $\varnothing 27\text{ mm}$, cắt bỏ phần phía $-Y$ (hở $0.5\text{ mm}$ với tấm ốp chốt ở $y = -20.09$).
3. **Lỗ chốt xoay:** Trên mặt $y = -19.6$, lỗ $\varnothing 8.3 \times 6.5\text{ mm}$ tại trục $J_4$ nhận chốt `04_J4_PivotPin`; ở đáy lỗ có lỗ cấy ren M3 $\varnothing 4.2 \times 6\text{ mm}$ (tới $y = -7.1$) cho vít giữ chốt.
4. **Hốc né hộp số servo $J_4$:** Trên mặt $y = 18.7$, đường tròn $\varnothing 21.2\text{ mm}$ sâu $0.9\text{ mm}$.
5. **Hốc đĩa sừng hai cánh:** Trên mặt $y = 18.7$, biên dạng đĩa sừng (moay-ơ $\varnothing 7.2$, hai cánh dọc $X$ rộng $5.6 \to 3.9\text{ mm}$, đầu cánh ở $\pm 15.85\text{ mm}$), cắt sâu $5.7\text{ mm}$ (đáy ở $y = 13.0$). Đĩa sừng bị kẹp giữa đáy hốc và mặt hộp số servo nên không cần vít tâm.
6. **Đệm bụng:** khối $y = \pm 8.2$, mặt dưới phẳng tại $z = 287.0$, từ $x = 139.5$ tới $158.4\text{ mm}$, hòa vào bụng tròn của cổ tay; cho sàn dày $2.05\text{ mm}$ dưới hốc thân servo.
7. **Vấu vít tai:** khối $y = \pm 3.5$, $z \in [283.3, 288]$, $x \in [149.5, 158.4]$ dưới đệm bụng.
8. **Hốc thân servo $J_5$:** Từ mặt phẳng $x = 169\text{ mm}$, chữ nhật $y = \pm 6.3$, $z \in [289.08, 312.48]$, cắt về $-X$ tới $x = 139.8\text{ mm}$. Servo đưa vào từ mặt trước, trục hướng $+X$, đầu thân xa trục hướng xuống; mặt dưới tai ở $x = 158.4$, nóc hộp số ở $x = 168.6$ (ngang mặt trước), đỉnh trục ở $x = 172.6\text{ mm}$.
9. **Rãnh tai servo $J_5$:** chữ nhật $y = \pm 6.3$, $z \in [282.5, 317.25]$, cắt tới $x = 158.4\text{ mm}$ (mặt tựa mặt dưới tai; tai chiếm $x = 158.4 \to 161.1$, $z = 284.63 \to 316.93$). Rãnh mở ra bụng cổ tay; phía trên rãnh mũi cổ tay còn nguyên một cầu dày $6\text{ mm}$.
10. **Rãnh dây servo $J_5$:** chữ nhật $y = \pm 2.2$, $z \in [312.3, 316.0]$, cắt tới $x = 143\text{ mm}$, ngay trên đầu thân phía trục.
11. **Lỗ mồi vít tai servo $J_5$:** $\varnothing 1.7 \times 8\text{ mm}$ tại $(y, z) = (0, 286.78)$ trên mặt $x = 158.4$ của vấu vít tai. Đầu tai phía rãnh dây không có vít.

Trong assembly chính, servo $J_4$ và hai tấm ốp khóa (Lock) vào thân càng; servo $J_5$ và chốt xoay khóa vào cổ tay. Cổ tay xoay quanh $J_4$ bằng mate Concentric (lỗ chốt $\varnothing 8.3$ của cổ tay với trụ hộp số servo $J_4$) và mate Distance $0.41\text{ mm}$ (mặt $y = 18.7$ của cổ tay với mặt trong nhánh càng).

### CHI TIẾT 7: `04_Forearm_CoverPivot.SLDPRT` (Tấm ốp $-Y$, nhánh càng mang chốt xoay)

*Cùng hệ tọa độ với thân càng. Khối gốc: tấm ốp `[22]` của KUKA ($y$ từ $-31.4$ đến $-20.09\text{ mm}$). Tấm này là nhánh càng thứ hai: nó bắt vào khối sau của thân càng, che khoang dây và đỡ chốt xoay $J_4$.*

1. **Lỗ trục và lỗ vít:** lỗ xuyên $\varnothing 8.4\text{ mm}$ tại trục $J_4$ $(137.2, 306.23)$; 3 lỗ xuyên $\varnothing 3.4\text{ mm}$ tại $(80, 291.5)$, $(101, 291.5)$, $(90, 324.5)$.
2. **Hốc đầu vít:** 3 hốc $\varnothing 6.2\text{ mm}$ cắt từ mặt phẳng $y = -24.1$ ra mặt ngoài, để lại $4\text{ mm}$ dưới đầu vít. Vít M3 × 10 đầu trụ vào lỗ cấy ren của thân càng.
3. **Hốc vành chốt:** $\varnothing 13\text{ mm}$ cắt từ mặt phẳng $y = -27.3$ ra mặt ngoài.
4. **Rãnh né vấu thân càng:** ở mép sau, chữ nhật $x \in [70.5, 70.95]$, $z \in [298.5, 314]$ cắt từ mặt $y = -20.09$ sâu $1.6\text{ mm}$; mép tấm ốp lùi $0.3\text{ mm}$ để cách vấu của thân càng (mặt $x = 70.75$, $y \in [-21.45, -20.09]$, $z \in [298.73, 313.77]$) $0.2\text{ mm}$.

### CHI TIẾT 8: `04_J4_PivotPin.SLDPRT` (Chốt xoay $J_4$)

Vành $\varnothing 12 \times 2\text{ mm}$ ($y = -29.3 \to -27.3$), thân $\varnothing 8\text{ mm}$ tới $y = -13.6$ (dài $13.7\text{ mm}$), lỗ dọc trục $\varnothing 3.4\text{ mm}$. Chốt luồn từ ngoài qua lỗ $\varnothing 8.4$ của tấm ốp vào lỗ $\varnothing 8.3$ của cổ tay, giữ bằng vít M3 × 20 vào lỗ cấy ren ở đáy lỗ cổ tay. Chốt và vít quay cùng cổ tay; bề mặt trượt là thân chốt trong lỗ tấm ốp (dài $7.2\text{ mm}$), nên vít không bị nới khi khớp quay. In đứng, vành nằm trên bàn in.

### CHI TIẾT 9: `04_Forearm_CoverServo.SLDPRT` (Tấm ốp $+Y$, quanh servo $J_4$)

*Khối gốc: tấm ốp `[23]` của KUKA, cắt phẳng tại $y = 28.45\text{ mm}$ để nằm trên mặt ngoài nhánh càng; servo $J_4$ không có nắp che.*

1. **Cửa sổ servo:** chữ nhật $x \in [115.3, 148.2]$, $z \in [299.83, 312.63]$ cắt xuyên tấm ốp; thân servo $J_4$ nhô qua cửa sổ tới $y = 46.7\text{ mm}$ và để hở.
2. **Rãnh dây:** ở mặt trong, chữ nhật $x \in [96, 115.4]$, $z \in [301.7, 310.7]$ sâu $3.55\text{ mm}$, nối cửa sổ với khe dây của thân càng.
3. **Lỗ vít:** 2 lỗ $\varnothing 3.4\text{ mm}$ tại $(100, 318)$ và $(112, 294.5)$ cho vít M3 × 8; 1 lỗ $\varnothing 2.4\text{ mm}$ tại $(152, 306.23)$ cho vít tự ren M2.
4. **Thứ tự lắp:** luồn đầu cắm servo $J_4$ qua khe dây vào khoang, đặt servo vào cửa sổ của thân càng và bắt 2 vít tai, úp tấm ốp, rồi vòng dây qua lưng servo về phía khuỷu và ấn vào rãnh dây.

### CHI TIẾT 10: `06_Gripper_Base.SLDPRT` (Đế tay gắp, quay quanh $J_5$)

*Bốn chi tiết tay gắp dùng chung một hệ tọa độ riêng: phương như hệ của cổ tay ở tư thế gập $0^\circ$, trục xoay và trục bánh răng tay gắp trùng nhau tại $y = 0$, $z = 301.0\text{ mm}$. Trong assembly, trục này đặt trùng trục $J_5$ của cổ tay ($z = 306.23$), tức cả cụm cao hơn tọa độ vẽ $5.23\text{ mm}$, nên hai ngón kẹp đối xứng qua trục xoay.*

1. **Thân:** $x \in [169.4, 193.9]$, tiết diện chữ nhật bo góc $y = \pm 19.5$, $z \in [279.7, 324.2]\text{ mm}$, bốn góc bo $R6$ (cùng tiết diện với khung dẫn hướng); mặt sau cách mặt trước cổ tay $0.84\text{ mm}$. In thân với mặt trước ($x = 193.9$) úp xuống bàn in.
2. **Vành cổ áo (mặt sau):** vành trụ đồng tâm trục xoay, bán kính trong $18.3$, ngoài $19.5\text{ mm}$, từ mặt sau lùi về $x = 161.5$; ôm ngoài mũi cổ tay và nóc servo $J_5$ (bán kính lớn nhất $17.9\text{ mm}$), dừng trước tai servo $0.4\text{ mm}$, che khe giữa cổ tay và tay gắp.
3. **Hốc đĩa sừng servo $J_5$ (mặt sau):** moay-ơ $\varnothing 7.2$ và hai cánh dọc $Z$ (rộng $5.6 \to 3.9\text{ mm}$, đầu cánh ở $\pm 15.85$), sâu $4.4\text{ mm}$ (đáy ở $x = 173.8$); lỗ $\varnothing 2.4\text{ mm}$ ở tâm cho vít đĩa sừng, siết từ phía trước qua hốc servo trước khi lắp servo tay gắp.
4. **Hốc servo tay gắp (mặt trước):** $y = \pm 6.4$, $z \in [294.75, 318.15]$, sâu tới $x = 175.3$. Servo MG90S đưa vào đáy trước, trục hướng $+X$ trùng trục $J_5$; mặt dưới tai tựa lên mặt trước $x = 193.9$, nóc hộp số ở $x = 204.1$, đỉnh trục ở $x = 208.1\text{ mm}$.
5. **Rãnh dây:** $y = \pm 2.2$, $z \in [291.2, 294.9]$, sâu tới $x = 178.5$.
6. **Lỗ mồi vít tai:** $\varnothing 1.7 \times 8\text{ mm}$ tại $(y, z) = (0, 320.45)$.
7. **Lỗ bắt khung dẫn hướng:** 4 lỗ cấy ren M3 $\varnothing 4.2 \times 5.5\text{ mm}$ trên mặt trước tại $(y, z) = (\pm 12, 290)$ và $(\pm 12, 312)$, cho vít M3 × 8.
8. **Kênh thả dây:** $x \in [178.5, 184]$, $y = \pm 2.2$, từ đáy thân ($z = 279.7$) lên rãnh dây ($z = 291.3$); dây servo tay gắp rơi ra đáy đế rồi vòng về cổ tay, không đi qua vùng bánh răng.

### CHI TIẾT 11: `06_Gripper_Pinion.SLDPRT` (Bánh răng tay gắp)

Mô-đun $1.5$, $10$ răng (bán kính lăn $7.5\text{ mm}$, đỉnh răng $8.7$, chân răng $5.625$), bề rộng răng $5.3\text{ mm}$ ($x = 209.3 \to 214.6$). Phía sau là đĩa mang $\varnothing 33 \times 4.4\text{ mm}$ ($x = 204.9 \to 209.3$) có hốc ôm đĩa sừng hai cánh nguyên bản của MG90S (moay-ơ $\varnothing 7.2$, cánh tới $\pm 15.85$), nên không phải cắt ngắn đĩa sừng. Lỗ tâm $\varnothing 2.4$, hốc đầu vít $\varnothing 4.6 \times 3\text{ mm}$ ở mặt trước; vít đĩa sừng kẹp bánh răng và đĩa sừng lên trục servo.

### CHI TIẾT 12: `06_Gripper_Jaw.SLDPRT` (Thanh răng liền ngón kẹp, in 2 cái)

*Vẽ ở vị trí khép, cho ngón phía trên; ngón thứ hai là cùng chi tiết xoay $180^\circ$ quanh trục $J_5$.*

1. **Thanh răng:** $y \in [-6, 31]$, $x \in [209.7, 214.4]$, lưng ở $z = 318$, răng hướng xuống trục; đường lăn ở $z = 308.6$ (cách trục $7.6\text{ mm}$, hở thêm $0.1$), đỉnh răng $z = 307.4$, chân răng $z = 310.475$, bước răng $4.712\text{ mm}$. Mỗi sườn răng được cắt lùi $0.12\text{ mm}$ theo phương $y$ (đỉnh răng rộng $1.09\text{ mm}$) để tạo khe hở sườn với bánh răng.
2. **Gờ dẫn hướng:** trên lưng thanh răng, $x \in [211, 213]$, cao tới $z = 320.3$, chạy suốt chiều dài.
3. **Ngón kẹp:** khối $y \in [-6, 0]$, $z \in [287, 318]$, $x \in [215, 245]$, nối với mặt trước thanh răng qua đoạn $z \in [310.6, 318]$. Mặt kẹp là mặt $y = 0$. Đầu ngón thon lại trên đoạn $x \in [230, 245]$: chiều cao giảm từ $31$ xuống $15\text{ mm}$ ($z \in [295, 310]$ tại mút) và bề dày giảm từ $6$ xuống $3\text{ mm}$ ở mặt lưng. Mặt kẹp có rãnh chữ V $90^\circ$ sâu $1.5\text{ mm}$ tại $x = 224$, chạy suốt chiều cao ngón, để định tâm vật trụ.

Servo quay $180^\circ$ cho mỗi ngón chạy $23.6\text{ mm}$, độ mở tối đa khoảng $46\text{ mm}$. Với mô-men MG90S $1.8\text{ kg·cm}$ ở $4.8\text{ V}$ và bán kính lăn $7.5\text{ mm}$, lực kẹp mỗi ngón khi servo kẹt là $11.8\text{ N}$; dùng $30\%$ mức đó để giữ lâu thì giữ được khoảng $215\text{ g}$ với mặt PETG trơn (hệ số ma sát $0.3$).

### CHI TIẾT 13: `06_Gripper_Guide.SLDPRT` (Khung dẫn hướng thanh răng)

Khung hộp hở mặt trước, bắt vào vành trước của đế bằng 4 vít M3:

1. **Tấm lưng:** $x \in [193.9, 196.6]$, $y = \pm 19.5$, $z \in [279.7, 324.2]$; khoét $y = \pm 6.5$, $z \ge 289.8$ cho tai và hộp số servo; 4 lỗ $\varnothing 3.4$ trùng lỗ cấy ren của đế.
2. **Hai vách bên:** $|y| \in [17.2, 19.5]$, tới $x = 209.3$ (dừng sau mặt phẳng thanh răng để thanh răng trượt ra hai bên).
3. **Trần và sàn:** $z \in [318.3, 324.2]$ và $z \in [279.7, 283.7]$, tới $x = 215$; mỗi tấm có rãnh $x \in [210.75, 213.25]$ sâu $2.4\text{ mm}$ ôm gờ dẫn hướng của thanh răng. Trần khoét $y = \pm 3$ tại $x \le 199$ để né đầu vít tai servo. Bốn cạnh dọc ngoài của khung bo $R6$.
4. **Phần đỡ gốc ngón:** trần và sàn kéo dài thêm tới $x = 221$ (không có rãnh), đỡ mặt trên của gốc ngón kẹp với khe $0.3\text{ mm}$; bề rộng tựa của mỗi ngón tăng từ $4.7$ lên $11.3\text{ mm}$ nên ngón ít lắc quanh phương trượt.
5. **Thứ tự lắp:** bắt đế vào đĩa sừng $J_5$; lắp servo tay gắp và vít tai; bắt khung dẫn hướng bằng 4 vít M3 × 8 vào lỗ cấy ren của đế; lắp bánh răng cùng đĩa sừng lên trục; đưa hai thanh răng vào từ hai bên cùng lúc trong khi quay bánh răng.

Trong assembly chính: đế tay gắp xoay quanh $J_5$ (Concentric giữa lỗ vít tâm của đế và trụ hộp số servo $J_5$, Distance $0.8\text{ mm}$ từ mặt sau đế tới nóc hộp số); servo tay gắp và khung dẫn hướng khóa vào đế; bánh răng quay trên trục servo tay gắp; hai ngón nằm trong rãnh khung: mỗi ngón có hai mate Distance định vị trong rãnh, một mate Limit Distance $0 	o 23.6	ext{ mm}$ giữa mặt $y = 0$ của ngón và mặt $y = 0$ của khung (`LimitDistance1`, `LimitDistance2`; $23.6	ext{ mm}$ là nửa vòng bánh răng nên thanh răng không rời bánh răng), và một mate Rack Pinion giữa cạnh thẳng dọc thanh răng và lỗ tâm bánh răng với đường kính lăn $15	ext{ mm}$ (`RackPinionMate1`, `RackPinionMate2`). Quay bánh răng thì hai ngón chạy đối xứng trong khoảng độ mở $0 	o 47.2	ext{ mm}$. Công cụ MCP không tạo được hai loại mate này; chúng được tạo bằng macro `cad/tools/gripper_motion_mates.swb` (Tools > Macro > Run khi assembly đang mở). Với cổ tay gập tới $\pm 105^\circ$ và xoay bất kỳ, cổ tay và tay gắp không chạm cẳng tay; ở $+110^\circ$ vấu vít tai của cổ tay chạm thân càng.

Chiều dài động học đo trên assembly: $L_2 = 127.8\text{ mm}$ (từ $J_3$ tại $(9.8, 296.45)$ tới $J_4$ tại $(137.2, 306.23)$, lệch $9.78\text{ mm}$ theo phương vuông góc) và $L_3 = 86.8\text{ mm}$ (từ trục $J_4$ tới rãnh chữ V của ngón kẹp trên trục $J_5$; mút ngón cách $J_4$ $107.8\text{ mm}$). Mã MATLAB (`matlab/kuka_robot_model.m`, `matlab/kuka_gui_control.m`) và `cad/tools/verify_kinematics_5dof.py` dùng đúng hai giá trị này; góc $\theta_3 = 0$ của mô hình ứng với đường thẳng $J_3 \to J_4$, lệch $4.39^\circ$ so với trục thân cẳng tay.

---

### ĐƯỜNG ĐI DÂY SERVO

| Đoạn | Đường đi | Giữ dây |
|---|---|---|
| Tay gắp, $J_5$ $\to$ khoang dây thân càng | rãnh dây của đế tay gắp và của cổ tay, qua lỗ luồn lục giác $\varnothing 6$ ở vách trước thân càng | vòng dây tự do quanh $J_5$ và $J_4$ |
| $J_4$ $\to$ khoang dây thân càng | rãnh ở mặt trong tấm ốp $+Y$, khe dây $9 \times 4.5$ | rãnh tấm ốp |
| Khoang dây $\to$ khối khuỷu | lỗ $\varnothing 10$ tại $(0, 304.5)$ vào khoang bắt ốc của khuỷu, ra miệng sau khuỷu | – |
| Khuỷu $\to$ cánh tay trên | vòng dây tự do quanh $J_3$ (dài khoảng $60\text{ mm}$), nhập thêm dây servo $J_3$ | – |
| Dọc cánh tay trên | ống dẫn dây ở lưng `03_UpperArmKuka` | khe ép $3\text{ mm}$ |
| Cánh tay trên $\to$ turret | vòng dây tự do quanh $J_2$ (dài khoảng $120\text{ mm}$), nhập thêm dây servo $J_2$ | lỗ xỏ ở vấu lưng turret |
| Turret $\to$ đế | vòng dây dự trữ khoảng $80\text{ mm}$ cho $J_1$ quay $\pm 90^\circ$, xuống lỗ $\varnothing 10$ trên nóc hộp sau | lỗ nóc hộp sau |

Chiều dài dây cần từ servo tới shield: tay gắp khoảng $650\text{ mm}$, $J_5$ khoảng $600\text{ mm}$, $J_4$ khoảng $500\text{ mm}$, $J_3$ khoảng $370\text{ mm}$, $J_2$ khoảng $220\text{ mm}$. Dây liền servo MG90S dài $250\text{ mm}$, MG996R và DS3225 dài $300\text{ mm}$, nên cần dây nối dài $500\text{ mm}$ cho tay gắp và $J_5$, $300\text{ mm}$ cho $J_4$, $150\text{ mm}$ cho $J_3$. Đặt các đầu nối trong khoang dây thân càng và khoang bắt ốc, không đặt trong ống dẫn của cánh tay trên.

---

## III. QUY TRÌNH LẮP RÁP TỔNG THỂ TRÊN SOLIDWORKS (`00_Robot_J1J2_Assembly.SLDASM`)

### 1. Nguyên tắc cố định gốc:
* Chèn chi tiết đầu tiên: `01_Base_Kuka.SLDPRT`. Click chuột phải chọn **`Fix`** (gắn chặt vào gốc tọa độ Assembly).

### 2. Thiết lập các ràng buộc (Mates) chuẩn động học:
1. **Khớp xoay $J_1$ (turret trên đĩa sừng 25T và mặt đế):**
   * `Concentric Mate`: Hốc đĩa sừng $\varnothing 20.4\text{ mm}$ của `02_Turret_ForkKuka` đồng tâm với vành đĩa sừng $J_1$ (đĩa sừng và servo $J_1$ cố định theo đế).
   * `Coincident Mate`: Mặt tựa hốc đĩa sừng của turret ($z = 91.85$) tiếp xúc mặt trên vành đĩa sừng trên trục servo $J_1$.
   * `Lock Mate`: servo $J_2$, vòng bi 698ZZ và `03_J2_BearingSpacer` khoá vào turret.
2. **Khớp vai $J_2$ (Upper Arm xoay trong lòng Turret):**
   * `Concentric Mate`: Lỗ tâm $\varnothing 7\text{ mm}$ của tấm bắt sừng `03_UpperArmKuka` đồng tâm với lỗ ổ bi $\varnothing 19.1\text{ mm}$ ở tai $-Y$ của càng.
   * `Distance Mate`: Mặt ngoài tấm ổ bi của cánh tay ($y = -25.97$) cách mặt trong tai ổ bi ($y = -26.46$) $0.49\text{ mm}$.
   * `Lock Mate`: đĩa sừng $J_2$ và servo $J_3$ khoá vào cánh tay.
3. **Khớp khuỷu $J_3$ (khối khuỷu trên cánh tay trên):**
   * `Concentric Mate`: lỗ tâm của `04_Forearm_ElbowKuka` đồng tâm với lỗ ổ bi ở tai $-Y$ đầu $J_3$ của cánh tay.
   * `Distance Mate`: khối khuỷu cách tai ổ bi $0.5\text{ mm}$.
   * `Lock Mate`: đĩa sừng $J_3$ khoá vào khối khuỷu.
4. **Thân càng cẳng tay:** `04_Forearm_ForkKuka` ngồi trong khối khuỷu bằng `Concentric` + `Coincident`; servo $J_4$ và hai tấm ốp khoá vào thân càng.
5. **Khớp cổ tay $J_4$, $J_5$ và tay gắp:** theo mô tả ở cuối mục cổ tay và mục tay gắp (cổ tay: `Concentric` + `Distance` $0.41\text{ mm}$; đế tay gắp: `Concentric` + `Distance` $0.8\text{ mm}$; hai ngón: ba mate `Distance` mỗi ngón).

Assembly có 28 component và 35 mate. Cố định (`Fix`): đế, khay, servo và đĩa sừng $J_1$, Arduino Uno và shield PCA9685. Arduino và shield đặt bằng tọa độ, lệch $0.2\text{ mm}$ về phía $+Z$ của assembly so với tâm khoang điện.

Kéo turret, cánh tay, khối khuỷu, cổ tay hoặc đế tay gắp trong SolidWorks để xoay $J_1$ đến $J_5$.

### 3. Kiểm tra va chạm & Góc quay vật lý (Limit Angle Mate):
* Xuất STL từng component rồi chạy `python cad/tools/check_interference_stl.py <thư_mục>`; đối chiếu thêm bằng **`Evaluate` $\rightarrow$ `Interference Detection`**. Ở tư thế lưu trong file, Interference Detection chỉ báo trục then hoa của ba servo cỡ chuẩn lún vào đĩa sừng ($J_1$, $J_2$, $J_3$), là mối ghép ép có chủ ý.
* Giới hạn góc quay bằng `Advanced Mate` $\rightarrow$ `Angle Mate`:
  * $J_1$: $-90^\circ \to +90^\circ$ (giới hạn bởi servo $180^\circ$; cơ khí quay được trọn vòng).
  * $J_2$: $-45^\circ \to +165^\circ$ (cánh tay chạm thân turret ở $-60^\circ$).
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
   * Mật độ độn (Infill): **$15\% - 20\%$** cho các khối thân KUKA lớn (đế, turret, cánh tay); **$30\% - 40\%$ Gyroid** cho chi tiết nhỏ chịu lực.
   * Lớp trên/dưới (Top/Bottom layers): 5 lớp.
