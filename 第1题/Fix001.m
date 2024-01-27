%%
% 修正代码
function [] = Fix001 ()
unun = 0.0;
for i = 1 : size(vibrationbind2, 2)
    if ~isinf(vibrationbind2(1, i)) && ~isnan(vibrationbind2(1, i))
        unun = unun + vibrationbind2(1, i);
    end
end
Termindex(termindex, 1) = unun;
end