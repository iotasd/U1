function F1=one(sol,model)
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