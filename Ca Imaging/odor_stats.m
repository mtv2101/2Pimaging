function [ALLDAYS, ALLBLOCKS] = odor_stats(day, ALLBLOCKS, allblocks_parsed, sig_win,...
    post_x,pre_x, alpha, postframes, preframes)

allblock_o1 = cat(1, allblocks_parsed.o1b1, allblocks_parsed.o1b2,...
    allblocks_parsed.o1b3, allblocks_parsed.o1b4);
allblock_o2 = cat(1, allblocks_parsed.o2b1, allblocks_parsed.o2b2,...
    allblocks_parsed.o2b3, allblocks_parsed.o2b4);


%%%%%% find rois with significant responses relative to baseline
%%%%%% find rois with sig responses between two odors
for r = 1:size(allblocks_parsed.o1b1, 3) %for each roi
    baseline = 1:preframes;
    dffbase_o1 = nanmean(allblock_o1(:, baseline, r), 2);
    dffbase_o2 = nanmean(allblock_o2(:, baseline, r), 2);
    for w = 1:pre_x+post_x
        winstart = 1:sig_win:(preframes+postframes);
        indx = winstart(w):(winstart(w)+sig_win-1);
        % sig rel to baseline
        [h_testo1(r,w), p_testo1(r,w)] = ttest2(dffbase_o1,...
            nanmean(allblock_o1(:, indx, r), 2), 'alpha', alpha);
        [h_testo2(r,w), p_testo2(r,w)] = ttest2(dffbase_o2,...
            nanmean(allblock_o2(:, indx, r), 2), 'alpha', alpha);
        o1stat = nanmean(allblock_o1(:, indx, r),2);
        o2stat = nanmean(allblock_o2(:, indx, r),2);
        % sig between two odors
        [h_tuned(r,w), p(r,w)] = ttest2(o1stat, o2stat, 'alpha', alpha);
    end
    ALLDAYS(day).stats(r).sig_o1all = h_testo1(r,:)';
    ALLDAYS(day).stats(r).sig_o2all = h_testo2(r,:)';
    ALLDAYS(day).stats(r).sig_odortuned = h_tuned(r,:)';
end


% %%%%% find rois that have different responses between the two odors
% for b = 1:length(ALLBLOCKS)
%     for r = 1:size(ALLBLOCKS(b).tune_sigs,1) %for each roi
%         if ~any(ALLBLOCKS(b).tune_sigs(r,:) < alpha) %if there are no sig frames
%             has_tune(r) = 0; %there are no sig frames
%         else
%             has_tune(r) = 1;
%         end
%         if ~any(ALLBLOCKS(b).o1response_sigs(r,:) < alpha)
%             has_respo1(r) = 0;
%         else
%             has_respo1(r) = 1;
%         end
%         if ~any(ALLBLOCKS(b).o2response_sigs(r,:) < alpha)
%             has_respo2(r) = 0;
%         else
%             has_respo2(r) = 1;
%         end
%     end
%     all_tune_sigs(:,:,b) = ALLBLOCKS(b).tune_sigs;
%     o1_resp_sigs(:,:,b) = ALLBLOCKS(b).o1response_sigs;
%     o2_resp_sigs(:,:,b) = ALLBLOCKS(b).o2response_sigs;
%     ALLBLOCKS(b).sigtab = table(has_tune', has_respo1', has_respo2',...
%         'VariableNames', {'has_tune' 'has_respo1' 'has_respo2'});
% end

%%%%%% describe timecourse of ROIS over all trials
% cat_allblock_o1 = [];
% cat_allblock_o2 = [];
% for k = 1:size(allblock_o1,4)
%     cat_allblock_o1 = cat(1, cat_allblock_o1, allblock_o1(:,:,:,k));
%     cat_allblock_o2 = cat(1, cat_allblock_o2, allblock_o2(:,:,:,k));
% end
% for m = 1:size(cat_allblock_o1,3) %for each roi
%     win1 = [1:80]; %baseline
%     win2 = [90:100]; %pre-odor
%     win3 = [100:150]; %odor
%     win4 = [150:200]; %post-odor
%     trend_o1(:,:,m) = [squeeze(nanmean(cat_allblock_o1(:,win1,m),2)),...
%         squeeze(nanmean(cat_allblock_o1(:,win2,m),2)),...
%         squeeze(nanmean(cat_allblock_o1(:,win3,m),2)),...
%         squeeze(nanmean(cat_allblock_o1(:,win4,m),2))];
%     trend_o2(:,:,m) = [squeeze(nanmean(cat_allblock_o2(:,win1,m),2)),...
%         squeeze(nanmean(cat_allblock_o2(:,win2,m),2)),...
%         squeeze(nanmean(cat_allblock_o2(:,win3,m),2)),...
%         squeeze(nanmean(cat_allblock_o2(:,win4,m),2))];
% end

% plot_odors(rootdir, odor1, odor2, sortrespo_indx, has_respo1_sort,...
%   has_respo2_sort, allblock_o1, allblock_o2,...
%  sort_respo1_sigs, sort_respo2_sigs, has_tune, ALLROI)

end