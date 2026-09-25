# Rebrand — xoá branding "v2 R.A.D." khỏi CAD

> Trả lời câu hỏi: **làm sao bỏ tên "V2 R.A.D." khỏi chi tiết in.**

## 1. Branding nằm ở đâu

Chữ trong ảnh chụp chi tiết **không phải text entity của STEP** (file STEP không
chứa `DRAUGHTING`/`ANNOTATION` nào — đã kiểm chứng). Nó được **khắc thành hình
học solid thật**, nên phải xoá bằng hình học.

Khảo sát toàn bộ 2 file STEP tìm mặt phẳng có nhiều wire bất thường (dấu hiệu
chữ khắc). Kết quả: **có 2 vị trí branding**, không phải 1.

### Vị trí 1 — `Base Cover` (v2RAD), mặt đáy `Z = -75.93 mm`

Một mặt phẳng **8330 mm² với 38 wire** (1 bao ngoài + **37 đường bao glyph**).
Khắc sâu **2 mm**. Nội dung (đọc từ render, gương theo trục X vì nhìn từ dưới):

```
KELTON SERRA
DESIGNED BY
v2 R.A.D.
```

Toạ độ vùng chữ: `X[-25.5, 25.5]`, `Y[-16.8, 45.7]`
- Dòng 1 `KELTON SERRA`  : Y 37.6 … 45.6, cao 8.0 mm, 9 glyph
- Dòng 2 `DESIGNED BY`   : Y 26.3 … 33.4, cao 7.0 mm, 9 glyph
- Dòng 3 `v2 R.A.D.`     : Y −16.8 … −4.8, cao 12.0 mm, 4 nhóm glyph

### Vị trí 2 — `Base (CD)` (bộ điều khiển v2CD), mặt `Z = -39.5 mm`

Một mặt phẳng **1192 mm² với 18 wire** → **16 glyph xếp thành VÒNG CUNG** quanh
tâm, từ góc −180° đến +155°. Nội dung: **"DESIGNED BY KELTON"** uốn cong.

| Góc | Tâm (x, y) | Cỡ (mm) |
|---|---|---|
| −179.8° | (−10.0, 0.0) | 7.1 × 3.4 |
| −158.9° | (−9.6, −3.7) | 7.1 × 2.4 |
| −138.9° | (−8.5, −7.4) | 6.8 × 4.9 |
| −115.3° | (−5.6, −11.8) | 7.6 × 7.2 |
| −96.6° | (−1.8, −15.2) | 6.3 × 7.5 |
| … | … | … |
| +154.5° | (−9.5, 4.5) | 7.5 × 4.7 |

## 2. Cách xoá

### `Base Cover` — đã tự động hoá ✅

```bash
python cad/tools/rebrand_remove_text.py
```

Cách làm: **boolean FUSE với một pad phẳng** phủ đúng vùng chữ, từ `Z = -76.2`
lên `Z = -73.93` (đáy rãnh khắc). Pad lấp mọi rãnh chữ và tạo mặt đáy phẳng.

Kết quả kiểm chứng:

| Chỉ số | Trước | Sau |
|---|---|---|
| Số mặt ở `Z=-75.93` | 276 | 1 |
| Số wire mặt đáy | 38 | 10 |
| Wire cỡ glyph | 37 | **0** |
| Thể tích | 25.0661 cm³ | 26.6087 cm³ (+1542 mm³) |
| Solid hợp lệ | ✓ | ✓ |

Kết quả: `cad/exports/rebranded/Base-Cover-rebranded.step` (+ `.stl`).
Ảnh kiểm chứng: `cad/exports/rebranded/verify-Base-Cover-no-text.png`.

**Vì sao không dùng cách khác** (đã thử và loại):

| Cách | Kết quả |
|---|---|
| Boolean **cut** hộp bao vùng chữ | Tạo HỐ, mất ~7 cm³ → **sai** |
| Xoá mặt rồi **sewing** ghép lại | Shell không kín, solid **invalid** |
| Ép từng mặt rãnh rồi fuse | Mặt rãnh phân mảnh, fuse **lỗi** |
| **Fuse với pad phẳng** | ✅ hợp lệ, +1542 mm³ |

### `Base (CD)` — chưa tự động hoá ⚠️

Chữ xếp vòng cung nên không thể dùng một pad chữ nhật (sẽ đắp cả vùng giữa
vòng cung, sai hình dạng). Hai cách:

1. **Khuyến nghị — sửa trong CAD:** import
   `cad/exports/v2cd/step/Base-CD.step` vào Onshape/Fusion, sketch một **hình
   vành khuyên** (annulus) phủ vòng chữ, `Extrude > Remove` sâu ~1 mm.
2. **Hoặc** bỏ qua: chữ này nằm ở **mặt đáy** bộ điều khiển, khi lắp lên bàn sẽ
   **không nhìn thấy**. Nếu không ai soi đáy thì không cần xoá.

## 3. Vì sao không dùng chữ khắc của tác giả

Thiết kế theo giấy phép **CC BY-NC-ND 4.0** (xem `README.md`).

| ✅ Được phép | ❌ Không được phép |
|---|---|
| In để học tập, làm đồ án | Dùng cho mục đích **thương mại** |
| Ghi công tác giả đầy đủ | **Chia sẻ bản sửa đổi / remix** (NoDerivatives) |
| Dùng nguyên bản | Chia sẻ mà không ghi công |

> ⚠️ **Điểm quan trọng cho đồ án:** điều khoản **ND (NoDerivatives)** không cho
> phép phát hành bản sửa đổi. Nhóm cần **thiết kế lại** nếu muốn phát triển tiếp,
> hoặc dùng thiết kế này thuần như **tham khảo + học tập**. Việc xoá branding
> **không** làm thay đổi nghĩa vụ ghi công — vẫn phải ghi công tác giả trong
> thuyết minh (đã có ở `README.md` mục "Ghi công nguồn tham khảo").

## 4. Nếu muốn rebrand (khắc tên nhóm)

Sau khi chạy script, mở `cad/exports/rebranded/Base-Cover-rebranded.step` trong
Onshape/Fusion và khắc chữ mới lên mặt đáy. Mặt đáy lúc này đã **phẳng hoàn
toàn**, khắc chữ mới rất dễ.

Lưu ý: nếu khắc lên mặt đáy (mặt tiếp xúc bàn in), chữ sẽ in ra **mặt đầu tiên**
— cần brim hoặc mặt đáy phẳng để bám tốt.

## 5. Công cụ liên quan

| File | Chức năng |
|---|---|
| `cad/tools/render_engraving.py` | Trích + vẽ mặt khắc chữ `Base Cover` ra PNG |
| `cad/tools/rebrand_remove_text.py` | Xoá chữ khắc `Base Cover` (đã kiểm chứng) |
| `cad/tools/split_step_parts.py` | Tách 33 chi tiết, kèm manifest có đường kính lỗ ổ bi |
