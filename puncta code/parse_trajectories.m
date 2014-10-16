clear all;

warning('off','all');

rootdirs = {'C:\Users\supersub\Desktop\Data\text files\0.5cutoff 8disp\all_latden\',...
    'C:\Users\supersub\Desktop\Data\text files\0.7cutoff 8disp\all_latden\',...
     'C:\Users\supersub\Desktop\Data\text files\1cutoff 8disp\all_latden\',...
     'C:\Users\supersub\Desktop\Data\text files\2cutoff 8disp\all_latden\'};%,...
%     'C:\Users\supersub\Desktop\Data\text files\1cutoff 8disp\all_latden\',...

days = [1:8; 1:8; 1:8; 1:8];%; 1:4; 5:8]; % days to analyze, lengths must be the same
groupnames = {'0.5' '0.7' '1.0' '2.0'}; %these names must contain the same number of characters

SUBTRACT_CONTROL = 1; 
control_group = 4; % which rootdir contains the control data

% re 10 color Palette
blue = [31 119 180]./255;
orange = [255 127 14]./255;
green = [44 160 44]./255;
red = [214 39 40]./255;
purple = [148 103 189]./255;
brown = [140 86 75]./255;
pink = [227 119 194]./255;
grey = [127 127 127]./255;
avocado = [188 189 34]./255;
teal = [23 190 207]./255;
plotcolors = [grey; blue; red; orange; brown; green; teal; grey];

% Choose plots
PLOT_PLI = 0; % puncta brightness over lifetime
PLOT_LIFETIMES = 0;
PUNCTA_PEAKS = 0;
PLOT_CUMLIFE = 0;
PUNCTA_DAYS = 0;
PLOT_PERSIST_PUNCTA = 0;
PLOT_NLDAYS = 1;
PLOT_NLRATIO = 0;
PLOT_SINGLES = 0;
PLOT_SLOPES = 0;

for n = 1:length(rootdirs)
    [condition(n).allpuncta, roi] = parse_trajectory(rootdirs{n}, days(n,:));
    roi_it = 1;
    for k = roi
        all_pp{k,n} = condition(n).allpuncta(k).percent_persistant;
        pp = condition(n).allpuncta(k).percent_persistant;
        if PLOT_LIFETIMES == 1
            lifetimeplot(roi_it,n) = plot(pp(1:end), 'Color', plotcolors(n,:)); ylim([0 1]); hold on;
            title(['Trajectory lifetimes over day ' mat2str(days(n,:))]);
        end
        fitx = 1:(length(pp));
        fity = pp(1:end);
        condition(n).allpuncta(k).fitcoeffs = polyfit(fitx, fity, 1); %linear fit
        stats(n).slopes(roi_it) = condition(n).allpuncta(k).fitcoeffs(1);
        roi_it = roi_it+1; %because some rois dont exist in the time window, "roi" specifies which ones are valid.
    end
    [condition(n).length, condition(n).theta] = pathlengths(condition(n).allpuncta); %function pathlengths
    clear all_lifetimes
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

% get average number puncta per day
for n = 1:length(rootdirs)
    for p = 1:length(condition(n).allpuncta)
        mean_puncta(p) = mean(condition(n).allpuncta(p).totalpuncta);
    end
    all_mean_puncta{n} = mean_puncta;
    clear mean_puncta
end

% get puncta images analysis values
for n = 1:length(rootdirs)
   [img_dat(n)] = analyze_punctaimages(condition(n).allpuncta);
end
        
%%%% plotting %%%%

