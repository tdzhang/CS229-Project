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




result_recall=[]
result_pre=[]
result_general_pre=[]
result_general_recall=[]
loop_r1=[1:2:330]
loop_r2=-[1:2:330]
%run the precision/recall/general precision evaluation for different region
for i=1:length(loop_r1)
    %region1 = [-15 +20];
    %region2 = [-Inf Inf];
    region1 = [loop_r2(i) loop_r1(i)];
    region2 = [-Inf Inf];
    class1 = region1; % Hold
    class2 = [region1(2), region2(2)]; % small buy
    class3 = [region2(1), region1(1)]; % small sell
    % class4 = [region2(2), region3(2)]; % large buy
    % class5 = [region3(1), region2(1)]; % large sell

    yclass = y;
    y_increase=y; %record the increase flage
    for ptr = 1:length(y)
        if (y(ptr)>0)
            y_increase(ptr) = 1;
        else
            y_increase(ptr)= 0;
        end
    end
    for ptr = 1:length(y)
        if (y(ptr)>class1(1) && y(ptr) < class1(2))
            yclass(ptr) = 1;
        elseif (y(ptr)>class2(1) && y(ptr) < class2(2))
            yclass(ptr) = 2;
        elseif (y(ptr)>class3(1) && y(ptr) < class3(2))
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
    recall = zeros(1, 3);
    precision = zeros(1,3);

    for ii = 1:3
        yt_temp = find(yp == ii);
        total = length(yt_temp);
        if total==0
            total=1;
        end
        prediction = predicted_label(yp == ii);
        recall(ii) = length(find(prediction==ii))/total * 100;
        pre_temp = find(predicted_label == ii);
        total = length(pre_temp);
        tp = yp(pre_temp);
        if total==0
            total=1;
        end
        precision(ii)=length(find(tp==ii))/total * 100;
    end

    %general increase
        ii=2;
        y_increase=y_increase(length(y_increase)-testSize+1:end);
        
        yt_temp = find(y_increase == 1);
        total = length(yt_temp);
        if total==0
            total=1;
        end
        prediction = predicted_label(yt_temp);
        general_rec = length(find(prediction==ii))/total * 100;
        

        pre_temp = find(predicted_label == ii);
        total = length(pre_temp);
        tp = y_increase(pre_temp);
        if total==0
            total=1;
        end
        general_pre=length(find(tp==1))/total * 100;
   %general decrease
        ii=3;
        y_decrease=y_increase(length(y_increase)-testSize+1:end);
        
        yt_temp = find(y_decrease == 0);
        total = length(yt_temp);
        if total==0
            total=1;
        end
        prediction = predicted_label(yt_temp);
        general_rec_d = length(find(prediction==ii))/total * 100;
        

        pre_temp = find(predicted_label == ii);
        total = length(pre_temp);
        tp = y_increase(pre_temp);
        if total==0
            total=1;
        end
        general_pre_d=length(find(tp==0))/total * 100;
        

    result_recall=[result_recall;recall];
    result_pre=[result_pre;precision];
    result_general_pre=[result_general_pre;general_pre,general_pre_d];
    result_general_recall=[result_general_recall; general_rec,general_rec_d]
end

%% plot
%decrease
Index=3;
figure(1)
hold on
%plot(result_recall(:,Index),'r')
%plot(result_pre(:,Index),'b')
%plot(result_general_pre(:,2),'y')
%plot(result_general_recall(:,2),'g')
%plot(result_general_pre(:,2).*result_general_recall(:,2),'m')
%increase
% Index=2;
% figure(2)
% hold on
%plot(result_recall(:,Index),'r')
%plot(result_pre(:,Index),'b')
plot(result_general_pre(:,1),'y')
plot(result_general_recall(:,1),'g')
%plot(result_general_pre(:,1).*result_general_recall(:,1),'r')