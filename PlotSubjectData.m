function [angleRT_init, angleRT_Raw, incorrectPerc, rt_Avg_Struct,...
    stats, rt_Structure_raw, angles, angleRTMean, IncorrectStruct, ...
    IncorrectPercStruct, masterAngles, h] = ...
    PlotSubjectData(subjectNames,attention,...
    protocol,myDir, myFiles, plotSeparate, folderName, color, linestyle, marker, dn)
cd(folderName{1});
masterAngles = [];
for k = 1:length(myFiles)
  baseFileName = myFiles(k).name;
  fullFileName = fullfile(myDir, baseFileName);
  fprintf(1, 'Now reading %s\n', fullFileName);
  data = table2array(readtable(fullFileName));
  % all of your actions for filtering and plotting go here
  if plotSeparate == true
    figure(k);
  elseif plotSeparate == false
  end;
  dist = data(:,2);
    RT = data(:,3);
    clear angleRTMean;
    clear angleRTSTDE;
    clear angles;
    angles = unique(dist);
    masterAngles = [masterAngles; angles];
    clear angleRT_init;
    clear idx;
    clear incorrect;
    clear angleRT;
    for ii = 1.0:length(angles)
        idx = find(dist == angles(ii));
        angleRT_init(ii).data = RT(idx); 
        angleRT_Raw(k).subject(ii).data = RT(idx); % Stores all raw RT values at angles
        angleLength(ii).data = length(angleRT_init(ii).data);
        angleRT(ii).data = angleRT_init(ii).data(angleRT_init(ii).data ~= 0);
        incorrect(ii).data = length(angleRT_init(ii).data(angleRT_init(ii).data == 0));
        IncorrectStruct(k).subject(ii).data = length(angleRT_init(ii).data(angleRT_init(ii).data == 0));
        IncorrectPercStruct(k).subject(ii).data = ...
            length(angleRT_init(ii).data(angleRT_init(ii).data == 0))/...
            length(angleRT_init(ii).data);
        compoundCond = (angleRT(ii).data > (prctile(angleRT(ii).data, 25) - 1.5*iqr(angleRT(ii).data))) & (angleRT(ii).data < (prctile(angleRT(ii).data, 75) + 1.5*iqr(angleRT(ii).data)));
        angleRT(ii).data = angleRT(ii).data(compoundCond);
        incorrectPerc(k).subject(ii).data = incorrect(ii).data./angleLength(ii).data;
        rt_Structure_raw(k).subject(ii).RT = angleRT(ii).data;
    end
    for jj = 1.0:length(angleRT)
        angleRTMean(jj) = mean([angleRT(jj).data]);
        angleRTSTDE(jj) = std([angleRT(jj).data]) / sqrt(length([angleRT(jj).data]));
    end
    scatter(angles, angleRTMean, marker, 'filled','MarkerFaceColor',color,...
        'MarkerEdgeColor', color,'LineWidth', 1)
    hold on
    errorbar(angles, angleRTMean,angleRTSTDE, marker,...
        'Color', color, 'LineWidth', 1, 'CapSize', 0)
    hold on
    for ii = 1:length(angles)
        rt_Avg_Struct(k).subject(ii).RT = angleRTMean(ii);
        rt_Avg_Struct(k).subject(ii).Err = angleRTSTDE(ii);
    end
    
    anglesRight = transpose(angles(angles >= 0)); 
    anglesLeft = transpose(angles(angles<= 0));
    rtRight = angleRTMean(find(angles >= 0));
    rtLeft = angleRTMean(find(angles <= 0));
    errRight= angleRTSTDE(find(angles >= 0));
    errLeft = angleRTSTDE(find(angles <= 0));

    angleTot = [anglesLeft;anglesRight];
    rtTot = [rtLeft;rtRight];
    errTot = [errLeft;errRight];
    stats(k).subject(1).RT = angleRTMean;
    stats(k).subject(1).RTErr = angleRTSTDE;
    stats(k).subject(1).incorrectPerc = incorrectPerc;

    for ii = 1:2
        xPoints = angleTot(ii,:);        % array containing x-values (independent variable)
        yPoints = rtTot(ii,:);        % array containing y-values (dependent variable/observations)
        yErr = errTot(ii,:);           % array containing error associated with y-values (Std. error)
        yErr(yErr == 0) = 0.00000001;
        weights = 1./(yErr);
        OLSFit = polyfit(xPoints, yPoints, 1);
        olsFit = xPoints*OLSFit(1) + OLSFit(2);
        R = corrcoef(xPoints,  yPoints);
        guessParams = [OLSFit(1), OLSFit(2)];
        f = @(x, xvals, yvals, w)sum(w.*((yvals-((xvals.*x(1))+x(2))).^2));
        optFun = @(x)f(x, xPoints, yPoints, weights);
        ms = MultiStart;
        approx = guessParams;
        problem = createOptimProblem('fmincon', 'x0', approx, ...
            'objective', optFun, 'lb' , [OLSFit(1)-20, OLSFit(2)-200], 'ub', ...
            [OLSFit(1)+20, OLSFit(2)+200] );
        params = run(ms,problem,50);
        slope = params(1);
        intercept = params(2);
        chi2BestFit = xPoints*slope + intercept;
        plot(xPoints, chi2BestFit,'LineWidth', 1, 'LineStyle',...
            linestyle, 'color', color);
        hold on;
        handleStringArray = dn;
       % g = sum(double(strcat(attention, protocol)));
        h = plot(1000, 'LineWidth', 1, 'MarkerFaceColor',color, 'color', color,...
            'DisplayName',dn, 'LineStyle', linestyle, 'Marker', marker, 'MarkerSize', 5);
        hold on
        