% plot puncta brightness trends over lifetime
if PLOT_PLI == 1
    blech = fieldnames(img_dat);
    blech_names = {'first_peak'; 'secnd_peak'; 'third_peak'; 'four_peak '; 'five_peak '; 'six_peak  '; 'last_peak '; 'stablepeak'};
    blech_idx = [4,7]; % index of where these data occur in "img_dat"
    for n = 1:length(rootdirs)
        figure;
        for b = 1:length(blech_idx)
            idx = blech_idx(b);
            if b == 1
                names_punctlifeimg = repmat(blech_names{b}, length(img_dat(n).(blech{idx})), 1);
                anova_punctlifeimg = img_dat(n).(blech{idx})';
            else
                names_punctlifeimg = vertcat(names_punctlifeimg, repmat(blech_names{b}, length(img_dat(n).(blech{idx})), 1));
                anova_punctlifeimg = vertcat(anova_punctlifeimg, img_dat(n).(blech{idx})');
            end
            punctalife(n).fields{b} = img_dat(n).(blech{idx})';
            [f, x] = ecdf(img_dat(n).(blech{idx})');
            plot(x, f, 'color',  plotcolors(b,:)); hold on;
        end
        %[pli_p, pli_table, pli_stats] = anova1(anova_punctlifeimg, names_punctlifeimg, 'color', plotcolors);
        %figure;boxplot(anova_punctlifeimg, names_punctlifeimg, 'notch', 'off', 'color', plotcolors);
        %ylim([0 255]);
        %multcompare(pli_stats);
        clear anova_punctlifeimg names_punctlifeimg
    end
end

% plot image peak ecdf
if PUNCTA_PEAKS == 1
    figure;
    for n = 1:length(rootdirs)
        [f{n}, x{n}] = ecdf(img_dat(n).mean_peak);
        plot(x{n}, f{n}, 'color',  plotcolors(n,:)); hold on;
        xlim([0 255]);
    end
end

% plot intensity over days for each group
if PUNCTA_DAYS == 1
    for n = 1:length(rootdirs)
        img_perday = img_dat(n).img_perday;
        for d = 1:size(img_perday,2) % for each day            
            for r = 1:size(img_perday(d).allimages, 3) % for each roi
                m(r) = mean(mean(img_perday(d).allimages(5:7, 5:7, r),2),1);
            end
            if d == 1
                id_names = repmat(['day ', mat2str(d)], length(m), 1);
                anova_id = m';
            else
                id_names = vertcat(id_names, repmat(['day ', mat2str(d)], length(m), 1));
                anova_id = vertcat(anova_id, m');
            end
            [f, x] = ecdf(m);
            plot(x, f, 'color',  plotcolors(d,:)); hold on;
            day_intensities(n).m{d} = m;
            clear m x f
        end
        %figure;boxplot(anova_id, id_names, 'color', plotcolors);
        %ylim([0 255]);
        %img_perday(n).anova_id = anova_id;
        clear anova_id id_names img_perday
    end
end

%plot all trajectory lengths
if PLOT_CUMLIFE == 1
    figure;
    for n = 1:length(rootdirs)
        h = cdfplot(condition(n).length); hold on;
        set(h,'Color',plotcolors(n,:));
        xlim([0 12]);
    end
end

%plot percentage of persistant puncta
if PLOT_PERSIST_PUNCTA == 1
    for n = 1:size(persistant_puncta, 1)
        for i = 1:size(persistant_puncta, 2)
            mean_pp(n,i) = mean(cell2mat(persistant_puncta{n,i}));
            sem_pp(n,i) = std(cell2mat(persistant_puncta{n,i}))/sqrt(length(persistant_puncta{n,i}));
        end
        errorbar(mean_pp(n,:), sem_pp(n,:), 'color',  plotcolors(n,:)); hold on;
        ylim([0 1]);
    end
end

% get %new per day and %lost per day
if PLOT_NLDAYS == 1
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
        newday_lin = nanmean(new_daily,2);
        %newday_lin = newday_lin(:);
        newday_lin = newday_lin(~isnan(newday_lin)); %remove NaNs
        lostday_lin = nanmean(lost_daily,2);
        %lostday_lin = lostday_lin(:);
        lostday_lin = lostday_lin(~isnan(lostday_lin));
        if n == 1
            newday_names = repmat(groupnames{n}, length(newday_lin), 1);
            newday_anova = newday_lin;
            lostday_names = repmat(groupnames{n}, length(lostday_lin), 1);
            lostday_anova = lostday_lin;
        else
            newday_names = vertcat(newday_names, repmat(groupnames{n}, length(newday_lin), 1));
            newday_anova = vertcat(newday_anova, newday_lin);
            lostday_names = vertcat(lostday_names, repmat(groupnames{n}, length(lostday_lin), 1));
            lostday_anova = vertcat(lostday_anova, lostday_lin);
        end
        if SUBTRACT_CONTROL == 1
            if n == control_group
                ctl_new = mean(newday_lin);
                newday_anova = newday_anova - ctl_new;
                ctl_lost = mean(lostday_lin);
                lostday_anova = lostday_anova - ctl_lost;
            end
        end
        clear new_daily lost_daily
    end
    figure;boxplot(newday_anova, newday_names, 'notch', 'off', 'color', plotcolors);
    newfig = gcf; title('Mean % new puncta created per day');
    figure;boxplot(lostday_anova, lostday_names, 'notch', 'off', 'color', plotcolors);
    lostfig = gcf; title('Mean % puncta lost per day');
    [new_p, new_table, new_stats] = anova1(newday_anova, newday_names, 'off');
    figure;new_multcompare = multcompare(new_stats);
    [lost_p, lost_table, lost_stats] = anova1(lostday_anova, lostday_names, 'off');
    figure;lost_multcompare = multcompare(lost_stats);
end

%plot all new/lost ratio
if PLOT_NLRATIO == 1
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
    figure;boxplot(anova_nl, nl_names, 'notch', 'off', 'color', plotcolors);
    [nl_p, nl_table, nl_stats] = anova1(anova_nl, nl_names, 'off');    
    figure; nl_multcompare = multcompare(nl_stats);
end

%plot all proportion of singles
if PLOT_SINGLES == 1
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
    figure;boxplot(anova_singles, propsingle_names, 'notch', 'off', 'color', plotcolors);
    [singles_p, singles_table, singles_stats] = anova1(anova_singles, propsingle_names, 'off');    
    figure; singles_multcompare = multcompare(singles_stats);
end

% plot the slopes of whatever survival/lifetime measurement was made above (ecdf or persistance)
if PLOT_SLOPES == 1
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
    figure;boxplot(anova_slopes, slope_names, 'notch', 'off', 'color', plotcolors);
    %anova_slopes_norm = anova_slopes - mean_base; % subtract mean value of short-term observations from daily observations
    [slopes_p, slopes_table, slopes_stats] = anova1(anova_slopes, slope_names, 'off');    
    figure; slopes_multcompare = multcompare(slopes_stats);
end
