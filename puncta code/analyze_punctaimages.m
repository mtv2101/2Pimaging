dat = allpuncta;

% get all images
lifetimes = [];
i=1;
for n = 1:size(dat,2);
    lifetimes = cat(2, lifetimes, dat(n).puncta.lifetime);
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

% get new puncta
img_first = [];
img_last = [];
for n = 1:size(dat,2);
    lifetimes = cat(2, lifetimes, dat(n).puncta.lifetime);
    for m = 1:size(dat(n).allimg, 2)
        for k = 1:size(dat(n).allimg(m).img, 3)
            if isempty(dat(n).allimg(m).img(:,:,k)) == 1
            	continue
            end
            if dat(n).puncta(m).firstobs > 0
                firstobs = dat(n).puncta(m).firstobs;
                img_first = cat(3, img_first, dat(n).allimg(m).img(:,:,firstobs));
            end
            if dat(n).puncta(m).firstobs + dat(n).puncta(m).lifetime < max(lifetimes);
                if dat(n).puncta(m).firstobs + dat(n).puncta(m).lifetime ~= size(dat(n).allimg(m).img,3)
                    continue
                end
                lastobs = dat(n).puncta(m).firstobs + dat(n).puncta(m).lifetime;
                img_last = cat(3, img_last, dat(n).allimg(m).img(:,:,lastobs));
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

first_band = squeeze(mean(img_first(:,5:7,:),2));
first_mean = mean(first_band,2);
firstsem = std(first_band, [], 2)/sqrt(size(first_band,2));
last_band = squeeze(mean(img_last(:,5:7,:),2));
last_mean = mean(last_band,2);
lastsem = std(last_band, [], 2)/sqrt(size(last_band,2));

errorbar(first_mean,firstsem, 'k');hold on;errorbar(last_mean,lastsem, 'r');
