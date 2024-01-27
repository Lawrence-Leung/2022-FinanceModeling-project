function [BuySellArray, ClosedValue] = IkunBuySellBasis (InputMatrix, PredictArray, InitValue, DealMatrix)
%%
% 2022.11.4
% 网格买入卖出函数（基本的）
% 每1分钱（0.01元）一格
% 每个买入/卖出100个

% InputMatrix:
% 输入矩阵：列数：前n个点         size: 行 * 列
%           行数：样本个数
%
% PredictArray: 
% 输入数组：1列                   size: 行 * 列
%           行数：样本个数
%
% InitValue:
% 初始持仓数
%
% BuySellArray: 买卖数量决定
% 输出数组：2列                   size: 行 * 列
%           行数：样本个数
%           列数：第1列：买/卖的数量
% ClosedValue:
% 最终持仓数
%%
basegrid = 10 ^ (-4);                    % 基准格数大小
topgrid = 10 ^ (-1);
diffrence = 0;
ClosedValue = 0;
basecountpergrid = min(150, 2 * max(DealMatrix(:, 10)));             % 每个买入或卖出的股数
BuySellArray = zeros([], 1);
for i = 1 : size(InputMatrix, 1)    % 逐行操作
    difference = InputMatrix(i, size(InputMatrix, 2)) - PredictArray(i, 1);
    sellnumber = 0;
    sellnumber = sellnumber + IkunConvertFunction002(difference, basegrid, topgrid);    %美的模型
    BuySellArray (i, 1) = sellnumber;
end
ClosedValue = InitValue + sum(BuySellArray(:, 1));



end

function y = IkunConvertFunction002 (x, basegrid, topgrid)
%     if x == 0
%         y = 0;
%     elseif x > 0 && x <= basegrid
%         y = floor(1 / basegrid);
%     elseif x > basegrid && x <= topgrid
%         y = floor(1 / x);
%     elseif x > topgrid
%         y = 0
%     elseif x >= - basegrid && x < 0
%         y = ceil(1 / -basegrid);
%     elseif x >= -topgrid && x < - basegrid
%         y = ceil(1 / x);
%     elseif x < -topgrid
%         y = 0
%     end
%     
%     if y > 0
%     y = floor(y * 0.1);
%     else
%     y = ceil(y * 0.1);
%     end

y = atan(x) / (pi/2) * 1000;

end