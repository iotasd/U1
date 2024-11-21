

function cost = CostFunction(sol,model)

F_inf = inf;
n = model.n;
H = model.H;

% Input solution
x=sol.x;
y=sol.y;
z=sol.z;

% Start location
xs=model.start(1);
ys=model.start(2);
zs=model.start(3);

% Final location
xf=model.end(1);
yf=model.end(2);
zf=model.end(3);

% 完整路径包含了起点和终点
x_all = [xs x xf];
y_all = [ys y yf];
z_all = [zs z zf];

N = size(x_all,2); % Full path length

% 真实高度是地形高度加上设定的终点高度
z_abs = zeros(1,N);
for i = 1:N
    z_abs(i) = z_all(i) + H(round(y_all(i)),round(x_all(i)));
    
end

%% 成本函数
%  F1 - 航程长度成本
F1 = 0;
for i = 1:N-1
    diff = [x_all(i+1) - x_all(i);y_all(i+1) - y_all(i);z_abs(i+1) - z_abs(i)];
    F1 = F1 + norm(diff);
end
% F1

% F2 - 威胁成本
threats = model.threats;
threat_num = size(threats,1);
drone_size = 10;% D
danger_dist = 2*drone_size; % S

F2 = 0;
for i = 1:threat_num
    threat = threats(i,:);
    threat_x = threat(1);
    threat_y = threat(2);
    threat_radius = threat(4);
    for j = 1:N-1
        % Distance between projected line segment and threat origin
        dist = DistP2S([threat_x threat_y],[x_all(j) y_all(j)],[x_all(j+1) y_all(j+1)]);
        if dist > (threat_radius + drone_size + danger_dist) % No collision
            threat_cost = 0;
        elseif dist < (threat_radius + drone_size)  % Collision
            threat_cost = F_inf;
        else  % danger
            threat_cost = (threat_radius + drone_size + danger_dist) - dist;
        end
        F2 = F2 + threat_cost;
    end
end
% F2

% F3 - 高度成本
zmax = model.zmax;
zmin = model.zmin;
F3 = 0;
for i=1:n
    if z(i) < 0 ||  z(i)<zmin ||  z(i)>zmax
        J3_node = F_inf;
    else
        J3_node = abs(z(i) - (zmax + zmin)/2);
    end

    F3 = F3 + J3_node;
end
% F3

% F4 - 平滑成本
F4 = 0;
turning_max = 45;
climb_max = 45;
for i = 1:N-2

    for j = i:-1:1
        segment1_proj = [x_all(j+1); y_all(j+1); 0] - [x_all(j); y_all(j); 0];
        if nnz(segment1_proj) ~= 0
            break;
        end
    end
    for j = i:N-2
        segment2_proj = [x_all(j+2); y_all(j+2); 0] - [x_all(j+1); y_all(j+1); 0];
        if nnz(segment2_proj) ~= 0
            break;
        end
    end
    climb_angle1 = atan2d(z_abs(i+1) - z_abs(i),norm(segment1_proj));
    climb_angle2 = atan2d(z_abs(i+2) - z_abs(i+1),norm(segment2_proj));

    turning_angle = atan2d(norm(cross(segment1_proj,segment2_proj)),dot(segment1_proj,segment2_proj));
    if abs(turning_angle) > turning_max
        F4 = F4 + abs(turning_angle);
    end
    if abs(climb_angle2 - climb_angle1) > climb_max
        F4 = F4 + abs(climb_angle2 - climb_angle1);
    end
end
% F4

% 各成本函数比重
b1 = 10;
b2 = 100;
b3 = 10;
b4 = 50;
% 总成本
cost = b1*F1 + b2*F2 + b3*F3 + b4*F4;

end