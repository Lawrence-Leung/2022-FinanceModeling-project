function [BuySellArray, ClosedValue] = IkunBuySellReverseRatio (InputMatrix, PredictArray, InitValue)
%%
% 2022.11.4
% 网格买入卖出函数（反比例函数+网格）
% 每1分钱（0.01元）一格
% 每格卖出/买入 100 * (1/第x格) 个
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
gridsize = 10 ^ (-4);                    % 每格大小（元）
diffrence = 0;
ClosedValue = 0;
basecountpergrid = 10 ^ 4;             % 每个买入或卖出的股数
BuySellArray = zeros([], 1);
for i = 1 : size(InputMatrix, 1)    % 逐行操作
    difference = InputMatrix(i, size(InputMatrix, 2)) - PredictArray(i, 1);
    sellnumber = 0;
    if difference > (-1 * gridsize)
        for j = 1 : ceil(difference / gridsize)
            sellnumber = sellnumber + ceil(basecountpergrid * IkunConvertFunction001(j));
        end
    else
        for j = floor(difference / gridsize) : -1
            sellnumber = sellnumber + floor(basecountpergrid * IkunConvertFunction001(j));      
        end
    end
    BuySellArray (i, 1) = sellnumber;
end
ClosedValue = InitValue + sum(BuySellArray(:, 1));
end


function y = IkunConvertFunction001 (x)
    y = 1 / x;



end

