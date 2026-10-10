#!/usr/bin/env python3
"""
Kiểm chứng Động học Thuận (FK) và Động học Nghịch (IK) cho Robot 5-DOF
Kiến trúc: Base Yaw (J1) -> Shoulder Pitch (J2) -> Elbow Pitch (J3) -> Wrist Pitch (J4) -> Wrist Roll (J5)
Kích thước: h0 = 169.05, a1 = 9.8, L1 = 127.4, L2 = 100.0, L3 = 55.0 mm
"""

import math
import sys
import numpy as np

if sys.stdout.encoding != 'utf-8':
    try:
        sys.stdout.reconfigure(encoding='utf-8')
    except Exception:
        pass

# Thông số hình học
H0 = 169.05
A1 = 9.8
L1 = 127.4
L2 = 100.0
L3 = 55.0

def forward_kinematics(theta1_deg, theta2_deg, theta3_deg, theta4_deg, theta5_deg):
    """
    Tính tọa độ đầu gắp (x, y, z) và hướng (pitch, roll) từ 5 góc khớp (độ)
    """
    t1 = math.radians(theta1_deg)
    t2 = math.radians(theta2_deg)
    t3 = math.radians(theta3_deg)
    t4 = math.radians(theta4_deg)
    t5 = math.radians(theta5_deg)

    # Trong mặt phẳng dọc của cánh tay:
    # Góc tích lũy của các khâu 2, 3, 4:
    theta23 = t2 + t3
    theta234 = t2 + t3 + t4

    # Bán kính phẳng r và chiều cao z:
    r = A1 + L1 * math.cos(t2) + L2 * math.cos(theta23) + L3 * math.cos(theta234)
    z = H0 + L1 * math.sin(t2) + L2 * math.sin(theta23) + L3 * math.sin(theta234)

    x = r * math.cos(t1)
    y = r * math.sin(t1)

    pitch_deg = math.degrees(theta234)
    roll_deg = theta5_deg

    return np.array([x, y, z]), pitch_deg, roll_deg

def inverse_kinematics(x, y, z, pitch_deg=-90.0, roll_deg=0.0):
    """
    Giải động học nghịch: Cho trước (x, y, z), góc chúc pitch và góc xoay roll
    Mặc định: pitch_deg = -90 (đầu gắp chúc thẳng đứng vuông góc mặt bàn để gắp/thả)
    """
    # 1. Khớp 1: Base yaw
    theta1 = math.atan2(y, x)
    r = math.sqrt(x**2 + y**2)

    # 2. Vị trí tâm cổ tay (Wrist center p_w):
    pitch_rad = math.radians(pitch_deg)
    rw = r - A1 - L3 * math.cos(pitch_rad)
    zw = z - H0 - L3 * math.sin(pitch_rad)

    D_sq = rw**2 + zw**2
    D = math.sqrt(D_sq)

    # Kiểm tra tầm với
    if D > (L1 + L2) or D < abs(L1 - L2):
        raise ValueError(f"Điểm ({x:.1f}, {y:.1f}, {z:.1f}) nằm ngoài vùng làm việc! D = {D:.1f} mm, Max = {L1+L2} mm")

    # 3. Định luật cos cho khớp 3 (Elbow)
    cos_t3 = (D_sq - L1**2 - L2**2) / (2.0 * L1 * L2)
    cos_t3 = max(-1.0, min(1.0, cos_t3))
    
    # Chọn cấu hình khuỷu trên (Elbow-up: theta3 âm hoặc dương tùy quy ước)
    theta3 = -math.acos(cos_t3)  # Khuỷu gập

    # 4. Khớp 2 (Shoulder)
    alpha = math.atan2(zw, rw)
    beta = math.atan2(L2 * math.sin(-theta3), L1 + L2 * math.cos(-theta3))
    theta2 = alpha + beta

    # 5. Khớp 4 (Wrist Pitch)
    theta4 = pitch_rad - (theta2 + theta3)

    # 6. Khớp 5 (Wrist Roll)
    theta5 = math.radians(roll_deg)

    return (math.degrees(theta1),
            math.degrees(theta2),
            math.degrees(theta3),
            math.degrees(theta4),
            math.degrees(theta5))

def test_kinematics():
    print("=== KIỂM CHỨNG ĐỘNG HỌC ROBOT 5-DOF ===")
    test_points = [
        # (X, Y, Z, pitch, roll, mô tả)
        (150.0, 0.0, 30.0, -90.0, 0.0, "Vùng gắp chính diện thấp"),
        (0.0, 180.0, 50.0, -90.0, 45.0, "Vùng thả bên hông xoay 45 độ"),
        (120.0, 120.0, 20.0, -90.0, 30.0, "Góc chéo bàn cờ"),
        (200.0, 0.0, 169.05, 0.0, 0.0, "Vươn thẳng ngang 200mm"),
    ]

    all_pass = True
    for x, y, z, p, r, desc in test_points:
        try:
            angles = inverse_kinematics(x, y, z, p, r)
            pos_fk, p_fk, r_fk = forward_kinematics(*angles)
            err = np.linalg.norm(pos_fk - np.array([x, y, z]))
            print(f"[{desc}]")
            print(f"  Target: ({x:.1f}, {y:.1f}, {z:.1f}) mm | Pitch: {p:.1f}° | Roll: {r:.1f}°")
            print(f"  IK Angles: J1={angles[0]:.2f}°, J2={angles[1]:.2f}°, J3={angles[2]:.2f}°, J4={angles[3]:.2f}°, J5={angles[4]:.2f}°")
            print(f"  FK Result: ({pos_fk[0]:.2f}, {pos_fk[1]:.2f}, {pos_fk[2]:.2f}) mm | Sai số: {err*1e3:.4f} µm")
            if err > 1e-4:
                print("  => FAILED!")
                all_pass = False
            else:
                print("  => PASSED (Khớp tuyệt đối) ✓")
        except Exception as e:
            print(f"  Lỗi: {e}")
            all_pass = False
        print("-" * 50)

    if all_pass:
        print("TẤT CẢ PHÉP THỬ ĐỘNG HỌC THÀNH CÔNG 100%!")

if __name__ == "__main__":
    test_kinematics()
