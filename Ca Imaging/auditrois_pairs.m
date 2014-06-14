%function [ROIS] = auditrois_pairs(data, similarity, cell_sig)

similarity = .5;
rootdir = 'C:\Users\PMO\Desktop\Matt\ciasom code\New Code March 2014\Kurt code';
cd(rootdir);
DFF1 = load('DFF.mat');
DFF = DFF1.DFF;
data = squeeze(nanmean(DFF,1));

RHO = corr(data);
hist(RHO(:), 100);
simmat = RHO;
simmat(RHO < similarity) = 0;
simmat(RHO > similarity) = 1;
simmod = simmat; %use simmod to accumulate ROI concatenations

i=1;
for n=1:size(simmat,1);
    indx = find(simmod(n,:));
    matches(n).indx = indx;
    if length(indx) == 1
        continue
    end
    c = length(indx);       
    for x=2:c
        figure;   
        subplot(2,1,1);imagesc(DFF(:,:,indx(1)));
            title(['ROI ' num2str(indx(1))]);
        subplot(2,1,2);imagesc(DFF(:,:,indx(x)));
            title(['ROI ' num2str(indx(x))]);
        result = input(['are these ROIs the same? Press 1 if yes, ENTER if no']);
        if isempty(result)
            result = 0;
            simmod(n,indx(x)) = 0;
        end
        matches(n).rois(x-1) = result;
        simmod(indx(x),:) = 0; %if a=b than set b=0 so you dont meet it again
        close
    end 
    clear indx
    matches(n).match = find(simmod(n,:));
end
