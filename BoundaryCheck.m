%% 边界检查函数
function [X] = BoundaryCheck(x,ub,lb,dim)
    %dim为数据的维度大小
    %x为输入数据，维度为[1,dim];
    %ub为数据上边界，维度为[1,dim]
    %lb为数据下边界，维度为[1,dim]
    for i = 1:dim
        if x(i)>ub(i)
           x(i) = ub(i); 
        end
        if x(i)<lb(i)
            x(i) = lb(i);
        end
    end
    X = x;
end