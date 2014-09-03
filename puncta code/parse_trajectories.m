clear all;

rootdirs = {'C:\Users\supersub\Desktop\Data\text files\1cutoff 4disp\all_latden',...
    'C:\Users\supersub\Desktop\Data\text files\1cutoff 6disp\all_latden',...
    'C:\Users\supersub\Desktop\Data\text files\1cutoff 8disp\all_latden',...
    'C:\Users\supersub\Desktop\Data\text files\1cutoff 10disp\all_latden',...
    'C:\Users\supersub\Desktop\Data\text files\1cutoff 12disp\all_latden'};
days = [1:4; 1:4; 1:4; 1:4; 1:4]; %days to analyze
groupnames = {'4 disp' '6 disp' '8 disp' '10disp' '12disp'}; %these names must be the same number of characters

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
        plot(all_cumhist(1:end), 'Color', plotcolors(n,:)); ylim([0 1]); hold on;
        title(['Trajectory lifetimes over day ' mat2str(days(n,:))]);
        fitx = 2:(size(all_cumhist,1));
        fity = all_cumhist(2:end)'; %dont fit to single puncta (non trajectory puncta)
        condition(n).allpuncta(k).fitcoeffs = polyfit(fitx, fity, 1); %linear fit
        stats(n).slopes(k) = condition(n).allpuncta(k).fitcoeffs(1);
        clear all_cumhist
    end
    condition(n).length = pathlengths(condition(n).allpuncta);
    condition(n).all_lifetimes = all_lifetimes;
    clear all_lifetimes
end

%%%% plotting %%%%
%plot all cum lifetimes
figure;
for n = 1:length(rootdirs)
    h = cdfplot(condition(n).length); hold on;
    set(h,'Color',plotcolors(n,:));
    xlim([0 12]);
end

%plot all proportion of singles
for n = 1:length(rootdirs)
    if n == 1
        propsingle_names = repmat(groupnames{n}, length([condition(n).allpuncta.propsingle]), 1);
        anova_singles = [condition(n).allpuncta.propsingle]';
    else
        propsingle_names = vertcat(propsingle_names, repmat(groupnames{n}, length([condition(n).allpuncta.propsingle]), 1));
        anova_singles = vertcat(anova_singles, [condition(n).allpuncta.propsingle]');
    end
end
singles_p = anova1(anova_singles, propsingle_names);

for n = 1:length(rootdirs)
    if n == 1
        slope_names = repmat(groupnames{n}, length(stats(n).slopes),1);
        anova_slopes = stats(n).slopes';
    else
        slope_names = vertcat(slope_names, repmat(groupnames{n}, length(stats(n).slopes),1));
        anova_slopes = vertcat(anova_slopes, stats(n).slopes');
    end    
end
slopes_p = anova1(anova_slopes, slope_names);
