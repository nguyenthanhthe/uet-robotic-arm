# Thông số động học đo từ CAD — v2 R.A.D.

> Tài liệu này chứa **số đo thật** trích trực tiếp từ
> `hardware/reference/v2rad-all-parts.step` bằng OpenCASCADE, dùng để thay các
> placeholder $L_1, L_2, L_3, h_0$ trong `docs/typst/kinematics.typ`.

## 1. Cách đo

Các **tâm khớp** được xác định từ **lỗ ổ bi** (mặt trụ lớn) trong CAD, không
phải ước lượng bằng mắt. Mỗi khớp quay có một cặp lỗ ổ bi đồng trục đường kính
lớn — đó chính là trục khớp.

Công cụ: OpenCASCADE qua `OCP`, quét `GeomAbs_Cylinder` trên mọi mặt của từng
solid. Xem `cad/tools/split_step_parts.py`.

## 2. Hệ toạ độ

CAD export ở **tư thế đã lắp** (assembled pose). Chọn hệ toạ độ như sau:

| Trục | Định nghĩa |
|---|---|
| $z$ | Trục quay của thân (base yaw), hướng lên |
| $y$ | Hướng cánh tay duỗi ra khi lắp (trong CAD: $+y$ là về phía elbow) |
| $x$ | Trục của các khớp shoulder / elbow / wrist |

**Gốc toạ độ**: giao của trục thân với **trục khớp shoulder**.
Trong CAD: điểm `(0, -10, 0)`.

## 3. Tâm các khớp (đo từ lỗ ổ bi)

| Khớp | Trục quay | Điểm trên trục (CAD, mm) | Bằng chứng (lỗ ổ bi) |
|---|---|---|---|
| $J_1$ thân (yaw) | $z$ | $(0,\ -10,\ *)$ | `Shoulder Base` Ø74/70, `Base Main` Ø82/92 |
| $J_2$ shoulder | $x$ | $(0,\ -10,\ 0)$ | `Main Arm Main` Ø40 (DT 2576 mm²), `Shoulder L/R` Ø40 |
| $J_3$ elbow | $x$ | $(0,\ 50,\ 0)$ | `Forearm Main` Ø40 (DT 2576 mm²), `Main Arm L/R` Ø40 |
| $J_4$ wrist | $x$ | $(0,\ -27.5,\ 35)$ | `Wrist L/R` Ø30 (DT 966 mm²), `Forearm R/L` Ø30 |
| $J_5$ pulley | $x$ | $(0,\ 8,\ 35)$ | `Forearm R/L` Ø30 (DT 188 mm²) |

> **Phát hiện quan trọng:** có **5 trục quay**, không phải 4. Ngoài 4 khớp động
> còn một **pulley trung gian** tại $(0, 8, 35)$ — cùng cao độ $z=35$ với khớp
> cổ tay. Đây là cơ cấu **truyền đai/pulley** cho cổ tay (kiểu parallelogram),
> không phải một bậc tự do điều khiển riêng.

## 4. Chiều dài link (khoảng cách giữa các tâm khớp)

Đo trực tiếp từ toạ độ tâm khớp:

| Ký hiệu | Ý nghĩa | Giá trị |
|---|---|---|
| $L_1$ | shoulder → elbow | **60.00 mm** |
| $L_2$ | elbow → wrist | **85.04 mm** $\left(=\sqrt{77.5^2 + 35^2}\right)$ |
| $L_3$ | wrist → tâm đầu gắp | **≈ 41.3 mm** |
| $h_0$ | mặt bàn (đáy base) → trục shoulder | **73.9 mm** |

Chi tiết $L_2$: trong mặt phẳng dọc, elbow→wrist lệch $\Delta y = -77.5$ mm và
$\Delta z = +35$ mm, nên $L_2 = \sqrt{77.5^2 + 35^2} = 85.04$ mm.

Chi tiết $L_3$: đầu ngón gắp ở $y = -64.6$ mm, tâm theo $z \approx 16.8$ mm;
khoảng cách từ wrist $(0, -27.5, 35)$ tới đầu ngón là 41.3 mm.

## 5. Kiểm tra tầm với so với yêu cầu 200 mm

⚠️ **Đây là điểm cần lưu ý cho đồ án.**

Tầm với lý thuyết khi duỗi thẳng hoàn toàn (các link thẳng hàng):

$$R_{\max} = L_1 + L_2 + L_3 = 60.00 + 85.04 + 41.32 = 186.4\ \text{mm}$$

