clc
%%
% 2022.11.2
% 金融数模股票数据提取程序
%%
% 导入最初的数据到这里，生成origin矩阵：
% 注意：导入时要用数值矩阵的方式！不要用默认的表的方式！

    subplotn = 4;   %画图子图每行的个数
    subplotm = ceil(size(VarName1, 1) / subplotn);

for index = 1 : size(VarName2, 1)
    index
    origin =  eval(VarName2(index));

    %%
    origin = transpose(origin);   %原始数据，矩阵转置
    %origindata = size(origin);
    newtradematrix = zeros([], 6, []);                %得出最终数据的矩阵
    outdatamatrix = zeros(100,2);                       %输出信息的矩阵
    matrixindex = zeros(1, 2);                    %上面的矩阵的索引
    day = 1;                 %每一天对应的情况分析
    tempnum = 0.0;
    tempval = 0.0;
    temptime = 0.0;
    tempsingle = 0.0;

    k = 0;
    k1 = 0;
    k2 = 0;
    vibration = zeros([],[]);          %两个相邻数据间的振幅（单价元/时间秒）
    frequency = zeros([],[]);          %频率记录（秒）
    motion = zeros(1, []);
        %%
            % newtradematrix 矩阵说明：
            % 第1维度：每一天的情况
            % 第2维度：
            %   第1行：成交量差（手）
            %   第2行：成交额差（元）
            %   第3行：平均成交单价（元）
            %   第4行：时间差（秒）
            %   第5行：时间差从1到i（index）的累积和（秒）

            %   第6行：两个相邻数据间的振幅（单价元/时间秒）

            % outdatamatrix 矩阵说明：
            % 行数：第n天
            % 列数：
            %   第1列：总升
            %   第2列：总减
        %%
        % 数据提取部分
    for i = 1 : size(origin,2)-1

        if (origin(2,i+1) - origin(2,i) >= 500000.0)    %判断是否到了第二天
            day = day + 1;
            matrixindex(day) = 1;
            k = 0;      %循环变量
            k1 = 0;     %循环变量
        end
        if (origin(2,i+1) - origin(2,i) <= 150.0)
            if (origin(7,i+1) - origin(7,i) > 0)       %滤掉成交额和成交量为0的数据
                tempnum = origin(8, i+1) - origin(8, i);    %成交量差
                tempval = origin(7, i+1) - origin(7, i);    %成交额差
                temptime = ((origin(2, i+1) - origin(2, i))) * 0.6;   %时间差
                tempsingle = (tempval / tempnum) / 100;             %平均单价

                if (tempsingle > min(origin(6,i+1), origin(6, i)) && tempsingle < max(origin(5,i+1), origin(5, i)))   %滤掉低于最低价、高于最高价的值

                    if (abs(tempsingle - (tempval / tempnum) / 100) < 10^100 || k2 <= 1)
                        motion(k2 + 1) = (tempval / tempnum) / 100;
                    else
                        motion(k2 + 1) = motion(k2);
                    end
                    k2 = k2 + 1;

                    matrixindex(day) = matrixindex(day) + 1;
                    newtradematrix(day,1,matrixindex(day)) = tempnum;  %导入数据到矩阵里面
                    newtradematrix(day,2,matrixindex(day)) = tempval;
                    newtradematrix(day,3,matrixindex(day)) = tempsingle;
                    newtradematrix(day,4,matrixindex(day)) = temptime;

                    %加入数据到总升、总减中
                    if matrixindex(day) > 1
                        change = newtradematrix(day,3,matrixindex(day)) - newtradematrix(day,3,matrixindex(day)-1);
                        if change >= 0  %加入总升

                            if k < 0
                                k1 = k1 + 1;
                                frequency(day, k1) = abs(k);
                                k = 0;
                            end
                            k = k + abs(temptime);

                            outdatamatrix(day,1) = outdatamatrix(day,1) + change;
                        else            %加入总减

                            if k > 0
                                k1 = k1 + 1;
                                frequency(day, k1) = abs(k);
                                k = 0;
                            end
                            k = k - abs(temptime);


                            outdatamatrix(day,2) = outdatamatrix(day,2) + change;
                        end
                        newtradematrix(day,6,matrixindex(day)) = change / temptime;
                        vibration(day, matrixindex(day)) = change / temptime;     %振幅(改为总升-总降)
                    end

                    if matrixindex(day) == 1    %时间差累积和
                        newtradematrix(day, 5, matrixindex(day)) = 0; 
                    else
                        newtradematrix(day, 5, matrixindex(day)) = newtradematrix(day, 5, matrixindex(day)-1) + temptime;
                    end
                end
            end    %判断是否为空数据
        end    
    end    %for循环

    %%
    %绘图部分
    subplotn = 4;   %画图子图每行的个数
    subplotm = ceil(31 / 4);
%     for j = 1 : day
%        grid on;
%         plotx = zeros(1, 2);
%         ploty = zeros(1, 2);
%         k = 0;
%         for i = 1 : matrixindex(1, j)
%             if newtradematrix(j, 3, i) ~= 0
%                 k = k + 1;
%                 plotx(k) = newtradematrix(j, 5, i);
%                 ploty(k) = newtradematrix(j, 3, i);
%             end
%         end
%         subplot(subplotm, subplotn, j);
%                 xlabel('累计时间;');
%                 ylabel('成交单价');
%                 title('002594');
%         hline1 = plot(plotx, ploty, 'r');
%     end
%     hline1 = plot(plotx, ploty, 'r');

    %%
