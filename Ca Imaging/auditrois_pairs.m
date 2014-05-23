%function [ROIS] = auditrois_pairs(data, similarity, cell_sig)

%similarity = .8;
data = ica_segments;

RHO = corr(cell_sig');
simmat = RHO;
simmat(RHO < similarity) = 0;
simmat(RHO > similarity) = 1;
bin_segs = data;
bin_segs(data>0) = 1;
bin_segs(bin_segs<1) = 0;
xlen = size(bin_segs,2);
ylen = size(bin_segs,3);
simmod = simmat; %use simmod to accumulate ROI concatenations
skiplist = NaN(size(simmat,1),1);

for n=1:size(simmat,1);
    indx = find(simmod(n,:));
    matches(n).indx = indx;
    if length(indx) == 1
        continue
    end
    c = length(indx);       
    for x=2:c
        figure;
        subplot(2,1,1); hold on; h1 = gca;    
        imshow(zeros(xlen, ylen)); %plot black background
        subplot(2,1,2); hold on; h2 = gca; 
        axes(h1);
        white = cat(3, ones(xlen), ones(xlen), ones(xlen)); %white transparency
        h = imshow(white);
        set(h, 'AlphaData', squeeze(bin_segs(indx(1),:,:)));
        red = cat(3, ones(xlen), zeros(xlen), zeros(xlen)); %red transparency
        hh = imshow(red);
        set(hh, 'AlphaData', squeeze(bin_segs(indx(x),:,:)));
        set(h1, 'DataAspectRatioMode', 'auto');
        pbaspect('auto');
        cords = regionprops(squeeze(bin_segs(indx(x),:,:)), 'centroid');
        text(cords.Centroid(1), cords.Centroid(2), num2str(indx(x)), 'color', [1 1 1]);
        plot(h2, cell_sig(indx(1),1:(ceil(size(cell_sig,2)/2))), 'k');
        plot(h2, cell_sig(indx(x),1:(ceil(size(cell_sig,2)/2))), 'r');
        matches(n).rois = input(['are these ROIs the same? Press 1 if yes, ENTER if no']);
            if matches(n).rois == 1
                matches(n).assignment = indx(x);
                skiplist(n) = indx(x); %use this later to skip this roi
            end
        simmod(indx(x),n) = 0; %if a=b than set b=0 so you dont meet it again
        close
    end 
    clear indx
end

x=1;
for n=1:size(simmat,1);
    if isnan(skiplist(n)) == 0
        continue
    end
    if matches(n).rois == 1
        indx = matches(n).indx;
        ROIS(x,:,:) = logical(bin_segs(n,:,:) + bin_segs(matches(n).assignment,:,:));
    else 
        ROIS(x,:,:) = logical(bin_segs(n,:,:));
    end
    x=x+1;
end