**Kết luận: 186.4 mm < 200 mm — KHÔNG đạt yêu cầu tầm với tối thiểu.**

Nguyên nhân: thiết kế v2 R.A.D. gốc là cánh tay **để bàn nhỏ gọn** (compact
desktop arm), tác giả không nhắm tới 200 mm.

Vì $L_2$ nằm lệch 35 mm theo $z$, hình chiếu ngang khi duỗi thẳng chỉ còn:

$$R_{\text{ngang}} \approx 60 + 77.5 + 37.1 = 174.6\ \text{mm}$$

### Ba phương án xử lý

| # | Phương án | Ưu | Nhược |
|---|---|---|---|
| 1 | **Kéo dài link** ($L_1, L_2$) theo tỉ lệ | Giữ nguyên kiến trúc, chỉ sửa kích thước | Phải in lại, kiểm tra lại moment servo |
| 2 | **Chấp nhận và giải thích** trong thuyết minh | Không tốn công | Mất điểm tiêu chí tầm với |
| 3 | Thiết kế lại cánh tay dài hơn | Đạt yêu cầu rõ ràng | Nhiều công, rủi ro tiến độ |

**Khuyến nghị:** phương án 1. Cần tăng tổng link thêm **≥ 15 mm** để vượt 200 mm
có dư an toàn — ví dụ kéo dài $L_1$ từ 60 → 75 mm (hệ số 1.25) cho
$R_{\max} \approx 201$ mm, hoặc kéo dài cả $L_1$ và $L_2$ hệ số 1.15 cho
$R_{\max} \approx 214$ mm.

⚠️ Khi kéo dài link **phải tính lại moment servo**: moment tĩnh tăng theo chiều
dài tay đòn, nên servo SG90 có thể không còn đủ. Xem mục 7.

## 6. Bảng tham số Denavit–Hartenberg (đề xuất)

Với kiến trúc articulated 4 DOF, các khớp 2–4 song song trong mặt phẳng dọc:

| Khớp $i$ | $\theta_i$ | $d_i$ | $a_i$ | $\alpha_i$ |
|---|---|---|---|---|
| 1 (thân) | $\theta_1$ | $h_0 = 73.9$ | $0$ | $\pi/2$ |
| 2 (shoulder) | $\theta_2$ | $0$ | $L_1 = 60.0$ | $0$ |
| 3 (elbow) | $\theta_3$ | $0$ | $L_2 = 85.0$ | $0$ |
| 4 (wrist) | $\theta_4$ | $0$ | $L_3 = 41.3$ | $0$ |

> **Lưu ý về mô hình hoá:** bảng DH trên là mô hình **articulated 4 DOF lý
> tưởng**. Thực tế v2 R.A.D. dùng **truyền đai cho cổ tay** (pulley tại
> $(0,8,35)$), nên góc cổ tay thực tế là **tổ hợp** của góc servo cổ tay và góc
> elbow — cần mô hình hoá thêm hệ số truyền nếu muốn chính xác. Với báo cáo,
> nên nêu rõ giả thiết đơn giản hoá này.

## 7. Kiểm tra moment servo (cần làm trước khi chốt)

Tải tối đa 50 g tại tầm với xa nhất. Moment tĩnh xấu nhất ở khớp shoulder:

$$T_{\text{static}} = \underbrace{m_{\text{payload}} \cdot g \cdot R_{\max}}_{\text{vật gắp}} + \underbrace{\sum_i m_i \cdot g \cdot r_i}_{\text{khối lượng các link}}$$

Với $m = 50\ \text{g} = 0.05$ kg, $g = 9.81$, $R = 0.186$ m:

$$T_{\text{payload}} = 0.05 \times 9.81 \times 0.186 \approx 0.091\ \text{N·m} \approx 0.93\ \text{kg·cm}$$

Cộng khối lượng các link (xem khối lượng trong `cad/exports/v2rad/PARTS.md`)
thì moment tổng lớn hơn đáng kể. **SG90 (≈1.8 kg·cm) có thể không đủ** — nên
dùng **MG90S (≈2.2 kg·cm)** hoặc **MG996R (≈10 kg·cm)** cho khớp shoulder.

> Cần tính đầy đủ trong thuyết minh (mục "Statics & Dynamics" theo yêu cầu
> `goal.md`).

## 8. Cách tái tạo số đo

```bash
# Xuất từng chi tiết (kèm manifest có kích thước, khối lượng, đường kính lỗ)
python cad/tools/split_step_parts.py --verify

# Xem báo cáo khắc chữ
python cad/tools/render_engraving.py
```
