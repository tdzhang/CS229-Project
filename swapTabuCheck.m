% ---  Swap Tabu check --- %
function swapTabuCheck = swapTabuCheck(swapTabuTable, reqNo, chNo)
% ======================================================================= %
% taddTabuCheck: true if the operation is tabu; false if the operation is
%                not tabu.
% chNo: specify the original channel request with reqNo before it is swapped
% ======================================================================= %
tabuIdx = find(swapTabuTable(:, 1) == reqNo, 1);
if not(isempty(tabuIdx))
    if (swapTabuTable(tabuIdx, 2) == chNo)
        swapTabuCheck = true;
    else
        swapTabuCheck = false;
    end
else
    swapTabuCheck = false;
end

% --- Don't check original channel --- %
% for tabuPtr = 1:size(swapTabuTable, 1)
%     if (swapTabuTable(tabuPtr) == reqNo)
%         swapTabuCheck = true;
%         break;
%     end
% end
end