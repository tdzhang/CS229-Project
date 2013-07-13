%% Load data %%
load('rawData_all.mat')
close all;
datalist = [{'NASDAQ','S&P500','DJIA','Hang Seng','Nikkei225','FTSE100','DAX','AUSTRALIA','Gold PM','Silver','Platinum PM','Palladium PM','Oil','AUD','Euro','JPY';}];
[outputData, timeFrame, outputFeature] = DataReader(datalist);
windowSize = 2;
dataDiff = outputData(windowSize:end, :) - outputData(1:end-windowSize + 1,:);

%% Prediction accuracy with respect to training window size %%
testSize = 250;
y = sign(dataDiff(:,1));
x = dataDiff;
featureIdx = [7, 10];
trainSizeArray = 1*(1:10);
accuracyArray = zeros(1, length(trainSizeArray));
for trainSizePtr = 1:length(trainSizeArray)
    trainSize = trainSizeArray(trainSizePtr);
%     xt = x(size(x,1) - trainSize - testSize + 1:size(x,1) - testSize, featureIdx);
    xt = x(247:249, featureIdx);
%     yt = y(size(x,1) - trainSize - testSize + 1:size(x,1) - testSize);
    yt = y(247:249);
    xp = x(size(x,1) - testSize + 1:end, featureIdx);
    yp = y(size(x,1) - testSize + 1:end);
    model = train(yt, sparse(xt), '-s 2 -q');
    [predicted_label, accuracy, decision_values] = predict(yp, sparse(xp), model);
    accuracyArray(trainSizePtr) = accuracy(1);
end
figure; plot(trainSizeArray, accuracyArray, '-o', 'MarkerSize', 8, 'LineWidth', 2); grid on;
xlabel('Training window size', 'FontSize', 14); ylabel('Test accuracy', 'FontSize', 14);
set(gca, 'FontSize', 14);