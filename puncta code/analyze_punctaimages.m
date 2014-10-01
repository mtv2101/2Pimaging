function [img_perday, mean_peak, max_peak, last_peak, first_peak, stable_peak] = analyze_punctaimages(dat)

%dat = condition(1).allpuncta;

plotcolors = [31 119 180; 255 127 14; 44 160 44; 214 39 40; 148 103 189; 140 86 75;...
    227 119 194]./255;

% get all images of puncta in a trajectory
i=1;
for n = 1:size(dat,2); % for each roi
    %lifetimes = cat(2, lifetimes, dat(n).trajectory.lifetime);
    for m = 1:size(dat(n).trajimg, 2)
        for k = 1:size(dat(n).trajimg(m).img, 3)
            if isempty(dat(n).trajimg(m).img(:,:,k)) == 1
                continue
            end
            images(:,:,i) = dat(n).trajimg(m).img(:,:,k);
            i=i+1;
        end
    end
end

% get all images by day
for d = 1:length(dat(n).allimg) % for each day
    allimages = [];
    for n = 1:size(dat,2) %for each roi
        if ~isempty(dat(n).allimg) && (length(dat(n).allimg) >= d) %if data exists or that day
            for p = 1:size(dat(n).allimg(d).img,3)  %for each puncta
                ii(:,:,p) = dat(n).allimg(d).img(:,:,p);
            end
            allimages = cat(3, allimages, ii);
            clear ii
        end
    end
    img_perday(d).allimages = allimages;
    clear allimages
end

% get first and last puncta
img_first = []; first_idx = logical(zeros(1,size(images, 3)));
img_second = []; sec_idx = logical(zeros(1,size(images, 3)));
img_third = []; third_idx = logical(zeros(1,size(images, 3)));
img_four = []; fourth_idx = logical(zeros(1,size(images, 3)));
img_five = []; fifth_idx = logical(zeros(1,size(images, 3)));
img_six = []; sixth_idx = logical(zeros(1,size(images, 3)));
img_last = []; last_idx = logical(zeros(1,size(images, 3)));
img_stable = [];
i = 1;
for n = 1:size(dat,2);
    %lifetimes = cat(2, lifetimes, dat(n).trajectory.lifetime);
    for m = 1:size(dat(n).trajimg, 2)
        for k = 1:size(dat(n).trajimg(m).img, 3) %for each day
            if isempty(dat(n).trajimg(m).img(:,:,k)) == 1 %if image is filled with NaNs becuase it crosses fov border
                continue
            end
            if dat(n).trajectory(m).new(k) == 1
                img_first = cat(3, img_first, dat(n).trajimg(m).img(:,:,k));
                first_idx(i) = 1;
                if size(dat(n).trajimg(m).img,3) >= k+1 % if there is a puncta after the first
                    img_second = cat(3, img_second, dat(n).trajimg(m).img(:,:,k+1));
                    sec_idx(i) = 1;
                end
                if size(dat(n).trajimg(m).img,3) >= k+2 % if there is a puncta after the first
                    img_third = cat(3, img_third, dat(n).trajimg(m).img(:,:,k+2)); %third obseravtion of puncta
                    third_idx(i) = 1;
                end
                if size(dat(n).trajimg(m).img,3) >= k+3 % if there is a puncta after the first
                    img_four = cat(3, img_four, dat(n).trajimg(m).img(:,:,k+3)); %third obseravtion of puncta
                    fourth_idx(i) = 1;
                end
                if size(dat(n).trajimg(m).img,3) >= k+4 % if there is a puncta after the first
                    img_five = cat(3, img_five, dat(n).trajimg(m).img(:,:,k+4)); %third obseravtion of puncta
                    fifth_idx(i) = 1;
                end
                if size(dat(n).trajimg(m).img,3) >= k+5 % if there is a puncta after the first
                    img_six = cat(3, img_six, dat(n).trajimg(m).img(:,:,k+5)); %third obseravtion of puncta
                    sixth_idx(i) = 1;
                end
            end
            if dat(n).trajectory(m).lost(k) == 1
                img_last = cat(3, img_last, dat(n).trajimg(m).img(:,:,end));
                last_idx(i) = 1;
            end
            i = i+1;
        end
        if dat(n).trajectory(m).lifetime == length(dat(n).percent_persistant) %if the puncta lives the whole obseravtion
            img_temp = mean(dat(n).trajimg(m).img, 3);
            img_stable = cat(3, img_stable, img_temp);
        end
    end
end


diam = size(images,1); %image diameter
rad = (diam-1)/2;
oin_rad = rad-3; %difference between outside and inside rings, take outside 2 pixels
outside_mask = ones(diam);
outside_mask(rad-oin_rad:rad+2+oin_rad, rad-oin_rad:rad+2+oin_rad) = 0;
outside_mask = logical(outside_mask);
out_size = sum(sum(outside_mask));
inside_mask = zeros(diam);
inside_mask(rad:rad+2, rad:rad+2) = 1;
inside_mask = logical(inside_mask);
in_size = sum(sum(inside_mask));
for n = 1:size(images,3)
    img_temp = images(:,:,n);
    img_in = img_temp(inside_mask);
    img_in = sum(sum(img_in))/in_size; % take average peak
    img_out = img_temp(outside_mask);
    img_out = sum(sum(img_out))/out_size;
    img_sn(n) = (img_in-img_out)/img_in; %use df/f calculation
end
MCdat = img_sn;

% find high-contrast "sharp" puncta
images_db = double(images);
ranks = [.5, 1, 2, 3, 5, 10, 20, 30, 50, 70, 90]; % ranks to extract, in %, pseudo log scale

