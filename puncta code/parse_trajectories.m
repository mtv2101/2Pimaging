clear all;

rootdirs = {'C:\Users\supersub\Desktop\Data\text files\MC lateral non-enriched',...
    'C:\Users\supersub\Desktop\Data\text files\MC lateral non-enriched',...
    'C:\Users\supersub\Desktop\Data\text files\10min controls'};
days = [1:4; 5:8; 1:4]; %days to analyze

plotcolors = {'k', 'r', 'b'};

figure
for n = 1:length(rootdirs)
    [condition(n).allpuncta, roi] = parse_trajectory(rootdirs{n}, days(n,:));
    all_lifetimes = [];
    for k = roi
        all_lifetimes = cat(2, all_lifetimes, condition(n).allpuncta(k).lifetimes);
        all_cumhist = condition(n).allpuncta(k).cumhist;
        plot(all_cumhist(1:end-1), plotcolors{n}); ylim([0 1]); hold on;
        title(['Trajectory lifetimes over day ' mat2str(days(n,:))]);
        fitx = 0:(size(all_cumhist,1)-2);
        fity = all_cumhist(1:end-1)'; %dont fit to single puncta (non trajectory puncta)
        condition(n).allpuncta(k).fitcoeffs = polyfit(fitx, fity, 1);
        stats(n).slopes(k) = condition(n).allpuncta(k).fitcoeffs(1);
        clear all_cumhist
    end
    condition(n).length = pathlengths(condition(n).allpuncta);
    condition(n).all_lifetimes = all_lifetimes;
    clear all_lifetimes
end

%%%% plotting %%%%
figure;
for n = 1:length(rootdirs)
    h = cdfplot(condition(n).length); hold on;
    %h = get(gca, 'children');
    set(h,'Color',plotcolors{n});
    xlim([0 10]);
end
%boxplot(slopes, 'colors', 'krb', 'notch', 'on');
names = [repmat({'group1'}, length(stats(1).slopes), 1); repmat({'group2'}, length(stats(2).slopes), 1);...
    repmat({'control'}, length(stats(3).slopes), 1)];
[p,table,stats] = anova1([stats(1).slopes'; stats(2).slopes'; stats(3).slopes'], names);
figure; c = multcompare(stats);
