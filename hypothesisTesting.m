function [incorrectHypArray] = hypothesisTesting(myFiles, myDir, ~, numOptions,...
    angleRT_Raw, masterAngles)
for k = 1:length(myFiles)
    clear angles;
    baseFileName = myFiles(k).name;
    fullFileName = fullfile(myDir, baseFileName);
    data = table2array(readtable(fullFileName));
    dist = data(:,2);
    angles = unique(dist);
    for t = 1:length(masterAngles)
        incorrectHypArray(1,t+1) = masterAngles(t);
    end
    incorrectHypArray(k+1,1) = k;
    for ii = 1:length(angles)
        [~, p] = ttest(logical(angleRT_Raw(k).subject(ii).data),...
            numOptions, 'Tail', 'right');
        idx = find(masterAngles == angles(ii));
        incorrectHypArray(k+1, idx + 1) = p;
    end
end
end