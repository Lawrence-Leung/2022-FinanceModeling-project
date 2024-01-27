function [AfterHoldCount, AfterCash, OutputMatrix, OutputDeal, sellnumber] = CoreUpdate11tHoldStocks (InputMatrix, DealMatrix, Input11Array, Input11Deal, BeforeHoldCount, BeforeCash, IsVibrant, BasisPrice, k, initprice)
%%
% 2022.11.5
% 当前是第11时刻
% 输入第10时刻的持仓、资金数，以及第11时刻的股价，输出第11时刻的持仓和股数
%
% 输入矩阵
% InputMatrix (m, n=10)
% m行：m个分别的股票
% n列：必须得是10个，每一行前10时刻的数据
%
% DealMatrix (m, n=10)
% m行：m个分别的股票
% n列：前10时刻各自的成交量（非累计）
%
% Input11Array (m, n=1)
% m行：m个分别的股票
% n列：必须得是1个，第11时刻的股票票价
%
% Input11Deal (m, n=1)
% m行：m个分别的股票
% n列：必须得是1个，第11时刻的成交量
%
% BeforeHoldCount(m, 1)
% m行：m个分别的股票
% n列：必须得是1个，第10时刻持有的股票
%
% BeforeCash(m, 1)
% m行：m个分别的股票 
% 1列：第10时刻持有的现金
%
% 中间变量
% sellnumber (m, n=1)
% m行：m个分别的股票
% n列：1列，第11时刻的买卖数量
%
% predicteleven (m, n=1)
% m行：m个分别的股票
% n列：1列，第11时刻预测的股价
%
% BasisPrice (1,1)
% 股票基准价
%
% 输出矩阵
%
% AfterHoldCount(m, 1)
% m行：m个分别的股票
% n列：必须得是1个，第10时刻持有的股票
%
% AfterCash(m, 1)
% m行：m个分别的股票 
% 1列：第10时刻持有的现金
%
% OutputMatrix (m, n=10)
% m行：m个分别的股票
% n列：必须得是10个，每一行第2时刻到第11时刻的单价数据
%
% OutputDeal (m, n=10)
% m行：m个分别的股票
% n列：必须得是10个，每一行第2时刻到第11时刻的成交量
%%
sellnumber = CoreInput10tOutputNum(InputMatrix, DealMatrix, IsVibrant, k, BasisPrice, initprice, BeforeHoldCount);

%%

if (-1 * max(sellnumber)) > BeforeHoldCount(1,1) - 1   %不可能使卖出的股票数量多于持有的股票数量
    sellnumber = -1;
end
if max(Input11Array(:,1)) < (100-k(1,1)) * 0.01 * BasisPrice (1,1) && sellnumber < 0
    sellnumber = -1 * abs(BeforeHoldcount(1,1) - initprice(1,1));    %跌停全卖止损措施
end


AfterHoldCount = BeforeHoldCount(1,1) - sellnumber;

stamptax = zeros(size(Input11Array, 1), 1);
bidirectcharge = zeros(size(Input11Array, 1), 1);

for i = 1 : size(Input11Array, 1)
    
    if sellnumber(i, 1) > 0
        stamptax(i, 1) = 10^(-3) * sellnumber(i, 1) * Input11Array(i,1);       %印花税
    end
    if abs((sellnumber(i, 1) * Input11Array(i,1))) > 10^5 / 3
        bidirectcharge(i, 1) = abs((sellnumber(i, 1) * Input11Array(i,1))) * 0.15 * 10^(-3);   %双向0.15‰佣金
    else
        bidirectcharge(i, 1) = 5;
    end

end
AfterCash = BeforeCash - (sellnumber .* Input11Array) - bidirectcharge - stamptax;

% OutputMatrix = zeros([], max([10, size(InputMatrix, 2)]));
for i = 1 : size(InputMatrix, 2) - 1
   OutputMatrix(:, i) = InputMatrix(:, i + 1); 
   OutputDeal(:, i) = DealMatrix(:, i + 1);
end
   OutputMatrix(:, 10) = Input11Array(:, 1);
   OutputDeal(:, 10) = Input11Deal(:, 1);
   
end