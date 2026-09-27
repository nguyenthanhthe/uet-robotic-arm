%% =========================================================================
% MO HINH DONG HOC & TINH TOAN MO-MEN KUKA KR 3 (5-DOF + GRIPPER)
% Do an thiet ke va dieu khien canh tay robot - UET / VNU
% =========================================================================
clear; clc; close all;

%% 1. KHOI TAO CAC THONG SO HINH HOC CO BAN (don vi: mm)
h0 = 80.0;    % Chieu cao truc vai J2 so voi mat ban
L1 = 110.0;   % Chieu dai canh tay tren (Upper Arm: J2 -> J3)
L2 = 100.0;   % Chieu dai cang tay (Forearm: J3 -> J4)
L3 = 55.0;    % Chieu dai co tay va khau kep (Wrist & Gripper: J4 -> End-Effector)

fprintf('--- THONG SO HINH HOC CANH TAY ROBOT KUKA (UET) ---\n');
fprintf('Chieu cao de (h0): %.1f mm\n', h0);
fprintf('Canh tay Link 1 (L1): %.1f mm\n', L1);
fprintf('Cang tay Link 2 (L2): %.1f mm\n', L2);
fprintf('Dau kep Link 3 (L3): %.1f mm\n', L3);
fprintf('Tam vuon toi da (R_max): %.1f mm\n', L1 + L2 + L3);

%% 2. TAO MO HINH ROBOT BANG ROBOTICS SYSTEM TOOLBOX
robot = rigidBodyTree('DataFormat', 'row', 'MaxNumBodies', 6);

% Link 1: Base Turret (Quay quanh truc dung Z0 - J1)
body1 = rigidBody('link1');
jnt1 = rigidBodyJoint('jnt1', 'revolute');
setFixedTransform(jnt1, trvec2tform([0, 0, h0]));
jnt1.JointAxis = [0, 0, 1];
jnt1.PositionLimits = deg2rad([-90, 90]);
body1.Joint = jnt1;
addBody(robot, body1, 'base');

% Link 2: Upper Arm (Quay quanh truc ngang Y1 - J2)
body2 = rigidBody('link2');
jnt2 = rigidBodyJoint('jnt2', 'revolute');
setFixedTransform(jnt2, trvec2tform([0, 0, 0]));
jnt2.JointAxis = [0, 1, 0];
jnt2.PositionLimits = deg2rad([-30, 90]);
body2.Joint = jnt2;
addBody(robot, body2, 'link1');

% Link 3: Forearm (Quay quanh truc ngang Y2 - J3)
body3 = rigidBody('link3');
jnt3 = rigidBodyJoint('jnt3', 'revolute');
setFixedTransform(jnt3, trvec2tform([L1, 0, 0])); % doc theo Link 1
jnt3.JointAxis = [0, 1, 0];
jnt3.PositionLimits = deg2rad([-110, 10]);
body3.Joint = jnt3;
addBody(robot, body3, 'link2');

% Link 4: Wrist Pitch (Quay quanh truc ngang Y3 - J4)
body4 = rigidBody('link4');
jnt4 = rigidBodyJoint('jnt4', 'revolute');
setFixedTransform(jnt4, trvec2tform([L2, 0, 0]));
jnt4.JointAxis = [0, 1, 0];
jnt4.PositionLimits = deg2rad([-90, 90]);
body4.Joint = jnt4;
addBody(robot, body4, 'link3');

% Link 5: Wrist Roll (Quay quanh truc doc Z4 - J5)
body5 = rigidBody('link5');
jnt5 = rigidBodyJoint('jnt5', 'revolute');
setFixedTransform(jnt5, trvec2tform([L3, 0, 0]));
jnt5.JointAxis = [1, 0, 0];
jnt5.PositionLimits = deg2rad([-90, 90]);
body5.Joint = jnt5;
addBody(robot, body5, 'link4');

%% 3. VE MO HINH 3D TRONG MAT-LAB
figure('Name', 'Mo hinh 3D Robot KUKA KR 3 (UET)', 'Color', 'w');
q_home = deg2rad([0, 45, -45, 0, 0]);
show(robot, q_home, 'PreservePlot', false, 'Frames', 'on');
title('Mô hình 3D Robot KUKA KR 3 - Vị trí Home q = [0, 45, -45, 0, 0]');
xlabel('X (mm)'); ylabel('Y (mm)'); zlabel('Z (mm)');
axis([-200 300 -250 250 0 350]);
grid on; view(135, 25);

%% 4. KIEM NGHIEM MO-MEN TAI TRONG CAC KHOP (TORQUE ANALYSIS)
% Cac khoi luong thanh phan (don vi: kg)
m_payload = 0.050; % Vat gap toi da 50g
m_gripper = 0.040; % Cum ban kep + servo MG90S kep
m_wrist   = 0.030; % Cum co tay + servo MG90S roll
m_L2      = 0.045; % Than cang tay Link 2 in 3D
m_servoJ4 = 0.0135;% Servo MG90S dieu khien co tay J4
m_servoJ3 = 0.0135;% Servo MG90S o khuyp J3
m_L1      = 0.065; % Than canh tay Link 1 in 3D

g = 9.81; % m/s^2

