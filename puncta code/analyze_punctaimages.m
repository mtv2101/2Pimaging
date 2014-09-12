dat = condition(1).allpuncta;

plotcolors = [31 119 180; 255 127 14; 44 160 44; 214 39 40; 148 103 189; 140 86 75;...
    227 119 194]./255;

% get all images
lifetimes = [];
i=1;
for n = 1:size(dat,2); % for each roi
    lifetimes = cat(2, lifetimes, dat(n).trajectory.lifetime);
    for m = 1:size(dat(n).allimg, 2)
        for k = 1:size(dat(n).allimg(m).img, 3)
            if isempty(dat(n).allimg(m).img(:,:,k)) == 1
                continue
            end
            images(:,:,i) = dat(n).allimg(m).img(:,:,k);
            i=i+1;
        end
    end
end

% get first and last puncta
img_first = []; first_idx = logical(zeros(1,size(images, 3)));
img_second = []; sec_idx = logical(zeros(1,size(images, 3)));
img_third = []; third_idx = logical(zeros(1,size(images, 3)));
img_four = []; fourth_idx = logical(zeros(1,size(images, 3)));
img_last = []; last_idx = logical(zeros(1,size(images, 3)));
img_stable = []; 
i = 1;
for n = 1:size(dat,2);
    lifetimes = cat(2, lifetimes, dat(n).trajectory.lifetime);
    for m = 1:size(dat(n).allimg, 2)
        for k = 1:size(dat(n).allimg(m).img, 3) %for each day
            if isempty(dat(n).allimg(m).img(:,:,k)) == 1 %if image is filled with NaNs becuase it crosses fov border
            	continue
            end
            if dat(n).trajectory(m).new(k) == 1
                img_first = cat(3, img_first, dat(n).allimg(m).img(:,:,k)); 
                first_idx(i) = 1;
                if size(dat(n).allimg(m).img,3) >= k+1 % if there is a puncta after the first
                    img_second = cat(3, img_second, dat(n).allimg(m).img(:,:,k+1)); 
                    sec_idx(i) = 1;
                end
                if size(dat(n).allimg(m).img,3) >= k+2 % if there is a puncta after the first
                    img_third = cat(3, img_third, dat(n).allimg(m).img(:,:,k+2)); %third obseravtion of puncta
                    third_idx(i) = 1;
                end
                if size(dat(n).allimg(m).img,3) >= k+3 % if there is a puncta after the first
                    img_four = cat(3, img_four, dat(n).allimg(m).img(:,:,k+3)); %third obseravtion of puncta
                    fourth_idx(i) = 1;
                end
            end
            if dat(n).trajectory(m).lost(k) == 1
                img_last = cat(3, img_last, dat(n).allimg(m).img(:,:,end));
                last_idx(i) = 1;
            end    
            i = i+1;
        end
        if dat(n).trajectory(m).lifetime == length(dat(n).percent_persistant) %if the puncta lives the whole obseravtion
            img_temp = mean(dat(n).allimg(m).img, 3);
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

%ecdf(img_sn, 'alpha', .05, 'bounds', 'on');

% find high-contrast "sharp" puncta
images_db = double(images);
thresholds = [.49:.05:.99];
for t = 1:length(thresholds)
    for n = 1:size(images,3)
        offpeak(n,t) = mean([images_db(4,4,n), images_db(8,4,n), images_db(8,8,n), images_db(4,8,n)]);
        all_dyn(n,t) = (images_db(6,6,n)-offpeak(n))/images_db(6,6,n);
        if all_dyn(n,t) < 1 && all_dyn(n) > thresholds(t)
            sharp(n) = 1;
        else
            sharp(n) = 0;
        end
    end
    sharp = logical(sharp);
    sharp_images(t).img = images(:,:,sharp);
end


[first_mean, firstsem, mean_first] = imgreduce(img_first);
    first_sn = nanmean(MCdat(first_idx));
[sec_mean, secsem, mean_sec] = imgreduce(img_second);
    sec_sn = nanmean(MCdat(sec_idx));
[third_mean, thirdsem, mean_third] = imgreduce(img_third);
    third_sn = nanmean(MCdat(third_idx));
[four_mean, foursem, mean_four] = imgreduce(img_four);
    fourth_sn = nanmean(MCdat(fourth_idx));
[last_mean, lastsem, mean_last] = imgreduce(img_last);
    last_sn = nanmean(MCdat(last_idx));
[stable_mean, stablesem, mean_stable] = imgreduce(img_stable);
[all_mean, allsem, mean_all] = imgreduce(images);

for t = 1:length(thresholds)
    [sharp_mean(:,t), sharpsem(:,t), mean_sharp(:,:,t)] = imgreduce(sharp_images(t).img);
    %[sigmaNew(t),muNew(t),Anew(t)]=mygaussfit([1:length(sharp_mean(:,t))],(sharp_mean(:,t));
    %y(:,t)=Anew(t)*exp(-(x-muNew(t)).^2/(2*sigmaNew(t)^2));
end

%figure; errorbar(first_mean,firstsem, 'k');hold on;errorbar(last_mean,lastsem, 'r');
figure; errorbar(first_mean,firstsem, 'color', plotcolors(1,:));hold on;
errorbar(sec_mean,secsem, 'color', plotcolors(2,:));
errorbar(third_mean,thirdsem, 'color', plotcolors(3,:));
errorbar(four_mean,foursem, 'color', plotcolors(4,:));
errorbar(last_mean,lastsem, 'color', plotcolors(5,:));hold on;
errorbar(stable_mean,stablesem, 'color', plotcolors(6,:));hold on;

figure; imagesc(mean_first, [0 120]);
figure; imagesc(mean_last, [0 120]);
figure; imagesc(mean_stable, [0 120]);