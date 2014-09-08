%This code written by Matt Valley will fill blank data as NaN
%gathered after FIJI registratrion and ROI generation.
%waves from each roi done in FIJI must be saves with filename
%containing "wave_block" so that it loads correctly

%2014-07-07 Kurt modified line 25 to allow loading wave .txt tab delimited files
%instead of needing to first convert to a .mat file.

% This code does 4 things:
% 1. It reformats the data from [frames, rois] to [trials, frames, rois]
% 2. Df/f is then calculated using baseline data from all trials in each block
%       output is alldff [trials, images, rois]
% 3. Trials are rejected if there are too many dropped frames
% 4. df/f traces are saved to ALLBLOCKS

clear all

rootdir = 'D:\Metch olfactometer study\031114-07\2014-05-13';
cd(rootdir);
load 'ALLBLOCKS.mat'
Filenames = dir(['*wave_block*']);
base_win = [20:100]; %frames that define baseline for df/f
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
                    fprintf 'ERROR! FIX THE DAMN CODE MATT '
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
    
    %%%%%%%%%%%%%%% do df/f
    for r = 1:size(alldat,2) %for each roi
        dims = size(dat);
        ft = dat(:,:,r); %timeseries mean of ROI
        f0 = nanmean(nanmean(ft(:,base_win), 2)); %mean of baseline window within each block
        df = (ft(:)-f0)./f0; %df/f
        alldff(:,:,r) = reshape(df,dims(1),dims(2));
    end


ALLBLOCKS(x).dff = alldff;
save(['ALLBLOCKS.mat'], 'ALLBLOCKS');

clear rejtrial alldff dat ft
end