%         chi2Val = sum((weights.*((yPoints - ((xPoints.*slope) + intercept)))).^2);
        chi2Val = optFun(params);
        syms sErr;
%         slopeErrTemp = solve(sum((weights.*((yPoints - ((xPoints.*sErr) + intercept)))).^2) == chi2Val+1 , sErr);  
        slopeErrTemp = solve(f([sErr, intercept], xPoints, yPoints, weights)...
            == chi2Val+1 , sErr);  
        slopeErr = vpa(slopeErrTemp);
        slopeErr = slopeErr(2) - slope;
        syms iErr;
%         intErrTemp = solve(sum((weights.*((yPoints - ((xPoints.*slope) + iErr)))).^2) == chi2Val+1 , iErr);  
        intErrTemp = solve(f([slope, iErr], xPoints, yPoints, weights)...
            == chi2Val+1 , iErr);  
        intErr = vpa(intErrTemp);
        interceptErr = intErr(2)-intercept;
        redChiSquare = chi2Val / (length(xPoints)-2);
        if ii == 1
            stats(k).subject(1).slopeNeg = slope;
            stats(k).subject(1).slopeNegErr = double(slopeErr);
            stats(k).subject(1).chi2Neg = chi2Val;
            stats(k).subject(1).redChi2Neg = redChiSquare;
            stats(k).subject(1).interNeg = intercept;
            stats(k).subject(1).interNegErr = double(interceptErr);
            stats(k).subject(1).R_Neg = -1*R(1,2);
        end
        if ii == 2
            stats(k).subject(1).slopePos = slope;
            stats(k).subject(1).slopePosErr = double(slopeErr);
            stats(k).subject(1).chi2Pos = chi2Val;
            stats(k).subject(1).redChi2Pos = redChiSquare;
            stats(k).subject(1).interPos = intercept;
            stats(k).subject(1).interPosErr = double(interceptErr);
            stats(k).subject(1).R_Pos = R(1,2);
        end
    end
    xline(0);
    xlim( [-65 65] );
    ylim([100 900]);
    title('test');
    ylabel('Reaction Time (ms)');
    xlabel('Eccentricity (°)');
    if length(subjectNames) == length(myFiles)
        title( strcat(subjectNames(k) , {' '},'Horizontal B/BBB')  );
    else 
        title(strcat('Subject', {' '}, string(k)));
    end
    %handleArray = [handleArray; h];
%     lgd = {};
%     lgd{end+1} = legend(h, 'Location', 'Northeastoutside', 'AutoUpdate', 'off');
%     legend(lgd);
    hold all;
    box on
    set(gcf, 'Position',  [20, 20, 700, 800]);
    hold on;
    fileName = strcat('Subject', {' '}, string(k), {' '}, attention, {' '}, protocol,...
        '.png');
    saveas(gcf, fileName);
    
end
cd ..
end