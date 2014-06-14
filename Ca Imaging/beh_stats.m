function [ALLDAYS, ALLBLOCKS] = beh_stats(day, ALLDAYS, ALLBLOCKS,...
    allblocks_parsed, post_x, pre_x, sig_win, alpha, postframes, preframes)

fields = fieldnames(allblocks_parsed);
dat = [];
hasdata = zeros(1,numel(fields));
for n = 1:numel(fields) % for each odor/bnehavior pair
    if size(allblocks_parsed.(fields{n}), 1) > 3 %only consider those with more than 3 trials
        hasdata(n) = 1;
    end
end

for r = 1:size(allblocks_parsed.(fields{1}), 3) %for each roi
    baseline = 20:preframes; %start at frame 20 to avoid trial-start evoked activity
    for n=1:numel(fields)
        if hasdata(n) == 0
            ALLDAYS(day).stats(r).p(:,n) = nan(pre_x+post_x,1);
            ALLDAYS(day).stats(r).sig_behaviors(:,n) = nan;
            ALLDAYS(day).stats(r).sig_times(:,n) = nan;
            ALLDAYS(day).stats(r).mean_times(:,n) = nan;
            ALLDAYS(day).stats(r).sem_times(:,n) = nan;
            continue
        else
            for w = 1:pre_x+post_x
                winstart = 1:sig_win:(preframes+postframes);
                indx = winstart(w):(winstart(w)+sig_win-1);
                roi_dat = allblocks_parsed.(fields{n}); % [trial, frame, roi]
                roid_base = nanmean(roi_dat(:,baseline,r),2); %get mean df/f in timewindow "baseline"
                roid_sig = nanmean(roi_dat(:,indx,r),2); %get mean df/f in timewindow "indx"
                [h(w,n), beh_tune_p] = ttest2(roid_sig,roid_base);
                ALLDAYS(day).stats(r).p(w,n) = beh_tune_p;
                ALLDAYS(day).stats(r).sig_times(w,n) = h(w,n);
                ALLDAYS(day).stats(r).mean_times(w,n) = nanmean(roid_sig);
                ALLDAYS(day).stats(r).sem_times(w,n) = std(roid_sig)/sqrt(length(roid_sig));
                clear roi_dat roid_base roid_sig
            end 
            if any(ALLDAYS(day).stats(r).p < alpha) %if there are any chunks of time where a behavioral response is sig different
                ALLDAYS(day).stats(r).sig_behaviors(n) = 1;
            else
                ALLDAYS(day).stats(r).sig_behaviors(n) = 0;
            end
        end
    end
    
end

%
% b1_mean = squeeze(nanmean(nanmean(allblock_b1,1), 3));
% b2_mean = squeeze(nanmean(nanmean(allblock_b2,1), 3));
% b3_mean = squeeze(nanmean(nanmean(allblock_b3,1), 3));
% b4_mean = squeeze(nanmean(nanmean(allblock_b4,1), 3));
%
% b1_std = squeeze(std(nanmean(allblock_b1,1), [], 3));
% b2_std = squeeze(std(nanmean(allblock_b2,1), [], 3));
% b3_std = squeeze(std(nanmean(allblock_b3,1), [], 3));
% b4_std = squeeze(std(nanmean(allblock_b4,1), [], 3));
%
% for n = 1:length(ALLBLOCKS)
%     figure;
%     shadedErrorBar([], b1_mean(:,n), b1_std/sqrt(size(allblock_b1,3)),...
%         {'color', [.5, .5, 1]}, 1);hold on;
%     shadedErrorBar([], b2_mean(:,n), b2_std/sqrt(size(allblock_b2,3)),...
%         {'color', [1, 0.5, 0.2]}, 1);hold on;
%     shadedErrorBar([], b3_mean(:,n), b3_std/sqrt(size(allblock_b3,3)),...
%         {'color', [0, .8, 1]}, 1);hold on;
%     shadedErrorBar([], b4_mean(:,n), b4_std/sqrt(size(allblock_b4,3)),...
%         {'color', [0.2, 0.2, 0.2]}, 1);hold on;
%     legend('HIT',  'CR', 'FA', 'MISS');
% end

