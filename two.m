function F2=two(sol,model)
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
      % F2 -    障碍成本
    % 障碍
    threats = model.threats;
    threat_num = size(threats,1);
    
    drone_size = 10;
    danger_dist = 2*drone_size;
    
    F2 = 0;
    for i = 1:threat_num
        threat = threats(i,:);
        threat_x = threat(1);
        threat_y = threat(2);
        threat_radius = threat(4);
        for j = 1:N-1
            % 投影线段与障碍原点之间的距离
            dist = DistP2S([threat_x threat_y],[x_all(j) y_all(j)],[x_all(j+1) y_all(j+1)]);
            if dist > (threat_radius + drone_size + danger_dist) % 无碰撞
                threat_cost = 0;%威胁代价计算
            elseif dist < (threat_radius + drone_size)  % 碰撞
                threat_cost = J_inf;
            else  % 危险
                threat_cost = (threat_radius + drone_size + danger_dist) - dist;
            end
            F2 = F2 + threat_cost;
        end
    end
end