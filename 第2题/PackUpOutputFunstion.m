function [HoldCountRouting, CashTests, AveCost, SellNumber, AveProfitRate, MaximemRetfinal, TradeNumbers, HoldCountTest, PureProfit] = PackUpOutputFunstion (Input11ArrayOrigin, Input11DealOrigin, BeforeHoldCount, BeforeCash, EndPriceYesterday)
%%
% 2022.11.6
% 大打包函数
% 输入：
%
% m 是同一只股票的不同的时间点！
%
% Input11ArrayOrigin (m, 1) = 每时刻股价原始数据，m行1列
% Input11DealOrigin (m, 1) = 每时刻交易量原始数据，m行1列
% BeforeHoldCount (1,1) = 从前的持仓数目
% BeforeCash(1,1) = 从前的持有金额
% EndPriceYesterday(1,1) = 从前的收盘价
% 
% 输出：
% HoldCountRouting (m-10, 1) = 持仓数目（过程）
% CashTests (m-10,1) = 最终的持有金额
% AveCost (m-10, 1) = 平均成本
% SellNumber (m-10, 1) = 每次买入的数量（买正卖负）
% AveProfitRate (m-10, 1) = 平均收益率
% MaximumRetracement (1, 1) = 最大回撤
% HoldCountTest (1,1) = 最终的持仓数目 （终点）
% PureProfit (1,1) = 最终收益

% 变量设置部分
InputMatrixTest = zeros(1, 10);
DealMatrixTest = zeros(1, 10);
HoldCountTest = BeforeHoldCount(1, 1);
CashTests = zeros([], 1);
CashTest = 0;
sellnumber = 0;
SellNumber = zeros([], 1);
AveCost = zeros([], 1);
AveProfitRate = zeros([], 1);
HoldCountRouting = zeros([], 1);
avecostcell = EndPriceYesterday;
MaximumRetracement = 0;
maximumrec = 0;
minimumrec = 0;
TradeNumber = 0;
TradeNumbers = zeros([], 1);
%aveprofitrate = 0;
m = 0;
%beforecash = BeforeCash;
beforeholdcount = zeros(1,1);
beforeholdcount = BeforeHoldCount(1, 1);      %分量，用于存储从前的持仓数目

k = 90;                  %一种止损线的设置策略，股价低于基准价的k%时就卖股止损
basisprice = 0;         %基准价
IsVibrant = PackUpJudgeHistory (-1, Input11ArrayOrigin, Input11DealOrigin);



