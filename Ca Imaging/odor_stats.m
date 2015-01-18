function [ALLDAYS, ALLBLOCKS] = odor_stats(ALLBLOCKS, sig_win,...
    post_x,pre_x, alpha, postframes, preframes, group1_data, group2_data)

%%%%%% find rois with significant responses relative to baseline
%%%%%% find rois with sig responses between two odors
for r = 1:size(ALLBLOCKS(1).dff, 3) %for each roi
    baseline = 1:preframes;
    dffbase_o1 = nanmean(group1_data(:, baseline, r), 2);
    dffbase_o2 = nanmean(group2_data(:, baseline, r), 2);
    for w = 1:pre_x+post_x
        winstart = 1:sig_win:(preframes+postframes);
        indx = winstart(w):(winstart(w)+sig_win-1);
        % sig rel to baseline
        [h_testo1(r,w), p_testo1(r,w)] = ttest2(dffbase_o1,...
            nanmean(group1_data(:, indx, r), 2), 'alpha', alpha);
        [h_testo2(r,w), p_testo2(r,w)] = ttest2(dffbase_o2,...
            nanmean(group2_data(:, indx, r), 2), 'alpha', alpha);
        o1stat = nanmean(group1_data(:, indx, r),2);
        o2stat = nanmean(group2_data(:, indx, r),2);
        % sig between two odors
        [h_tuned(r,w), p(r,w)] = ttest2(o1stat, o2stat, 'alpha', alpha);
    end
    ALLDAYS.stats(r).sig_o1all = h_testo1(r,:)';
    ALLDAYS.stats(r).sig_o2all = h_testo2(r,:)';
    ALLDAYS.stats(r).sig_odortuned = h_tuned(r,:)';
end
end