function [AggregateMeans, AggregateStd, aggregateRT, angleRT_New, aggregateRTMean,...
    AggregatePosFit, AggregateNegFit, AggregateStd_E] =...
    AggregateAnalysisFunction(myFiles, myDir, angleRT_Raw, folderName, color, masterAngles,...
    linestyle, marker, dn)
figure(100);
for k = 1:length(angleRT_Raw)
    clear angles;
    clear dist;
    baseFileName = myFiles(k).name;
    fullFileName = fullfile(myDir, baseFileName);
    data = table2array(readtable(fullFileName));
    dist = data(:,2);
    RT = data(:,3);
    angles = unique(dist);
    angleTest = angleRT_Raw;
    for k = 1:length(myFiles)
        for ii = 1:length(angleRT_Raw(k).subject)
            angleTest(k).subject(ii).data(angleTest(k).subject(ii).data == 0) = NaN;
            [angleRT_Test_new,TF] = rmoutliers(angleTest(k).subject(ii).data,'quartiles');
            angleRT_New(k).subject(ii).data = angleRT_Test_new;
        end
    end
end
for k = 1:length(myFiles)
    baseFileName = myFiles(k).name;
    fullFileName = fullfile(myDir, baseFileName);
    data = table2array(readtable(fullFileName));
    dist = data(:,2);
    angles = unique(dist);
    for ii = 1:length(angles)
        idx = find(masterAngles == angles(ii));
        for jj = 1:length(angleRT_New(k).subject(ii).data)
            aggregateRT(jj, idx, k) = (angleRT_New(k).subject(ii).data(jj));
        end
    end
end
aggregateRT(aggregateRT == 0) = NaN;
aggregateRTMean = zeros(length(myFiles), length(angles));
aggregateRTStd = zeros(length(myFiles), length(angles));
aggregateRT_N = zeros(length(myFiles), length(angles));
for k = 1:length(myFiles)
    for ii = 1:length(masterAngles)
        aggregateRTMean(k, ii) = mean(aggregateRT(:, ii, k), 'omitnan');
        aggregateRTStd(k, ii) = std(aggregateRT(:, ii, k), 'omitnan');
        aggregateRT_N(k,ii) = length(aggregateRT(:,ii,k)) - ...
            sum(isnan(aggregateRT(:,ii,k)));
    end
end
for ii = 1:length(masterAngles)
    AggregateMeans(ii) = sum(aggregateRTMean(:,ii)./(aggregateRTStd(:,ii)./...
        aggregateRT_N(:,ii)), 'omitnan')...
        ./sum(1./(aggregateRTStd(:,ii)./aggregateRT_N(:,ii)), 'omitnan');
    AggregateStd(ii) = std(aggregateRTMean(:,ii), 'omitnan');
    AggregateStd_E(ii) = std(aggregateRTMean(:,ii), 'omitnan')...
        /sqrt(length(aggregateRTMean(:,ii)));
end
% scatter(masterAngles, AggregateMeans, 'filled', color);
hold on;
scatter(masterAngles, AggregateMeans, marker, 'filled','MarkerFaceColor',...
    color, 'MarkerEdgeColor', color,'LineWidth', 1);
hold on;
% errorbar(masterAngles, AggregateMeans, AggregateStd_E, 'o', 'Color', color, 'CapSize', 0);
errorbar(masterAngles, AggregateMeans, AggregateStd_E, marker, 'Color', color, 'LineWidth', 1, 'CapSize', 0);
ylim([100 900]);
xlim([(angles(1) - 5) (angles(length(angles)) +5)]);
AggregatePosFit = chiSquareFunction(masterAngles(masterAngles >= 0),...
    AggregateMeans(find(masterAngles >= 0)), AggregateStd_E(find(masterAngles>= 0)));
hold on;
% plot(angles(angles >= 0), angles(angles >= 0)*AggregatePosFit.slope + ...
%     AggregatePosFit.intercept ,...
%     'Color', color, 'LineWidth', 1);
plot(angles(angles >= 0), angles(angles >= 0)*AggregatePosFit.slope + ...
    AggregatePosFit.intercept ,...
    'LineWidth', 1, 'LineStyle', linestyle, 'color', color);
AggregateNegFit = chiSquareFunction(angles(angles <= 0),...
    AggregateMeans(find(masterAngles <= 0)), AggregateStd_E(find(masterAngles<= 0)));
hold on;
% plot(masterAngles(masterAngles <= 0), ...
%     masterAngles(masterAngles <= 0)*AggregateNegFit.slope + AggregateNegFit.intercept ,...
%     'Color', color, 'LineWidth', 1);
plot(masterAngles(masterAngles <= 0), ...
    masterAngles(masterAngles <= 0)*AggregateNegFit.slope + AggregateNegFit.intercept ,...
    'LineWidth', 1, 'LineStyle', linestyle, 'color', color);
box on;
grid on;
xlabel('Eccentricity (°)');
ylabel('Reaction Time (ms)');
title('Aggregated Plot Weighted Average Horizontal B/BBB');
fileName = 'Aggregated-Plot-Weighted-Average-H.png'
set(gcf, 'Position',  [20, 20, 700, 800]);
cd(folderName{1});
saveas(gcf, fileName);
cd ..
hold on;
end