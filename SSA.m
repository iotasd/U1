% % 微信公众号：KAU的云实验台
% 付费代码(仅在此购买代码可答疑)：https://mbd.pub/o/author-a2iWlGtpZA==
% 严禁倒卖，违者必究


function [Convergence_curve  ,fMin ,bestX] = SSA(lb,ub,dim,fobj,Popsize,maxgen,model)


%% 算法参数初始化
find_ = 0.4;  % 发现者在种群中的比例
ST = 0.8; % 安全阈值
FD = 0.2; % 意识到危险的麻雀比例

%% 初始化种群
pNum = round( Popsize *  find_ );    % 种群中发现者个数

for i = 1 : Popsize
    x( i, : ) = lb + (ub - lb) .* rand( 1, dim );
    fit( i ) = fobj( SphericalToCart(x( i, : ),model) ) ;
end

pFit = fit;
pX = x;                            % 个体最优适应度
[ fMin, bestI ] = min( fit );      % 全局最优个体适应度
bestX = x( bestI, : );             % 全局最优个体

%% 迭代

for t = 1 : maxgen

    % 排序找到全局最差位置
    [ ans, sortIndex ] = sort( pFit );% 从小到大
    [fmax,B]=max( pFit );
    worse= x(B,:);

    % 发现者位置更新
    r2=rand(1);
    if(r2<ST)
        for i = 1 : pNum
            r1=rand(1);
            x( sortIndex( i ), : ) = pX( sortIndex( i ), : )*exp(-(i)/(r1*maxgen));
            x( sortIndex( i ), : ) = Bounds( x( sortIndex( i ), : ), lb, ub );
            fit( sortIndex( i ) ) = fobj( SphericalToCart(x( sortIndex( i ), : ),model) );
        end
    else
        for i = 1 : pNum
            x( sortIndex( i ), : ) = pX( sortIndex( i ), : )+randn(1)*ones(1,dim);
            x( sortIndex( i ), : ) = Bounds( x( sortIndex( i ), : ), lb, ub );
            fit( sortIndex( i ) ) = fobj( SphericalToCart(x( sortIndex( i ), : ),model));

        end
    end

    % 最优更新
    [ fMMin, bestII ] = min( fit );
    bestXX = x( bestII, : );

    % 加入者更新
    for i = ( pNum + 1 ) : Popsize

        A=floor(rand(1,dim)*2)*2-1;
        if( i>(Popsize/2))
            x( sortIndex(i ), : )=randn(1)*exp((worse-pX( sortIndex( i ), : ))/(i)^2);
        else
            x( sortIndex( i ), : )=bestXX+(abs(( pX( sortIndex( i ), : )-bestXX)))*(A'*(A*A')^(-1))*ones(1,dim);
        end
        x( sortIndex( i ), : ) = Bounds( x( sortIndex( i ), : ), lb, ub );
        fit( sortIndex( i ) ) = fobj( SphericalToCart(x( sortIndex( i ), : ),model) );

    end

    % 随机产生意识到危险的麻雀
    llb=randperm(numel(sortIndex));
    b=sortIndex(llb(1:round( Popsize *  FD )));
    for j =  1  : length(b)

        if( pFit( sortIndex( b(j) ) )>(fMin) )
            x( sortIndex( b(j) ), : )=bestX+(randn(1,dim)).*(abs(( pX( sortIndex( b(j) ), : ) -bestX)));
        else
            x( sortIndex( b(j) ), : ) =pX( sortIndex( b(j) ), : )+(2*rand(1)-1)*(abs(pX( sortIndex( b(j) ), : )-worse))/ ( pFit( sortIndex( b(j) ) )-fmax+1e-50);
        end
        x( sortIndex(b(j) ), : ) = Bounds( x( sortIndex(b(j) ), : ), lb, ub );
        fit( sortIndex( b(j) ) ) = fobj( SphericalToCart(x( sortIndex( b(j) ), : ),model) );
    end

    % 最优更新
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
