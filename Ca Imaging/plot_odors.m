function plot_odors(rootdir, odor1, odor2, sortrespo1_indx, sortrespo2_indx,...
    has_respo1_sort, has_respo2_sort, sort_respo1, sort_respo2, allblock_o1,...
    allblock_o2, sort_respo1_sigs, sort_respo2_sigs, has_tune)

%%% initialize plotly
% api_path = 'C:\Users\PMO\Desktop\Matt\ciasom code\plotly';
% addpath(genpath(api_path))
% signin('subgranules', '05fijvty35')
%
% Dependency: shadedErrorBar.m
% http://www.mathworks.com/matlabcentral/fileexchange/26311-shadederrorbar

quarto1 = floor(length(sortrespo1_indx)/4); % top quartile of responding rois
quarto1_rois = sortrespo1_indx((end-quarto1):end);
quarto2 = floor(length(sortrespo2_indx)/4); % top quartile of responding rois
quarto2_rois = sortrespo2_indx((end-quarto2):end);

lin_color_map=pmkmp(256, 'LinLhot');

axis('fill');
set(0,'DefaultAxesFontSize',10)
sub1 = subplot(3,3,1);    
    jimage(has_respo1_sort); colormap(flipud(gray));
    sub1cb = colorbar; set(sub1cb,'FontSize',8);
    cbfreeze(sub1cb);freezeColors;
    title('Sig Blocks Odor A');
    xlabel('block');
    ylabel('trial');
sub2 = subplot(3,3,2);
    jimage(has_respo2_sort); colormap(flipud(gray));
    sub2cb = colorbar; set(sub2cb,'FontSize',8);cbfreeze(sub2cb);
    freezeColors;
    title('Sig Blocks Odor B');
    xlabel('block');
    ylabel('trial');
sub3 = subplot(3,3,3);
    jimage(has_tune); colormap(lin_color_map);
    sub3cb = colorbar; set(sub3cb,'FontSize',8);cbfreeze(sub3cb);
    freezeColors;
    title('Tuned Blocks A vs. B'); 
    xlabel('block');
    ylabel('ROI rank');
sub4 = subplot(3,3,4);    
    imagesc(squeeze(mean(sort_respo1_sigs,3)), [0 .05]);
    colormap(flipud(lin_color_map));freezeColors;
    sub4cb = colorbar; set(sub4cb,'FontSize',8);
    colormap(lin_color_map);cbfreeze(sub4cb);
    title('Odor A timecourse of roi sig');
    xlabel('time (s)');
    ylabel('ROI rank');
sub5 = subplot(3,3,5);    
    imagesc(squeeze(mean(sort_respo2_sigs,3)), [0 .05]);
    colormap(flipud(lin_color_map));freezeColors;
    sub5cb = colorbar; set(sub5cb,'FontSize',8);
    colormap(lin_color_map);cbfreeze(sub5cb);
    title('Odor B timecourse of roi sig');
    xlabel('time (s)');
    ylabel('ROI rank');
sub6 = subplot(3,3,6);axis off;
    text(.1, .9, rootdir, 'Interpreter', 'none', 'Fontsize', 12);
    text(.1, .65, ['odorA = ' odor1], 'Fontsize', 12); 
    text(.1, .4, ['odorB = ' odor2], 'Fontsize', 12);
sub7 = subplot(3,3,7);    
    o1mean = squeeze(nanmean(nanmean(allblock_o1(:,:,quarto1_rois,:),3),1));
    topquart_o1error = std(o1mean,[],2)/sqrt(size(o1mean,2));
    o2mean = squeeze(nanmean(nanmean(allblock_o2(:,:,quarto1_rois,:),3),1));
    topquart_o2error = std(o2mean,[],2)/sqrt(size(o2mean,2));
    jimage(o1mean');
        sub7cb = colorbar; colormap(redblue);set(sub7cb,'FontSize',8);
        cbfreeze(sub7cb);freezeColors;
        title('Odor A df/f over blocks');
        xlabel('time (frames)');
        ylabel('block');
sub8 = subplot(3,3,8);    
    jimage(o2mean');
        sub8cb = colorbar; set(sub8cb,'FontSize',8);cbfreeze(sub8cb);
        colormap(redblue);freezeColors;
        title('Odor B df/f over blocks');
        xlabel('time (frames)');
        ylabel('block');
sub9 = subplot(3,3,9);    
    shadedErrorBar([],nanmean(o1mean,2), topquart_o1error, {'color', [.5, .5, 1]}, 1);hold on;
    shadedErrorBar([],nanmean(o2mean,2), topquart_o2error,  {'color', [1, 0.5, 0.2]}, 1);hold on;
    axis tight;
    xLimits = get(sub9,'XLim'); 
    yLimits = get(sub9,'YLim');  
    h = patch([100; 100; 130; 130], [yLimits(1); yLimits(2); yLimits(2); yLimits(1);], [.7 .7 .7]);
    set(h, 'FaceAlpha', .4, 'EdgeColor', 'none');
    title('A vs. B mean of top-quartile df/f');
    xlabel('time (frames)');
    ylabel('df/f');

    %packcols(3,3);

    
%%% Do allROI subplots

    cat_allblock_o1 = [];
    cat_allblock_o2 = [];
    for k = 1:size(allblock_o1,4)
        cat_allblock_o1 = cat(1, cat_allblock_o1, allblock_o1(:,:,:,k));
        cat_allblock_o2 = cat(1, cat_allblock_o2, allblock_o2(:,:,:,k));
    end
    numsubplots = size(allblock_o1, 3); %number of ROIs
    rows = ceil(sqrt(numsubplots));
figure;    
    for s = 1:numsubplots
        subplot(rows, rows, s);
        base_mean = squeeze(nanmean(nanmean(cat_allblock_o1(:,1:100,s),2),1));
        signal_max = max(max(cat_allblock_o1(:,:,s),[],2),[],1);
        datrange = [(base_mean-signal_max) signal_max];
        imagesc(cat_allblock_o1(:,:,s), datrange);colormap(redblue);freezeColors;
    end
        droppedframes = isnan(cat_allblock_o1(:,:,1));
        isdropped = zeros(size(cat_allblock_o1(:,:,1)));
        isdropped(droppedframes) = 1;        
    subplot(rows, rows, numsubplots+1);
        imagesc(isdropped); colormap(flipud(gray));freezeColors;        
    packboth(rows,rows);
    
    figure;
    for s = 1:numsubplots
        subplot(rows, rows, s);
        base_mean = squeeze(nanmean(nanmean(cat_allblock_o2(:,1:100,s),2),1));
        signal_max = max(max(cat_allblock_o2(:,:,s),[],2),[],1);
        datrange = [(base_mean-signal_max) signal_max];
        imagesc(cat_allblock_o2(:,:,s), datrange);colormap(redblue);freezeColors;
    end
        droppedframes = isnan(cat_allblock_o2(:,:,1));
        isdropped = zeros(size(cat_allblock_o2(:,:,1)));
        isdropped(droppedframes) = 1;        
    subplot(rows, rows, numsubplots+1);
        imagesc(isdropped); colormap(flipud(gray));freezeColors;
    packboth(rows,rows);

function [c] = redblue
%figure(h);
m=256;
n = fix(0.5*m);
r = [(0:1:n-1)/n,ones(1,n)];
g = [(0:n-1)/n, (n-1:-1:0)/n];
b = [ones(1,n),(n-1:-1:0)/n];
c = [r(:), g(:), b(:)];
%colormap(c);
end



end