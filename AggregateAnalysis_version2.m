protocolMasterList={};
%% Input Options
[subjectNames, protocol, attention] = InputOptions();
folderName = strcat('Subject Plots Folder', {' '}, attention, {' '}, protocol);
mkdir(folderName{1});

%% User-Interface getDirectory / Plot Data
myDir = uigetdir; %gets directory
myFiles = dir(fullfile(myDir,'*.csv')); 
C = {[0.5020 0.5020 0.5020],[0 0 0],[1.0000    0.4118    0.1608], [0.6353    0.0784    0.1843],  [0.0745    0.6235    1.0000], [0 0 1]};
L = {'-', '--', '-', '--', '-', '--'};
dn = { 'Covert SRT', 'Overt SRT', 'Covert 2 CRT', 'Overt 2 CRT', 'Covert 3 CRT', 'Overt 3 CRT'};
S = {'o', 'd', '*', '^', 's', 'h'};
% plotSeparate = true/false
if strcmp(attention,'covert') & strcmp(protocol,'B')
    C = C{1};L = L{1};dn = dn{1};S = S{1};
    protocolMasterList{end+1} = 1;
elseif strcmp(attention,'overt') & strcmp(protocol,'B')
    C = C{2};L = L{2};dn = dn{2};S = S{2};
    protocolMasterList{end+1} = 2;
elseif strcmp(attention,'covert') & strcmp(protocol,'BB')
    C = C{3};L = L{3};dn = dn{3};S = S{3};
    protocolMasterList{end+1} = 3;
elseif  strcmp(attention,'overt') & strcmp(protocol,'BB')
    C = C{4};L = L{4};dn = dn{4};S = S{4};
    protocolMasterList{end+1} = 4;
elseif strcmp(attention,'covert') & strcmp(protocol,'BBB')
    C = C{5};L = L{5};dn = dn{5};S = S{5};
    protocolMasterList{end+1} = 5;
elseif strcmp(attention,'overt') & strcmp(protocol,'BBB')
    C = C{6};L = L{6};dn = dn{6};S = S{6}; 
    protocolMasterList{end+1} = 6;
end
plotSeparate = true;
[angleRT_init, angleRT_Raw, incorrectPerc, rt_Avg_Struct,stats, rt_Structure_raw,...
    angles, angleRTMean, IncorrectStruct, IncorrectPercStruct, masterAngles, h]...
    = PlotSubjectData(subjectNames, attention, protocol,myDir, myFiles, plotSeparate,...
    folderName, C, L, S, dn);
masterAngles = unique(masterAngles);
%% Adding Legends to Plots
cd(folderName{1});
hArray = [];
C = {[0.5020 0.5020 0.5020],[0 0 0],[1.0000    0.4118    0.1608], [0.6353    0.0784    0.1843],  [0.0745    0.6235    1.0000], [0 0 1]};
L = {'-', '--', '-', '--', '-', '--'};
dn = { 'Covert SRT', 'Overt SRT', 'Covert 2 CRT', 'Overt 2 CRT', 'Covert 3 CRT', 'Overt 3 CRT'};
S = {'o', 'd', '*', '^', 's', 'h'};
for k = 1:length(myFiles)
    for p = 1:length(protocolMasterList)
        h(p) = plot(1000, 'LineWidth', 1, 'MarkerFaceColor',C{protocolMasterList{p}},...
            'color', C{protocolMasterList{p}},...
            'DisplayName',dn{protocolMasterList{p}},...
            'LineStyle', L{protocolMasterList{p}}, 'Marker',...
            S{protocolMasterList{p}}, 'MarkerSize', 5);
    end
    figure(k);
    legend(h, 'Location', 'Northeastoutside');
    fileName = strcat('Subject', {' '}, string(k), {' '}, attention, {' '}, protocol,...
        '.png');
    saveas(gcf, fileName);
end
cd .. 
%% Organize Data
[OutputParamStats, IncorrectTest] = ...
    organizeData(myFiles, myDir, subjectNames,stats, incorrectPerc, masterAngles);
