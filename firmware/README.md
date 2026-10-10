# firmware/ — Mã nguồn điều khiển

## Trạng thái

⚠️ **Chưa có firmware của nhóm cho phần cứng hiện tại.** File `v2rad_code/v2rad_code.ino`
là code của thiết kế tham khảo v2 R.A.D., viết cho Arduino Nano ESP32; chỉ dùng để tham
khảo logic, không chạy được trên Arduino Uno + PCA9685.

## Phần cứng điều khiển

| Khối | Ghi chú |
|---|---|
| MCU | Arduino Uno R3, đặt trên khay `01_Base_Tray` trong đế `01_Base_Kuka` |
| Mạch PWM | Shield PCA9685 16 kênh cắm chồng lên Uno, I2C qua A4 (SDA) / A5 (SCL), địa chỉ `0x40` |
| Servo J1, J3 | MG996R (trục 25T) |
| Servo J2 | Servo số cỡ chuẩn $40 \times 20\text{ mm}$, trục 25T, $25\text{ kg}\cdot\text{cm}$, $180^\circ$ |
| Servo J4, J5, tay gắp | MG90S |
| Nguồn servo | $6\text{ V}$ riêng, từ $8\text{ A}$, cấp vào cầu đấu V+ của shield; hàn tụ $1000\ \mu\text{F}$ vào chỗ chờ trên shield |
| Kết nối PC | USB Serial qua cổng USB-B ở mặt sau đế |

⚠️ **Không cấp servo từ chân 5 V của Uno.** Một servo MG996R kẹt trục có thể kéo trên
$2\text{ A}$; sụt áp sẽ làm Uno reset.

## Kiến trúc

```
┌─────────────────────────────────────────┐
│ MASTER — PC / Laptop                    │
│  • Vision (OpenCV): nhận diện hình dạng │
│  • IK solver: toạ độ -> góc khớp        │
│  • Nội suy quỹ đạo                      │
└──────────────┬──────────────────────────┘
               │ USB Serial (115200)
               ▼
┌─────────────────────────────────────────┐
│ SLAVE — Arduino Uno R3 + PCA9685        │
│  • Nhận góc khớp                        │
│  • Phát PWM 50 Hz cho 6 servo           │
│  • Ghi / phát lại quỹ đạo (Teaching)    │
└─────────────────────────────────────────┘
```

## Phân bổ kênh PCA9685

| Kênh | Khớp | Servo |
|---|---|---|
| 0 | J1 đế | MG996R |
| 1 | J2 vai | servo số $25\text{ kg}\cdot\text{cm}$, $180^\circ$ |
| 2 | J3 khuỷu | MG996R |
| 3 | J4 gập cổ tay | MG90S |
| 4 | J5 xoay cổ tay | MG90S |
| 5 | Tay gắp | MG90S |

## Độ phân giải góc

PCA9685 ở $50\text{ Hz}$ có bước xung $20\text{ ms} / 4096 \approx 4.88\ \mu\text{s}$, tức khoảng
$0.44^\circ$ mỗi bước với servo $180^\circ$. Ở tầm với $280\text{ mm}$, một bước của khớp đế
tương ứng khoảng $2\text{ mm}$ ở đầu tay gắp. Để đạt yêu cầu $\pm 3\text{ mm}$, có thể điều
khiển J1 và J2 trực tiếp từ chân 9 / 10 của Uno bằng thư viện `Servo` (bước
khoảng $0.5\ \mu\text{s}$) và để các khớp còn lại trên PCA9685.

## Việc cần làm

- [ ] Viết sketch cho Uno: thư viện `Adafruit_PWMServoDriver`, tần số 50 Hz
- [ ] Hiệu chuẩn xung min / max và góc 0 của từng servo
- [ ] Định nghĩa protocol serial PC <-> Uno
- [ ] Nội suy góc để servo không giật
- [ ] Teaching mode: ghi mảng `q(t)` rồi phát lại

## Tài liệu liên quan

| File | Nội dung |
|---|---|
| `docs/thong-so-dong-hoc.md` | $h_0, a_1, L_1, L_2, L_3$, bảng D-H, mô-men và chọn servo |
| `docs/ke-hoach-dieu-khien-ai-robot.md` | Kiến trúc điều khiển, hộp mạch trong đế, thị giác |
| `docs/typst/kinematics.typ` | FK/IK chạy trên PC (master) |
| `docs/chuyen-mcu-esp32-stm32.md` | Ghi chú nếu chuyển MCU sang ESP32/STM32 |
