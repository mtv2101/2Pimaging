clear all;

rootdirs = {'C:\Users\supersub\Desktop\Data\text files\2cutoff 8disp\all_latden',...
    'C:\Users\supersub\Desktop\Data\text files\1cutoff 8disp\all_latden',...
    'C:\Users\supersub\Desktop\Data\text files\0.7cutoff 8disp\all_latden',...
    'C:\Users\supersub\Desktop\Data\text files\0.5cutoff 8disp\all_latden',...
    'C:\Users\supersub\Desktop\Data\text files\0.3cutoff 8disp\all_latden'};
days = [1:4; 1:4; 1:4; 1:4; 1:4]; %days to analyze
groupnames = {'2.0cutoff 8disp', '1.0cutoff 8disp', '0.7cutoff 8disp', '0.5cutoff 8disp', '0.3cutoff 8disp'}; %these names have to be the same number of characters

%% plotcolors = {'k', 'r', 'b'};
plotcolors = [31 119 180; 255 127 14; 44 160 44; 214 39 40; 148 103 189; 140 86 75;...
    227 119 194; 127 127 127; 188 189 34; 23 190 207]./255; % Tableau 10 Palette

figure
for n = 1:length(rootdirs)
    [condition(n).allpuncta, roi] = parse_trajectory(rootdirs{n}, days(n,:));
    all_lifetimes = [];
    for k = roi
        all_lifetimes = cat(2, all_lifetimes, condition(n).allpuncta(k).lifetimes);
        all_cumhist = condition(n).allpuncta(k).cumhist;
        plot(all_cumhist(1:end-1), 'Color', plotcolors(n,:)); ylim([0 1]); hold on;
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
    set(h,'Color',plotcolors(n,:));
    xlim([0 10]);
end
%boxplot(slopes, 'colors', 'krb', 'notch', 'on');
names = [repmat(groupnames{1}, length(stats(1).slopes), 1); repmat(groupnames{2}, length(stats(2).slopes), 1);...
    repmat(groupnames{3}, length(stats(3).slopes), 1); repmat(groupnames{4}, length(stats(4).slopes), 1);...
    repmat(groupnames{5}, length(stats(5).slopes), 1)];
[p,table,stats] = anova1([stats(1).slopes'; stats(2).slopes'; stats(3).slopes'; stats(4).slopes'; stats(5).slopes'], names);
figure; c = multcompare(stats);
