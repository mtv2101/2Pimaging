function plot_allblocks(ALLBLOCKS, xcorrthresh, perccent_rej)

%first plot correlation histogram
corrs=[];
for x = 1:length(ALLBLOCKS)
    c = ALLBLOCKS(x).corrs;
    corrs = cat(2,corrs,c);
end
subplot(1,3,1, 'align');
hist(corrs, 50);hold on;
maxy = max(hist(corrs, 50));
plot(xcorrthresh, 1:maxy, 'r');
title('Frequency of correlation coeffs (Ch1 to median Ch1)');
xlabel('correlation coeff.');ylabel('frequency');
annotation('textbox',[(xcorrthresh)/2, .82, .1, .06], 'String',...
    [num2str(perccent_rej) '% rejected'],...
    'EdgeColor', [1 1 1], 'Color', [1 0 0]);

i=1;
for x = 1:length(ALLBLOCKS)
    indx=1;
    for y = 1:length(ALLBLOCKS(x).imgindx)
        for z = 1:length(ALLBLOCKS(x).imgindx{y});
            len = length(ALLBLOCKS(x).imgindx{y});
            trial_corrs(i,z) = ALLBLOCKS(x).corrs(indx);
            trial_rej(i,z) = ALLBLOCKS(x).include(indx);
            indx=indx+1;
        end  
        i=i+1;
    end
    clear indx;
end

subplot(1,3,2, 'align');
imagesc(trial_corrs, [0 1]);
title('Correlation coeffs. within each trial');xlabel('frame');ylabel('trial');
colorbar('location', 'SouthOutside');

subplot(1,3,3, 'align');
imagesc(trial_rej);colormap(gray);
title('Rejected frames within each trial');xlabel('frame');ylabel('trial');
colorbar('location', 'SouthOutside');