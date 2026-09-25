# firmware/ — Mã nguồn điều khiển

## Trạng thái

⚠️ **Chưa có firmware của nhóm.** Code gốc của tác giả (`v2rad_code.ino`) nằm trên
trang Printables (mục "Other files"), **không** có trong repo này.

## Kế hoạch

Theo `goal.md`, kiến trúc điều khiển tách hai tầng:

```
┌─────────────────────────────────────────┐
│ MASTER — PC / Laptop                    │
│  • Vision (OpenCV): nhận diện hình dạng │
│  • IK solver: toạ độ -> 4 góc khớp      │
│  • Trajectory planning                  │
└──────────────┬──────────────────────────┘
               │ USB Serial (115200)
               ▼
┌─────────────────────────────────────────┐
│ SLAVE — MCU (ESP32 / STM32)             │
│  • Nhận góc khớp                        │
│  • Phát PWM cho 5 servo                 │
│  • Đọc 5 biến trở (ADC) cho Teaching    │
│  • Phát lại quỹ đạo đã ghi              │
└─────────────────────────────────────────┘
```

## Cấu trúc đề xuất

```
firmware/
├── README.md              # file này
├── esp32/                 # ⭐ Khuyến nghị — ít rủi ro nhất
│   ├── robot_arm_esp32.ino
│   └── config.h           # ánh xạ chân, hằng số hiệu chuẩn
├── stm32/                 # (tùy chọn) nếu chọn STM32
│   └── ...
└── protocol.md            # định nghĩa gói lệnh serial PC <-> MCU
```

## Việc cần làm

- [ ] Lấy `v2rad_code.ino` gốc từ Printables (chỉ để tham khảo logic)
- [ ] Chốt MCU — xem `docs/chuyen-mcu-esp32-stm32.md` mục 3
- [ ] Lập bảng ánh xạ chân, **tránh** GPIO6–11, ADC2 (khi bật WiFi), chân strapping
- [ ] Đưa 5 biến trở vào **ADC1**
- [ ] Hiệu chuẩn ADC (5 điểm, nội suy) — ESP32 ADC không tuyến tính
- [ ] Định nghĩa protocol serial (xem `protocol.md`)
- [ ] Teaching mode: ghi mảng `q(t)` rồi phát lại
- [ ] Nối **GND chung** giữa nguồn servo 6 V và MCU

## Phần cứng tham chiếu (từ sơ đồ wiring v2 R.A.D.)

| Khối | Ghi chú |
|---|---|
| MCU | ESP32 (thay Arduino Nano ESP32) |
| Servo ×5 | 4 khớp + 1 gripper; **MG90S/MG996R** cho shoulder |
| Nguồn servo | **6 V riêng**, KHÔNG lấy từ MCU |
| Biến trở ×5 | 10 kΩ, đọc góc khớp |
| 74HC595 | Mở rộng chân — cần xác nhận lại cách đấu thực tế |
| Nút Power/Gripper | Digital input, bật pull-up |

⚠️ **Không cấp servo từ chân 5 V/3.3 V của MCU.** 5 servo SG90 có thể kéo dòng
đỉnh > 3 A → sụt áp → reset MCU.

## Tài liệu liên quan

| File | Nội dung |
|---|---|
| `docs/chuyen-mcu-esp32-stm32.md` | So sánh ESP32 vs STM32, ánh xạ chân, code mẫu |
| `docs/thong-so-dong-hoc.md` | $L_1, L_2, L_3, h_0$ + cảnh báo tầm với |
| `docs/typst/kinematics.typ` | FK/IK để chạy trên PC (master) |
