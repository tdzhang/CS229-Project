%% Load data %%
clear all;
longTermInclude = 0;
load('rawData_all.mat')
close all;
datalist = [{'NASDAQ','S&P500','DJIA','Hang Seng','Nikkei225','FTSE100','DAX','AUSTRALIA','Gold PM','Silver','Platinum PM','Palladium PM','Oil','AUD','Euro','JPY';}];
[outputData, timeFrame, outputFeature] = DataReader(datalist);
windowSize = 2;
dataDiff = outputData(windowSize:end, :) - outputData(1:end-windowSize + 1,:);
targetIdx = 1;
offset = 4; %Feature offset
if (longTermInclude == 1)
    timeDiff = [6, 11, 21, 31, 41, 51];
    
    x = dataDiff(timeDiff(end) - windowSize + 2:end, offset:end); % Eliminate the first 3 first;
    x = [dataDiff(timeDiff(end) - windowSize + 1:end-1, 1:offset-1), x]; % Add back the first 3;
    y = sign(dataDiff(timeDiff(end) - windowSize + 2:end, targetIdx));
    for i = 1:length(timeDiff)
        windowSize = timeDiff(i);
        dataDiff = outputData(windowSize:end, :) - outputData(1:end-windowSize + 1,:);
        x = [x, dataDiff( timeDiff(end) - windowSize + 1:end-1, 1:offset-1)];
        x = [x, dataDiff( timeDiff(end) - windowSize + 2:end, offset:end)];
    end
else
    x = dataDiff(windowSize + 2:end, offset:end); % Eliminate the first 3 first;
    x = [dataDiff(windowSize + 1:end-1, 1:offset-1), x]; % Add back the first 3;
    y = sign(dataDiff(windowSize + 2:end, targetIdx));
end
save AllFeature_Short_Long_Term.mat x y;
testSize = 250;
currAccuracy = 0;
totalFeatureNo = size(x,2);
yt = y(1:size(x,1) - testSize);
yp = y(size(x,1) - testSize + 1:end);
selectedFeature = zeros(totalFeatureNo, 1);
%------------------------
acc=[]
features=[]
%------------------------

    for featurePtr = 1:totalFeatureNo
        if (isempty(find(selectedFeature == featurePtr, 1)))
                xt = x(1:size(x,1) - testSize, featurePtr);
                xp = x(size(x,1) - testSize + 1:end, featurePtr);
            model = train(yt, sparse(xt), '-s 2 -q');
            [predicted_label, accuracy, decision_values] = predict(yp, sparse(xp), model);
            acc=[acc accuracy(1)];
        end
    end

    %------------------------

% selectedFeature = c + (offset - 1)*ones(length(selectedFeature), 1);
% for i = 1:length(selectedFeature)
%     if (selectedFeature(i) == offset-1)
%         selectedFeature(i) = targetIdx;
%     end
% end
% disp(outputFeature(selectedFeature));