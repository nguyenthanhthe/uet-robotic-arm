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
├── docs/                  # Tài liệu: yêu cầu kỹ thuật, SLIDE, thuyết minh
├── firmware/              # Mã nguồn Arduino (điều khiển khớp, teaching mode)
├── hardware/
│   ├── reference/         # Thiết kế tham khảo (PDF lắp ráp, STEP, 3MF)
│   └── cad/               # File thiết kế 3D tùy biến của nhóm
└── vision/                # (tùy chọn) Code nhận diện vật / lỗ thả
```

## Đóng góp

- Clone: `git clone https://github.com/nguyenthanhthe/uet-robotic-arm.git`
- Quy ước commit: dùng thì quá khứ ngắn gọn, ví dụ `add servo kinematic firmware`, `update requirements`.
- Thay đổi lớn: tạo nhánh riêng (`git checkout -b feature/...`) rồi mở Pull Request.
- Chạy thử trước khi commit; không đẩy file nhị phân lớn, file tạm hoặc bí mật.

## Ghi công nguồn tham khảo

Thiết kế tham khảo ban đầu: **Arduino Robot Arm and Controller v2 (R.A.D.)** — Build Some Stuff (Kelton Serra), giấy phép **CC BY-NC-ND 4.0**. Chỉ dùng cho học tập/tham khảo tại `hardware/reference/`; mọi phần tùy biến của nhóm đặt tại `hardware/cad/`.