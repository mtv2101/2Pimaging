x = 2;
dat = ALLBLOCKS(x).dff;
takeforf0 = 0.2; 

% for r = 1:size(dat,3) %for each roi
%     dims = size(dat);
%     for t = 1:dims(1) %for each trial            
%         ft = squeeze(dat(t,:,r)); %timeseries
%         [ft_rank, ft_rank_idx] = sort(ft);
%         toget = ceil(length(ft)*takeforf0); %number of frames representing bottom fraction of data values
%         f0(t,r) = nanmean(ft_rank(1:toget));
%         df = (ft-f0(t,r))/f0(t,r); %df/f
%         alldff(t,:,r) = df;
%     end
% end

for r = 1:size(dat,3); %for each roi
    dims = size(dat);
    % pre-smoothing before baseline subtraction, which is necessary in low s/n
    % data, is very hard here because z-correction has created many NaNs
    % producing holes in the waveforms.  To solve this must fundamentally
    % change how z-correct editing is done which may be a very large
    % re-write.
%     for t = 1:dims(1); %for each trial                
%         smth_trials(t,:) = medfilt1(dat(t,:,r),10); %smooth individual trials before averaging
%         alltrial_base = nanmean(smth_trials(t,:), 1); % get mean of all roi trials to use as a baseline
%     end
    for t = 1:dims(1); %for each trial       
        ft = squeeze(dat(t,:,r)); %timeseries
        %ft = ft - alltrial_base; % subtract alltrial baseline 
        [ft_rank, ft_rank_idx] = sort(ft);
        toget = ceil(length(ft)*takeforf0); %number of frames representing bottom fraction of data values
        f0(t,r) = nanmean(ft_rank(1:toget)); % get mean of lower percentile of frames
        df = (ft-f0(t,r))/f0(t,r); %df/f
        alldff(t,:,r) = df;
        ALLBLOCKS(x).dffmean = nanmean(df);
        alldffmean(t,r) = nanmean(df);
        [dff_takeforf0, dff_takeforf0_idx] = sort(df); % recalculate mean of lower percentile of frames using dff
        dff_percentile(t,r) = nanmean(dff_takeforf0(1:toget));
    end
end

[dffmean_rank, dffmean_rankidx] = sort(alldffmean(:));
    findnan = find(isnan(dffmean_rank) == 1, 1); %  get last trace before the sorted nan traces
[rankidx_i, rankidx_j] = ind2sub(size(alldffmean), dffmean_rankidx);
dff_f0_rank = dff_percentile(:);
dff_f0_rank = dff_f0_rank(dffmean_rankidx);

toplotmin = nanmin(alldff(rankidx_i(1),:,rankidx_j(1)));
toplotmax = nanmax(alldff(rankidx_i(1),:,rankidx_j(1)));
%toplotmax = nanmax(alldff(rankidx_i(findnan-1),:,rankidx_j(findnan-1)));

figure;
    subplot(2,2,[1,2]);
        plot(dffmean_rank, 'k');hold on;
        scatter(1:length(dff_f0_rank), dff_f0_rank, '.', 'r');
    subplot(2,2,3); %max mean dff
        plot(alldff(rankidx_i(1),:,rankidx_j(1)), 'k'); hold on;
        plot([1:dims(2)],(dff_percentile(rankidx_i(1),rankidx_j(1))), 'r');
        ylim([toplotmin, toplotmax]);
    subplot(2,2,4); %min mean dff
        plot(alldff(rankidx_i(findnan-1),:,rankidx_j(findnan-1)), 'k'); hold on;
        plot([1:dims(2)],(dff_percentile(rankidx_i(findnan-1),rankidx_j(findnan-1))), 'r');
        ylim([toplotmin, toplotmax]);

trial = 3;
roi = 3;
%plot(squeeze(alldff(trial,:,roi)),'k');hold on;
%plot([1:size(dat,2)], f0(roi,trial), 'r');