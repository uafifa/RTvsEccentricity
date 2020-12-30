function [normalityArray, normalityJB] = normalityTest(myFiles, myDir, angleRT_Raw, angles)
for k = 1:length(myFiles)
    baseFileName = myFiles(k).name;
    fullFileName = fullfile(myDir, baseFileName);
    data = table2array(readtable(fullFileName));
    clear dist;
    dist = data(:,2);
    clear angles;
    angles = unique(dist);
    for ii = 1:length(angles)
        currentArray = angleRT_Raw(k).subject(ii).data;
        currentArray = currentArray(currentArray ~= 0);
        normalityArray(k, ii) = lillietest(currentArray);
        normalityJB(k, ii) = jbtest(currentArray);
    end
end