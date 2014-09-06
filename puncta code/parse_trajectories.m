clear all;

rootdirs = {'C:\Users\supersub\Desktop\Data\text files\1cutoff 8disp\all_latden_nonenriched\',...
    'C:\Users\supersub\Desktop\Data\text files\1cutoff 8disp\all_latden_nonenriched\',...
    'C:\Users\supersub\Desktop\Data\text files\1cutoff 8disp\10min_control\'};
days = [1:4; 5:8; 1:4]; %days to analyze
groupnames = {'first4' 'last_4' 'cntrol'}; %these names must be the same number of characters

%% plotcolors = {'k', 'r', 'b'};
plotcolors = [31 119 180; 255 127 14; 44 160 44; 214 39 40; 148 103 189; 140 86 75;...
    227 119 194; 127 127 127; 188 189 34; 23 190 207]./255; % Tableau 10 Palette

figure
for n = 1:length(rootdirs)
    [condition(n).allpuncta, roi] = parse_trajectory(rootdirs{n}, days(n,:));
    all_lifetimes = [];
    for k = roi
        all_lifetimes = cat(2, all_lifetimes, condition(n).allpuncta(k).lifetimes);
        all_cumhist{k,n} = condition(n).allpuncta(k).cumhist;
        pp{k,n} = condition(n).allpuncta(k).percent_persistant;
        cumhist = condition(n).allpuncta(k).cumhist;
        lifetimeplot(k,n) = plot(cumhist(1:end), 'Color', plotcolors(n,:)); ylim([0 1]); hold on;
        title(['Trajectory lifetimes over day ' mat2str(days(n,:))]);
        fitx = 2:(size(cumhist,1));
        fity = cumhist(2:end)';
        condition(n).allpuncta(k).fitcoeffs = polyfit(fitx, fity, 1); %linear fit
        stats(n).slopes(k) = condition(n).allpuncta(k).fitcoeffs(1);
        clear cumhist
    end
    condition(n).length = pathlengths(condition(n).allpuncta);
    condition(n).all_lifetimes = all_lifetimes;
    clear all_lifetimes
    %legend(groupnames{n}, 'Location', 'SouthWest', 'TextColor', plotcolors(n));
end

% rearrange cumulative histogram data into group x day cell array 
% this makes it much easier to run stats
for i = 2:size(days,2) %we will ignore the first day of a trajectory which is always observed   
    for n = 1:length(rootdirs)    
        onegroup_cumhist = {};
        for k = 1:size(all_cumhist,1) 
            cumhist = all_cumhist{k,n};
            %for c = 2:length(cumhist) %not all cumhistograms ahve hte same number of values - i.e. conditions may make just be one or two observations
            if length(all_cumhist{k,n}) >=i
                onegroup_cumhist = cat(1, onegroup_cumhist, cumhist(i));
            else continue
            end
        end
        allgroup_cumhist{n,i} = onegroup_cumhist; clear onegroup_cumhist;
    end    
end

% do the same for percent persistant puncta
for i = 2:size(days,2) %we will ignore the first day of a trajectory which is always observed   
    for n = 1:length(rootdirs)    
        onegroup_pp = {};
        for k = 1:size(pp,1)          
            pp_re = pp{k,n};
            %for c = 2:length(cumhist) %not all cumhistograms ahve hte same number of values - i.e. conditions may make just be one or two observations
            if length(pp{k,n}) >=i
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
    legend(groupnames{n}); legend boxoff;
    set(h,'Color',plotcolors(n,:));
    xlim([0 12]);
end

%plot box plots of all cumulative lifetime values
% for i = 2:size(days,2)
%     for n = 1:length(rootdirs)    
%         if n == 1
%             proplife_names = repmat(groupnames{n}, length(allgroup_cumhist{n,i}), 1);
%             proplife = [(allgroup_cumhist{n,i})];
%         else
%             proplife_names = vertcat(proplife_names, repmat(groupnames{n}, length(allgroup_cumhist{n,i}), 1));
%             proplife = vertcat(proplife, [(allgroup_cumhist{n,i})]);
%         end
%     end
%     all_proplife{:,i} = proplife; clear proplife;
%     all_proplife_names{:,i} = proplife_names; clear propsingle_names;
%     anova1(cell2mat(all_proplife{:,i}), all_proplife_names{:,i});
% end
figure;
for n = 1:size(allgroup_cumhist, 1)  
    for i = 2:size(allgroup_cumhist, 2)
        mean_proplife(n,i-1) = mean(cell2mat(allgroup_cumhist{n,i}));
        sem_proplife(n,i-1) = std(cell2mat(allgroup_cumhist{n,i}))/sqrt(length(allgroup_cumhist{n,i}));        
    end
    errorbar(mean_proplife(n,:), sem_proplife(n,:), 'color',  plotcolors(n,:)); hold on;
    ylim([0 1]);
end

%plot percentage of persistant puncta
figure;
for n = 1:size(persistant_puncta, 1)
    for i = 2:size(persistant_puncta, 2)
        mean_pp(n,i-1) = mean(cell2mat(persistant_puncta{n,i}));
        sem_pp(n,i-1) = std(cell2mat(persistant_puncta{n,i}))/sqrt(length(persistant_puncta{n,i}));
    end
    errorbar(mean_pp(n,:), sem_pp(n,:), 'color',  plotcolors(n,:)); hold on;
    ylim([0 1]);
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
[singles_p, singles_table, singles_stats] = anova1(anova_singles, propsingle_names);
%singles_multcompare = multcompare(singles_stats);

for n = 1:length(rootdirs)
    if n == 1
        slope_names = repmat(groupnames{n}, length(stats(n).slopes),1);
        anova_slopes = stats(n).slopes';
    else
        slope_names = vertcat(slope_names, repmat(groupnames{n}, length(stats(n).slopes),1));
        anova_slopes = vertcat(anova_slopes, stats(n).slopes');
    end    
end
[slopes_p, slopes_table, slopes_stats] = anova1(anova_slopes, slope_names);
%slopes_multcompare = multcompare(slopes_stats);
