%% =========================================================================
% GIAO DIEN DIEU KHIEN & MO PHONG 3D DIGITAL TWIN KUKA KR 3 (MATLAB)
% Do an thiet ke va dieu khien canh tay robot - UET / VNU
% =========================================================================
function kuka_gui_control()
    % Khoi tao thong so dong hoc (mm)
    h0 = 80.0; L1 = 110.0; L2 = 100.0; L3 = 55.0;
    
    % Khoi tao goc khop ban dau
    q = [0, 45, -45, 0, 0]; % J1, J2, J3, J4, J5 (do)
    gripper_state = 0;      % 0: Mo, 1: Dong
    
    % Bien luu cong Serial Arduino
    s_port = [];
    
    % Tao cua so GUI
    fig = figure('Name', 'KUKA KR 3 - Digital Twin & Control GUI (UET)', ...
                 'NumberTitle', 'off', 'Color', [0.95 0.95 0.95], ...
                 'Position', [100, 100, 1000, 600]);
             
    % Vung ve 3D robot
    ax3d = axes('Parent', fig, 'Position', [0.38, 0.12, 0.58, 0.82]);
    grid(ax3d, 'on'); hold(ax3d, 'on'); view(ax3d, 135, 25);
    axis(ax3d, [-200 300 -250 250 0 350]);
    xlabel(ax3d, 'X (mm)'); ylabel(ax3d, 'Y (mm)'); zlabel(ax3d, 'Z (mm)');
    title(ax3d, 'Mô Phỏng 3D Thời Gian Thực (Digital Twin)', 'FontSize', 12);
    
    % Bang dieu khien ben trai
    panel = uipanel('Parent', fig, 'Title', 'BẢNG ĐIỀU KHIỂN ROBOT', ...
                    'Position', [0.02, 0.05, 0.33, 0.92], 'FontSize', 10, 'FontWeight', 'bold');
                
    % Serial connection UI
    uicontrol('Parent', panel, 'Style', 'text', 'String', 'Cổng COM:', ...
              'Position', [10, 500, 70, 20], 'HorizontalAlignment', 'left');
    editPort = uicontrol('Parent', panel, 'Style', 'edit', 'String', 'COM3', ...
                         'Position', [80, 500, 70, 25]);
    btnConnect = uicontrol('Parent', panel, 'Style', 'pushbutton', 'String', 'Kết nối', ...
                           'Position', [160, 500, 70, 25], 'Callback', @connectSerial);
                       
    % Slider cho tung khop
    names = {'J1 (Đế xoay)', 'J2 (Khớp vai)', 'J3 (Khớp khuỷu)', 'J4 (Cổ tay Pitch)', 'J5 (Cổ tay Roll)'};
    mins  = [-90, -30, -110, -90, -90];
    maxs  = [ 90,  90,   10,  90,  90];
    sliders = gobjects(5, 1);
    lblVals = gobjects(5, 1);
    
    for i = 1:5
        yPos = 460 - (i-1)*45;
        uicontrol('Parent', panel, 'Style', 'text', 'String', names{i}, ...
                  'Position', [10, yPos+18, 120, 18], 'HorizontalAlignment', 'left');
        lblVals(i) = uicontrol('Parent', panel, 'Style', 'text', 'String', sprintf('%.1f°', q(i)), ...
                               'Position', [140, yPos+18, 50, 18], 'HorizontalAlignment', 'right');
        sliders(i) = uicontrol('Parent', panel, 'Style', 'slider', ...
                               'Min', mins(i), 'Max', maxs(i), 'Value', q(i), ...
                               'Position', [10, yPos, 200, 20], ...
                               'Callback', @(src, event) onSliderChange(i));
    end
    
    % Nut bat/tat ban kep (Gripper)
    btnGrip = uicontrol('Parent', panel, 'Style', 'pushbutton', 'String', 'KẸP: ĐANG MỞ', ...
                        'Position', [10, 220, 200, 30], 'BackgroundColor', [0.8 1 0.8], ...
                        'Callback', @toggleGripper);
                    
    % Nhap toa do Cartesian (X, Y, Z) cho giai IK
    uicontrol('Parent', panel, 'Style', 'text', 'String', '--- ĐIỀU KHIỂN THEO TỌA ĐỘ (IK) ---', ...
              'Position', [10, 175, 200, 20], 'FontWeight', 'bold');
    uicontrol('Parent', panel, 'Style', 'text', 'String', 'X:', 'Position', [10, 145, 20, 20]);
    edX = uicontrol('Parent', panel, 'Style', 'edit', 'String', '180.0', 'Position', [30, 145, 45, 22]);
    uicontrol('Parent', panel, 'Style', 'text', 'String', 'Y:', 'Position', [80, 145, 20, 20]);
    edY = uicontrol('Parent', panel, 'Style', 'edit', 'String', '0.0', 'Position', [100, 145, 45, 22]);
    uicontrol('Parent', panel, 'Style', 'text', 'String', 'Z:', 'Position', [150, 145, 20, 20]);
    edZ = uicontrol('Parent', panel, 'Style', 'edit', 'String', '50.0', 'Position', [170, 145, 45, 22]);
    
    btnMoveIK = uicontrol('Parent', panel, 'Style', 'pushbutton', 'String', 'Giải IK & Chạy Tới Điểm', ...
                          'Position', [10, 105, 205, 30], 'BackgroundColor', [0.6 0.8 1], ...
                          'Callback', @moveCartesian);
                      
    % Ve hinh robot ban dau
    hRobotPlot = plot3(ax3d, [0 0], [0 0], [0 0], '-o', 'LineWidth', 5, ...
                       'MarkerSize', 8, 'MarkerFaceColor', [0.9 0.4 0], 'Color', [0.2 0.2 0.8]);
    updateRobotPlot();

    %% CAC HAM XU LY SU KIEN (CALLBACKS)
    function onSliderChange(idx)
        q(idx) = get(sliders(idx), 'Value');
        set(lblVals(idx), 'String', sprintf('%.1f°', q(idx)));
        updateRobotPlot();
        sendSerialCommand();
    end

    function toggleGripper(~, ~)
        if gripper_state == 0
            gripper_state = 1;
            set(btnGrip, 'String', 'KẸP: ĐÃ ĐÓNG', 'BackgroundColor', [1 0.8 0.8]);
        else
            gripper_state = 0;
            set(btnGrip, 'String', 'KẸP: ĐANG MỞ', 'BackgroundColor', [0.8 1 0.8]);
        end
        sendSerialCommand();
    end

    function moveCartesian(~, ~)
        X_t = str2double(get(edX, 'String'));
        Y_t = str2double(get(edY, 'String'));
        Z_t = str2double(get(edZ, 'String'));
        phi_t = deg2rad(-30);
        
        [q_new, ok] = solve_analytical_ik(X_t, Y_t, Z_t, phi_t, h0, L1, L2, L3);
        if ok
            q(1:4) = rad2deg(q_new);
            for k = 1:4
                set(sliders(k), 'Value', q(k));
                set(lblVals(k), 'String', sprintf('%.1f°', q(k)));
            end
            updateRobotPlot();
            sendSerialCommand();
        else
            warndlg('Tọa độ mục tiêu nằm ngoài tầm với của cánh tay KUKA!', 'Lỗi IK');
        end
    end

    function updateRobotPlot()
        % Tinh toan toa do 3D cac khop
        rads = deg2rad(q);
        t1 = rads(1); t2 = rads(2); t3 = rads(3); t4 = rads(4);
        
        P0 = [0, 0, 0];
        P1 = [0, 0, h0];
        
        % Chieu trong mat phang vai
        r2 = L1 * cos(t2);
        z2 = h0 + L1 * sin(t2);
        P2 = [r2 * cos(t1), r2 * sin(t1), z2];
        
        r3 = r2 + L2 * cos(t2 + t3);
        z3 = z2 + L2 * sin(t2 + t3);
        P3 = [r3 * cos(t1), r3 * sin(t1), z3];
        
        r4 = r3 + L3 * cos(t2 + t3 + t4);
        z4 = z3 + L3 * sin(t2 + t3 + t4);
        P4 = [r4 * cos(t1), r4 * sin(t1), z4];
        
        pts = [P0; P1; P2; P3; P4];
        set(hRobotPlot, 'XData', pts(:,1), 'YData', pts(:,2), 'ZData', pts(:,3));
    end

    function connectSerial(~, ~)
        portName = get(editPort, 'String');
        try
            if isempty(s_port)
                s_port = serialport(portName, 115200);
                configureTerminator(s_port, "CR/LF");
                set(btnConnect, 'String', 'Ngắt KN', 'BackgroundColor', [1 0.7 0.7]);
                msgbox(['Đã kết nối thành công với Arduino trên cổng ' portName], 'Thành công');
            else
                delete(s_port);
                s_port = [];
                set(btnConnect, 'String', 'Kết nối', 'BackgroundColor', [0.9 0.9 0.9]);
            end
        catch ME
            errordlg(['Không thể kết nối cổng ' portName ': ' ME.message], 'Lỗi Serial');
        end
    end

    function sendSerialCommand()
        if ~isempty(s_port) && isvalid(s_port)
            % Dinh dang gui lenh: "M J1 J2 J3 J4 J5 G\n"
            cmd = sprintf('M %.1f %.1f %.1f %.1f %.1f %d\n', q(1), q(2), q(3), q(4), q(5), gripper_state);
            writeline(s_port, cmd);
        end
    end
end

function [q, valid] = solve_analytical_ik(X, Y, Z, phi, h0, L1, L2, L3)
    q = zeros(1, 4); valid = true;
    q(1) = atan2(Y, X);
    r = sqrt(X^2 + Y^2);
    rw = r - L3 * cos(phi);
    zw = Z - h0 - L3 * sin(phi);
    D2 = rw^2 + zw^2; D = sqrt(D2);
    if D > (L1 + L2) || D < abs(L1 - L2), valid = false; return; end
    cos_a3 = (L1^2 + L2^2 - D2) / (2 * L1 * L2);
    q(3) = acos(max(-1, min(1, cos_a3))) - pi;
    b1 = atan2(zw, rw);
    cos_b2 = (L1^2 + D2 - L2^2) / (2 * L1 * D);
    q(2) = b1 + acos(max(-1, min(1, cos_b2)));
    q(4) = phi - (q(2) + q(3));
end
