%% =========================================================================
% MO HINH DONG HOC & TINH TOAN MO-MEN KUKA KR 3 (5-DOF + GRIPPER)
% Do an thiet ke va dieu khien canh tay robot - UET / VNU
% =========================================================================
clear; clc; close all;

%% 1. KHOI TAO CAC THONG SO HINH HOC CO BAN (don vi: mm)
a1 = 9.8;     % Do lech truc vai J2 ra phia truoc truc de J1
h0 = 169.05;  % Chieu cao truc vai J2 so voi mat ban
L1 = 127.4;   % Chieu dai canh tay tren (Upper Arm: J2 -> J3)
L2 = 127.8;   % Chieu dai cang tay (Forearm: J3 -> J4, do theo duong thang noi hai truc)
L3 = 86.8;    % Chieu dai co tay va khau kep (J4 -> ranh chu V cua ngon kep)

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
setFixedTransform(jnt2, trvec2tform([a1, 0, 0]));
jnt2.JointAxis = [0, -1, 0]; % Goc duong nang khau len (cung quy uoc voi IK)
jnt2.PositionLimits = deg2rad([-45, 105]);
body2.Joint = jnt2;
addBody(robot, body2, 'link1');

% Link 3: Forearm (Quay quanh truc ngang Y2 - J3)
body3 = rigidBody('link3');
jnt3 = rigidBodyJoint('jnt3', 'revolute');
setFixedTransform(jnt3, trvec2tform([L1, 0, 0])); % doc theo Link 1
jnt3.JointAxis = [0, -1, 0]; % Goc duong nang khau len (cung quy uoc voi IK)
jnt3.PositionLimits = deg2rad([-90, 75]);
body3.Joint = jnt3;
addBody(robot, body3, 'link2');

% Link 4: Wrist Pitch (Quay quanh truc ngang Y3 - J4)
body4 = rigidBody('link4');
jnt4 = rigidBodyJoint('jnt4', 'revolute');
setFixedTransform(jnt4, trvec2tform([L2, 0, 0]));
jnt4.JointAxis = [0, -1, 0]; % Goc duong nang khau len (cung quy uoc voi IK)
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
axis([-250 350 -350 350 0 450]);
grid on; view(135, 25);

%% 4. KIEM NGHIEM MO-MEN TAI TRONG CAC KHOP (TORQUE ANALYSIS)
% Tu the xau nhat: ca canh tay duoi thang nam ngang, mang vat gap 50 g.
% The tich V, dien tich A va trong tam cua chi tiet in do tren 00_Robot_J1J2_Assembly.
% "d" la khoang cach tu truc khop dau khau den trong tam, do doc theo khau.
rho_petg  = 1.27;  % Khoi luong rieng PETG (g/cm^3)
t_wall    = 0.16;  % Be day thanh in: 4 lop x 0.4 mm (cm)
infill_L  = 0.20;  % Infill cac khoi than KUKA lon
infill_S  = 0.35;  % Infill chi tiet nho chiu luc
m_payload = 50;    % Vat gap toi da (g)
k_dyn     = 1.8;   % He so gia toc khi khoi dong/dung
g         = 9.81;  % m/s^2

% Chi tiet in: {Ten, khau, V (cm^3), A (cm^2), infill, d (mm)}
% Khau 1: J2 -> J3, khau 2: J3 -> J4, khau 3: J4 -> tam gap
printed = { ...
    '03_UpperArmKuka',        1, 383.05, 557.43, infill_L,  59.5; ...
    '04_Forearm_ElbowKuka',   2, 145.72, 264.12, infill_L,  18.4; ...
    '04_Forearm_ForkKuka',    2,  69.61, 204.98, infill_L,  85.5; ...
    '04_Forearm_CoverPivot',  2,  26.25,  82.80, infill_S, 100.4; ...
    '04_Forearm_CoverServo',  2,   6.01,  55.05, infill_S,  98.0; ...
    '05_WristKuka',           3,  54.54, 119.99, infill_S,   0.1; ...
    '06_Gripper_Base',        3,  35.78, 114.13, infill_S,  43.5; ...
    '06_Gripper_Guide',       3,  13.42,  93.15, infill_S,  67.3; ...
    '06_Gripper_Jaw (x2)',    3,  12.94,  74.85, infill_S,  85.7};

% Linh kien mua san: {Ten, khau, khoi luong (g), d (mm)}
cots = { ...
    'MG996R khop J3 (nam trong canh tay tren)', 1, 55.0, 118.4; ...
    'Dia sung 25T khop J3',                     2,  5.0,   0.0; ...
    'MG90S khop J4',                            2, 13.4, 122.8; ...
    'MG90S khop J5',                            3, 13.4,  15.8; ...
    'MG90S tay gap',                            3, 13.4,  51.3};

V = cell2mat(printed(:, 3));
A = cell2mat(printed(:, 4));
V_shell   = min(A * t_wall, V);  % Lop vo dac
m_printed = rho_petg * (V_shell + cell2mat(printed(:, 5)) .* (V - V_shell));

link = [cell2mat(printed(:, 2)); cell2mat(cots(:, 2))];
mass = [m_printed;               cell2mat(cots(:, 3))];  % g
d    = [cell2mat(printed(:, 6)); cell2mat(cots(:, 4))];  % mm

% Servo dan dong tung khop va mo-men ham o 6 V (kg.cm)
link_start  = [0, L1, L1 + L2];  % Khoang cach tu J2 den dau moi khau (mm)
joint_name  = {'Vai J2', 'Khuyu J3', 'Co tay J4'};
servo_name  = {'Servo so 25 kg', 'MG996R', 'MG90S'};
servo_stall = [22.0, 11.0, 2.2];

fprintf('\n--- KET QUA KIEM NGHIEM TAI TRONG & MO-MEN XOAN TINH ---\n');
for k = 1:3
    fprintf('Khau %d: %.0f g\n', k, sum(mass(link == k)));
end
for j = 1:3
    carried = link >= j;
    arm = link_start(link(carried))' - link_start(j) + d(carried);  % mm
    T_kgcm = (sum(mass(carried) .* arm) + ...
              m_payload * (L1 + L2 + L3 - link_start(j))) / 1e4;
    fprintf(['Khop %-9s: tinh %.2f kg.cm (%.2f N.m), dong %.2f kg.cm | ' ...
             '%s %.1f kg.cm @ 6V -> S tinh = %.2f, S dong = %.2f\n'], ...
        joint_name{j}, T_kgcm, T_kgcm * g / 100, k_dyn * T_kgcm, ...
        servo_name{j}, servo_stall(j), servo_stall(j) / T_kgcm, ...
        servo_stall(j) / (k_dyn * T_kgcm));
end

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

    % Doi chieu nghiem voi gioi han khop cua mo hinh
    q_lim = [jnt1.PositionLimits; jnt2.PositionLimits; jnt3.PositionLimits; jnt4.PositionLimits];
    out = find(q_sol' < q_lim(:, 1) | q_sol' > q_lim(:, 2))';
    if isempty(out)
        fprintf('Nghiem nam trong gioi han khop.\n');
    else
        fprintf('CANH BAO: nghiem vuot gioi han khop J%d.\n', out);
    end
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
    a1 = 9.8;
    rw = r - a1 - L3 * cos(phi);
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
