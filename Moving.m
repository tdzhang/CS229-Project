load('rawData_all.mat')
close all;
datalist = [{'NASDAQ','S&P500','DJIA','Hang Seng','Nikkei225','FTSE100','DAX','AUSTRALIA','Gold PM','Silver','Platinum PM','Palladium PM','Oil','AUD','Euro','JPY';}];
[outputData, timeFrame, outputFeature] = DataReader(datalist);
windowSize = 41;
dataDiff = outputData(windowSize:end, :) - outputData(1:end-windowSize + 1,:);

dataDiffSign = sign(dataDiff);
maxlag = 50;
crossCorr = zeros(maxlag*2 + 1, size(dataDiff, 2));
for ptr = 1:size(dataDiff, 2)
    crossCorr(:, ptr) = xcorr(dataDiffSign(:,8), dataDiffSign(:,ptr), maxlag, 'coeff');
end

figure; plot(-50:50, crossCorr, 'LineWidth', 2); grid on;
legend('NASDAQ','S&P500','DJIA','Hang Seng','Nikkei225','FTSE100','DAX','AUSTRALIA','Gold PM','Silver','Platinum PM','Palladium PM','Oil','AUD','Euro','JPY');
xlabel('Delay', 'FontSize', 14); ylabel('Cross-correlation with respect to NASDAQ', 'FontSize', 14); set(gca, 'FontSize', 14);

trainSize =3000;
featureIdx = 4:16;
testSize = size(outputData, 1) - trainSize;
y = dataDiffSign(:, 1);
x = dataDiff;
yt = y(1:trainSize);
% dDiff = outputData(2:end, :) - outputData(1:end-2 + 1,:);
% yt = sign(dDiff(windowSize-1:windowSize - 2 + trainSize, 1)); 
xt = x(1:trainSize, featureIdx);
% xt = [x(1:trainSize, featureIdx), dDiff(windowSize-1:windowSize-2+trainSize, featureIdx)];

xp = x(trainSize+1:end, featureIdx);
yp = y(trainSize+1:end);
% yp = sign(dDiff(windowSize - 1 + trainSize:end, 1)); 
% xp = [x(trainSize+1:end, featureIdx), dDiff(windowSize - 1 + trainSize:end, featureIdx)];
model = train(yt, sparse(xt), '-s 2');
[predicted_label, accuracy, decision_values] = predict(sign(yp), sparse(xp), model);