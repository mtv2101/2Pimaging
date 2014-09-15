clear all;

warning('off','all');

rootdirs = {'C:\Users\supersub\Desktop\Data\text files\1cutoff 8disp\MCenriched\',...
    'C:\Users\supersub\Desktop\Data\text files\1cutoff 8disp\TCenriched\',...
    'C:\Users\supersub\Desktop\Data\text files\1cutoff 8disp\glomenriched\',...
    'C:\Users\supersub\Desktop\Data\text files\1cutoff 8disp\10min_control\'};%...
%     'C:\Users\supersub\Desktop\Data\text files\1cutoff 8disp\MCenriched\'};%,...    
%      'C:\Users\supersub\Desktop\Data\text files\1cutoff 8disp\ALLTC\',...
%      'C:\Users\supersub\Desktop\Data\text files\1cutoff 8disp\TC\',...
%      'C:\Users\supersub\Desktop\Data\text files\1cutoff 8disp\TCenriched\',...
%     'C:\Users\supersub\Desktop\Data\text files\1cutoff 8disp\10min_control\'};
days = [1:8; 1:8; 1:8; 1:8]; % days to analyze, lengths must be the same
groupnames = {'MCe' 'TCe' 'GLe' '10m'};% 'TCall' 'TCnon' 'TCenr' '10min'}; %these names must contain the same number of characters
%{'ALLMCbse' 'MCnonenr' 'MClast_4' 'ALLTCbse' 'TCnonenr' 'TClast_4' ' control'};
control_group = 7; % which rootdir contains the control data

%% plotcolors = {'k', 'r', 'b'};
plotcolors = [31 119 180; 255 127 14; 44 160 44; 214 39 40; 148 103 189; 140 86 75;...
    227 119 194]./255;%; 127 127 127; 188 189 34; 23 190 207]./255); % Tableau 10 Palette, reverse order
start_slope = 1; %day on which to start slope calculation.  Choose 2 to avoid day1-2 nonlinearity

figure
for n = 1:length(rootdirs)
    [condition(n).allpuncta, roi] = parse_trajectory(rootdirs{n}, days(n,:));
    %all_lifetimes = [];
    roi_it = 1;
    for k = roi       
        %all_lifetimes = cat(2, all_lifetimes, condition(n).allpuncta(k).lifetimes);
        %all_cumhist{k,n} = condition(n).allpuncta(k).cumhist;
        all_pp{k,n} = condition(n).allpuncta(k).percent_persistant;
        %cumhist = condition(n).allpuncta(k).cumhist;
        pp = condition(n).allpuncta(k).percent_persistant;
        lifetimeplot(roi_it,n) = plot(pp(1:end), 'Color', plotcolors(n,:)); ylim([0 1]); hold on;
        title(['Trajectory lifetimes over day ' mat2str(days(n,:))]);
        fitx = start_slope:(length(pp));
        fity = pp(start_slope:end);
        condition(n).allpuncta(k).fitcoeffs = polyfit(fitx, fity, 1); %linear fit
        stats(n).slopes(roi_it) = condition(n).allpuncta(k).fitcoeffs(1);
        clear cumhist
        roi_it = roi_it+1; %because some rois dont exist in the time window, "roi" specifies which ones are valid.
    end
    condition(n).length = pathlengths(condition(n).allpuncta);
    %condition(n).all_lifetimes = all_lifetimes;
    clear all_lifetimes
    %legend(groupnames{n}, 'Location', 'SouthWest', 'TextColor', plotcolors(n));
end

% do the same for percent persistant puncta
for i = 1:size(days,2) 
    for n = 1:length(rootdirs)    
        onegroup_pp = {};
        for k = 1:size(all_pp,1)          
            pp_re = all_pp{k,n};
            if length(all_pp{k,n}) >=i
                onegroup_pp = cat(1, onegroup_pp, pp_re(i));
            else continue
            end
        end
        persistant_puncta{n,i} = onegroup_pp; clear onegroup_pp;
    end    
end

%%%% plotting %%%%
%plot all cum lifetimes
figure;
for n = 1:length(rootdirs)
    h = cdfplot(condition(n).length); hold on;
    %legend(groupnames{n}); legend boxoff;
    set(h,'Color',plotcolors(n,:));
    xlim([0 12]);
end

