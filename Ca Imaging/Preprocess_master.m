%%  Code to prepare large two-photon calcium imaging datasets for analysis
%%  Matt Valley, December 2013
%%
%%  This code loads data from tif stacks containing two interleaved channels
%%  of image data, Ch1 and Ch2 assuming that the signal in Ch1 is not time variant.
%%  Typically, Ch1 will be a morphological label, and Ch2 the calcium dye.
%%  Tif stacks can be generated from t-series data exported by Prairieview (Bruckerview?)
%%  by first running TiftoStack.m
%%
%%  Unique function calls:
%%  1.  Load Data from tif stacks
%%      loadtif.m
%%  2.  Identify frames with z-shift from Ch1
%%      zcorr_cpu.m
%%
%% THEN... zcorr_solo to find good threshold for z-correction
%% and enable tif saving to output single .tif of valid images
%% THEN... block_reg to register all blocks and median filter


clear all

%%%%% DEFINE VARS
blocksize = 20; %break up data processing into groups of trials this long
xpix = 512;
ypix = 512;
downresfactor = 2; % for registration use this fraction of the total image
xcorrthresh = 0.35; % reject images that correlate worse than this value
%maxstep = .002; % maximum step length for the registration optimizer

%%%%% BATCH LOAD TIF STACKS AND DO XYZ REGISTRATIONS WITH CH1
rootdir = 'D:\2015-Jan-Feb external train study\110514-06\2015-01-21'; % full path to root directory of your tiff stacks
cd(rootdir);
FullList = dir;
ImgExtension = '.tif'; % specify image extension
ImgList1 = dir(['*Ch1*' ImgExtension]); % get all Ch1 file names
ImgList2 = dir(['*Ch2*' ImgExtension]); % get all Ch2 file names

%chunk trials in appropriately sized blocks for analysis
numtrials = length(ImgList1); % take blocks from Ch1, but will apply the same to Ch2
numblocks = numtrials/blocksize;
if ceil(numblocks) - numblocks > .5
    numblocks = ceil(numblocks) + 1; %make new block if num of trials is above 50% the size of the rest of the blocks
else 
    numblocks = ceil(numblocks);
end
for n = 1:numblocks
    if n<numblocks
        blockstart = 1+(blocksize*n)-blocksize;
        ALLBLOCKS(n).triallist = blockstart:(blockstart+blocksize-1);
    else
        blockstart = 1+(blocksize*n)-blocksize;
        ALLBLOCKS(n).triallist = blockstart:numtrials; %last block contains trials ending at numtrials
    end
end

%%%%%%% 1. Load Data from tif stacks, consolidate into blocks
for block = 1:length(ALLBLOCKS)
    block1data = [];block2data = [];
    triallist = ALLBLOCKS(block).triallist;
    for i = 1:length(triallist)
        trial = triallist(i);
        stack1 = loadtif(ImgList1(trial).name, rootdir);
        stack2 = loadtif(ImgList2(trial).name, rootdir);
        if size(stack1,3) ~= size(stack2,3) %make number of frames match in each stack
            trunc = min([size(stack1,3), size(stack2,3)]);
            stack1 = stack1(:,:,1:trunc);
            stack2 = stack2(:,:,1:trunc);
        end
        disp(['loading trial ' num2str(trial) ', file ' num2str(ImgList1(trial).name)]);
        nimg(i) = size(stack1,3); %applies equally
        block1data = cat(3,block1data,stack1);
        block2data = cat(3,block2data,stack2);
        ALLBLOCKS(block).imgindx{i} = 1:nimg(i);
        clear stack1 stack2
    end
    
    %%%%%%% 2. Get frame correlations to identify z-shifts from Ch1
    [corrs] = zcorr_cpu(block1data);
    ALLBLOCKS(block).corrs = corrs;    
    
end
save(['ALLBLOCKS.mat'], 'ALLBLOCKS');