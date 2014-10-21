function [bandmean, imgsem, meanimg] = imgreduce(img)
if isempty(img)
    meanimg = NaN; imgsem = NaN; bandmean = NaN;
else
    band = squeeze(mean(img(:,5:7,:),2));
    bandmean = nanmean(band,2);
    imgsem = nanstd(band, [], 2)/sqrt(size(band,2));
    meanimg = nanmean(img,3);
end
end