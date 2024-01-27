function [PredictArray] = IkunLineFitting (InputMatrix)
%%
% 2022.11.4
% 通用直线股票预测工具
% 高频取2个点，低频取3到4个点分析
% 输入矩阵：列数：前n个点         size: 行 * 列
%           行数：样本个数
% 输出数组：1列                   size: 行 * 列
%           行数：样本个数
PredictArray = zeros([], 1);
for i = 1 : size(InputMatrix, 1)
    PredictFunc = polyfit(1 : size(InputMatrix, 2), InputMatrix(i, :), 1);
    PredictArray(i, 1) = (size(InputMatrix, 2)+1) * PredictFunc(1) + PredictFunc(2);
end

end