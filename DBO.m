

function [Convergence_curve , fMin, bestX] = DBO(lb,ub,dim,fobj,Popsize,Max_iteration,model)


rol_percent = 0.25;  rolNum = rol_percent*Popsize; % 滚球蜣螂个数
egg_percent = 0.25;  eggNum = egg_percent*Popsize; % 育雏球个数
bab_percent = 0.25; babNum = bab_percent*Popsize; % 小蜣螂个数
ste_percent = 0.25; steNum = ste_percent*Popsize; % 偷窃蜣螂个数

%% 初始化种群
for i = 1 : Popsize
    x( i, : ) = lb + (ub - lb) .* rand( 1, dim );
    fit( i ) = fobj( SphericalToCart(x( i, : ),model) ) ;
end
pFit = fit;
pX = x;
XX=pX;
[ fMin, bestI ] = min( fit );
bestX = x( bestI, : );

%% 迭代
for t = 1 : Max_iteration

    [fmax,B]=max(fit);
    worse= x(B,:);

    % 跳舞or滚球概率
    r2=rand(1);
    for i = 1 : rolNum
        if(r2<0.9)
            % 滚球
            r1=rand(1);
            % 自然系数
            a=rand(1,1);
            if (a>0.1)
                a=1;
            else
                a=-1;
            end
            % 滚球蜣螂位置
            x( i , : ) =  pX(  i , :)+0.3*abs(pX(i , : )-worse)+a*0.1*(XX( i , :));
        else
            % 跳舞
            aaa= randperm(180,1);
            if ( aaa==0 ||aaa==90 ||aaa==180 )
                x(  i , : ) = pX(  i , :);
            end
            theta= aaa*pi/180;

            x(  i , : ) = pX(  i , :)+tan(theta).*abs(pX(i , : )-XX( i , :));

        end
        % 更新
        x(  i , : ) = Boundss( x(i , : ), lb, ub );
        fit(  i  ) = fobj( SphericalToCart(x( i, : ),model) );
    end
    [ fMMin, bestII ] = min( fit );
    bestXX = x( bestII, : );

    % 育雏球
    R=1-t/Max_iteration;
    % 小蜣螂
    Xnew1 = bestXX.*(1-R);
    Xnew2 =bestXX.*(1+R);
    Xnew1= Bounds( Xnew1, lb, ub );
    Xnew2 = Bounds( Xnew2, lb, ub );
    % 产卵区域
    Xnew11 = bestX.*(1-R);
    Xnew22 =bestX.*(1+R);
    Xnew11= Boundss( Xnew11, lb, ub );
    Xnew22 = Boundss( Xnew22, lb, ub );

    % 小蜣螂更新
    for i = ( rolNum + 1 ) :rolNum+babNum
        x( i, : )=bestXX+((rand(1,dim)).*(pX( i , : )-Xnew1)+(rand(1,dim)).*(pX( i , : )-Xnew2));
        x(i, : ) = Boundss( x(i, : ), Xnew1, Xnew2 );
        fit(i ) = fobj(  SphericalToCart(x( i, : ),model) ) ;
    end

    % 育雏球更新
    for i = rolNum+babNum +1: rolNum+babNum+eggNum
        x( i, : )=pX( i , : )+((randn(1)).*(pX( i , : )-Xnew11)+((rand(1,dim)).*(pX( i , : )-Xnew22)));
        x(i, : ) = Boundss( x(i, : ),lb, ub);
        fit(i ) = fobj(  SphericalToCart(x( i, : ),model) ) ;

    end

    % 小偷蜣螂更新
    for j = rolNum+babNum+eggNum+1 : Popsize
        x( j,: )=bestX+randn(1,dim).*((abs(( pX(j,:  )-bestXX)))+(abs(( pX(j,:  )-bestX))))./2;
        x(j, : ) = Bounds( x(j, : ), lb, ub );
        fit(j ) = fobj(  SphericalToCart(x( j, : ),model) ) ;
    end

    % 更新个体最优和全局最优
    XX=pX;
    for i = 1 : Popsize
        if ( fit( i ) < pFit( i ) )
            pFit( i ) = fit( i );
            pX( i, : ) = x( i, : );
        end

        if( pFit( i ) < fMin )
            fMin= pFit( i );
            bestX = pX( i, : );

        end
    end
    Convergence_curve(t)=fMin;
end

