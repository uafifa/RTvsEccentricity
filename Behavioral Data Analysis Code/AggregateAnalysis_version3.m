%% Enter In Information for making Folder
dirName = FolderNameGenerator();
disp(dirName);
mkdir(dirName);
%% Experiment Information
[protocolNames, colors, linestyle, axes] = experimentInformation();
S = {'o', 'd', 's', 'h'};
%% Choose Large Meta Folder
myDir = uigetdir; %gets directory
listing = dir(myDir);
for ii = 3:length(listing)
    subFolder(ii-2).subfolder = listing(ii).name;
    fileList(ii-2).files = dir(fullfile(myDir, listing(ii).name, '*.csv')); 
end

%% Sort Through Data
masterAngles = [];
for k = 1:length(fileList)
    folderPath = fullfile(listing(k+2).folder, listing(k+2).name);
    addpath(folderPath);
    for ii = 1:length(fileList(k).files)
        file = fileList(k).files(ii).name;
        fprintf(1, 'Now Reading %s\n' , fileList(k).files(ii).name);
        data = table2array(readtable(fileList(k).files(ii).name));
        dist = data(:,2);
        angles = unique(dist);
        RT = data(:,3);
        masterAngles = [masterAngles; angles];
        masterAngles = unique(masterAngles);
        for jj = 1:length(angles)
            idx = find(dist == angles(jj));
            RT_IDX = RT(idx);
            angleRT_Raw(k).protocol(ii).subject(jj).data = RT(idx);
            angleRT_Incorrect(k).protocol(ii).subject(jj).data = sum(RT_IDX(:) == 0);
            angleRT_IncorrectPerc(k).protocol(ii).subject(jj).data = sum(RT_IDX(:) == 0)/...
                length(RT_IDX);
            RT_IDX = RT_IDX(RT_IDX~=0);
            [RT_IDX_RMO, TF] = rmoutliers(RT_IDX, 'quartiles');
            angleRT_RMO(k).protocol(ii).subject(jj).data = RT_IDX_RMO;
            angleRT_outlier(k).protocol(ii).subject(jj).data = sum(TF);
            angleRT_Mean(k).protocol(ii).subject(jj).data = mean(RT_IDX_RMO);
            angleRT_StdErr(k).protocol(ii).subject(jj).data = std(RT_IDX_RMO)/...
                sqrt(length(RT_IDX_RMO));
        end
    end
end
%% Plotting
[outputParamStats, protocolOutput] = plotSubjectData_v3(fileList,listing,...
    angleRT_Mean, angleRT_StdErr, myDir, linestyle, protocolNames, S, axes, colors,...
    masterAngles);
%% Plotting Incorrect Percentages
cd(dirName);
for k = 1:length(fileList)
    mkdir(strcat(protocolNames{k}, 'Percentage Correct'));
    cd(strcat(protocolNames{k}, 'Percentage Correct'));
    folderPath = fullfile(listing(k+2).folder, listing(k+2).name);
    addpath(folderPath);
    for ii = 1:length(fileList(k).files)
        file = fileList(k).files(ii).name;
        fprintf(1, 'Now Reading %s\n' , fileList(k).files(ii).name);
        data = table2array(readtable(fileList(k).files(ii).name));
        dist = data(:,2);
        angles = unique(dist);
        bar(angles, 100*(1-[angleRT_IncorrectPerc(k).protocol(ii).subject.data]));
        for jj = 1:length([angleRT_IncorrectPerc(k).protocol(ii).subject])
            binomSTDE = 100*sqrt([angleRT_IncorrectPerc(k).protocol(ii).subject.data].*...
                (1-[angleRT_IncorrectPerc(k).protocol(ii).subject.data])...
                /length(angleRT_Raw(k).protocol(ii).subject(jj).data));
        end
        hold on;
        errorbar(angles, (100*(1-[angleRT_IncorrectPerc(k).protocol(ii).subject.data])),...
            [binomSTDE],'o', 'Color', 'r', 'MarkerFaceColor', 'r', 'MarkerSize', 0.1);
        ylim([30 100]);
        xlabel('Eccentricity (°)');
        ylabel('Percentage Incorrect');
        title(strcat('Subject', {' '}, string(ii), {' '}, 'Percentage Correct for',...
            {' '}, string(protocolNames{k})));
        saveas(gcf, strcat('Subject', '_', string(ii), 'PercCorrect.png'));
        hold off;
    end
    cd ..
end
cd ..
%% Output to XLSX
cd(dirName);
for ii = 1:length(outputParamStats)
    tableStats = struct2table(outputParamStats(ii));
    fileName = strcat('output-Parameters for' , {' '}, ...
        string(protocolNames{ii}), '.xlsx');
    fileName = regexprep(fileName, ' ', '_');
    writetable(tableStats, fileName, 'Sheet', 1);
