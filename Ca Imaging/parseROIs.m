% written by Matt Valley, 2014
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


clear all

rootdir = 'C:\Users\supersub\Claire Dropbox\Dropbox\Matlab\documents-export-2015-01-20';
cd(rootdir);
load 'ALLBLOCKS.mat'
Filenames = dir(['*block*']);
%base_win = [20:100]; %frames that define baseline for df/f
takeforf0 = 0.25; % fraction of lowest-amplitude timeseries data values to average for f0
trial_reject = .5; %reject trials with more than this fraction of discarded frames

all_alldffmean = [];
all_alldff = [];
for x = 1:length(ALLBLOCKS) %for each block
    disp(['dffing block ', num2str(x)]);
%   d = struct2cell(load(Filenames(x).name)); For loading .mat format 
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
    dims = size(dat);
    for r = 1:dims(3) %for each roi
        
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
            %alldffmean(t,r) = nanmean(df);
        end
    end
    
    %all_alldffmean = cat(1, all_alldffmean, alldffmean);
    all_alldff = cat(1, all_alldff, alldff);
    ALLBLOCKS(x).dff = alldff;
    save(['ALLBLOCKS.mat'], 'ALLBLOCKS');

    clear rejtrial dat ft alldff 
end

all_alldffmean = squeeze(nanmean(all_alldff,2));
[dffmean_rank, dffmean_rankidx] = sort(all_alldffmean(:));
findnan = find(isnan(dffmean_rank) == 1, 1); % get last trace before the sorted nan traces
if isempty(findnan) % if there are no nans
    findnan = length(dffmean_rank);
end            
[rankidx_i, rankidx_j] = ind2sub(size(all_alldffmean), dffmean_rankidx);

% set plot min and max y axis to the largest df/f waveform
toplotmin = nanmin(all_alldff(rankidx_i(findnan-1),:,rankidx_j(findnan-1)));
toplotmax = nanmax(all_alldff(rankidx_i(findnan-1),:,rankidx_j(findnan-1)));

all_all_alldff = permute(all_alldff, [1 3 2]);
all_all_alldff = reshape(all_all_alldff, [length(dffmean_rankidx),size(all_alldff,2)]);
mean_alldff = nanmean(all_all_alldff,1);

[hist_dffy, hist_dffx] = hist(dffmean_rank, 100);
figure;
    subplot(2,2,1);
        [hAx,hLine1,hLine2] = plotyy(dffmean_rank,1:length(dffmean_rank),hist_dffx,hist_dffy);
        title('sorted mean df/f values and histogram of mean df/f values');
        xlabel('mean df/f');
    subplot(2,2,2)
        imagesc(all_all_alldff(dffmean_rankidx, :));
        title('waveforms from all trials sorted by mean df/f');
        xlabel('time (frames)');
        ylabel('trial # (sorted)');
    subplot(2,2,3); %max mean dff
        plot(all_alldff(rankidx_i(1),:,rankidx_j(1)), 'k'); hold on;
        plot(mean_alldff,'r');
        ylim([toplotmin, toplotmax]);
        title('trial with smallest mean df/f (black) and mean of all trials (red)');
        xlabel('time (frames)');
        ylabel('df/f');
    subplot(2,2,4); %min mean dff
        plot(all_alldff(rankidx_i(findnan-1),:,rankidx_j(findnan-1)), 'k'); hold on;
        plot(mean_alldff,'r');
        ylim([toplotmin, toplotmax]);
        xlabel('time (frames)');
        title('trial with greatest mean df/f (black) and mean of all trials (red)');
        ylabel('df/f');