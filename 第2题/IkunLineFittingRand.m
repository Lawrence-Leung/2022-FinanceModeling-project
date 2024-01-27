function [PredictArray] = IkunLineFittingRand (InputMatrix, RandArray)
%%
% 2022.11.4
% 通用直线股票预测工具（随机抽数据debug用）
% 高频取2个点，低频取3到4个点分析
% 输入矩阵：列数：前n个点         size: 行 * 列
%           行数：样本个数
% 输出数组：1列                   size: 行 * 列
%           行数：样本个数
PredictArray = zeros([], 1);

k = 0;
for i = 1 : 10000
    k = k + 1;
    PredictFunc = polyfit(1 : size(InputMatrix, 2), InputMatrix(RandArray(i, 1), :), 1);
    PredictArray(k, 1) = (size(InputMatrix, 2)+1) * PredictFunc(1) + PredictFunc(2);
end

end