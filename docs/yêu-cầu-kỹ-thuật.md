# Yêu cầu kỹ thuật cơ bản — Cánh tay robot (Robot Arm + Gripper)

> Môn học: Các cơ cấu chấp hành robot — Khoa Công nghệ, Trường Đại học Công nghệ, ĐHQGHN (UET)
> Tài liệu: Phiên bản khởi đầu — nhóm bổ sung và cập nhật trong quá trình thực hiện.

---

## 1. Mục tiêu và phạm vi

Thiết kế và chế tạo một cánh tay robot gắn tay gắp (gripper) có nhiệm vụ:

- **Gắp** các vật thể có hình dáng khác nhau (ví dụ: hình **sao**, hình **vuông**, hình **tròn**).
- **Thả chính xác** vật vào lỗ có hình dáng tương ứng trên bảng lắp ghép.

Phạm vi dự án gói gọn trong một hệ thống để bàn, in 3D, điều khiển bằng vi điều khiển giá rẻ (Arduino) kết hợp động cơ Servo, phù hợp kinh phí sinh viên (~500.000 VNĐ/người).

## 2. Thông số kỹ thuật chính

| Thông số | Giá trị yêu cầu | Ghi chú |
|---|---|---|
| Tầm với tối thiểu | **200 mm** | Giả định từ đề bài ghi "200m" (gõ nhầm đơn vị); chốt 200mm cho cánh tay để bàn. |
| Tải trọng nâng tối thiểu | **50 g** | Khối lượng vật + chi tiết gắp được nâng ổn định ở mọi tư thế. |
| Số bậc tự do (DOF) | 4–5 | Base (xoay), shoulder, elbow, wrist, gripper. |
| Kích thước vật gắp | ~20–40 mm | Vật nhựa/giấy các hình sao, vuông, tròn. |
| Độ chính xác định vị | Sơ bộ ±3 mm | Đủ để vật chìm vào lỗ tương ứng; tinh chỉnh sau thử nghiệm. |
| Chu kỳ gắp–thả | ≤ 15 s/vật (mục tiêu) | Gồm di chuyển, gắp, di chuyển về lỗ, thả. |
| Tay gắp | Kẹp song song, mở ≥ 50 mm | Đủ ôm vật lớn nhất; thiết kế thay đầu kẹp dễ dàng. |

## 3. Vật thể và bảng thả

- Bộ vật mẫu: **sao**, **vuông**, **tròn** (kích thước ~20–40 mm).
- Bảng thả có 3 lỗ tương ứng, kích thước lỗ lớn hơn vật ~3–5 mm để dung sai định vị.
- Tiêu chí chính xác: vật thả nằm gọn trong lỗ đúng hình dáng, không cần xoay đặc biệt về pha (shape-matching, không bắt buộc orientation-matching ở bước đầu).

## 4. Hệ thống điều khiển

- **Vi điều khiển**: Arduino Nano hoặc Uno.
- **Động cơ**: Servo 9g (SG90) cho các khớp; servo có moment lớn hơn (MG90S hoặc SG90 khỏe) cho gripper.
- **Nguồn**: tách riêng nguồn cho servo (không cấp từ chân 5V của Arduino) để tránh sụt áp reset.
- **Giao diện điều khiển** (2 phương án, không bắt buộc máy tính nhúng):
  1. Nút bấm trên breadboard — điều khiển từng khớp / chuyển bước.
  2. Điều khiển trực tiếp qua máy tính (PC) bằng kết nối serial USB.

## 5. Tính năng nâng cao (dự kiến — được đánh giá điểm cao)

Được tách riêng, validate theo thứ tự ưu tiên:

1. **Teaching Mode (Ghi/nhớ động tác — Imitation Learning)**
   - Người dùng thao tác mẫu (điều khiển từng khớp) → ghi chuỗi biến khớp (joint angles) theo thời gian.
   - Phát lại tự động toàn bộ quá trình gắp–thả.
2. **Vision (Thị giác máy tính)**
   - Camera nhận diện hình dạng vật (tròn, vuông…) và vị trí lỗ thả tương ứng.
   - Sử dụng OpenCV / thư viện phù hợp trên PC, tính toán tọa độ gửi xuống Arduino.

## 6. Ràng buộc

- **Kinh phí**: ~500.000 VNĐ/sinh viên (tổng nhóm ~1,5 triệu VNĐ), ưu tiên linh kiện sẵn có tại Việt Nam.
- **Gia công**: chi tiết in 3D (FDM, nhựa PLA), không yêu cầu trợ cấp (support-free) nếu có thể.
- **Không bắt buộc** máy tính nhúng / vi xử lý tốc độ cao; mức công nghệ + sáng tạo mới là tiêu chí chấm điểm.

## 7. Phân công dự kiến (3 thành viên)

| Thành viên | Vai trò | Nhiệm vụ chính |
|---|---|---|
| 1 (điền tên) | Cơ khí / Thiết kế 3D | Thiết kế khung, khớp, gripper; in 3D; lắp ráp. |
| 2 (điền tên) | Điện – Điều khiển | Sơ đồ mạch, nguồn, phần mềm Arduino (kinematic + ghi/phát lại). |
| 3 (điền tên) | Thị giác / Tích hợp hệ thống | Camera nhận diện hình dáng vật & lỗ thả; tích hợp end-to-end; tài liệu video. |

## 8. Rủi ro và các giả định

- **Giả định đơn vị tầm với**: đề bài ghi 200m → quy về **200mm**.
- **Moment servo**: tải 50g ở tầm với 200mm có thể làm sụt tốc/đứng khớp nếu dùng servo yếu — cần kiểm tra moment theo tư thế xấu nhất.
- **Lò xo/ma sát gripper**: cần thử nghiệm độ mở – độ bám với các hình dạng khác nhau.
- **Nhiễu nguồn servo** gây reset Arduino nếu dùng chung nguồn.
- **Giấy phép tài liệu tham khảo**: thiết kế tham khảo "v2 R.A.D." của Build Some Stuff theo giấy phép **CC BY-NC-ND** — chỉ dùng để tham khảo/học tập, cần thiết kế lại nếu phát triển từ đó (ghi công nguồn đầy đủ).

## 9. Sản phẩm bàn giao

1. Mô hình robot hoạt động (demo thực tế + video ghi lại quá trình vận hành).
2. Slide báo cáo thuyết trình.
3. Quyển thuyết minh báo cáo (< 20 trang): tính toán thiết kế, phần mềm sử dụng, bảng phân công chi tiết.

---

*Cập nhật bởi nhóm; mọi thay đổi qua commit trên repository GitHub `uet-robotic-arm`.*