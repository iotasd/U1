

function Draw_results(results,model)

smooth=0.95;
algo_num = size(results.Curve,1);

color_mat = hsv(algo_num); % 按算法个数定义颜色
drone_size = 10;% D
danger_dist = 2*drone_size; % S

%% 3D视角
figure
subplot(221)
% 山地
mesh(model.X,model.Y,model.H); % Plot the data
colormap summer;                    % Default color map.
shading interp;                  % Interpolate color across faces.
material dull;                   % Mountains aren't shiny.
camlight left;                   % Add a light over to the left somewhere.
lighting gouraud;                % Use decent lighting.
xlabel('x [m]','FontName','Times New Roman');
ylabel('y [m]','FontName','Times New Roman');
zlabel('z [m]','FontName','Times New Roman');
hold on

title('3D View','FontName','Times New Roman','FontSize',14)
alpha = .7;
% 威胁物
threats = model.threats;
threat_num = size(threats,1);
h=max(max(model.H)); % Height
for i = 1:threat_num
    threat = threats(i,:);
    threat_x = threat(1);
    threat_y = threat(2);
    threat_z = threat(3);
    threat_radius = threat(4);

    [xc,yc,zc]=cylinder(threat_radius); % create a unit cylinder
    % set the center and height
    xc=xc+threat_x;
    yc=yc+threat_y;
    zc=zc*h+threat_z;
    c = surf(xc,yc,zc,'facecolor',[2 48 71]/255,'edgecolor','none','FaceAlpha',alpha);hold on % set color and transparency

end

for n_algo=1:algo_num
    sol = SphericalToCart(results.Chorm(n_algo,:),model); % 转换坐标
    x=sol.x;
    y=sol.y;
    z=sol.z;

    % 起点
    xs=model.start(1);
    ys=model.start(2);
    zs=model.start(3);
    % 终点
    xf=model.end(1);
    yf=model.end(2);
    zf=model.end(3);
    % 路径
    x_all = [xs x xf];
    y_all = [ys y yf];
    z_all = [zs z zf];

    N = size(x_all,2); %实际路径长度
    % 路径高度相对于地面高度
    for i = 1:N
        z_map = model.H(round(y_all(i)),round(x_all(i)));
        z_all(i) = z_all(i) + z_map;
    end

    xyz = [x_all;y_all;z_all];
    [ndim,npts]=size(xyz);
    xyzp=zeros(size(xyz));
    for k=1:ndim
        xyzp(k,:)=ppval(csaps(1:npts,xyz(k,:),smooth),1:npts);
    end
    all_xyzp{n_algo}= xyzp; % 保存所有的平滑后的路径
    %路径
    p1(n_algo) = plot3([x_all(1) xyzp(1,:) x_all(end)],[y_all(1) xyzp(2,:) y_all(end)],[z_all(1) xyzp(3,:) z_all(end)],'color',color_mat(n_algo,:),'LineWidth',2);
    plot3(xyzp(1,:),xyzp(2,:),xyzp(3,:),'color',color_mat(n_algo,:),'LineWidth',2);
end

% plot start point
p2 = scatter3(x_all(1),y_all(1),z_all(1),100,'bs','MarkerFaceColor','y');
% 终点
p3 = scatter3(x_all(N),y_all(N),z_all(N),100,'kp','MarkerFaceColor','y');
view(-30,70)
% legend([p1,p2,p3],results.algo{1,:},'起点','终点')
hold off;
box on
grid on
xlim([0 model.xmax])
ylim([0 model.ymax])
zlim([min(min(model.H)) 400])


%% 俯视角
subplot(222)
surf(model.X,model.Y,model.H);
colormap summer;
shading flat;
material dull;
camlight left;
lighting gouraud;
xlabel('x [m]','FontName','Times New Roman');
ylabel('y [m]','FontName','Times New Roman');
zlabel('z [m]','FontName','Times New Roman');
hold on
title('Top view','FontName','Times New Roman','FontSize',14)
hold on

% Threats as cylinders
threats = model.threats;
threat_num = size(threats,1);


alpha = .5;
% 威胁物
threats = model.threats;
threat_num = size(threats,1);

