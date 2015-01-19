function [ALLDAYS, ALLBLOCKS] = beh_stats(ALLDAYS, ALLBLOCKS,...
    post_x, pre_x, sig_win, postframes, preframes,...
    group1_data, group2_data)

for r = 1:size(ALLBLOCKS(1).dff, 3) %for each roi
    %baseline = 1:preframes; %start at frame 20 to avoid trial-start evoked activity
    for w = 1:pre_x+post_x
        winstart = 1:sig_win:(preframes+postframes);
        indx = winstart(w):(winstart(w)+sig_win-1);
        %roi_dat = allblocks_parsed.(fields{n}); % [trial, frame, roi]
        group1_sig = nanmean(group1_data(:,indx,r),2); %get mean df/f in timewindow
        group2_sig = nanmean(group2_data(:,indx,r),2); %get mean df/f in timewindow
        [h(w), beh_tune_p] = ttest2(group1_sig,group2_sig);
        ALLDAYS.stats(r).p(w) = beh_tune_p;
        ALLDAYS.stats(r).sig_times(w) = h(w);
        ALLDAYS.stats(r).mean_times_gp1(w) = nanmean(group1_sig);
        ALLDAYS.stats(r).sem_times_gp1(w) = nanstd(group1_sig)/sqrt(length(group1_sig));
        ALLDAYS.stats(r).mean_times_gp2(w) = nanmean(group2_sig);
        ALLDAYS.stats(r).sem_times_gp2(w) = nanstd(group2_sig)/sqrt(length(group2_sig));
    end     
end
