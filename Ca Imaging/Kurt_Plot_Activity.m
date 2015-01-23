%For plotting all activity of each ROI

clear all

rootdir = 'D:\2014-Nov 1-day interval structural plasticity\071514-03\ALL ALLBLOCKS\1 Spontaneous';
cd(rootdir);
Fulllist = dir('*ALLBLOCKS*');

ROI2Plot = 8;
dat2 = [];
for n = 1:length(Fulllist);
    load(Fulllist(n).name);
    for k = 1:length(ALLBLOCKS);
        for i = 1:size(ALLBLOCKS(k).dff,1);
                dat = ALLBLOCKS(k).dff(i,:,ROI2Plot);
                dat2 = [dat2; dat]; 
                end
                     
        end
end
figure;plot(dat2','DisplayName','dat2')




