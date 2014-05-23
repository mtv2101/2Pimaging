%function [ROIS] = auditdff_pairs(data, similarity, cell_sig)

similarity = .2;
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
        matches(n).rois = 1;
        matches(n).assignment = indx(x);
        skiplist(n) = indx(x); %use this later to skip this roi
        simmod(indx(x),n) = 0; %if a=b than set b=0 so you dont meet it again
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
        ROIS(x,:,:) = logical(bin_segs(n,:,:) + logical(bin_segs(matches(n).indx,:,:)));
    else 
        ROIS(x,:,:) = logical(bin_segs(n,:,:));
    end
    x=x+1;
end