% 主循环
for i = 1 : size(Input11ArrayOrigin, 1)
    
    %计算回撤部分
    if i > 2
        if Input11ArrayOrigin(i, 1) - Input11ArrayOrigin(i-1, 1) < 0 && Input11ArrayOrigin(i-1, 1) - Input11ArrayOrigin(i-2, 1) >= 0    %极大值
            
            if Input11ArrayOrigin(i-1, 1) >= maximumrec
                MaximumRetracement = max(MaximumRetracement, maximumrec - minimumrec);
                MaximemRetfinal = MaximumRetracement/ maximumrec;
                maximumrec = Input11ArrayOrigin(i-1, 1);
                minimumrec = Input11ArrayOrigin(i-1, 1);
            else  %Input11ArrayOrigin(i-1, 1) < maximumrec
            end
            maximumrec = Input11ArrayOrigin(i-1, 1);
        end
        if Input11ArrayOrigin(i, 1) - Input11ArrayOrigin(i-1, 1) > 0 && Input11ArrayOrigin(i-1, 1) - Input11ArrayOrigin(i-2, 1) <= 0    %极小值
            minimumrec = min(minimumrec, Input11ArrayOrigin(i-1, 1));
        end
    end
    % 交易部分
    if i <= 10           %前10个时刻不进行任何交易
        InputMatrixTest(1, i) = Input11ArrayOrigin(i, 1);
        DealMatrixTest(1, i) = Input11DealOrigin(i, 1);
        basisprice = basisprice + 0.1 * Input11ArrayOrigin(i, 1); %基准价  

    elseif ( i == size(Input11ArrayOrigin, 1) && (HoldCountTest > beforeholdcount)) || mod(i, floor(size(Input11ArrayOrigin, 1)/21)) == 0       %最后一刻，剩下的全部卖出，最终得到高频交易所需股票
        holdcounttest = HoldCountTest;  %前一时刻的持仓
        
        [~,~,InputMatrixTest, DealMatrixTest, ~] = CoreUpdate11tHoldStocks (InputMatrixTest, DealMatrixTest, Input11ArrayOrigin(i, 1), Input11DealOrigin(i, 1), HoldCountTest, CashTest, IsVibrant, basisprice, k, beforeholdcount);
        sellnumber = HoldCountTest - beforeholdcount;
        HoldCountTest = HoldCountTest - sellnumber;
        CashTest = CashTest + sellnumber * Input11ArrayOrigin(i, 1);
        
        if  mod(i, floor(size(Input11ArrayOrigin, 1)/21)) == 0
            basisprice = Input11ArrayOrigin(i, 1);          %基准价每天调整，这里是21天的情况
        end
        
        m = m + 1;
        
        if sellnumber < 0       % 买入
            avecostcell = ((holdcounttest * avecostcell) - (Input11ArrayOrigin(i, 1)) * sellnumber) / (HoldCountTest);     %计算平均成本
            aveprofitrate = ((Input11ArrayOrigin(i, 1) - avecostcell) / avecostcell);       %计算收益率
        else                    % 卖出
            aveprofitrate = 0;
        end
        
        AveCost(m, 1) = avecostcell;
        SellNumber(m, 1) = sellnumber;
        HoldCountRouting(m, 1) = HoldCountTest;
        AveProfitRate(m, 1) = aveprofitrate;
    else                                %进行交易
        holdcounttest = HoldCountTest;  %前一时刻的持仓
        [HoldCountTest, CashTest, InputMatrixTest, DealMatrixTest, sellnumber] = CoreUpdate11tHoldStocks (InputMatrixTest, DealMatrixTest, Input11ArrayOrigin(i, 1), Input11DealOrigin(i, 1), HoldCountTest, CashTest, IsVibrant, basisprice, k, beforeholdcount);
        
        m = m + 1;
        
        if sellnumber < 0       % 卖出
            avecostcell = ((holdcounttest * avecostcell) - (Input11ArrayOrigin(i, 1)) * sellnumber) / (HoldCountTest);     %计算平均成本
            aveprofitrate = -((Input11ArrayOrigin(i, 1) - avecostcell) / avecostcell);       %计算收益率
        else                    % 买入
            aveprofitrate = 0;
        end
        
        AveCost(m, 1) = avecostcell;
        SellNumber(m, 1) = sellnumber;
        HoldCountRouting(m, 1) = HoldCountTest;
        
        
        
        AveProfitRate(m, 1) = aveprofitrate;

        
        PureProfit = HoldCountTest - BeforeCash;
        CashTests(m, 1) = CashTest;
    end
    TradeNumber = TradeNumber + abs(sellnumber);
    TradeNumbers(i, 1) = TradeNumber;
    
    if TradeNumber > 0.1 * sum(Input11DealOrigin)   %持仓情况
        
                holdcounttest = HoldCountTest;  %前一时刻的持仓
        
        [~,~,InputMatrixTest, DealMatrixTest, ~] = CoreUpdate11tHoldStocks (InputMatrixTest, DealMatrixTest, Input11ArrayOrigin(i, 1), Input11DealOrigin(i, 1), HoldCountTest, CashTest, IsVibrant, basisprice, k, beforeholdcount);
        sellnumber = HoldCountTest - beforeholdcount;
        HoldCountTest = HoldCountTest - sellnumber;
        CashTest = CashTest + sellnumber * Input11ArrayOrigin(i, 1);
        
        m = m + 1;
        
        if sellnumber < 0       % 买入
            avecostcell = ((holdcounttest * avecostcell) - (Input11ArrayOrigin(i, 1)) * sellnumber) / (HoldCountTest);     %计算平均成本
            aveprofitrate = -((Input11ArrayOrigin(i, 1) - avecostcell) / avecostcell);       %计算收益率
        else                    % 卖出
            aveprofitrate = 0;
        end
        
        AveCost(m, 1) = avecostcell;
        SellNumber(m, 1) = sellnumber;
        HoldCountRouting(m, 1) = HoldCountTest;
        AveProfitRate(m, 1) = aveprofitrate;
        
       break;
    end
    if HoldCountTest < 0
       break;
    end
    
end

if mean(AveProfitRate) < 0
    AveProfitRate = AveProfitRate * -1;
end
end

% 函数引用关系
% PackUpOutPutFunstion()
%     -> PackUpJudgeHistory()
%         -> CNNJudge20221106()
%     -> CoreUpdate11tHoldStocks()
%         -> CoreInput10OutputNum()
%             -> IkunBuySellBasis()
%             -> IkunBuySellClassic()
%             -> IkunVibrantPredict001()
%             -> IkunStaticPredict001()
