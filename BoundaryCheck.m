%% �߽��麯��
function [X] = BoundaryCheck(x,ub,lb,dim)
    %dimΪ���ݵ�ά�ȴ�С
    %xΪ�������ݣ�ά��Ϊ[1,dim];
    %ubΪ�����ϱ߽磬ά��Ϊ[1,dim]
    %lbΪ�����±߽磬ά��Ϊ[1,dim]
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