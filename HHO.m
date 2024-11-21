% % 微信公众号：KAU的云实验台
% 付费代码(仅在此购买代码可答疑)：https://mbd.pub/o/author-a2iWlGtpZA==
% 严禁倒卖，违者必究

function [CNVG , Rabbit_Energy, Rabbit_Location] = HHO(lb,ub,dim,fobj,Popsize,iter,model)


% 猎物-兔子
Rabbit_Location=zeros(1,dim);
Rabbit_Energy=inf;

%% 初始化种群
X=initialization(Popsize,ub,lb,dim);

CNVG=zeros(1,iter);

t=0;

%% 迭代
while t<iter

    % 更新个体与适应度
    for i=1:size(X,1)
        % 边界检查
        FU=X(i,:)>ub;FL=X(i,:)<lb;X(i,:)=(X(i,:).*(~(FU+FL)))+ub.*FU+lb.*FL;
        % 适应度计算
        fitness=fobj(SphericalToCart(X(i,:),model));
        % 更新位置
        if fitness<Rabbit_Energy
            Rabbit_Energy=fitness;
            Rabbit_Location=X(i,:);
        end
    end

    % 猎物逃逸能量
    E1=2*(1-(t/iter));

    for i=1:size(X,1)

        % 猎物逃逸能量 更新
        E0=2*rand()-1;
        Escaping_Energy=E1*(E0);

        if abs(Escaping_Energy)>=1

            % 探索阶段 ；两种策略
            q=rand();
            rand_Hawk_index = floor(Popsize*rand()+1);
            X_rand = X(rand_Hawk_index, :);
            if q<0.5
                X(i,:)=X_rand-rand()*abs(X_rand-2*rand()*X(i,:));
            elseif q>=0.5
                X(i,:)=(Rabbit_Location(1,:)-mean(X))-rand()*((ub-lb)*rand+lb);
            end

        elseif abs(Escaping_Energy)<1

            % 开发阶段 4种策略
            Sp=rand();

            % 硬包围
            if Sp>=0.5 && abs(Escaping_Energy)<0.5
                X(i,:)=(Rabbit_Location)-Escaping_Energy*abs(Rabbit_Location-X(i,:));
            end

            % 软包围
            if Sp>=0.5 && abs(Escaping_Energy)>=0.5
                Jump_strength=2*(1-rand());
                X(i,:)=(Rabbit_Location-X(i,:))-Escaping_Energy*abs(Jump_strength*Rabbit_Location-X(i,:));
            end

            % 渐进式快速俯冲软包围
            if Sp<0.5 && abs(Escaping_Energy)>=0.5

                Jump_strength=2*(1-rand());
                X1=Rabbit_Location-Escaping_Energy*abs(Jump_strength*Rabbit_Location-X(i,:));

                if fobj(SphericalToCart(X1,model))<fobj(SphericalToCart(X(i,:),model))
                    X(i,:)=X1;
                else
                    X2=Rabbit_Location-Escaping_Energy*abs(Jump_strength*Rabbit_Location-X(i,:))+rand(1,dim).*Levy(dim);
                    if (fobj(SphericalToCart(X2,model))<fobj(SphericalToCart(X(i,:),model)))
                        X(i,:)=X2;
                    end
                end
            end

            % 渐进式快速俯冲硬包围
            if Sp<0.5 && abs(Escaping_Energy)<0.5
                Jump_strength=2*(1-rand());
                X1=Rabbit_Location-Escaping_Energy*abs(Jump_strength*Rabbit_Location-mean(X));

                if fobj(SphericalToCart(X1,model))<fobj(SphericalToCart(X(i,:),model))
                    X(i,:)=X1;
                else
                    X2=Rabbit_Location-Escaping_Energy*abs(Jump_strength*Rabbit_Location-mean(X))+rand(1,dim).*Levy(dim);
                    if (fobj(SphericalToCart(X2,model))<fobj(SphericalToCart(X(i,:),model))) % improved move?
                        X(i,:)=X2;
                    end
                end
            end
            %%
        end
    end
    t=t+1;
    CNVG(t)=Rabbit_Energy;

end