%% Test for Normality
[normalityTableLillie, normalityJB] = normalityTest(myFiles, myDir, angleRT_Raw, angles);
%% Hypothesis Testing
% num options (# of buttons / choices)
numOptions = 3/3;
[incorrectHypArray] = hypothesisTesting(myFiles, myDir, angles, numOptions,...
    angleRT_Raw, masterAngles);
%% Plotting Incorrect Percentages
cd(folderName{1});
for k = 1:length(myFiles)
    clear angles;
    baseFileName = myFiles(k).name;
    fullFileName = fullfile(myDir, baseFileName);
    data = table2array(readtable(fullFileName));
    dist = data(:,2);
    angles = unique(dist);
    figure(k+13);
    clear stdE_binom;
    clear binom_Prob;
    for ii = 1:length(angles)
        angleRT_Raw(k).subject(ii).data(angleRT_Raw(k).subject(ii).data == 0) = NaN;
        
        binomial_prob(k).data(ii).data =length(find(isnan(angleRT_Raw(k).subject(ii).data)))...
            /length(angleRT_Raw(k).subject(ii).data);
        binomProb(ii) = length(find(isnan(angleRT_Raw(k).subject(ii).data)))...
            /length(angleRT_Raw(k).subject(ii).data);
        standardErr_binom(k).data(ii).data = sqrt(binomial_prob(k).data(ii).data .* ...
            (1-binomial_prob(k).data(ii).data) ./ length(angleRT_Raw(k).subject(ii).data));
        stdE_binom(ii) = sqrt(binomial_prob(k).data(ii).data .* ...
            (1-binomial_prob(k).data(ii).data) ./ length(angleRT_Raw(k).subject(ii).data));
    end
    idx = [];
    for ii = 1:length(angles)
        idx = [idx,find(angles(ii) == transpose(masterAngles))];
    end
    bar(angles, IncorrectTest(k+1, idx(1)+1:idx(end)+1)*100);
    
    hold on;
%     errorbar(angles, IncorrectTest(k+1,2:end)*100, 100.*[standardErr_binom(k).data.data],...
%         'o', 'Color', 'r', 'MarkerFaceColor', 'r');
    errorbar(angles, IncorrectTest(k+1,idx(1)+1:idx(end)+1)*100, 100.*[stdE_binom],...      
        'o', 'Color', 'r', 'MarkerFaceColor', 'r');
    ylim([0 100]);
    xlabel('Eccentricity (°)');
    ylabel('Percentage Incorrect');
    title(strcat('Subject',{' '}, string(k),{' '}, 'Incorrect Percentage' ));
    fileName = strcat('Subject','_', string(k),'_', 'Incorrect Percentage.png' );
    saveas(gcf, fileName);
end
clear stdE_binom;
clear standardError_binom;
cd ..
%% Output Data to xlsx
cd(folderName{1});
T = struct2table(OutputParamStats);
filename = 'OutputParameters.xlsx';
writetable(T,filename,'Sheet',1);
T2 = array2table(incorrectHypArray(2:end, :));
T2.Properties.VariableNames = {'Subject', '-60', '-45', '-30', '-15'...
    '0', '15', '30', '45', '60'};
filename = 'Hypothesis_Testing_Values.xlsx';
writetable(T2, filename, 'Sheet', 1);
cd .. ;
%% Aggregate Plot Single Condition
% [AggregateMeans, AggregateStd, aggregateRT, angleRT_New, aggregateSubjectMeans...,
%     aggregatePosFit, aggregateNegFit, aggregateStd_E] =...
%     AggregateAnalysisFunction(myFiles, myDir, angleRT_Raw,folderName, 'b', masterAngles);
C = {[0.5020 0.5020 0.5020],[0 0 0],[1.0000    0.4118    0.1608], [0.6353    0.0784    0.1843],  [0.0745    0.6235    1.0000], [0 0 1]};
L = {'-', '--', '-', '--', '-', '--'};
dn = { 'Covert SRT', 'Overt SRT', 'Covert 2 CRT', 'Overt 2 CRT', 'Covert 3 CRT', 'Overt 3 CRT'};
S = {'o', 'd', '*', '^', 's', 'h'};
% plotSeparate = true/false
if strcmp(attention,'covert') & strcmp(protocol,'B')
    C = C{1};L = L{1};dn = dn{1};S = S{1};
    %protocolMasterList{end+1} = 1;
elseif strcmp(attention,'overt') & strcmp(protocol,'B')
    C = C{2};L = L{2};dn = dn{2};S = S{2};
    %protocolMasterList{end+1} = 2;
elseif strcmp(attention,'covert') & strcmp(protocol,'BB')
    C = C{3};L = L{3};dn = dn{3};S = S{3};
    %protocolMasterList{end+1} = 3;
elseif  strcmp(attention,'overt') & strcmp(protocol,'BB')
    C = C{4};L = L{4};dn = dn{4};S = S{4};
    %protocolMasterList{end+1} = 4;
elseif strcmp(attention,'covert') & strcmp(protocol,'BBB')
    C = C{5};L = L{5};dn = dn{5};S = S{5};
    %protocolMasterList{end+1} = 5;
elseif strcmp(attention,'overt') & strcmp(protocol,'BBB')
    C = C{6};L = L{6};dn = dn{6};S = S{6}; 
    %protocolMasterList{end+1} = 6;
end
[AggregateMeans, AggregateStd, aggregateRT, angleRT_New, aggregateSubjectMeans...,
    aggregatePosFit, aggregateNegFit, aggregateStd_E] =...
    AggregateAnalysisFunction(myFiles, myDir, angleRT_Raw,folderName,...
    C, masterAngles, L, S, dn);
figure(100);
% h = plot(1000, 'LineWidth', 1, 'MarkerFaceColor',C, 'color', C, ...
%     'DisplayName',dn, 'LineStyle', L, 'Marker', S, 'MarkerSize', 5);
% legend(h, 'Location', 'Northeastoutside');

%% Adding Legends to Plots
cd(folderName{1});
hArray = [];
C = {[0.5020 0.5020 0.5020],[0 0 0],[1.0000    0.4118    0.1608], [0.6353    0.0784    0.1843],  [0.0745    0.6235    1.0000], [0 0 1]};
L = {'-', '--', '-', '--', '-', '--'};
dn = { 'Covert SRT', 'Overt SRT', 'Covert 2 CRT', 'Overt 2 CRT', 'Covert 3 CRT', 'Overt 3 CRT'};
S = {'o', 'd', '*', '^', 's', 'h'};

    for p = 1:length(protocolMasterList)
        h(p) = plot(1000, 'LineWidth', 1, 'MarkerFaceColor',C{protocolMasterList{p}},...
            'color', C{protocolMasterList{p}},...
            'DisplayName',dn{protocolMasterList{p}},...
            'LineStyle', L{protocolMasterList{p}}, 'Marker',...
            S{protocolMasterList{p}}, 'MarkerSize', 5);
    end
    figure(100);
    legend(h, 'Location', 'Northeastoutside');
    fileName = 'Aggregated-Plot-Weighted-Average-H.png';
    saveas(gcf, fileName);

cd .. 
%% ANOVA test
[pAnova, tblAnova, anovaStats] = anova1(aggregateSubjectMeans);
multCompare = multcompare(anovaStats);
%% Three-way ANOVA Test
angleAnova= [];
RTAnova = [];
subjectAnova = [];
observationNum = [];
for k = 1:length(myFiles)
    clear angles;
    clear dist;
    baseFileName = myFiles(k).name;
    fullFileName = fullfile(myDir, baseFileName);
    data = table2array(readtable(fullFileName));
    dist = data(:,2);
    RT = data(:,3);
    angleAnova = [angleAnova; dist];
    RTAnova = [RTAnova; RT];
    subjectAnova = [subjectAnova; k*ones([length(dist), 1])];
    observationNum = [observationNum; transpose(1:1:length(dist))];
end
RTAnova(RTAnova == 0) = NaN;
%% N-way Analysis of Variance
[p_anovaN, tbl_anovaN, stats_anovaN] = ...
    anovan(RTAnova, {angleAnova, subjectAnova, observationNum},...
    'varnames',{'Eccentricity','Subject', 'Observation Number'});

% %% Creating 1D Array for ANOVA-N
% clear anovaAngles;
% clear angleStartIndex;
% clear anovaN;
% clear anovaNSubject;
% anovaN = [];
% anovaNSubject = [];
% for k = 1:length(myFiles)
%     for ii = 1:length(angles)
%         angleStartIndex(((k-1)*length(angles) + ii)) = length(angleRT_New(k).subject(ii).data);
%         angleStartIndex = transpose(angleStartIndex);
%     end
% end
% for ii = 1:length(angleStartIndex)
%     if ii == 1
%         continue
%     end
%     angleStartIndex(ii) = angleStartIndex(ii)+angleStartIndex(ii-1);
% end
% k = 1;
% while k <= length(myFiles)
%     ii = 1;
%     while ii <= length(angles)
%         jj = 1;
%         anovaN = [anovaN; angleRT_New(k).subject(ii).data];
%         while jj <= length(angleRT_New(k).subject(ii).data)
%             anovaNSubject = [anovaNSubject; k];
%             jj = jj + 1;
%         end
%         ii = ii + 1;
%     end
%     k = k +1 ;
% end;
% for k = 1:length(myFiles)
%     if k == 1
%         anovaAngles(1:length(angleRT_New(1).subject(1).data)) = -60;
%         for ii = 1:length(angles)-1;
%             anovaAngles((angleStartIndex(ii)+1):(angleStartIndex(ii+1)+1)) =...
%                 angles(ii+1);
%         end
%         continue
%     end
%     for ii = 1:length(angles)-1
%         anovaAngles((angleStartIndex((k-1)*length(angles)+ii)+1): ...
%             (angleStartIndex((k-1)*length(angles)+ii+1)+1))...
%             = angles(ii+1);
%     end
% end
% anovaAngles = transpose(anovaAngles);
% anovaAngles(2296) = [];
% anovaAngles(anovaAngles == 0) = -60;
% %% N-way Analysis of Variance
% [p_anovaN, tbl_anovaN, stats_anovaN] = ...
%     anovan(anovaN, {anovaAngles, anovaNSubject},'varnames',{'Eccentricity','Subject'});
% 
