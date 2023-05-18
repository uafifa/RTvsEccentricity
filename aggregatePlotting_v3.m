function [] = aggregatePlotting_v3(masterAngles, protocolWeightedMean, colors,...
    protocolStdErr,protocolChiFitPos, protocolChiFitNeg, linestyle,protocolNames, S,...
    axes, refDist)

for ii = 1:4
    scatter(masterAngles, protocolWeightedMean(ii,:), S{ii}, 'filled', 'MarkerFaceColor',...
       colors{ii}, 'MarkerEdgeColor', colors{ii}, 'LineWidth', 1);
   S{ii}
    hold on;
    errorbar(masterAngles, protocolWeightedMean(ii,:),...
        protocolStdErr(ii,:), S{ii}, 'Color', colors{ii}, 'LineWidth', 1, 'Capsize', 0);
    hold on;
    plot(masterAngles(masterAngles>=refDist),masterAngles(masterAngles>=refDist)*...
        protocolChiFitPos(ii).slope + protocolChiFitPos(ii).intercept, 'LineWidth', 1,...
        'LineStyle', linestyle{ii}, 'color', colors{ii});
    hold on;
    plot(masterAngles(masterAngles<=refDist),masterAngles(masterAngles<=refDist)*...
        protocolChiFitNeg(ii).slope + protocolChiFitNeg(ii).intercept, 'LineWidth', 1,...
        'LineStyle', linestyle{ii}, 'color', colors{ii});
    hold on;
    xlabel(axes{1});
    ylabel(axes{2});
    box on;
    %grid on;
    set(gcf, 'Position',  [20, 20, 600, 800]);
%     h(ii) = plot(2000, 'LineWidth', 1, 'MarkerFaceColor', colors{5-ii}, 'color', colors{5-ii}, ...
%      'LineStyle', linestyle{5-ii}, 'MarkerSize', 5, 'DisplayName', protocolNames{5-ii},...
%      'Marker', S{5-ii}); hold on;
%     legend(h, 'Location', 'Northeastoutside', 'AutoUpdate', 'off');
    xlim([(masterAngles(1)-5) (masterAngles(end)+5)]);
    ylim([150 920]);
    set(gca, 'fontsize', 18);
    xticks(masterAngles);
    saveas(gcf, fullfile(pwd,  'combined_plots' ,strcat('Aggregate', '.png')));
end
