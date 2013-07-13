% --- Data reader --- %
function [outputData, timeFrame, outputFeature] = DataReader(dataList)
% for test only
% dataList = {'NASDAQ'; 'DJIA'};
load 'rawData_all.mat';
timeFrame = rawData.timeFrame;
dataDim = size(timeFrame);
outputData = zeros(dataDim(1), length(dataList));
outputFeature = {[length(dataList), 1]};

for dataPtr = 1:length(dataList)
    for featurePtr = 1:length(rawData.featureName)
        if (strcmp(dataList{dataPtr}, rawData.featureName{featurePtr}))
            outputData(:, dataPtr) = rawData.data(:, featurePtr);
            outputFeature{dataPtr} = rawData.featureName{featurePtr};
            break;
        end
    end
end

end