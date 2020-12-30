function [OutputParamStats, IncorrectTest] = ...
    organizeData(myFiles, myDir, subjectNames,stats, incorrectPerc, masterAngles)
for k = 1:length(myFiles)
    clear angles;
    baseFileName = myFiles(k).name;
    fullFileName = fullfile(myDir, baseFileName);
    data = table2array(readtable(fullFileName));
    dist = data(:,2);
    RT = data(:,3);
    angles = unique(dist);
    if length(subjectNames) == length(myFiles)
        OutputParamStats(k).Subject = subjectNames(k);
    else
        OutputParamStats(k).Subject = strcat('subject', string(k));
    end
    OutputParamStats(k).slopePos = stats(k).subject.slopePos;
    OutputParamStats(k).slopePosErr = stats(k).subject.slopePosErr;
    OutputParamStats(k).slopeNeg = stats(k).subject.slopeNeg;
    OutputParamStats(k).slopeNegErr = stats(k).subject.slopeNegErr;
    OutputParamStats(k).interceptPos = stats(k).subject.interPos;
    OutputParamStats(k).interceptPosErr = stats(k).subject.interPosErr;
    OutputParamStats(k).interceptNeg = stats(k).subject.interNeg;
    OutputParamStats(k).interceptNegErr = stats(k).subject.interNegErr;
    OutputParamStats(k).chi2ValPos = stats(k).subject.chi2Pos;
    OutputParamStats(k).redChi2Pos = stats(k).subject.redChi2Pos;
    OutputParamStats(k).chi2ValNeg = stats(k).subject.chi2Neg;
    OutputParamStats(k).redChi2Neg = stats(k).subject.redChi2Neg;
    OutputParamStats(k).R_Pos = stats(k).subject.R_Pos;
    OutputParamStats(k).R_Neg = stats(k).subject.R_Neg;
    for t = 1:length(masterAngles)
        IncorrectTest(1, t+1) = masterAngles(t);
    end
    for p = 1:length(angles)
        idx = find(masterAngles == angles(p));
        IncorrectTest(k+1, idx+1) = incorrectPerc(k).subject(p).data;
        IncorrectTest(k+1, 1) = k;
    end
end
end