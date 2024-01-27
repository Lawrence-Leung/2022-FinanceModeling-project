function [sellnumber, predicteleven] = CoreInput10tOutputNum (InputMatrix, DealMatrix, IsVibrant, k, Basisprice, initprice, BeforeHoldCount)
%%
% 2022.11.5
% 输入前10时刻的数据，决定第11时刻的买卖量
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
% 输出矩阵
% sellnumber (m, n=1)
% m行：m个分别的股票
% n列：1列，第11时刻的买卖数量
%
% predicteleven (m, n=1)
% m行：m个分别的股票
% n列：1列，第11时刻预测的股价
%
%%
% 注意使用情形：
% 建议m = 1;

SELECT_PREDICTION_MACHINE = IsVibrant(1,1);
SELECT_BUYSELL_MACHINE = 1;
% 预测机：0 = 高频，1 = 低频，2 = 拟合
% 买卖机：0 = Classic，1 = Basis, 99 = 巴菲特股价事件，100 = 光大事件

% 中间变量 tempt11 (m, n = 1)
% 第11的股价输出值


%%
if SELECT_PREDICTION_MACHINE <= 0
    tempt11 = IkunStaticPredict001 (InputMatrix);
elseif SELECT_PREDICTION_MACHINE >= 1
    tempt11 = IkunVibrantPredict001 (InputMatrix);
else
    tempt11 = SELECT_PREDICTION_MACHINE * IkunVibrantPredict001 (InputMatrix) + (1-SELECT_PREDICTION_MACHINE) * IkunStaticPredict001 (InputMatrix);
end

%tempt11 = IkunLineFitting (InputMatrix);


% 中间变量 tempbuysellorigin (m, n = 1)
% 原始的第11时刻股价的预测价格
tempbuysellorigin = zeros(1,1);
if SELECT_BUYSELL_MACHINE == 0
    tempbuysellorigin = IkunBuySellClassic (InputMatrix, tempt11, 0, DealMatrix);
elseif SELECT_BUYSELL_MACHINE == 1
    tempbuysellorigin = IkunBuySellBasis (InputMatrix, tempt11, 0, DealMatrix);
elseif SELECT_BUYSELL_MACHINE == 99
    if InputMatrix(1, size(InputMatrix, 2)) > InputMatrix(1, size(InputMatrix, 2)-1)
    tempbuysellorigin = -50 * 1000 * (InputMatrix(1, size(InputMatrix, 2)) - InputMatrix(1, size(InputMatrix, 2)-1));
    elseif InputMatrix(1, size(InputMatrix, 2)) < InputMatrix(1, size(InputMatrix, 2)-1)
    tempbuysellorigin = 10 * 1000 * (InputMatrix(1, size(InputMatrix, 2)) - InputMatrix(1, size(InputMatrix, 2)-1));
    else
        
    end
end
if SELECT_BUYSELL_MACHINE == 100
    if tempt11 > (100 + k(1,1)) * 0.01 * Basisprice(1,1)        %涨停
        tempbuysellorigin(:, 1) = -1 * abs(BeforeHoldcount(1,1) - initprice(1,1));
    else
        tempbuysellorigin = IkunBuySellBasis (InputMatrix, tempt11, 0, DealMatrix);
    end
end

% 中间变量 tempbuysellfinal (m, n = 1)
% 原始的第11时刻股价的决定价格
if SELECT_BUYSELL_MACHINE ~= 99 && SELECT_BUYSELL_MACHINE ~= 100
    tempbuysellfinal = zeros([], 1);
    for m = 1 : min([size(DealMatrix, 1), size(InputMatrix, 1)])
        if tempbuysellorigin (m, 1) <= mean(DealMatrix(m, :)) * 2
            tempbuysellfinal(m, 1) = tempbuysellorigin(m, 1);
        else
            tempbuysellfinal(m, 1) = floor(mean(DealMatrix(m, :)));
        end
    end
    
    sellnumber = -abs(floor(tempbuysellorigin));

else
    sellnumber = floor(tempbuysellorigin(1,1));
end
predicteleven = tempt11;
%tempbuysellfinal;


end