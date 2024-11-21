function F4=four(sol,model)
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
     % F4 - Smooth 成本
    F4 = 0;
    turning_max = 45;
    climb_max = 45;
    for i = 1:N-2
        
        % 投影
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

end