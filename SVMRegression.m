%% Load data %%
clear all;
longTermInclude = 1;
load('rawData_all.mat');
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
    y = dataDiff(timeDiff(end) - windowSize + 2:end, targetIdx);
    for i = 1:length(timeDiff)
        windowSize = timeDiff(i);
        dataDiff = outputData(windowSize:end, :) - outputData(1:end-windowSize + 1,:);
        x = [x, dataDiff( timeDiff(end) - windowSize + 1:end-1, 1:offset-1)];
        x = [x, dataDiff( timeDiff(end) - windowSize + 2:end, offset:end)];
    end
else
    x = dataDiff(windowSize + 2:end, offset:end); % Eliminate the first 3 first;
    x = [dataDiff(windowSize + 1:end-1, 1:offset-1), x]; % Add back the first 3;
    y = dataDiff(windowSize + 2:end, targetIdx);
end
% save AllFeature_Short_Long_Term.mat x y;

testSize = 250;
selectedFeature = [ 7 10 71];
xt = x(1:length(y)-testSize, selectedFeature);
yt = y(1:length(y)-testSize);
xp = x(length(y) - testSize + 1:end, selectedFeature);
yp = y(length(y) - testSize + 1:end);

model = svmtrain(yt, sparse(xt), '-s 3 -t 0');
[predicted_label, accuracy, decision_values] = svmpredict(yp, sparse(xp), model);