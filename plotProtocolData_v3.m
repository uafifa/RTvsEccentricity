function [outputParamStats, protocolOutput, h] = plotProtocolData_v3(fileList,listing,...
    angleRT_Norm, angleRT_StdErr, myDir, linestyle, protocolNames, S, axes,...
    masterAngles, refDist, color, SubjectNames,  protocolWeightedMean,...
    protocolStdErr,protocolChiFitPos, protocolChiFitNeg, direc)
for k = 1:length(fileList)
    folderPath = fullfile(listing(k+2).folder, listing(k+2).name);
    addpath(folderPath);
    
    figure(k);
    for ii = 1:length(fileList(k).files)
        data = table2array(readtable(fileList(k).files(ii).name));
        dist = data(:,2);
        angles = unique(dist);
        
        hold on;
        scatter(angles, [angleRT_Norm(k).protocol(ii).subject.data], S{k}, 'filled', ...
            'LineWidth', 1, 'MarkerFaceColor',color{ii}, 'MarkerEdgeColor', color{ii});
        hold on;
        errorbar(angles, [angleRT_Norm(k).protocol(ii).subject.data],...
            [angleRT_StdErr(k).protocol(ii).subject.data], S{k}, 'Color', color{ii},...
            'LineWidth', 1, 'CapSize', 0);
        addpath(myDir, '\..\..');
        PosChiSquare = chiSquareFunction(angles(angles >= refDist), ...
            [angleRT_Norm(k).protocol(ii).subject(find(angles >=refDist)).data],...
            [angleRT_StdErr(k).protocol(ii).subject(find(angles>=refDist)).data]);
        NegChiSquare = chiSquareFunction(angles(angles <= refDist), ...
            [angleRT_Norm(k).protocol(ii).subject(find(angles <=refDist)).data],...
            [angleRT_StdErr(k).protocol(ii).subject(find(angles<=refDist)).data]);
        plot(angles(angles >= refDist), angles(angles >= refDist)*PosChiSquare.slope +...
            PosChiSquare.intercept, 'LineWidth', 1, 'LineStyle', '--',...
            'color', color{ii});
        hold on;
        plot(angles(angles <= refDist), angles(angles <= refDist)*NegChiSquare.slope +...
            NegChiSquare.intercept, 'LineWidth', 1, 'LineStyle', '--',...
            'color', color{ii});
        hold on;
        
        %add the aggregated plot
        scatter(masterAngles, protocolWeightedMean(k,:), S{k}, 'filled', 'MarkerFaceColor',...
        'k', 'MarkerEdgeColor', 'k', 'LineWidth', 2);
   
        hold on;
        errorbar(masterAngles, protocolWeightedMean(k,:),...
        protocolStdErr(k,:), S{k}, 'Color', 'k', 'LineWidth', 2, 'Capsize', 0);
    hold on;
    plot(masterAngles(masterAngles>=refDist),masterAngles(masterAngles>=refDist)*...
        protocolChiFitPos(k).slope + protocolChiFitPos(k).intercept,  'LineWidth', 2,...
        'LineStyle', '-', 'color', 'k');
    hold on;
    plot(masterAngles(masterAngles<=refDist),masterAngles(masterAngles<=refDist)*...
        protocolChiFitNeg(k).slope + protocolChiFitNeg(k).intercept, 'LineWidth', 2,...
        'LineStyle', '-', 'color', 'k');
    
        
        xlabel(axes{1});
        ylabel(axes{2});
        box on;
        %grid on;
        set(gcf, 'Position',  [20, 20, 600, 800]);
        h(ii) = plot(2000, 'LineWidth', 1, 'MarkerFaceColor', color{ii}, 'color', color{ii}, ...
          'LineStyle', '--', 'MarkerSize', 5, 'DisplayName', SubjectNames{ii},...
          'Marker', S{k}); hold on;
      h(14) = plot(2000, 'LineWidth', 1, 'MarkerFaceColor', 'k', 'color', 'k', ...
          'LineStyle', '-', 'MarkerSize', 5, 'DisplayName', 'Aggregated',...
          'Marker', S{k}); hold on;
        
        xlim([(masterAngles(1)-5) (masterAngles(end)+5)]);
        ylim([100 1100]);
        %yticks([300:50:900]);
        xticks(masterAngles);
        set(gca, 'fontsize', 18);
        
        title(strcat(string(protocolNames{k}), {' '}));
            %saveas(gcf, fullfile(pwd,  protocolNames{k},strcat(string(protocolNames{k}), '.png')));
        
    end
    hold on;
        
     %   legend(h, 'Location', 'Northeastoutside');
        
        saveas(gcf, fullfile(pwd,  direc ,strcat(string(protocolNames{k}), '_',...
                'protocol plots', '.png')));
        

    end
end

        