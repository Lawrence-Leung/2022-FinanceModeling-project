function [BuySellArray, ClosedValue] = IkunBuySellClassic (InputMatrix, PredictArray, InitValue, DealMatrix)
%%
% 2022.11.4
% 网格买入卖出函数（最经典）
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
%
% DealMatrix (m, n=10)
% m行：m个分别的股票
% n列：前10时刻各自的成交量（非累计）
%
%
% BuySellArray: 买卖数量决定
% 输出数组：2列                   size: 行 * 列
%           行数：样本个数
%           列数：第1列：买/卖的数量
% ClosedValue:
% 最终持仓数
%%
gridsize = 0.01;                    % 每格大小（元）
diffrence = 0;
sellnumber = 0;
ClosedValue = 0;
basecountpergrid = min(5, 0.015 * max(DealMatrix(:, 10)));             % 每个买入或卖出的股数
BuySellArray = zeros([], 1);
for i = 1 : size(InputMatrix, 1)    % 逐行操作
    difference = InputMatrix(i, size(InputMatrix, 2)) - PredictArray(i, 1);
    sellnumber = ceil(ceil(difference / gridsize) * basecountpergrid);
    BuySellArray (i, 1) = sellnumber;
end
ClosedValue = InitValue + sum(BuySellArray(:, 1));
end
