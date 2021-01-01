function [outputParamStats, protocolOutput] = plotSubjectData_v3(fileList,listing,...
    angleRT_Mean, angleRT_StdErr, myDir, linestyle, protocolNames, S, axes, colors,...
    masterAngles)
for k = 1:length(fileList)
    folderPath = fullfile(listing(k+2).folder, listing(k+2).name);
    addpath(folderPath);
    mkdir(protocolNames{k});
    for ii = 1:length(fileList(k).files)
        data = table2array(readtable(fileList(k).files(ii).name));
        dist = data(:,2);
        angles = unique(dist);
        figure((k-1)*length(fileList(k).files) + ii);
        scatter(angles, [angleRT_Mean(k).protocol(ii).subject.data], S{k}, 'filled', ...
            'LineWidth', 1, 'MarkerFaceColor',colors{k}, 'MarkerEdgeColor', colors{k});
        hold on;
        errorbar(angles, [angleRT_Mean(k).protocol(ii).subject.data],...
            [angleRT_StdErr(k).protocol(ii).subject.data], S{k}, 'Color', colors{k},...
            'LineWidth', 1, 'CapSize', 0);
        addpath(myDir, '\..\..');
        PosChiSquare = chiSquareFunction(angles(angles >= 0), ...
            [angleRT_Mean(k).protocol(ii).subject(find(angles >=0)).data],...
            [angleRT_StdErr(k).protocol(ii).subject(find(angles>=0)).data]);
        NegChiSquare = chiSquareFunction(angles(angles <= 0), ...
            [angleRT_Mean(k).protocol(ii).subject(find(angles <=0)).data],...
            [angleRT_StdErr(k).protocol(ii).subject(find(angles<=0)).data]);
        plot(angles(angles >= 0), angles(angles >= 0)*PosChiSquare.slope +...
            PosChiSquare.intercept, 'LineWidth', 1, 'LineStyle', linestyle{k},...
            'color', colors{k});
        hold on;
        plot(angles(angles <= 0), angles(angles <= 0)*NegChiSquare.slope +...
            NegChiSquare.intercept, 'LineWidth', 1, 'LineStyle', linestyle{k},...
            'color', colors{k});
        xlabel(axes{1});
        ylabel(axes{2});
        box on;
        grid on;
        set(gcf, 'Position',  [20, 20, 700, 800]);
        h = plot(2000, 'LineWidth', 1, 'MarkerFaceColor', colors{k}, 'color', colors{k}, ...
         'LineStyle', linestyle{k}, 'MarkerSize', 5, 'DisplayName', protocolNames{k},...
         'Marker', S{k}); hold on;
        legend(h, 'Location', 'Northeastoutside');
        xlim([(masterAngles(1)-5) (masterAngles(end)+5)]);
        ylim([100 900]);
        title(strcat('Subject', {' '}, string(ii), {' '}, string(protocolNames{k})));
        saveas(gcf, fullfile(pwd,  protocolNames{k},strcat('Subject', '_', string(ii), '.png')));
        outputParamStats(k).slopePos(ii) = PosChiSquare.slope;
        outputParamStats(k).slopePosErr(ii) = PosChiSquare.slopeErr;
        outputParamStats(k).slopeNeg(ii) = NegChiSquare.slope;
        outputParamStats(k).slopeNegErr(ii) = NegChiSquare.slopeErr;
        outputParamStats(k).interceptPos(ii) = PosChiSquare.intercept;
        outputParamStats(k).interceptPosErr(ii) = PosChiSquare.interceptErr;
        outputParamStats(k).interceptNeg(ii) = NegChiSquare.intercept;
        outputParamStats(k).interceptNegErr(ii) = NegChiSquare.interceptErr;
        outputParamStats(k).chi2valPos(ii) = PosChiSquare.chi2Val;
        outputParamStats(k).redChi2Pos(ii) = PosChiSquare.redChiSquare;
        outputParamStats(k).chi2valNeg(ii) = NegChiSquare.chi2Val;
        outputParamStats(k).redChi2Neg(ii) = NegChiSquare.redChiSquare;
        outputParamStats(k).R_Pos(ii) = PosChiSquare.R;
        outputParamStats(k).R_Neg(ii) = NegChiSquare.R;
    end
end
for k = 1:length(fileList)
    outputParamStats(k).slopePos = [outputParamStats(k).slopePos]';
    outputParamStats(k).slopePosErr = [outputParamStats(k).slopePosErr]';
    outputParamStats(k).slopeNeg = [outputParamStats(k).slopeNeg]';
    outputParamStats(k).slopeNegErr = [outputParamStats(k).slopeNegErr]';
    outputParamStats(k).interceptPos = [outputParamStats(k).interceptPos]';
    outputParamStats(k).interceptPosErr = [outputParamStats(k).interceptPosErr]';
    outputParamStats(k).interceptNeg = [outputParamStats(k).interceptNeg]';
    outputParamStats(k).interceptNegErr = [outputParamStats(k).interceptNegErr]';
    outputParamStats(k).chi2valPos = [outputParamStats(k).chi2valPos]';
    outputParamStats(k).redChi2Pos = [outputParamStats(k).redChi2Pos]';
    outputParamStats(k).chi2valNeg = [outputParamStats(k).chi2valNeg]';
    outputParamStats(k).redChi2Neg = [outputParamStats(k).redChi2Neg]';
    outputParamStats(k).R_Pos = [outputParamStats(k).R_Pos]';
    outputParamStats(k).R_Neg = [outputParamStats(k).R_Neg]';
end
for ii = 1:4
    protocolOutput(ii).table = struct2table(outputParamStats(ii));
end
end