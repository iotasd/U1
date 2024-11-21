%% 举例

rng(4)
goalPos = [10 10 1];
startPos = [0 0 0];

AngleRange = pi/4;

dirVector = goalPos - startPos;
phi0 = atan2(dirVector(2),dirVector(1));

% 球形坐标
r=unifrnd(1,4,4);
psi=unifrnd(-pi/4,pi/4,4);
phi=unifrnd(phi0 - AngleRange,phi0 + AngleRange,4);
xs = startPos(1);
ys = startPos(2);
zs = startPos(3);
% 球转直角
% First Cartesian coordinate
x(1) = xs + r(1)*cos(psi(1))*sin(phi(1));

% Check limits
if x(1) > 10
    x(1) = 10;
end
if x(1) < 0
    x(1) = 0;
end

y(1) = ys + r(1)*cos(psi(1))*cos(phi(1));
if y(1) >10
    y(1) = 10;
end
if y(1) < 0
    y(1) = 0;
end

z(1) = zs + r(1)*sin(psi(1));
if z(1) > 10
    z(1) = 10;
end
if z(1) < 0
    z(1) = 0;
end

% Next Cartesian coordinates
for i = 2:4
    x(i) = x(i-1) + r(i)*cos(psi(i))*sin(phi(i));
    if x(i) > 10
        x(i) = 10;
    end
    if x(i) < 0
        x(i) = 0;
    end

    y(i) = y(i-1) + r(i)*cos(psi(i))*cos(phi(i));
    if y(i) > 10
        y(i) = 10;
    end
    if y(i) < 0
        y(i) = 0;
    end

    % z(i) = z(i-1) + r(i)*cos(psi(i));
    z(i) = z(i-1) + r(i)*sin(psi(i));
    if z(i) > 1
        z(i) = 1;
    end
    if z(i) < 0
        z(i) = 0;
    end
end

x1 = x;
y1 = y;
z1 = z;

% 直角坐标
dim =4;
x(1:dim) = unifrnd(startPos(1),goalPos(1),1,dim);
% x(1:dim) = sort( x(1:dim));
y(1:dim) = unifrnd(startPos(2),goalPos(2),1,dim);
% y(1:dim) = sort( y(1:dim));
z(1:dim) = unifrnd(startPos(3),goalPos(3),1,dim);
% z(1:dim) = sort( z(1:dim));


p1 = scatter3(startPos(1), startPos(2), startPos(3),100,'bs','MarkerFaceColor','y');
hold on
p2 = scatter3(goalPos(1), goalPos(2), goalPos(3),100,'kp','MarkerFaceColor','y');


x_seq1=[startPos(1), x1, goalPos(1)];
y_seq1=[startPos(2), y1, goalPos(2)];
z_seq1=[startPos(3), z1, goalPos(3)];

x_seq2=[startPos(1), x, goalPos(1)];
y_seq2=[startPos(2), y, goalPos(2)];
z_seq2=[startPos(3), z, goalPos(3)];

% 利用三次样条拟合散点

k = length(x_seq1);
i_seq = linspace(0,1,k);
xx_seq = linspace(0,1,10);
yy_seq = linspace(0,1,10);
zz_seq = linspace(0,1,10);
X_seq1 = spline(i_seq,x_seq1,xx_seq);
Y_seq1 = spline(i_seq,y_seq1,yy_seq);
Z_seq1 = spline(i_seq,z_seq1,zz_seq);
X_seq2 = spline(i_seq,x_seq2,xx_seq);
Y_seq2 = spline(i_seq,y_seq2,yy_seq);
Z_seq2 = spline(i_seq,z_seq2,zz_seq);
path1 = [X_seq1', Y_seq1', Z_seq1'];
path2 = [X_seq2', Y_seq2', Z_seq2'];



p3 = plot3(path1(:,1), path1(:,2),path1(:,3),'LineWidth',2);
p4 = plot3(path2(:,1), path2(:,2),path2(:,3),'LineWidth',2);
hold off
grid on

legend([p1,p2,p3,p4],'起点','终点','球形坐标路线','直角坐标路线')


