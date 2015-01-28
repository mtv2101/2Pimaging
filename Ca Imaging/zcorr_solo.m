% Use correlation information within ALLBLOCKS.mat and re-plot the
% different thresholded distributrions of the dataset.
% Once desired threshold is chosen, reload data in blocks and extract valid
% images, then save each block as single .tif 
%
% BEFORE RUNNING ENSURE YOU HAVE WRITE ACCESS TO THE ROOTDIR
%
% Matt Valley, March, 2014
clear all

rootdir = 'D:\2015-Jan-Feb external train study\110514-06\2015-01-21'; % full path to root directory of your tiff stacks
cd(rootdir);
xcorrthresh = .7;
load('ALLBLOCKS');
SAVEIMG = 0; % if 1, save single .tif of all z-thresholded images
%DOMED = 0; % do median filter on final Ca data??? 1=yes    

%%%%%%%%%%%%%%%%%%%

corrs = [];
for block = 1:length(ALLBLOCKS)
    includelist = zeros(size(ALLBLOCKS(block).corrs, 2), 1);
    corrs = ALLBLOCKS(block).corrs;
    for k = 1:size(ALLBLOCKS(block).corrs, 2)
        if corrs(k)> xcorrthresh
            includelist(k) = 1;
        end
    end
    ALLBLOCKS(block).include = logical(includelist);
    percent_rej = 100 - (sum(includelist)/length(includelist))*100;
    disp(['block_' num2str(block) ' rejected ' num2str(percent_rej) '% frames']);
end
figure;plot_allblocks(ALLBLOCKS, xcorrthresh, percent_rej);
save(['ALLBLOCKS.mat'], 'ALLBLOCKS');

%%%%%%%%%%%%%%%%%%%%

if SAVEIMG == 1
    blocksize = 10; %break up data processing into groups of trials this long
    xpix = 512;
    ypix = 512;
    cd(rootdir);
    FullList = dir;
    ImgExtension = '.tif'; % specify image extension
    ImgList1 = dir(['*Ch1*' ImgExtension]); % get all Ch1 file names
    ImgList2 = dir(['*Ch2*' ImgExtension]); % get all Ch2 file names
    
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
            clear stack1 stack2
        end
        saveastiff(block2data(1:xpix,1:ypix, ALLBLOCKS(block).include), ['block_', num2str(block) '_Ch2.tif']);
        saveastiff(block1data(1:xpix,1:ypix, ALLBLOCKS(block).include), ['block_', num2str(block) '_Ch1.tif']);
    end    
end