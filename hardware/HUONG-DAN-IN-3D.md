# Hướng dẫn in 3D — Arduino Robot Arm & Controller v2 (R.A.D.)

> **Nguồn CAD:** [printables.com/model/1834841](https://www.printables.com/model/1834841-arduino-robot-arm-and-controller-v2-rad/files)
> — thiết kế của **Kelton Serra (Build Some Stuff)**, giấy phép **CC BY-NC-ND 4.0**.
> Chỉ dùng cho mục đích học tập, **không thương mại**. Xem mục [Ghi công & giấy phép](#ghi-công--giấy-phép).

Tài liệu này giải thích **cách in từng chi tiết** trong `hardware/reference/`, dựa trên
chính file `v2rad-and-v2cd-printgcode.3mf` — đây **không phải** file model rời, mà là
**project Bambu Studio đã slice sẵn** (đã có toolpath `.gcode`), nên toàn bộ thông số
dưới đây là **số liệu thật do slicer tính**, không phải ước lượng.

---

## 1. Bạn có gì trong `hardware/reference/`

| File | Kích thước | Vai trò |
|---|---|---|
| `v2rad-and-v2cd-printgcode.3mf` | 9.7 MB | ⭐ **File in chính** — project Bambu Studio đã slice, 4 plate, có sẵn gcode |
| `v2rad-all-parts.step` | 5.4 MB | CAD cánh tay robot — **24 solid** đã đặt tên |
| `v2cd-all-parts.step` | 1.9 MB | CAD bộ điều khiển — **9 solid** đã đặt tên |
| `1834841-...-rad-....pdf` | 509 KB | Trang mô tả trên Printables (không phải hướng dẫn lắp) |

### Vì sao dùng file `.3mf` mà không phải `.step`?

File `.3mf` **đã được tác giả slice và xếp plate sẵn**. Mở nó ra là in được ngay,
không phải suy nghĩ về hướng đặt chi tiết, brim, hay support. File `.step` chỉ để
tham chiếu kích thước / sửa thiết kế.

> ⚠️ **Đừng** tự slice lại từ STEP nếu chưa có kinh nghiệm: 33 chi tiết này được tác giả
> xoay hướng cẩn thận để **in không cần support**. Tự xoay lại rất dễ sai hướng.

---

## 2. Tổng quan: 33 chi tiết / 4 plate

| Plate | Tên plate | Số chi tiết | Số layer | Thời gian in | Nhựa |
|---|---|---|---|---|---|
| **1** | `ROBOT ARM (v2RAD) p1` | 4 | 242 | 2h 56m 51s | 91.49 g |
| **2** | `ROBOT ARM (v2RAD) p2` | 6 | 212 | 2h 57m 19s | 87.46 g |
| **3** | `ROBOT ARM (v2RAD) p3` | 14 | 73 | 1h 47m 43s | 47.08 g |
| **4** | `CONTROLLER (v2CD)` | 9 | 150 | 1h 11m 57s | 27.26 g |
| | **TỔNG** | **33** | | **~8h 54m** | **253.29 g** |

Cộng thời gian chuẩn bị (làm nóng, leveling, AMS load) thì tổng thực tế **~9h 22m**.

**Nhựa cần mua:** 253 g là nhựa *thực sự in ra chi tiết*. Cộng thêm purging/prime tower
và hao hụt, nên chuẩn bị **1 cuộn PLA 1 kg** — thừa sức in cả bộ, kể cả khi in hỏng vài chi tiết.

---

## 3. Thông số in — dùng đúng như file đã lưu

Mở `.3mf` bằng **Bambu Studio** (hoặc OrcaSlicer), profile đã được nhúng sẵn:

| Thông số | Giá trị | Ghi chú |
|---|---|---|
| Máy in | **Bambu Lab P2S**, nozzle **0.4 mm** | Profile `0.20mm Standard @BBL P2S` |
| Vật liệu | **PLA** (Generic PLA @BBL P2S) | Nhiệt độ **220 °C** |
| Bed | **Textured PEI Plate**, **55 °C** | |
| Chiều cao layer | **0.20 mm** (layer đầu 0.20) | |
| Thành (wall loops) | **2** | |
| Lớp top / bottom | **5 / 3** | |
| Infill | **15 %, grid** | |
| Support | **KHÔNG DÙNG** ✅ | `enable_support = 0` — đã kiểm chứng: **0 lệnh support** trong cả 4 gcode |
| Brim | `auto_brim`, rộng **5 mm** | Đặt auto nhưng slicer **không sinh brim nào** — 33 chi tiết đều tự bám tốt |
| Seam | aligned | |
| Flow ratio | 0.98 | |
| Fan | bật, 100 % sau layer đầu | |

### 🔑 Ba điểm quan trọng nhất

1. **KHÔNG bật support.** Tác giả thiết kế để in support-free — đã kiểm chứng bằng cách
   quét toàn bộ gcode: **0 lệnh support**. Bật support lên sẽ làm hỏng bề mặt khớp và rất
   khó lấy ra ở các hốc ổ bi.
2. **In đúng hướng như file.** Chi tiết đã nằm đúng mặt phẳng in — không xoay lại.
3. **Không cần brim.** Tuy profile đặt `auto_brim` 5 mm, slicer **không sinh brim** cho chi
   tiết nào. Nếu máy/bed của bạn bám kém hơn P2S + PEI, cứ bật brim thủ công cho
   `Base Main` và `Main Arm Main` (hai chi tiết cao nhất).

### Nếu dùng máy in khác (Prusa, Ender, Voron…)

Vẫn mở được `.3mf` bằng OrcaSlicer/PrusaSlicer, nhưng **phải đổi printer profile** sang
máy của bạn. Giữ nguyên: **PLA, 0.2 mm layer, 2 wall, 15 % infill, không support, brim 5 mm**.
Nếu bed nhỏ hơn 256×256 mm thì in lại từng plate theo nhóm ở mục 4.

---

## 4. Chi tiết từng plate

> Cột **"cao"** = chiều cao in thật (trục Z khi in), lấy từ header gcode.

### 🟦 PLATE 1 — `ROBOT ARM (v2RAD) p1` — 4 chi tiết, 91.49 g

Phần **đế xoay (base)**. Đây là plate in lâu nhất vì `Base Main` rất cao.

| Chi tiết | Kích thước (mm) | Cao | Khối lượng |
|---|---|---|---|
| **Base Main** | 88.2 × 111.0 × 48.4 | 48.40 | ~28.8 g |
| **Base Cover** | 87.9 × 111.4 × 30.5 | 30.60 | ~26.3 g |
| **Shoulder Base** | 74.0 × 42.2 × 8.0 | 8.00 | ~13.5 g |
| **Shoulder Ring** | 80.7 × 81.9 × 4.5 | 4.40 | ~3.2 g |

`Shoulder Ring` là vành mỏng 4.5 mm đường kính ~81 mm — **mặt phẳng lớn, dễ cong góc**.
Slicer không sinh brim cho chi tiết này; nếu bị cong, tăng bed temp lên 60 °C cho plate này.

### 🟩 PLATE 2 — `ROBOT ARM (v2RAD) p2` — 6 chi tiết, 87.46 g

Phần **cánh tay chính (main arm) + forearm**.

| Chi tiết | Kích thước (mm) | Cao | Khối lượng |
|---|---|---|---|
| **Main Arm Main** | 42.5 × 56.0 × 40.0 | 42.40 | ~39.5 g |
| **Forearm Main** | 42.5 × 81.5 × 68.3 | 42.40 | ~22.3 g |
| **Wrist Right** | 24.3 × 38.4 × 38.4 | 24.20 | ~8.8 g |
| **Wrist Left** | 22.0 × 38.4 × 38.4 | 22.00 | ~8.1 g |
| **Forearm Cover** | 3.8 × 81.5 × 54.9 | 3.80 | ~6.9 g |
| **Main Arm Cover** | 3.8 × 44.0 × 40.0 | 3.80 | ~3.5 g |

Hai chi tiết **Cover** chỉ dày 3.8 mm nhưng rộng — in nằm phẳng, để mặt đẹp hướng lên trên
(sẽ lộ ra ngoài khi lắp).

### 🟨 PLATE 3 — `ROBOT ARM (v2RAD) p3` — 14 chi tiết, 47.08 g

**Các chi tiết nhỏ**: khớp vai, ngón gắp, bánh răng, thanh răng. Plate nhanh nhất.

| Chi tiết | Kích thước (mm) | Cao | Khối lượng |
|---|---|---|---|
| **Shoulder Left** | 7.8 × 40.0 × 30.6 | 8.00 | ~6.7 g |
| **Shoulder Right** | 7.8 × 40.0 × 37.0 | 7.80 | ~6.7 g |
| **Forearm Left** | 9.5 × 50.2 × 30.0 | 9.60 | ~6.0 g |
| **Main Arm Right** | 8.0 × 55.5 × 40.0 | 7.80 | ~4.9 g |
| **Main Arm Left** | 8.0 × 46.7 × 40.0 | 8.00 | ~4.6 g |
| **Forearm Right** | 8.0 × 43.6 × 30.0 | 7.80 | ~3.4 g |
| **Gripper Left** | 7.0 × 37.9 × 37.9 | 7.00 | ~2.8 g |
| **Gripper Right** | 7.0 × 37.9 × 37.9 | 7.00 | ~2.7 g |
| **Wrist Pulley** | 8.5 × 20.6 × 18.0 | 8.60 | ~1.6 g |
| **Gripper Gear** | 17.5 × 15.9 × 15.9 | 14.60 | ~1.4 g |
| **Controller Plug Cover** | 24.0 × 14.0 × 16.4 | 14.60 | ~1.4 g |
| **Gripper Rack Left** | 30.3 × 12.7 × 11.3 | 6.80 | ~1.4 g |
| **Gripper Rack Right** | 30.3 × 11.3 × 12.7 | 5.00 | ~1.2 g |
| **Pulley Servo Horn** | 4.0 × 16.7 × 12.4 | 4.00 | ~0.8 g |

> ⚠️ **`Gripper Gear` + `Gripper Rack`**: răng rất nhỏ. In **chậm** (giảm outer wall speed
> xuống 100 mm/s) và **bật fan mạnh** để răng sắc nét. Nếu răng bị dính, dùng dao nhỏ gỡ,
> **đừng** dùng lửa.

### 🟥 PLATE 4 — `CONTROLLER (v2CD)` — 9 chi tiết, 27.26 g

Bộ **tay điều khiển cầm tay** (v2CD) — 9 chi tiết khớp với 9 solid trong `v2cd-all-parts.step`:

| Chi tiết | Kích thước (mm) | Cao |
|---|---|---|
| **Base (CD)** | 47.6 × 43.8 × 13.0 | ~13.0 |
| **Forearm Main (CD)** | 14.8 × 43.4 × 26.3 | ~14.8 |
| **Shoulder (CD)** | 20.4 × 21.5 × 21.5 | ~30.0 |
| **Main Arm (CD)** | 15.0 × 26.0 × 20.0 | ~15.0 |
| **Base Cover (CD)** | 23.9 × 21.5 × 11.5 | ~11.6 |
| **Wrist Right (CD)** | 9.0 × 21.0 × 20.9 | ~9.0 |
| **Wrist Left (CD)** | 8.0 × 21.0 × 18.9 | ~8.0 |
| **Forearm Left (CD)** | 3.0 × 24.6 × 17.7 | ~3.0 |
| **Main Arm Left (CD)** | 3.0 × 21.0 × 20.0 | ~3.0 |

`Shoulder (CD)` in **dựng đứng** (cao 30 mm) — chi tiết cao nhất của plate này.

---

## 5. Quy trình in từng bước

### Bước 1 — Mở file
```
Mở Bambu Studio → File → Open → hardware/reference/v2rad-and-v2cd-printgcode.3mf
```
File mở ra sẽ hiện **4 plate** ở thanh dưới. Mỗi plate đã xếp sẵn chi tiết.

### Bước 2 — Kiểm tra trước khi in
- Chọn từng plate → xem preview, kéo thanh layer để chắc chắn **không có support**.
- Kiểm tra `bed_type = Textured PEI Plate` — nếu máy bạn dùng plate khác thì đổi lại.
- Nếu dùng máy không phải P2S: đổi printer profile, rồi **kiểm tra lại từng chi tiết có
  nằm trong bed không** (plate 1 cần ~230×230 mm).

### Bước 3 — In
In **lần lượt plate 1 → 2 → 3 → 4**. Có thể in riêng lẻ từng plate, không bắt buộc liên tục.

| Plate | Thời gian | Nhựa |
|---|---|---|
| 1 | ~2h 57m | 91.5 g |
| 2 | ~2h 57m | 87.5 g |
| 3 | ~1h 48m | 47.1 g |
| 4 | ~1h 12m | 27.3 g |

### Bước 4 — Sau khi in
1. **Để nguội hoàn toàn** trên bed trước khi gỡ (PLA + PEI plate → tự bong khi nguội).
2. **Giũa mép** chi tiết bằng giấy nhám 400 (nếu bạn có bật brim thủ công thì gỡ brim trước).
3. **Nong lỗ** bằng mũi khoan/que tròn nếu lỗ ổ bi bị co (in FDM hay co ~0.1–0.2 mm).
4. **Thử lắp khô (dry fit)** từng khớp trước khi lắp servo.

### Bước 5 — Lắp
File `assembly_step.json` trong `.3mf` có **1 bước lắp duy nhất** ("Final assembly") —
tức là tác giả **không kèm hướng dẫn lắp từng bước**. Tham khảo video của tác giả:
**https://www.youtube.com/watch?v=l2aaTA869cc**

---

## 6. Danh sách 33 chi tiết đầy đủ (từ STEP)

### Cánh tay robot — `v2rad-all-parts.step` (24 solid)

| # | Tên trong CAD | Kích thước (mm) |
|---|---|---|
| 1 | Base Main | 88.2 × 111.0 × 48.4 |
| 2 | Base Cover | 87.9 × 111.4 × 30.5 |
| 3 | Shoulder Ring | 80.7 × 81.9 × 4.5 |
| 4 | Shoulder Base | 74.0 × 42.2 × 8.0 |
| 5 | Shoulder Left | 7.8 × 40.0 × 30.6 |
| 6 | Shoulder Right | 7.8 × 40.0 × 37.0 |
| 7 | Main Arm Main | 42.5 × 56.0 × 40.0 |
| 8 | Main Arm Left | 8.0 × 46.7 × 40.0 |
| 9 | Main Arm Right | 8.0 × 55.5 × 40.0 |
| 10 | Main Arm Cover | 3.8 × 44.0 × 40.0 |
| 11 | Forearm Main | 42.5 × 81.5 × 68.3 |
| 12 | Forearm Left | 9.5 × 50.2 × 30.0 |
| 13 | Forearm Right | 8.0 × 43.6 × 30.0 |
| 14 | Forearm Cover | 3.8 × 81.5 × 54.9 |
| 15 | Wrist Left | 22.0 × 38.4 × 38.4 |
| 16 | Wrist Right | 24.3 × 38.4 × 38.4 |
| 17 | Wrist Pulley | 8.5 × 20.6 × 18.0 |
| 18 | Pulley Servo Horn | 4.0 × 16.7 × 12.4 |
| 19 | Gripper Left | 7.0 × 37.9 × 37.9 |
| 20 | Gripper Right | 7.0 × 37.9 × 37.9 |
| 21 | Gripper Gear | 17.5 × 15.9 × 15.9 |
| 22 | Gripper Rack Left | 30.3 × 12.7 × 11.3 |
| 23 | Gripper Rack Right | 30.3 × 11.3 × 12.7 |
| 24 | Controller Plug Cover | 24.0 × 14.0 × 16.4 |

### Bộ điều khiển — `v2cd-all-parts.step` (9 solid)

| # | Tên trong CAD | Kích thước (mm) |
|---|---|---|
| 25 | Base (CD) | 47.6 × 43.8 × 13.0 |
| 26 | Base Cover (CD) | 23.9 × 21.5 × 11.5 |
| 27 | Shoulder (CD) | 20.4 × 21.5 × 21.5 |
| 28 | Main Arm (CD) | 15.0 × 26.0 × 20.0 |
| 29 | Main Arm Left (CD) | 3.0 × 21.0 × 20.0 |
| 30 | Forearm Main (CD) | 14.8 × 43.4 × 26.3 |
| 31 | Forearm Left (CD) | 3.0 × 24.6 × 17.7 |
| 32 | Wrist Left (CD) | 8.0 × 21.0 × 18.9 |
| 33 | Wrist Right (CD) | 9.0 × 21.0 × 20.9 |

> **CD** = hậu tố tác giả dùng cho bộ **controller** (bộ điều khiển cầm tay). Bộ này là một
> bản thu nhỏ lặp lại cấu trúc cánh tay (base / shoulder / main arm / forearm / wrist) để làm
> **tay gáy điều khiển** — chạy chung file `v2rad_code.ino`.

---

## 7. Linh kiện cần mua (không in được)

Từ mô tả của tác giả và yêu cầu kỹ thuật của nhóm:

- **Arduino Nano** (+ cáp USB Mini/Micro tùy board)
- **Servo SG90 / MG90S** — đế xoay + các khớp; **MG90S** cho gripper (moment khỏe hơn)
- **Ổ bi / vòng bi** cho các khớp quay (đường kính theo lỗ trong STEP — đo lại sau khi in)
- **Vít M3** các loại (m2.5/M3 × 8, 10, 12, 16 mm) + **đai ốc chèn nhiệt (heat-set insert)**
- **Nguồn riêng cho servo** — ⚠️ **KHÔNG** cấp servo từ chân 5V của Arduino (sẽ sụt áp gây reset),
  xem `docs/yêu-cầu-kỹ-thuật.md` mục 4.
- Dây jumper, breadboard / nút bấm

> Tác giả có link Amazon cho toàn bộ linh kiện trong phần mô tả video:
> **https://www.youtube.com/watch?v=l2aaTA869cc**

---

## 8. Xử lý sự cố thường gặp

| Vấn đề | Nguyên nhân | Cách xử lý |
|---|---|---|
| `Base Main` / `Main Arm Main` bị đổ giữa chừng | Chi tiết cao, bám bed kém | Rửa bed bằng IPA, tăng bed 60 °C, bật brim thủ công 5 mm, chậm 50 % tốc độ ở 20 layer đầu |
| Răng `Gripper Gear` / `Rack` bị dính | Quá nhiệt, in quá nhanh | Giảm nozzle xuống 210 °C, outer wall speed ≤ 100 mm/s, fan 100 % |
| Lỗ ổ bi quá chặt | FDM co ngót ~0.1–0.2 mm | Nong bằng mũi khoan đúng cỡ, hoặc tăng `xy_contour_compensation` +0.1 |
| Chi tiết dính chặt bed, khó gỡ | Chưa nguội | Đợi nguội hẳn — PLA tự bong khỏi PEI |
| Bề mặt khớp bị nhám | Đây là **mặt tiếp xúc bed** | Hướng mặt đẹp lên trên; nếu cần, tăng top_shell_layers |
| In thiếu nhựa giữa các plate | Hết cuộn | Mỗi plate < 92 g → 1 cuộn 1 kg đủ cho tất cả + dự phòng |

---

## 9. Ghi công & giấy phép

Thiết kế gốc: **"Arduino Robot Arm and Controller v2 (R.A.D.)"**
— **Kelton Serra / Build Some Stuff**
— [Printables #1834841](https://www.printables.com/model/1834841-arduino-robot-arm-and-controller-v2-rad/files)

**Giấy phép: CC BY-NC-ND 4.0** (Attribution–NonCommercial–NoDerivatives)

Điều này có nghĩa là:

| ✅ Được phép | ❌ Không được phép |
|---|---|
| In để học tập, làm đồ án | Dùng cho mục đích **thương mại** (bán) |
| Ghi công tác giả đầy đủ | **Chia sẻ bản sửa đổi / remix** (NoDerivatives) |
| Dùng nguyên bản | Chia sẻ mà không ghi công |

> ⚠️ **Lưu ý cho đồ án này:** theo `docs/yêu-cầu-kỹ-thuật.md` mục 8, nhóm cần
> **thiết kế lại** nếu muốn phát triển tiếp từ thiết kế này — điều khoản **ND (NoDerivatives)**
> không cho phép phát hành bản sửa đổi. Dùng làm **tham khảo + học tập** thì hợp lệ,
> nhưng phần tùy biến của nhóm phải là thiết kế riêng (đặt ở `hardware/cad/`, không
> phải trong `hardware/reference/`).

---

## 10. Tóm tắt nhanh (TL;DR)

```
File in   : hardware/reference/v2rad-and-v2cd-printgcode.3mf
Phần mềm  : Bambu Studio (hoặc OrcaSlicer)
Số plate  : 4   →  in lần lượt 1, 2, 3, 4
Số chi tiết: 33  (24 cánh tay + 9 điều khiển)
Nhựa      : PLA, 220°C nozzle / 55°C bed, layer 0.2mm, 15% infill
Support   : KHÔNG dùng  ← quan trọng nhất (0 lệnh support trong gcode)
Brim      : không sinh brim nào (auto, nhưng không cần)
Thời gian : ~8h 54m in + ~30m chuẩn bị
Nhựa dùng : 253 g  →  mua 1 cuộn PLA 1kg
```
