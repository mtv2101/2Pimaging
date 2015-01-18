function [ALLDAYS, ALLBLOCKS] = beh_stats(ALLDAYS, ALLBLOCKS,...
    allblocks_parsed, post_x, pre_x, sig_win, alpha, postframes, preframes,...
    group1_data, group2_data)

fields = fieldnames(allblocks_parsed);
dat = [];
hasdata = zeros(1,numel(fields));
for n = 1:numel(fields) % for each odor/behavior pair
    if size(allblocks_parsed.(fields{n}), 1) > 3 %only consider those with more than 3 trials
        hasdata(n) = 1;
    end
end

for r = 1:size(ALLBLOCKS(1).dff, 3) %for each roi
    baseline = 20:preframes; %start at frame 20 to avoid trial-start evoked activity
    for n=1:numel(fields)
        if hasdata(n) == 0
            ALLDAYS.stats(r).p(:,n) = nan(pre_x+post_x,1);
            ALLDAYS.stats(r).sig_behaviors(:,n) = nan;
            ALLDAYS.stats(r).sig_times(:,n) = nan;
            ALLDAYS.stats(r).mean_times(:,n) = nan;
            ALLDAYS.stats(r).sem_times(:,n) = nan;
            continue
        else
            for w = 1:pre_x+post_x
                winstart = 1:sig_win:(preframes+postframes);
                indx = winstart(w):(winstart(w)+sig_win-1);
                roi_dat = allblocks_parsed.(fields{n}); % [trial, frame, roi]
                roid_base = nanmean(roi_dat(:,baseline,r),2); %get mean df/f in timewindow "baseline"
                roid_sig = nanmean(roi_dat(:,indx,r),2); %get mean df/f in timewindow "indx"
                [h(w,n), beh_tune_p] = ttest2(roid_sig,roid_base);
                ALLDAYS.stats(r).p(w,n) = beh_tune_p;
                ALLDAYS.stats(r).sig_times(w,n) = h(w,n);
                ALLDAYS.stats(r).mean_times(w,n) = nanmean(roid_sig);
                ALLDAYS.stats(r).sem_times(w,n) = std(roid_sig)/sqrt(length(roid_sig));
                clear roi_dat roid_base roid_sig
            end 
            if any(ALLDAYS.stats(r).p < alpha) %if there are any chunks of time where a behavioral response is sig different
                ALLDAYS.stats(r).sig_behaviors(n) = 1;
            else
                ALLDAYS.stats(r).sig_behaviors(n) = 0;
            end
        end
    end
    
end
