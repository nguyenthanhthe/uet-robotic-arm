# Chuyển firmware sang ESP32 / STM32

> Tài liệu này phân tích việc thay **Arduino Nano ESP32** (trong sơ đồ wiring
> gốc v2 R.A.D.) bằng **ESP32 thuần** hoặc **STM32**, kèm ảnh hưởng tới code
> điều khiển servo, đọc biến trở (potentiometer), và giao tiếp serial.

## 1. Sơ đồ phần cứng gốc (từ ảnh wiring v2 R.A.D.)

Sơ đồ gốc gồm các khối:

| Khối | Chức năng |
|---|---|
| **Arduino Nano ESP32** | MCU chính (ESP32-S3, logic 3.3 V) |
| **74HC595** (shift register) | Mở rộng chân điều khiển servo (3 chân → 8 kênh) |
| **Biến trở ×5** (10 kΩ) | Đọc góc khớp — 1 cho mỗi khớp |
| **Power/Gripper Button** | Nút bấm điều khiển tay gắp |
| **POTs Signals** | 5 tín hiệu analog từ biến trở |
| **Controller Plugs** | Giắc cắm ra tay điều khiển (v2CD) |
| **Power Switch** | Công tắc nguồn |
| **6V Power Supply** | Nguồn servo riêng (jack DC) |
| **LED** | Báo nguồn/trạng thái |
| **Điện trở 220 Ω** | Trở hạn dòng cho LED |

### Điểm quan trọng của kiến trúc gốc

1. **Servo dùng nguồn riêng 6 V**, không lấy từ chân 5 V của MCU. Đây là điều
   kiện bắt buộc để tránh sụt áp gây reset — đúng với
   `docs/yêu-cầu-kỹ-thuật.md` mục 4.

2. **74HC595 điều khiển servo** — nhưng ⚠️ **cần lưu ý**: 74HC595 là shift
   register số, đầu ra on/off, **không tự phát được PWM cho servo**. Trong sơ đồ
   này nó được dùng để **mở rộng số chân chọn kênh** (dạng multiplexer), chứ
   không phải nguồn PWM trực tiếp. Cần xác nhận lại cách đấu thực tế, vì nhiều
   bản v2 R.A.D. dùng 74HC595 để quét nhiều servo theo chu kỳ
   (time-multiplexed PWM) — cách này hoạt động nhưng có thể gây rung servo.

3. **Biến trở 10 kΩ** đọc góc khớp → cần **ADC**. Đây là điểm khác biệt lớn
   nhất giữa ESP32 và STM32.

4. **Nano ESP32 = ESP32-S3**, logic **3.3 V**, ADC 12 bit.

## 2. So sánh ba lựa chọn MCU

| Tiêu chí | Arduino Nano ESP32 (gốc) | ESP32 thuần (DevKit / WROOM) | STM32 (Blue Pill / Black Pill) |
|---|---|---|---|
| MCU | ESP32-S3 | ESP32 / ESP32-S3 | STM32F103 / F411 |
| Logic | 3.3 V | 3.3 V | 3.3 V |
| **Số kênh PWM phần cứng** | 8+ (LEDC) | 16 (LEDC) | 4 (F103 timer) / nhiều hơn F411 |
| **ADC** | 12 bit, 20 kênh | 12 bit, 18 kênh | **12 bit**, 10–16 kênh |
| ADC tuyến tính? | ⚠️ **kém tuyến tính** | ⚠️ kém tuyến tính | ✅ **tốt, tuyến tính** |
| WiFi/BT | Có | Có | ❌ Không |
| Giá (VN) | ~200–250 k | ~80–120 k | ~60–100 k |
| Toolchain | Arduino / ESP-IDF | Arduino / ESP-IDF | **STM32CubeIDE / HAL** |
| Servo library | ESP32Servo | ESP32Servo | Không có chuẩn — tự viết hoặc dùng HAL timer |
| Nguồn 5 V cho servo | Cần nguồn ngoài | Cần nguồn ngoài | Cần nguồn ngoài |

## 3. Khuyến nghị

### Chọn ESP32 thuần nếu...
- Muốn **giữ gần như nguyên code** Arduino hiện có (chỉ đổi board profile).
- Cần WiFi/BT cho phần **bonus** (ví dụ: gửi toạ độ từ PC sang không dây, hoặc
  web UI điều khiển).
- Muốn thư viện `ESP32Servo` xử lý PWM — tiết kiệm thời gian.

**Đây là lựa chọn ít rủi ro nhất cho đồ án.**

### Chọn STM32 nếu...
- Cần **ADC chính xác** cho 5 biến trở (chất lượng tín hiệu tốt hơn ESP32 rõ rệt).
- Muốn điểm cộng về "mức công nghệ" — bare-metal, timer, DMA.
- Chấp nhận viết lại code và tự cấu hình timer cho PWM servo.

### ⚠️ Lưu ý riêng về ADC ESP32

ADC của ESP32 **nổi tiếng không tuyến tính** (đặc biệt gần 0 V và 3.3 V). Với 5
biến trở làm tay điều khiển, sai số này gây **nhảy góc khớp**. Ba cách xử lý:

1. **Hiệu chuẩn (calibration)**: đo giá trị ADC thực tế tại vài vị trí đã biết,
   dựng bảng tra hoặc nội suy. Đơn giản, đủ dùng.
2. **Chỉ dùng dải giữa**: giới hạn biến trở trong 10 %–90 % hành trình.
3. **Dùng ADC ngoài** (ADS1115, I²C, 16 bit) — chính xác nhất, tốn thêm ~50 k.