for n = 1:size(images,3)
    offpeak(n) = mean([images_db(4,4,n), images_db(8,4,n), images_db(8,8,n), images_db(4,8,n)]);
    mean_peak(n) = mean(mean(images_db(5:7, 5:7, n)));
    max_peak(n) = max(max(images_db(5:7, 5:7, n),[],2),[],1);
    if n<=size(img_last,3)
        last_peak(n) = mean(mean(img_last(5:7, 5:7, n),2),1);
    end
    if n<=size(img_stable,3)
        stable_peak(n) = mean(mean(img_stable(5:7, 5:7, n),2),1);
    end
    if n<=size(img_first,3)
        first_peak(n) = mean(mean(img_first(5:7, 5:7, n),2),1);
    end
    %offpeak(n) = mean([images_db(5,5,n), images_db(7,5,n), images_db(7,7,n), images_db(5,7,n)]);
    %mean_peak(n) = images_db(6, 6, n);
    all_dyn(n) = (mean_peak(n)-offpeak(n))/mean_peak(n);
end
all_dyn(all_dyn < 0) = NaN;
include_imgs = find(isfinite(all_dyn));
images_finite = images(:,:,include_imgs);
all_dyn_finite = all_dyn(isfinite(all_dyn));
[rankedsharp, rank_idx] = sort(all_dyn_finite, 'descend');
len_dat = length(all_dyn_finite);
to_take = floor(len_dat*.005); % take 0.5% of data at each interval
for r = 1:length(ranks)
    end_take(r) = floor(ranks(r)*len_dat*.01);
    taken = rank_idx((end_take(r)-to_take+1):end_take(r)); %get 1% data at each rank position
    top_imgs = images_finite(:,:,taken);
    [sharp_mean(:,r), sharpsem(:,r), mean_sharp(:,:,r)] = imgreduce(top_imgs);
    [fitobject, gof(r)] = fit((1:length(sharp_mean(:,r)))', sharp_mean(:,r), 'gauss1');
    c = coeffvalues(fitobject); c = c(3);
    fwhm(r) = 2.35482*c*0.182; % conversion from c to fwhm in microns
    errors(r) = gof(r).rsquare;
    clear top_imgs fitobject taken top_imgs
end
%semilogx(ranks, fwhm, 'k'); hold on;
%semilogx(ranks, errors, 'r');

[first_mean, firstsem, mean_first] = imgreduce(img_first);
first_sn = nanmean(MCdat(first_idx));
[sec_mean, secsem, mean_sec] = imgreduce(img_second);
sec_sn = nanmean(MCdat(sec_idx));
% [third_mean, thirdsem, mean_third] = imgreduce(img_third);
%     third_sn = nanmean(MCdat(third_idx));
% [four_mean, foursem, mean_four] = imgreduce(img_four);
%     fourth_sn = nanmean(MCdat(fourth_idx));
% [fifth_mean, fivesem, mean_five] = imgreduce(img_five);
%     fifth_sn = nanmean(MCdat(fifth_idx));
% [six_mean, sixsem, mean_six] = imgreduce(img_six);
%     six_sn = nanmean(MCdat(sixth_idx));
[last_mean, lastsem, mean_last] = imgreduce(img_last);
last_sn = nanmean(MCdat(last_idx));
[stable_mean, stablesem, mean_stable] = imgreduce(img_stable);
[all_mean, allsem, mean_all] = imgreduce(images);

% plot([first_mean(6), sec_mean(6), third_mean(6), four_mean(6), fifth_mean(6),...
%     six_mean(6), stable_mean(6)]);

% [first, first_x] = ecdf(squeeze(max(max(img_first,[],2),[],1)));
% [second, second_x] = ecdf(squeeze(max(max(img_second,[],2),[],1)));
% [third, third_x] = ecdf(squeeze(max(max(img_third,[],2),[],1)));
% [fourth, fourth_x] = ecdf(squeeze(max(max(img_four,[],2),[],1)));
% [fifth, fifth_x] = ecdf(squeeze(max(max(img_five,[],2),[],1)));
% [sixth, sixth_x] = ecdf(squeeze(max(max(img_six,[],2),[],1)));
% [last, last_x] = ecdf(squeeze(max(max(img_last,[],2),[],1)));
% [stable, stable_x] = ecdf(squeeze(max(max(img_stable,[],2),[],1)));
% plot(first, 'color', plotcolors(1,:)); hold on;
% plot(second, 'color', plotcolors(2,:)); hold on;
% plot(third, 'color', plotcolors(3,:)); hold on;
% plot(fourth, 'color', plotcolors(4,:)); hold on;
% plot(fifth, 'color', plotcolors(5,:)); hold on;
% plot(sixth, 'color', plotcolors(6,:)); hold on;
% plot(first_x, first, 'color', plotcolors(1,:)); hold on;
% plot(second_x, second, 'color', plotcolors(2,:)); hold on;
% plot(third_x, third, 'color', plotcolors(3,:)); hold on;
% plot(last_x, last, 'color', plotcolors(4,:)); hold on;
% plot(stable_x, stable, 'color', plotcolors(5,:)); hold on;

%xlim([0 255]);
%figure; errorbar(first_mean,firstsem, 'color', plotcolors(1,:));hold on;
%errorbar(sec_mean,secsem, 'color', plotcolors(2,:));
% errorbar(third_mean,thirdsem, 'color', plotcolors(3,:));
% errorbar(four_mean,foursem, 'color', plotcolors(4,:));
%errorbar(last_mean,lastsem, 'color', plotcolors(5,:));hold on;
%errorbar(stable_mean,stablesem, 'color', plotcolors(6,:));hold on;

%figure; imagesc(mean_first, [0 120]);
%figure; imagesc(mean_last, [0 120]);
%figure; imagesc(mean_stable, [0 120]);

end