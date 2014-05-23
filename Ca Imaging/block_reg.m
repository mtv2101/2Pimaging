clear all

rootdir = 'C:\Kurt\011414-02\2014-03-01';
cd(rootdir);
xpix = 512;
ypix = 512;
maxstep = .002; % maximum step length for the registration optimizer
%temp_len = 100; % take this many images from start of .tif as template for registration
%load('template') % Average of first x-images for template
FILT_SIG = 0; % if 1 do 3x3 median filter of signal before applying registration

%ALLBLOCKS_name = dir(['*ALLBLOCKS*']); % get all ALLBLOCKS file name
%load(ALLBLOCKS_name.name, '-mat');
ImgExtension = '.tif'; % specify image extension
Images_Ch1 = dir(['*block*Ch1' ImgExtension]); % get all file names of block image stacks
Images_Ch2 = dir(['*block*Ch2' ImgExtension]); % get all file names of block image stacks

for block = 1:length(Images_Ch1)
    [blockdat_Ch1] = loadtif(Images_Ch1(block).name, rootdir);
    [blockdat_Ch2] = loadtif(Images_Ch2(block).name, rootdir);
    if block == 1 %register all images to median image from block1
        %template = median(blockdat_Ch1(:,:,1:temp_len),3);
        %ALLBLOCKS(1).template = template;
    end
    stackreg = regtoch1(blockdat_Ch1, blockdat_Ch2, maxstep, FILT_SIG);
    saveastiff(stackreg, ['block_', num2str(block) ' ' date '_Ch2_REG.tif']);
    clear stackreg smallstack includelist
end