%     % 数据整合部分
%     vibrationbind2 = [];
%     vibrationbind = abs(reshape(vibration, 1, []));  
%     stabilitybind = reshape(frequency, 1, []);
%     stabilitybind2 = [];
%     k = 0;
%     for i = 1 : size(vibrationbind, 2)
%         if vibrationbind(1, i) ~= 0 && ~isinf(vibrationbind(1, i)) && ~isnan(vibrationbind(1, i))
%             k = k + 1;
%             vibrationbind2(k) = vibrationbind(1, i);
%         end
%     end
%     vibrationbind1 = sum(vibrationbind2);    %总升-总降
% 
% 
% 
%     %总：
%     vibrationbind = reshape(vibration, 1, []);  
%     k = 0;
%     for i = 1 : size(vibrationbind, 2)
%         if vibrationbind(1, i) ~= 0 && ~isinf(vibrationbind(1, i)) && ~isnan(vibrationbind(1, i))
%             k = k + 1;
%             vibrationbind2(k) = vibrationbind(1, i);
%         end
%     end
%     vibrationbind3 = sum(vibrationbind2);   %总
% 
%     %总：
%     vibrationbind = reshape(vibration, 1, []);  
%     k = 0;
%     for i = 1 : size(vibrationbind, 2)
%         if vibrationbind(1, i) > 0 && ~isinf(vibrationbind(1, i)) && ~isnan(vibrationbind(1, i))
%             k = k + 1;
%             vibrationbind2(k) = vibrationbind(1, i);
%         end
%     end
%     vibrationbind4 = sum(vibrationbind2);   %仅总升
% 
% 
%     %vibrationbind = mean(vibrationbind2);
%     % 总升-总降
% 
%     k = 0;
%     for i = 1 : size(stabilitybind, 2)
%         if stabilitybind(1, i) ~= 0
%             k = k + 1;
%             stabilitybind2(k) = stabilitybind(1, i);
%         end
%     end
% 
%     stabilitybind1 = [];
%     k = 0;
%     for i = 1 : floor(size(stabilitybind2, 2) / 2)
%         k = k + 1;
%         stabilitybind1(k) = stabilitybind2(1, i) + stabilitybind2(1, i+1);
%     end
%     stabilitybind = mean(1.0 ./ stabilitybind1);
%     % 频率（峰值个数 / 周期），输出为stabilitybind。
% 
%     Var = var(motion);
%     % 所有有效数据的方差
% 
%     Kurtosis = kurtosis(motion);
%     % 所有有效数据的峰度
% 
%     motiony = 1 : size(motion, 2);
%     %motionp = polyfit(motiony, motion, 2);
%     motiony = motiony .^ 2 * motionp(1) + motiony .* motionp(2) + motionp(3);
% 
% 
% 
%     plot(1 : size(motion,2), motion);
%     %yticks(0:0.5:500)
%     yticks('auto')
%     grid on


    % %%
    % % 每只股票最终输出的东西，仅1行
    % % termindex = 0;                
    % % ;     %输出的数据
    % 
    % vibrationsize = size(reshape(vibration, 1, []), 2);
    % termindex = termindex + 1
    % % 确定下面的4个东西
    % Termindex (termindex, 1) = vibrationbind1 / vibrationsize;   % 01 总升 - 总降 / 总有效数据量
    % Termindex (termindex, 2) = stabilitybind;   % 02 频率
    % Termindex (termindex, 3) = Var;             % 03 方差
    % Termindex (termindex, 4) = Kurtosis;        % 04 峰度
    % 
    % %总升-总降 / 总有效数据量 * 频率
    % Termindex (termindex, 5) = vibrationbind1 / vibrationsize * stabilitybind * 10^4;
    % 
    % %总升-总 / 总有效数据量 * 频率
    %Termindex (termindex, 6) = ((vibrationbind4 - vibrationbind3) / vibrationsize) * stabilitybind * 10^4;
    % 
    % %总升 - 总 / 总有效数据量 * 峰度
    % Termindex (termindex, 7) = Termindex (termindex, 6) * Kurtosis;
    % %%
    % % 修正代码
    % unun = 0.0;
    % for i = 1 : size(vibrationbind2, 2)
    %     if ~isinf(vibrationbind2(1, i)) && ~isnan(vibrationbind2(1, i))
    %         unun = unun + vibrationbind2(1, i);
    %     end
    % end
    % Termindex(termindex, 1) = unun;

    %% 输出绘图部分

    grid on;
    plotx = zeros(1, 2);
    ploty = zeros(1, 2);
    [HoldCountTest, CashTest, AveCost, SellNumber, AveProfitRate, MaximumRetracement, TradeNumber] = PackUpOutputFunstion (Input11ArrayOrigin, Input11DealOrigin, 150000, 0, origin(3,1));
    hline1 = plot(motion);
   
    ylabel('收益率');
    string1 = append(VarName2(index), ' ','平均收益率', string(VarName3(index)));
    string1
    title(string1);
    
    if (index > 0 && index < size(VarName2, 1))
    subplot(subplotm, subplotn, index+1);
    else
    subplot(subplotm, subplotn, 1);
    end
    
end

