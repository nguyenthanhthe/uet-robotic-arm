# Cánh tay robot có tay gắp (UET Robotic Arm)

Thiết kế và chế tạo cánh tay robot (Robot Arm + Gripper) cho môn học **Các cơ cấu chấp hành robot**. Robot gắp các vật thể có hình dạng khác nhau (sao, vuông, tròn…) và thả chính xác vào lỗ tương ứng.

## Thông số mục tiêu

- Tầm với tối thiểu: **200 mm**
- Tải trọng nâng tối thiểu: **50 g**
- Số bậc tự do: **4–5** (base, shoulder, elbow, wrist, gripper)
- Điều khiển: **Arduino** + **Servo**, giao diện nút bấm breadboard hoặc điều khiển qua serial USB từ PC.
- Chi tiết in 3D, kinh phí ~500.000 VNĐ/sinh viên.

## Tính năng nâng cao (dự kiến)

- Teaching Mode: ghi nhớ và phát lại chuỗi động tác gắp – thả.
- Vision: camera nhận diện hình dạng vật và vị trí lỗ thả.

Chi tiết: [docs/yêu-cầu-kỹ-thuật.md](docs/yêu-cầu-kỹ-thuật.md)

## Cấu trúc thư mục

```
├── docs/                  # Tài liệu: yêu cầu kỹ thuật, động học, chuyển MCU
│   ├── thong-so-dong-hoc.md      # ⭐ Số đo động học thật từ CAD (L1, L2, L3, h0)
│   ├── chuyen-mcu-esp32-stm32.md # Hướng dẫn đổi Arduino Nano ESP32 -> ESP32/STM32
│   └── typst/             # Nguồn Typst (thuyết minh) + out/
├── firmware/              # Mã nguồn Arduino (điều khiển khớp, teaching mode)
├── hardware/
│   ├── reference/         # Thiết kế gốc (STEP, 3MF đã slice, PDF)
│   └── HUONG-DAN-IN-3D.md # ⭐ Hướng dẫn in: 33 chi tiết / 4 plate
├── cad/
│   ├── tools/             # ⭐ Script tách STEP, xoá branding, render chữ khắc
│   ├── exports/           # 33 chi tiết STEP+STL, manifest, PARTS.md
│   ├── REBRAND.md         # ⭐ Vị trí & cách xoá branding "v2 R.A.D."
│   └── featurescript/     # Custom FeatureScript
└── vision/                # (tùy chọn) Code nhận diện vật / lỗ thả
```

## Bắt đầu nhanh

```bash
# Tách 33 chi tiết từ STEP gốc -> cad/exports/ (STEP + STL + manifest)
pip install cadquery-ocp          # cần OpenCASCADE Python binding
python cad/tools/split_step_parts.py --verify    # kiểm chứng tên/kích thước
python cad/tools/split_step_parts.py             # xuất file

# Xoá branding "v2 R.A.D." khỏi Base Cover
python cad/tools/rebrand_remove_text.py

# Build thuyết minh
typst compile docs/typst/thuyet-minh.typ docs/typst/out/thuyet-minh.pdf
```

## Tài liệu chính

| Tài liệu | Nội dung |
|---|---|
| `hardware/HUONG-DAN-IN-3D.md` | In 3D: 33 chi tiết / 4 plate, ~8h54m, 253 g PLA, không support |
| `docs/thong-so-dong-hoc.md` | Số đo động học thật từ CAD + **cảnh báo tầm với < 200 mm** |
| `docs/chuyen-mcu-esp32-stm32.md` | Đổi MCU sang ESP32/STM32: PWM, ADC, nguồn |
| `cad/REBRAND.md` | Xoá branding tác giả (2 vị trí khắc chữ) |
| `cad/exports/v2rad/PARTS.md` | Danh sách 24 chi tiết cánh tay + khối lượng |
| `cad/exports/v2cd/PARTS.md` | Danh sách 9 chi tiết bộ điều khiển |

## ⚠️ Lưu ý kỹ thuật quan trọng

**Tầm với thiết kế gốc chỉ 186.4 mm — chưa đạt yêu cầu 200 mm.** Số đo từ CAD:
$L_1 = 60.0$, $L_2 = 85.0$, $L_3 = 41.3$ mm. Cần kéo dài link thêm ≥ 15 mm và
tính lại moment servo. Chi tiết: `docs/thong-so-dong-hoc.md`.

## Đóng góp

- Clone: `git clone https://github.com/nguyenthanhthe/uet-robotic-arm.git`
- Quy ước commit: dùng thì quá khứ ngắn gọn, ví dụ `add servo kinematic firmware`, `update requirements`.
- Thay đổi lớn: tạo nhánh riêng (`git checkout -b feature/...`) rồi mở Pull Request.
- Chạy thử trước khi commit; không đẩy file nhị phân lớn, file tạm hoặc bí mật.

## Ghi công nguồn tham khảo

Thiết kế tham khảo ban đầu: **Arduino Robot Arm and Controller v2 (R.A.D.)** — Build Some Stuff (Kelton Serra), giấy phép **CC BY-NC-ND 4.0**. Chỉ dùng cho học tập/tham khảo tại `hardware/reference/`; mọi phần tùy biến của nhóm đặt tại `cad/`.

⚠️ Giấy phép **ND (NoDerivatives)** không cho phép phát hành bản sửa đổi. Nhóm cần **thiết kế lại** nếu muốn phát triển tiếp từ thiết kế này. Xem `cad/REBRAND.md` mục 3.