dat = condition(1).allpuncta;

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
img_first = [];
img_last = [];
for n = 1:size(dat,2);
    lifetimes = cat(2, lifetimes, dat(n).trajectory.lifetime);
    for m = 1:size(dat(n).allimg, 2)
        for k = 1:size(dat(n).allimg(m).img, 3) %for each day
            if isempty(dat(n).allimg(m).img(:,:,k)) == 1 %if image is filled with NaNs becuase it crosses fov border
            	continue
            end
            if dat(n).trajectory(m).new(k) == 1
                %firstobs = dat(n).puncta(m).firstobs;
                img_first = cat(3, img_first, dat(n).allimg(m).img(:,:,1)); 
            end
            if dat(n).trajectory(m).lost(k) == 1
%                 if dat(n).trajectory(m).firstobs + dat(n).trajectory(m).lifetime ~= size(dat(n).allimg(m).img,3)
%                     continue
%                 end
                %lastobs = dat(n).trajectory(m).firstobs + dat(n).trajectory(m).lifetime;
                img_last = cat(3, img_last, dat(n).allimg(m).img(:,:,end));
            end
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
    img_sn(n) = (img_in-img_out)/img_out; %use df/f calculation
end
MCdat = img_sn;

%ecdf(img_sn, 'alpha', .05, 'bounds', 'on');

% find high-contrast "sharp" puncta
mages_db = double(images);
for n = 1:size(images,3)
    offpeak(n) = mean([images_db(4,4,n), images_db(8,4,n), images_db(8,8,n), images_db(4,8,n)]);
    all_dyn(n) = (images_db(6,6,n)-offpeak(n))/images_db(6,6,n); 
    if all_dyn(n) < 1 && all_dyn(n) > .90
        sharp(n) = 1;
    else
        sharp(n) = 0;
    end
end
sharp = logical(sharp);
sharp_images = images(:,:,sharp);

first_band = squeeze(mean(img_first(:,5:7,:),2));
first_mean = mean(first_band,2);
firstsem = std(first_band, [], 2)/sqrt(size(first_band,2));
mean_first = mean(img_first,3);

last_band = squeeze(mean(img_last(:,5:7,:),2));
last_mean = mean(last_band,2);
lastsem = std(last_band, [], 2)/sqrt(size(last_band,2));
mean_last = mean(img_last,3);

all_band = squeeze(mean(images(:,6,:),2));
all_mean = mean(all_band,2);
allsem = std(all_band, [], 2)/sqrt(size(all_band,2));
mean_all = mean(images,3);

sharp_band = squeeze(mean(sharp_images(:,6,:),2));
sharp_mean = mean(sharp_band,2);
sharpsem = std(sharp_band, [], 2)/sqrt(size(sharp_band,2));
mean_sharp = mean(sharp_images,3);

%figure; errorbar(first_mean,firstsem, 'k');hold on;errorbar(last_mean,lastsem, 'r');
figure; errorbar(all_mean,allsem, 'k');hold on;errorbar(sharp_mean,sharpsem, 'r');
figure; imagesc(mean_all, [0 120]);
figure; imagesc(mean_sharp, [0 120]);
