load('rawData_all.mat')
close all;
datalist = [{'NASDAQ','S&P500','DJIA','Hang Seng','Nikkei225','FTSE100','DAX','AUSTRALIA','Gold PM','Silver','Platinum PM','Palladium PM','Oil','AUD','Euro','JPY';}];
[outputData, timeFrame, outputFeature] = DataReader(datalist);
windowSize = 2;
dataDiff = outputData(windowSize:end, :) - outputData(1:end-windowSize + 1,:);

dataDiffSign = sign(dataDiff);
maxlag = 50;

crossCorr = zeros(maxlag*2 + 1, size(dataDiff, 2));
for ptr = 1:size(dataDiff, 2)
    crossCorr(:, ptr) = xcorr(dataDiffSign(:,1), dataDiffSign(:,ptr), maxlag, 'coeff');
end
figure; plot(-maxlag:maxlag, crossCorr, 'LineWidth', 2); grid on;
legend('NASDAQ','S&P500','DJIA','Hang Seng','Nikkei225','FTSE100','DAX','AUSTRALIA','Gold PM','Silver','Platinum PM','Palladium PM','Oil','AUD','Euro','JPY');
xlabel('Delay', 'FontSize', 14); ylabel('Cross-correlation with respect to NASDAQ', 'FontSize', 14); set(gca, 'FontSize', 14);

% Plot the correlation with differnt windowSize
windowSizeArray = [2, 11, 21, 31, 41, 51];
crossCorrMultiStep = zeros(maxlag*2 + 1, size(dataDiff, 2), length(windowSizeArray));
figure; hold on;
delay = -maxlag:maxlag;
for windowSizePtr = 1:length(windowSizeArray)
    windowSize = windowSizeArray(windowSizePtr);
    dataDiff = outputData(windowSize:end, :) - outputData(1:end-windowSize + 1,:);
    dataDiffSign = sign(dataDiff);
    for ptr = 1:size(dataDiff, 2)
        crossCorrMultiStep(:, ptr, windowSizePtr) = xcorr(dataDiffSign(:,1), dataDiffSign(:,ptr), maxlag, 'coeff');
    end
    plot3( delay, windowSizeArray(windowSizePtr)*ones(1, length(delay)), squeeze(crossCorrMultiStep(:,1:8,windowSizePtr)), 'LineWidth', 2);
end
grid on; xlabel('Relative delay', 'FontSize', 14);
ylabel('Time window size', 'FontSize', 14);
zlabel('Normalized correlation', 'FontSize', 14);
