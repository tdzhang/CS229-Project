load ('AllFeature_Short_Long_Term.mat');
trainSize = 500;
testSize = 250; % If testSize = 0, start test from earliest possible point.
if (testSize > 0)
    trainStartIdx = size(x, 1) - testSize - trainSize + 1;
else
    trainStartIdx = 1;
    testSize = size(x, 1) - trainSize;
end
featureIdx = [7, 10, 20, 71];
predictionResult = zeros(1, testSize);
for predictPtr = 1:testSize
    xt = x(trainStartIdx:trainStartIdx + trainSize - 1, featureIdx);
    yt = y(trainStartIdx:trainStartIdx + trainSize - 1);
    xp = x(trainStartIdx + trainSize, featureIdx);
    yp = y(trainStartIdx + trainSize);
    model = train(yt, sparse(xt), '-s 2 -q');
    [predicted_label, accuracy, decision_values] = predict(yp, sparse(xp), model);
    predictionResult(predictPtr) = predicted_label;
    trainStartIdx = trainStartIdx + 1;
end
finalAccuracy = (testSize - sum(abs(predictionResult - y(size(y, 1) - testSize + 1:end)'))/2)/testSize