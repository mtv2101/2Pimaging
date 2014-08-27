clear all;

rootdirs = {'C:\Users\supersub\Desktop\Data\text files\TC lateral enriched',...
    'C:\Users\supersub\Desktop\Data\text files\TC lateral non-enriched',...
    'C:\Users\supersub\Desktop\Data\text files\10min controls'};
days = [1:8]; %days to analyze

plotcolors = {'k', 'r', 'b'};

for d = 1:size(days,1)
    figure
    for n = 1:length(rootdirs)
        [condition(n).allpuncta, roi] = parse_trajectory(rootdirs{n}, days(d,:));
        all_lifetimes = [];
        for k = roi
            all_lifetimes = cat(2, all_lifetimes, condition(n).allpuncta(k).lifetimes);
            all_cumhist = condition(n).allpuncta(k).cumhist;
            plot(all_cumhist(1:end-1), plotcolors{n}); ylim([0 1]); hold on;
                title(['Lifetime of puncta day ' mat2str(days(d,:))]);
            fitx = 1:(size(all_cumhist,1)-2);
            fity = all_cumhist(2:end-1)'; %dont fit to single puncta (non trajectory puncta)
            condition(n).allpuncta(k).fitcoeffs = polyfit(fitx, fity, 1);
            clear all_cumhist
        end
    condition(n).length = pathlengths(condition(n).allpuncta);
    condition(n).all_lifetimes = all_lifetimes;
    clear all_lifetimes
    end
end

figure;
for n = 1:length(rootdirs)
    h = cdfplot(condition(n).length); hold on;    
    %h = get(gca, 'children');
    set(h,'Color',plotcolors{n});   
    xlim([0 10]);    
end
