function [corrs] = zcorr_cpu(data)

fprintf(1,['formatting Ch1 for cross-correlation...']);
xpix = size(data,1);
ypix = size(data,2);
median_ref = median(data,3);
medfilt_ref = medfilt2(median_ref); %denoise median image
a = mode(double(medfilt_ref(:)));
b = rms(double(medfilt_ref(:)));
thresh = a+b; %threshold is intensity mode + RMS of all intensities
thresh_ref = medfilt_ref;
thresh_ref(medfilt_ref < thresh) = 0; %set all values below threshold to 0
ref = single(reshape(thresh_ref,xpix,ypix));

for n = 1:size(data,3)
    img = data(:,:,n);
    medfilt_img = medfilt2(img);
    thresh_img = medfilt_img;
    thresh_img(medfilt_img < thresh) = 0; %set all values below threshold to 0
    img2(:,:,n) = single(reshape(thresh_img,xpix,ypix)); 
end
   
fprintf(1,['detecting z-shifts in frame:    ']);
for n = 1:size(data,3)
    corrs(n) = corr2(img2(:,:,n), ref); %do cross-correlation between frame and median image
    for x = 1:ceil(log10(n+1)), fprintf(1,'\b'); end %backspace for number of digits in counter 
    fprintf(1,'%d',n);
end
end

