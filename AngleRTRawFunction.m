function [angleRT_Raw] = AngleRTRawFunction(subjectNames,attention,protocol,myDir, myFiles)
for k = 1:length(myFiles)
  baseFileName = myFiles(k).name;
  fullFileName = fullfile(myDir, baseFileName);
  fprintf(1, 'Now reading %s\n', fullFileName);
  data = table2array(readtable(fullFileName));
  dist = data(:,2);
  RT = data(:,3);
  angles = unique(dist);
  for ii = 1.0:length(angles)
      idx = find(dist == angles(ii));
      angleRT_init(ii).data = RT(idx); 
      angleRT_Raw(k).subject(ii).data = RT(idx); % Stores all raw RT values at angles
      angleLength(ii).data = length(angleRT_init(ii).data);
      angleRT(ii).data = angleRT_init(ii).data(angleRT_init(ii).data ~= 0);
      compoundCond = (angleRT(ii).data > (prctile(angleRT(ii).data, 25) - 1.5*iqr(angleRT(ii).data))) & (angleRT(ii).data < (prctile(angleRT(ii).data, 75) + 1.5*iqr(angleRT(ii).data)));
      angleRT(ii).data = angleRT(ii).data(compoundCond);
      rt_Structure_raw(k).subject(ii).RT = angleRT(ii).data;
    end
end
end