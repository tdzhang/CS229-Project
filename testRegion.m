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

region1 = [-300 300];
region2 = [-Inf Inf];
class1 = region1; % Hold
class2 = [region1(2), region2(2)]; % small buy
class3 = [region2(1), region1(1)]; % small sell
% class4 = [region2(2), region3(2)]; % large buy
% class5 = [region3(1), region2(1)]; % large sell

yclass = y;
for ptr = 1:length(y)
    if (find(y(ptr)>class1(1) && y(ptr) < class1(2)))
        yclass(ptr) = 1;
    elseif (find(y(ptr)>class2(1) && y(ptr) < class2(2)))
        yclass(ptr) = 2;
    elseif (find(y(ptr)>class3(1) && y(ptr) < class3(2)))
        yclass(ptr) = 3;
%     elseif (find(y(ptr)>class4(1) && y(ptr) < class4(2)))
%         yclass(ptr) = 4;
%     elseif (find(y(ptr)>class5(1) && y(ptr) < class5(2)))
%         yclass(ptr) = 5;
    end
end

featureSelection = [7, 71, 20, 10];
testSize = 250;
model = train(yclass(1:length(yclass)-testSize), sparse(x(1:length(yclass)-testSize, featureSelection)), '-s 2s');
[predicted_label, accuracy, decision_values] = predict(yclass(length(yclass)-testSize+1:end), sparse(x(length(yclass)-testSize+1:end, featureSelection)), model);

yp = yclass(length(yclass)-testSize+1:end);
recall = zeros(3, 1);
for i = 1:3
    yt_temp = yp(yp == i);
    totalClassSize = length(yt_temp);
    prediction = predicted_label(yp == i);
    recall(i) = length(find(prediction==i))/totalClassSize * 100;
end

precision = zeros(3,1);
for i = 1:3
    prediction_temp = predicted_label(predicted_label == i);
%     totalClassSize = length(prediction_temp);
    yt = yp(predicted_label == i);
    precision(i) = length(prediction_temp(yt == i))/length(yt)*100;
    if i == 2
        predAcc = sum(predicted_label == i & y(end-testSize+1:end) > 0) / sum(predicted_label == i);
        disp(['General Acc:' num2str(predAcc)]);
    end
end