h=250; % Height
for i = 1:threat_num
    threat = threats(i,:);
    threat_x = threat(1);
    threat_y = threat(2);
    threat_z = threat(3);
    threat_radius = threat(4);
    scatter3(threat_x, threat_y, threat_z+400,'filled', 'MarkerFaceColor',[2 48 71]/255);

    theta = linspace(0, 2 * pi, 2000);
    % Create the x and y locations at each angle:
    x = threat_radius * cos(theta) + threat_x;
    y = threat_radius * sin(theta) + threat_y;
    % Need to make a z value for every (x,y) pair:
    z = zeros(1, numel(x)) + threat_z+400;
    plot3(x, y, z, '-', 'color', [2 48 71]/255, 'LineWidth', 2);
    threat_radius1 = threat_radius+drone_size;
    x = threat_radius1 * cos(theta) + threat_x;
    y = threat_radius1 * sin(theta) + threat_y;
    % Need to make a z value for every (x,y) pair:
    z = zeros(1, numel(x)) + threat_z+400;
    plot3(x, y, z, '-', 'color', [2 48 71]/255, 'LineWidth', 2);
    threat_radius2 = threat_radius+drone_size+danger_dist;
    x = threat_radius2 * cos(theta) + threat_x;
    y = threat_radius2 * sin(theta) + threat_y;
    % Need to make a z value for every (x,y) pair:
    z = zeros(1, numel(x)) + threat_z+400;
    plot3(x, y, z, '-', 'color', [2 48 71]/255, 'LineWidth', 2);
%     plot3(threat_x, threat_y, threat_z, 'o', 'color', '#752e29', 'MarkerSize', 3, 'MarkerFaceColor','#752e29');

end

for n_algo=1:algo_num
    % 路径
    xyzp = all_xyzp{1, n_algo};
    p1(n_algo)=plot3([x_all(1) xyzp(1,:) x_all(end)],[y_all(1) xyzp(2,:) y_all(end)],[z_all(1) xyzp(3,:) z_all(end)],'color',color_mat(n_algo,:),'LineWidth',2);
end
% plot start point
% plot start point
p2 = scatter3(x_all(1),y_all(1),z_all(1),100,'bs','MarkerFaceColor','y');
% 终点
p3 = scatter3(x_all(N),y_all(N),z_all(N),100,'kp','MarkerFaceColor','y');
legend([p1,p2,p3],results.algo{1,:},'起点','终点')
view(0,90)
xlim([0 model.xmax])
ylim([0 model.ymax])
box on
grid on


%% 侧视图
subplot(223)
mesh(model.X,model.Y,model.H); % Plot the data
colormap summer;                    % Default color map.
shading interp;                  % Interpolate color across faces.
material dull;                   % Mountains aren't shiny.
camlight left;                   % Add a light over to the left somewhere.
lighting gouraud;                % Use decent lighting.
xlabel('x [m]','FontName','Times New Roman','FontSize',14);
ylabel('y [m]','FontName','Times New Roman');
zlabel('z [m]','FontName','Times New Roman');
hold on
title('Side view','FontName','Times New Roman','FontSize',14)
hold on
hold on
for n_algo=1:algo_num
    xyzp = all_xyzp{1, n_algo};
    % plot path
    p1(n_algo)=plot3([x_all(1) xyzp(1,:) x_all(end)],[y_all(1) xyzp(2,:) y_all(end)],[z_all(1) xyzp(3,:) z_all(end)],'color',color_mat(n_algo,:),'LineWidth',2);

end


% plot start point
% plot start point
p2 = scatter3(x_all(1),y_all(1),z_all(1),100,'bs','MarkerFaceColor','y');
% 终点
p3 = scatter3(x_all(N),y_all(N),z_all(N),100,'kp','MarkerFaceColor','y');
view(90,0);
hold off;
box on
grid on
xlim([0 model.xmax])
ylim([0 model.ymax])
zlim([min(min(model.H)) 400])

%% 收敛曲线
subplot(224)
for n_algo=1:algo_num
    plot(results.Curve(n_algo,:),'LineWidth',2,'Color',color_mat(n_algo,:));
    hold on
end
xlabel('Iteration');
ylabel('Best Cost')

xlabel('Iteration','FontName','Times New Roman');
ylabel('Cost','FontName','Times New Roman');
hold on
title('Iterative curves for each algorithm','FontName','Times New Roman','FontSize',14)
hold on

legend(results.algo  {1, :})
grid on;

end