end
cd ..
%% Hypothesis Testing/Error Analysis
[incorrectHypArray] = hypothesisTesting_v3(fileList, listing,...
    angleRT_Raw, masterAngles);
%% Aggregate Analysis
masterAngles = [];
handles = [];
for k = 1:length(fileList)
   folderPath = fullfile(listing(k+2).folder, listing(k+2).name);
   addpath(folderPath);
   for ii = 1:length(fileList(k).files)
       fprintf(1, 'Now Reading %s\n' , fileList(k).files(ii).name);
        data = table2array(readtable(fileList(k).files(ii).name));
        dist = data(:,2);
        angles = unique(dist);
        masterAngles = [masterAngles; angles];
        masterAngles = unique(masterAngles);
        for jj = 1:length(angles)
            idx = find(masterAngles == angles(jj));
            aggregateMeans(ii, idx, k) = angleRT_Mean(k).protocol(ii).subject(jj).data;
            aggregateSTDE(ii,idx,k) = angleRT_StdErr(k).protocol(ii).subject(jj).data;
        end
   end
end
aggregateMeans(find(incorrectHypArray >= 0.05 & incorrectHypArray <= 1)) = NaN;
aggregateSTDE(find(incorrectHypArray >= 0.05 & incorrectHypArray <= 1)) = NaN;
aggregateMeans(aggregateMeans == 0) = NaN;
aggregateSTDE(aggregateSTDE == 0) = NaN;

for k = 1:length(fileList)
    for jj = 1:length(masterAngles)
        protocolWeightedMean(k, jj) = sum(aggregateMeans(:,jj,k)./aggregateSTDE(:,jj,k), ...
            'omitnan')/sum(1./aggregateSTDE(:,jj,k) , 'omitnan');
        protocolStdErr(k,jj) = std(aggregateMeans(:,jj,k)/...
            sqrt(length(aggregateMeans(:,jj,k))),...
            'omitnan');
    end
end
for ii = 1:4
    protocolChiFitPos(ii) = chiSquareFunction(masterAngles(masterAngles >= 0)...
        ,protocolWeightedMean(ii,find(masterAngles >= 0))...
        ,protocolStdErr(ii,find(masterAngles >= 0)));
    protocolChiFitNeg(ii) = chiSquareFunction(masterAngles(masterAngles <= 0)...
        ,protocolWeightedMean(ii,find(masterAngles <= 0))...
        ,protocolStdErr(ii,find(masterAngles <= 0)));
end
%% Output Aggregate Parameters to XLSX
cd(dirName);
for ii = 1:length(protocolNames)
    protocolChiFit(ii).slopePos = protocolChiFitPos(ii).slope;
    protocolChiFit(ii).slopePosErr = protocolChiFitPos(ii).slopeErr;
    protocolChiFit(ii).slopeNeg = protocolChiFitNeg(ii).slope;
    protocolChiFit(ii).slopeNegErr = protocolChiFitNeg(ii).slopeErr;
    protocolChiFit(ii).interceptPos = protocolChiFitPos(ii).intercept;
    protocolChiFit(ii).interceptPosErr = protocolChiFitPos(ii).interceptErr;
    protocolChiFit(ii).interceptNeg = protocolChiFitNeg(ii).intercept;
    protocolChiFit(ii).interceptNegErr = protocolChiFitNeg(ii).interceptErr;
    protocolChiFit(ii).chi2valPos = protocolChiFitPos(ii).chi2Val;
    protocolChiFit(ii).redChi2Pos = protocolChiFitPos(ii).redChiSquare;
    protocolChiFit(ii).chi2valNeg = protocolChiFitNeg(ii).chi2Val;
    protocolChiFit(ii).redChi2Neg = protocolChiFitNeg(ii).redChiSquare;
    protocolChiFit(ii).R_Pos = protocolChiFitPos(ii).R;
    protocolChiFit(ii).R_Neg = protocolChiFitNeg(ii).R;
    tableStats = struct2table(protocolChiFit(ii));
    fileName = strcat('Aggregate-Parameters-for',{' '}, string(protocolNames(ii)),...
        '.xlsx');
    fileName = regexprep(fileName, ' ', '_');
    writetable(tableStats, fileName, 'Sheet', 1);
end
cd ..
%%  Aggregate Plotting
aggregatePlotting_v3(masterAngles, protocolWeightedMean, colors,...
    protocolStdErr,protocolChiFitPos, protocolChiFitNeg, linestyle,protocolNames, S,...
    axes)
