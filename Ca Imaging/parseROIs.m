%written by Matt Valley, 2014
% This code will fill blank data as NaN
% gathered after FIJI registratrion and ROI generation.
% waves from each roi done in FIJI must be saved with filename
% containing "wave_block" so that it loads correctly

% 2014-07-07 Kurt modified to use dlmread to allow loading wave .txt tab delimited files
% instead of needing to first convert to a .mat file.

% This code does 4 things:
% 1. It reformats the data from [frames, rois] to [trials, frames, rois]
% 2. Df/f is then calculated using baseline data from all trials in each block
%       output is alldff [trials, images, rois]
% 3. Trials are rejected if there are too many dropped frames
% 4. df/f traces are saved to ALLBLOCKS


%% to do 
%% rank trials by average df/f and then pick out highly ative and low active trrials to visualize 
clear all

rootdir = 'D:\Metch olfactometer study\031114-07\2014-05-13';
cd(rootdir);
load 'ALLBLOCKS.mat'
Filenames = dir(['*wave_block*']);
%base_win = [20:100]; %frames that define baseline for df/f
takeforf0 = 0.2; % fraction of lowest-amplitude timeseries data values to average for f0
trial_reject = .5; %reject trials with more than this fraction of discarded frames

for x = 1:length(ALLBLOCKS) %for each block
%    d = struct2cell(load(Filenames(x).name)); For loading .mat format 
     d = {dlmread(Filenames(x).name, '\t', 1, 1)};
    alldat = d{1};
    for r = 1:size(alldat,2) %for each roi
        indx=1;
        inc=1;
        for t = 1:length(ALLBLOCKS(x).imgindx) %for each trial in the block
            for i = 1:length(ALLBLOCKS(x).imgindx{t}) %for each image in the trial
                if length(ALLBLOCKS(x).imgindx) * length(ALLBLOCKS(x).imgindx{t}) ~= length(ALLBLOCKS(x).include)
                    fprintf 'ERROR! FIX THE DAMN CODE MATT!!!'
                    indx=indx+1;
                    break
                end
                if ALLBLOCKS(x).include(indx) == 1
                    dat(t,i,r) = alldat(inc, r);
                    inc=inc+1; %inc only iterates valid images
                    indx=indx+1; %indx iterates regardless of if image is valid
                else
                    dat(t,i,r) = NaN;
                    indx=indx+1;
                    continue
                end
            end
        end
    end
    %%%%%%%%%%%%%%%%%% reject trials with too many dropped frames
    for t = 1:length(ALLBLOCKS(x).imgindx) %for each trial in the block
        if sum(isnan(dat(t,:,:)))/length(ALLBLOCKS(x).imgindx{t}) > trial_reject;
            rejtrial(t) = 1;
            dat(t,:,:) = NaN;
        else
            rejtrial(t) = 0;
        end
    end
    ALLBLOCKS(x).rejtrial = rejtrial;
    
    %%%%%%%%%%%%%%% do df/f using bottom fraction of data defined by takeforf0
    for r = 1:size(alldat,3) %for each roi
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
        for t = 1:dims(1) %for each trial       
            ft = squeeze(dat(t,:,r)); %timeseries
            %ft = ft - alltrial_base; % subtract alltrial baseline 
            [ft_rank, ft_rank_idx] = sort(ft);
            toget = ceil(length(ft)*takeforf0); %number of frames representing bottom fraction of data values
            f0(t,r) = nanmean(ft_rank(1:toget)); % get mean of lower percentile of frames
            df = (ft-f0(t,r))/f0(t,r); %df/f
            alldff(t,:,r) = df;
            ALLBLOCKS(x).dffmean = nanmean(df); % save mean dff for use later
            alldffmean(t,r) = nanmean(df);
            [dff_takeforf0, dff_takeforf0_idx] = sort(df); % recalculate mean of lower percentile of frames using dff
            dff_percentile(t,r) = nanmean(dff_takeforf0(1:toget));
        end
    end
    
    [dffmean_rank, dffmean_rankidx] = sort(alldffmean(:));
        findnan = find(isnan(dffmean_rank) == 1, 1); % get last trace before the sorted nan traces
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
        
     %%%%%%%%%%%%%%% do df/f using mean of all timeseries
%    for r = 1:size(alldat,2) %for each roi
%         dims = size(dat);          
%         ft = dat(:,:,r); %timeseries
%         f0 = nanmean(nanmean(ft(:,base_win), 2)); %mean of baseline window within each block
%         df = (ft(:)-f0)./f0; %df/f
%         alldff(:,:,r) = reshape(df,dims(1),dims(2));
%         end
%     end

ALLBLOCKS(x).dff = alldff;
save(['ALLBLOCKS.mat'], 'ALLBLOCKS');

clear rejtrial alldff dat ft
end