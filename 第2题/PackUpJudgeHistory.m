function [IsVibrant, Freq, TotProfit] = PackUpJudgeHistory (Input11MatrixExt, Input11ArrayOrigin, Input11DealOrigin)
% 2022.11.6
% 股票类型判断，基于历史数据判断
%
% 输入：
% Input11ArrayExt(m, 4)
% 第1列：时间；第2列：单价(可以)；第3列：现手；第4列：笔数(可以)
% 若输入-1，则执行下面的
%
% 或
% Input11ArrayOrigin (m, 1) = 每时刻股价原始数据，m行1列
% Input11DealOrigin (m, 1) = 每时刻交易量原始数据，m行1列
%
% 输出：
% Freq(1,1)：频率
% TotProfit(1,1)：收益差
% IsVibrant(1,1)：是否静态

%% 判断股票类型
tempfreq = zeros([], 1);
i1 = 0;
m = 0;
tempprofit = 0;
TIME = 3;       %间隔3秒一次交易

if Input11MatrixExt ~= -1
    for i = 1 : size(Input11MatrixExt, 1) - 1
        if Input11MatrixExt(i, 2) ~= 0 && Input11MatrixExt(i+1, 2) ~= 0 && Input11MatrixExt(i+1, 2)-Input11MatrixExt(i, 2) > 0     %增长
            tempprofit = tempprofit + abs((Input11MatrixExt(i+1, 2)-Input11MatrixExt(i, 2)) * Input11MatrixExt(i+1, 4));
            if m < 0
                i1 = i1 + 1;
                tempfreq(i1, 1) = abs(m * TIME);
                m = 0;
            end
                m = m + 1;
        elseif Input11MatrixExt(i, 2) ~= 0 && Input11MatrixExt(i+1, 2) ~= 0 && Input11MatrixExt(i+1, 2)-Input11MatrixExt(i, 2) < 0     %下跌
            if m > 0
                i1 = i1 + 1;
                tempfreq(i1, 1) = abs(m * TIME);
                m = 0;
            end
                m = m - 1;
        else           %不增不减
            if m > 0
                m = m + 1;
            elseif m < 0
                m = m - 1;
                else
                m = m;
            end
        end
    end
else
    for i = 1 : min(size(Input11ArrayOrigin, 1), size(Input11DealOrigin,1)) - 1
        if Input11ArrayOrigin(i, 1) ~= 0 && Input11ArrayOrigin(i+1, 1) ~= 0 && Input11ArrayOrigin(i+1, 1)-Input11ArrayOrigin(i, 1) > 0     %增长
            tempprofit = tempprofit + abs((Input11ArrayOrigin(i+1, 1)-Input11ArrayOrigin(i, 1)) * Input11DealOrigin(i+1, 1));
            if m < 0
                i1 = i1 + 1;
                tempfreq(i1, 1) = abs(m * TIME);
                m = 0;
            end
                m = m + 1;
        elseif Input11ArrayOrigin(i, 1) ~= 0 && Input11ArrayOrigin(i+1, 1) ~= 0 && Input11ArrayOrigin(i+1, 1)-Input11ArrayOrigin(i, 1) < 0     %下跌
            if m > 0
                i1 = i1 + 1;
                tempfreq(i1, 1) = abs(m * TIME);
                m = 0;
            end
                m = m - 1;
        else           %不增不减
            if m > 0
                m = m + 1;
            elseif m < 0
                m = m - 1;
                else
                m = m;
            end
        end
    end
end
i1 = i1 + 1;
tempfreq(i1, 1) = abs(m * TIME);

%最终数据处理
Freq = (1 / mean(tempfreq(:, 1))) * 100;
TotProfit = tempprofit / size(Input11MatrixExt, 1) / 3;

IsVibrant = CNNJudge20221106([TotProfit(1,1), Freq(1,1)]);

end