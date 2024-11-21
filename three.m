function F3=three(sol,model)
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
      % F3 - 高度成本
    %  在这个计算中，z, zmin和zmax是相对于地面的高度
    zmax = model.zmax;
    zmin = model.zmin;
    F3 = 0;
    for i=1:n        
        if z(i) <= 0   % 撞向地面
            J3_node = F_inf;
        else
            J3_node = abs(z(i) - (zmax + zmin)/2); %高度成本代价计算
        end
        
        F3 = F3 + J3_node;
    end
end