Với đồ án, cách 1 là đủ.

## 4. Ánh xạ chân (pin mapping)

Khi đổi MCU, **không dùng số chân Arduino cũ** — phải ánh xạ lại theo board mới.

| Tín hiệu | Loại | Ghi chú khi đổi |
|---|---|---|
| 5 × POT (biến trở) | ADC | Phải là chân **ADC1** trên ESP32 (ADC2 bị chặn khi bật WiFi) |
| 3 × chân 74HC595 (DS/SHCP/STCP) | Digital out | Chân nào cũng được |
| 1 × PWM servo (nếu đấu trực tiếp) | PWM | Dùng LEDC; tránh chân **strapping** (GPIO0, 2, 12) |
| Nút Power/Gripper | Digital in | Nên bật pull-up nội |
| LED báo | Digital out | Qua trở 220 Ω |

### ⚠️ Ba cái bẫy thường gặp trên ESP32

1. **GPIO6–11 không dùng được** — nối với flash SPI. Dùng sẽ làm board không boot.
2. **ADC2 không dùng khi bật WiFi** — 5 biến trở nên đưa hết vào ADC1
   (GPIO32–39 trên ESP32; khác trên S3).
3. **Chân strapping** (GPIO0, 2, 12, 15) — tránh dùng cho tín hiệu có thể kéo
   mức thấp lúc boot.

## 5. Ảnh hưởng tới code

### Điều khiển servo

**Arduino Nano ESP32 / ESP32 (dùng `ESP32Servo`):**
```cpp
#include <ESP32Servo.h>
Servo joint[4];
// LEDC timer tự gán; servo 50 Hz
joint[0].attach(PIN_SERVO_0, 500, 2400);   // min/max µs
joint[0].write(90);
```

**STM32 (HAL, tự cấu hình timer):**
```c
// TIM2, prescaler + ARR cho 50 Hz (20 ms), CCR điều chỉnh 500..2500 µs
// Cần 4 kênh PWM -> dùng 1 timer 4 kênh (TIM2 CH1..CH4)
HAL_TIM_PWM_Start(&htim2, TIM_CHANNEL_1);
__HAL_TIM_SET_COMPARE(&htim2, TIM_CHANNEL_1, pulse_us);
```

> Trên STM32F103, mỗi timer chỉ có 4 kênh PWM. Cần **≥ 4 khớp + 1 gripper = 5
> kênh** → phải dùng 2 timer. Đây là lý do nhiều nhóm chọn ESP32 (16 kênh LEDC).

### Đọc biến trở

```cpp
// ESP32: ADC 12 bit, 0..4095
int raw = analogRead(PIN_POT[i]);          // 0..4095
float ang = raw * (270.0f / 4095.0f);      // map sang góc servo
```

Với **hiệu chuẩn**, thay vì map tuyến tính:
```cpp
// Bảng tra: {adc, goc} đo thực tế
const int CAL_ADC[] = {  50, 1050, 2050, 3050, 4000 };
const int CAL_ANG[] = {   0,   45,   90,  135,  180 };
float ang = interp(raw, CAL_ADC, CAL_ANG, 5);
```

### Giao tiếp serial

Cả ESP32 và STM32 đều có UART USB. Giao thức gửi toạ độ từ PC (cho vision/IK)
**không đổi** — chỉ cần đúng baudrate:

```
PC  --(USB serial 115200)-->  MCU  -->  servo
# Gói lệnh ví dụ: "M 120.5 45.0 80.0 90.0\n"  (4 góc khớp)
```

Đây là lý do `goal.md` tách **Master (PC: vision + IK)** và **Slave (MCU: PWM +
low-level)** — đổi MCU không ảnh hưởng tầng PC.

## 6. Nguồn — phần KHÔNG được đổi

Dù dùng MCU nào, **giữ nguyên kiến trúc nguồn**:

```
Nguồn 6 V (jack DC) ──> Servo (5–6 V, dòng lớn)
                    └──> Buck 5 V ──> MCU (qua USB hoặc VIN)
GND chung giữa nguồn servo và MCU  ← BẮT BUỘC
```

⚠️ **Bắt buộc nối GND chung.** Thiếu GND chung → tín hiệu PWM không có mức tham
chiếu → servo giật hoặc không chạy.

⚠️ **Không cấp servo từ chân 5 V / 3.3 V của MCU.** 5 servo SG90 có thể kéo
dòng đỉnh > 3 A, làm sụt áp và reset MCU.

## 7. Checklist chuyển đổi

- [ ] Chọn MCU (khuyến nghị: **ESP32 thuần**)
- [ ] Lập bảng ánh xạ chân mới, tránh GPIO6–11, ADC2, chân strapping
- [ ] Đưa 5 biến trở vào **ADC1**
- [ ] Cấu hình PWM servo: 50 Hz, xung 500–2500 µs
- [ ] Hiệu chuẩn ADC cho 5 biến trở (đo 5 điểm, nội suy)
- [ ] Nối **GND chung** giữa nguồn servo và MCU
- [ ] Test từng servo riêng trước khi chạy cả hệ
- [ ] Giữ nguyên giao thức serial với PC (đổi MCU không đổi protocol)
- [ ] Đo lại dòng tiêu thụ khi cả 5 servo hoạt động đồng thời

## 8. Tham chiếu

- Firmware gốc: `v2rad_code.ino` (có trên trang Printables, mục "Other files")
- Wiring: ảnh `v2 R.A.D. Wiring`
- Yêu cầu nguồn: `docs/yêu-cầu-kỹ-thuật.md` mục 4
