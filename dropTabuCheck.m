% ---  Drop Tabu check --- %
function dropTabuCheck = dropTabuCheck(dropTabuTable, reqNo)
% ======================================================================= %
% dropTabuCheck: true if the operation is tabu; false if the operation is
% not tabu.
%
% ======================================================================= %
if isempty(find(dropTabuTable(:, 1) == reqNo, 1))
    dropTabuCheck = false;
else
    dropTabuCheck = true;
end
end