%plot percentage of persistant puncta
figure;
for n = 1:size(persistant_puncta, 1)
    for i = 1:size(persistant_puncta, 2)
        mean_pp(n,i) = mean(cell2mat(persistant_puncta{n,i}));
        sem_pp(n,i) = std(cell2mat(persistant_puncta{n,i}))/sqrt(length(persistant_puncta{n,i}));
    end
    errorbar(mean_pp(n,:), sem_pp(n,:), 'color',  plotcolors(n,:)); hold on;
    ylim([0 1]);
end

% get %new per day and %lost per day
for n = 1:length(rootdirs)
    new_daily = NaN(length(condition(n).allpuncta), size(days,2));
    lost_daily = NaN(length(condition(n).allpuncta), size(days,2));
    for x = 1:length(condition(n).allpuncta)
        for d = 2:length(condition(n).allpuncta(x).new)-1
            new_daily(x,d) = condition(n).allpuncta(x).new(d) / condition(n).allpuncta(x).traj_perday(d);
            lost_daily(x,d) = condition(n).allpuncta(x).lost(d) / condition(n).allpuncta(x).traj_perday(d);
        end
    end
    mean_newday(:,n) = nanmean(new_daily(:,2:end-1),1);
    sem_newday(:,n) = nanstd(new_daily(:,2:end-1), [], 1)/sqrt(size(new_daily,1));
    subplot(2,1,1);errorbar(mean_newday(:,n), sem_newday(:,n), 'color', plotcolors(n,:)); hold on;
    mean_lday(:,n) = nanmean(lost_daily(:,2:end-1),1);
    sem_lday(:,n) = nanstd(lost_daily(:,2:end-1), [], 1)/sqrt(size(lost_daily,1));
    subplot(2,1,2);errorbar(mean_lday(:,n), sem_lday(:,n), 'color', plotcolors(n,:)); hold on;
end

%plot all new/lost ratio
for n = 1:length(rootdirs)
    r = 1;
        for x = 1:length(condition(n).allpuncta)
            if ~isempty(condition(n).allpuncta(x).new)
                ratio(r) = sum([condition(n).allpuncta(x).new]/[condition(n).allpuncta(x).lost],2); % get average ratio in day range
                r = r+1;
            end
        end
        if n == 1
            nl_names = repmat(groupnames{n}, length(ratio), 1);
            anova_nl = ratio';
        else
            nl_names = vertcat(nl_names, repmat(groupnames{n}, length(ratio), 1));
            anova_nl = vertcat(anova_nl, ratio');
        end
    clear ratio r
end
[nl_p, nl_table, nl_stats] = anova1(anova_nl, nl_names);
figure; nl_multcompare = multcompare(nl_stats);

%plot all proportion of singles
for n = 1:length(rootdirs)
    if n == 1
        propsingle_names = repmat(groupnames{n}, length([condition(n).allpuncta.propsingle]), 1);
        anova_singles = [condition(n).allpuncta.propsingle]';
    else
        %if ~isempty(anova_singles)
        propsingle_names = vertcat(propsingle_names, repmat(groupnames{n}, length([condition(n).allpuncta.propsingle]), 1));
        anova_singles = vertcat(anova_singles, [condition(n).allpuncta.propsingle]');
        %end
    end
end
[singles_p, singles_table, singles_stats] = anova1(anova_singles, propsingle_names);
%singles_multcompare = multcompare(singles_stats);

% plot the slopes of whatever survival/lifetime measurement was made above (ecdf or persistance)
for n = 1:length(rootdirs)
    if n == 1
        slope_names = repmat(groupnames{n}, length(stats(n).slopes),1);
        anova_slopes = stats(n).slopes';
    else
        %if ~isempty(stats(n).slopes)
        slope_names = vertcat(slope_names, repmat(groupnames{n}, length(stats(n).slopes),1));
        anova_slopes = vertcat(anova_slopes, stats(n).slopes');
        %end
%         if n == control_group
%             base_slopes = [stats(n).slopes];
%             mean_base = mean(base_slopes);
%         end
    end    
end
%anova_slopes_norm = anova_slopes - mean_base; % subtract mean value of short-term observations from daily observations
[slopes_p, slopes_table, slopes_stats] = anova1(anova_slopes, slope_names);
figure;slopes_multcompare = multcompare(slopes_stats);
