dat = ALLBLOCKS(2).dff;
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
        f0(t,r) = nanmean(ft_rank(1:toget));
        df = (ft-f0(t,r))/f0(t,r); %df/f
        alldff(t,:,r) = df;
    end
end

trial = 3;
roi = 3;
plot(squeeze(alldff(trial,:,roi)),'k');hold on;
plot([1:size(dat,2)], f0(roi,trial), 'r');