% Tinh toan mo-men xoan tinh cuc dai tai khuyp J3 (khi duoi ngang toi da):
% Can tay don tinh tu tam J3 (don vi: m):
d_payload_J3 = (L2 + L3) / 1000;
d_grip_J3    = (L2 + L3/2) / 1000;
d_wrist_J3   = L2 / 1000;
d_servoJ4_J3 = (L2 - 10) / 1000;
d_L2_J3      = (L2 / 2) / 1000;

T_J3_Nm = (m_payload * d_payload_J3 + ...
           m_gripper * d_grip_J3 + ...
           m_wrist * d_wrist_J3 + ...
           m_servoJ4 * d_servoJ4_J3 + ...
           m_L2 * d_L2_J3) * g;
T_J3_kgcm = (T_J3_Nm / g) * 100;

% Tinh toan mo-men xoan tinh cuc dai tai vai J2 (khi duoi ngang toi da):
d_payload_J2 = (L1 + L2 + L3) / 1000;
d_grip_J2    = (L1 + L2 + L3/2) / 1000;
d_wrist_J2   = (L1 + L2) / 1000;
d_servoJ4_J2 = (L1 + L2 - 10) / 1000;
d_L2_J2      = (L1 + L2 / 2) / 1000;
d_servoJ3_J2 = L1 / 1000;
d_L1_J2      = (L1 / 2) / 1000;

T_J2_Nm = (m_payload * d_payload_J2 + ...
           m_gripper * d_grip_J2 + ...
           m_wrist * d_wrist_J2 + ...
           m_servoJ4 * d_servoJ4_J2 + ...
           m_L2 * d_L2_J2 + ...
           m_servoJ3 * d_servoJ3_J2 + ...
           m_L1 * d_L1_J2) * g;
T_J2_kgcm = (T_J2_Nm / g) * 100;

fprintf('\n--- KET QUA KIEM NGHIEM TAI TRONG & MO-MEN XOAN TINH ---\n');
fprintf('Mo-men tai Khop Khuyu J3: %.2f kg.cm (Servo MG90S max = 2.50 kg.cm @ 6V -> He so an toan S = %.2f)\n', ...
    T_J3_kgcm, 2.50 / T_J3_kgcm);
fprintf('Mo-men tai Khop Vai J2:   %.2f kg.cm (Servo MG996R max = 11.00 kg.cm @ 6V -> He so an toan S = %.2f)\n', ...
    T_J2_kgcm, 11.00 / T_J2_kgcm);

%% 5. TINH TOAN DONG HOC THUAN (FK) & DONG HOC NGHICH GIAI TICH (IK)
% Vi tri muc tieu de kiem tra gap vat:
X_target = 180.0;
Y_target = 50.0;
Z_target = 25.0; % Gap sat mat ban
phi_target = deg2rad(-30); % Huong kep chuc xuong 30 do

[q_sol, is_valid] = kuka_analytical_ik(X_target, Y_target, Z_target, phi_target, h0, L1, L2, L3);

if is_valid
    fprintf('\n--- GIAI DONG HOC NGHICH CHO TOA DO TARGET (X=%.1f, Y=%.1f, Z=%.1f) ---\n', ...
        X_target, Y_target, Z_target);
    fprintf('q_sol = [J1: %.1f deg, J2: %.1f deg, J3: %.1f deg, J4: %.1f deg, J5: 0 deg]\n', rad2deg(q_sol));
    
    % Kiem tra lai bang Forward Kinematics:
    T_fk = getTransform(robot, [q_sol, 0], 'link5');
    pos_fk = tform2trvec(T_fk);
    fprintf('Vi tri kiem chung lai tu FK: X=%.2f, Y=%.2f, Z=%.2f (Sai so: %.4f mm)\n', ...
        pos_fk(1), pos_fk(2), pos_fk(3), norm(pos_fk - [X_target, Y_target, Z_target]));
else
    fprintf('Toa do muc tieu nam ngoai vung lam viec cua robot!\n');
end

%% HAM GIAI DONG HOC NGHICH GIAI TICH (CLOSED-FORM ANALYTICAL IK)
function [q, valid] = kuka_analytical_ik(X, Y, Z, phi, h0, L1, L2, L3)
    q = zeros(1, 4);
    valid = true;
    
    % 1. Goc quay de theta1
    q(1) = atan2(Y, X);
    
    % 2. Toa do tam co tay trong he truc r-z
    r = sqrt(X^2 + Y^2);
    rw = r - L3 * cos(phi);
    zw = Z - h0 - L3 * sin(phi);
    
    % 3. Do dai noi tu vai den co tay
    D2 = rw^2 + zw^2;
    D = sqrt(D2);
    
    % Kiem tra dieu kien tam voi
    if D > (L1 + L2) || D < abs(L1 - L2)
        valid = false;
        return;
    end
    
    % 4. Goc khuyu tay theta3 (Dinh ly cosin)
    cos_alpha3 = (L1^2 + L2^2 - D2) / (2 * L1 * L2);
    cos_alpha3 = max(-1.0, min(1.0, cos_alpha3));
    alpha3 = acos(cos_alpha3);
    q(3) = alpha3 - pi; % Goc uon khuyu tay
    
    % 5. Goc vai theta2
    beta1 = atan2(zw, rw);
    cos_beta2 = (L1^2 + D2 - L2^2) / (2 * L1 * D);
    cos_beta2 = max(-1.0, min(1.0, cos_beta2));
    beta2 = acos(cos_beta2);
    q(2) = beta1 + beta2;
    
    % 6. Goc co tay theta4
    q(4) = phi - (q(2) + q(3));
end
