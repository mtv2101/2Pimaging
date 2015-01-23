%%For calculating the average activity of ROIs

clear all
FFrame = 120; %Input first frame  for calculating the average activity
LFrame = 150; %Input last frame  for calculating the average activity
AvgRange = [FFrame:LFrame];

rootdir = 'D:\2014-Nov 1-day interval structural plasticity\071514-03\ALL ALLBLOCKS\2 Odor evoked';
cd(rootdir);
Fulllist = dir('*ALLBLOCKS*');

dat2 = [];
for n = 1:length(Fulllist);
    load(Fulllist(n).name);
    for k = 1:length(ALLBLOCKS);
        for i = 1:size(ALLBLOCKS(k).dff,1);
            for p = 1:size(ALLBLOCKS(k).dff,3);
                
                dat(p,:) = nanmean(ALLBLOCKS(k).dff(i,AvgRange,p));
               end
             dat2 = [dat2 dat];             
        end
    end
end
figure;imagesc(dat2);colormap(hot);
title(['Average activity for each block frames ' num2str(FFrame) ':' num2str(LFrame)]);

% for h = 1:size(dat2,1);
%     AvgEach(h,:) = nanmedian(dat2(n,:));
% end
% figure;hist(AvgEach);



        