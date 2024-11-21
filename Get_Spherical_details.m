

function [lb,ub,dim,fobj] = Get_Spherical_details(VarMax, VarMin, model,flight_num)


fobj=@(x) CostFunction(x,model);

alpha = 1; % 减小

ub = alpha*[VarMax.r*ones(1,flight_num)/2 ,VarMax.psi*ones(1,flight_num) ,VarMax.phi*ones(1,flight_num)];
lb = alpha*[-VarMax.r*ones(1,flight_num)/2 ,VarMin.psi*ones(1,flight_num) ,VarMin.phi*ones(1,flight_num)];

dim = flight_num*3;


