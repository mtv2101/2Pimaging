%function plot_odors(day, ALLDAYS, allblocks_parsed, rootdir, odor1, odor2)

% Dependency: shadedErrorBar.m
% http://www.mathworks.com/matlabcentral/fileexchange/26311-shadederrorbar

%%%%%%%%% get data
fields = fieldnames(allblocks_parsed);
has_respo1 = [];
has_respo2 = [];
has_tune = [];
o1_resp_amp = [];
o2_resp_amp = [];
for roi = 1:size(allblocks_parsed.(fields{1}), 3)
    has_respo1 = cat(2, has_respo1, ALLDAYS(day).stats(roi).sig_o1all);
    has_respo2 = cat(2, has_respo2, ALLDAYS(day).stats(roi).sig_o2all);
    has_tune = cat(2, has_tune, ALLDAYS(day).stats(roi).sig_odortuned);
    o1_resp_amp = cat(2,o1_resp_amp, nanmean(ALLDAYS(day).stats(roi).mean_times(:,1:4),2));
    o2_resp_amp = cat(2,o2_resp_amp, nanmean(ALLDAYS(day).stats(roi).mean_times(:,5:8),2));
end

%function [c] = redblue
%figure(h);
m=256;
nn = fix(0.5*m);
r = [(0:1:nn-1)/nn,ones(1,nn)];
g = [(0:nn-1)/nn, (nn-1:-1:0)/nn];
b = [ones(1,nn),(nn-1:-1:0)/nn];
c = [r(:), g(:), b(:)];
%colormap(c);
redblue = c;
%end

allblock_o1 = cat(1, allblocks_parsed.o1b1, allblocks_parsed.o1b2,...
    allblocks_parsed.o1b3, allblocks_parsed.o1b4);
allblock_o2 = cat(1, allblocks_parsed.o2b1, allblocks_parsed.o2b2,...
    allblocks_parsed.o2b3, allblocks_parsed.o2b4);

%%%%%%%%% sort ROIS
statfields = [1:3,8]; %CHECK TO MAKE SURE FIELD POSITIONS HAVE NOT MOVED!!!
alldays_fields = fieldnames(ALLDAYS.stats);
for roi = 1:size(allblocks_parsed.(fields{1}), 3)
    for k = 1:length(statfields)
        ns(k,roi) = nansum(ALLDAYS(day).stats(roi).(alldays_fields{statfields(k)}));
    end
    numsigs(roi) = nansum(ns(:,roi),1);
end
[s_o1, sortrespo_indx] = sort(numsigs);
for n = 1:size(allblocks_parsed.(fields{1}), 3) %for each roi
    has_respo1_sort(:,n) = has_respo1(:,sortrespo_indx(n));
    sort_respo1_amp(:,n) = o1_resp_amp(:,sortrespo_indx(n));
    has_respo2_sort(:,n) = has_respo2(:,sortrespo_indx(n));
    sort_respo2_amp(:,n) = o2_resp_amp(:,sortrespo_indx(n));
    sort_has_tune(:,n) = has_tune(:,sortrespo_indx(n));
end

% quarto1 = floor(length(sortrespo_indx)/4); % top quartile of responding rois
% quarto1_rois = sortrespo_indx((end-quarto1):end);
% quarto2 = floor(length(sortrespo_indx)/4); % top quartile of responding rois
% quarto2_rois = sortrespo_indx((end-quarto2):end);

%color_map=pmkmp(256, 'LinLhot');
color_map = redblue;

axis('fill');
set(0,'DefaultAxesFontSize',10)
sub1 = subplot(3,3,1);
jimage(has_respo1_sort'); colormap(flipud(gray));
sub1cb = colorbar; set(sub1cb,'FontSize',8);
cbfreeze(sub1cb);freezeColors;
title('Sig Blocks Odor A vs. baseline');
xlabel('time (20 frames)');
ylabel('roi (ranked)');

sub2 = subplot(3,3,2);
jimage(has_respo2_sort'); colormap(flipud(gray));
sub2cb = colorbar; set(sub2cb,'FontSize',8);cbfreeze(sub2cb);
freezeColors;
title('Sig Blocks Odor B vs. baseline');
xlabel('time (20 frames)');
ylabel('roi (ranked)');

sub3 = subplot(3,3,3);
jimage(sort_has_tune'); colormap(flipud(gray));
sub3cb = colorbar; set(sub3cb,'FontSize',8);cbfreeze(sub3cb);
freezeColors;
title('Tuned Blocks A vs. B');
xlabel('time (20 frames)');
ylabel('roi (ranked)');

sub4 = subplot(3,3,4);
cmin = nanmean(sort_respo1_amp(:))-(3*std(sort_respo1_amp(:),[],1));
cmax = nanmean(sort_respo1_amp(:))+(3*std(sort_respo1_amp(:),[],1));
imagesc(sort_respo1_amp', [cmin cmax]);
set(gca,'YDir','normal');
colormap(color_map);freezeColors;
sub4cb = colorbar; set(sub4cb,'FontSize',8);
colormap(color_map);cbfreeze(sub4cb);
title('Odor A timecourse of roi amplitudes');
xlabel('time (20 frames)');
ylabel('roi (ranked)');

sub5 = subplot(3,3,5);
imagesc(sort_respo2_amp', [cmin cmax]);
set(gca,'YDir','normal');
colormap(color_map);freezeColors;
sub5cb = colorbar; set(sub5cb,'FontSize',8);
colormap(color_map);cbfreeze(sub5cb);
title('Odor B timecourse of roi amplitudes');
xlabel('time (20 frames)');
ylabel('roi (ranked)');

sub6 = subplot(3,3,6);axis off;
text(.1, .9, rootdir, 'Interpreter', 'none', 'Fontsize', 10);
text(.1, .65, ['odorA = ' odor1], 'Fontsize', 10);
text(.1, .4, ['odorB = ' odor2], 'Fontsize', 10);

sub7 = subplot(3,3,7);
has_anyo1 = zeros(1,size(has_respo1,2));
    has_anyo1(any(has_respo1)) = 1;
    has_anyo1 = logical(has_anyo1);
has_anyo2 = zeros(1,size(has_respo2,2));
    has_anyo2(any(has_respo2)) = 1; 
    has_anyo2 = logical(has_anyo2);
o1mean = squeeze(nanmean(allblock_o1(:,:,has_anyo1),3));
    o1mean_nonan = o1mean;
    o1mean_nonan(isnan(o1mean)) = 0; %remove NaNs because they screw up the std function
o1error = std(o1mean_nonan,[],1)/sqrt(size(o1mean_nonan,1));
o2mean = squeeze(nanmean(allblock_o2(:,:,has_anyo2),3));
    o2mean_nonan = o2mean;
    o2mean_nonan(isnan(o2mean)) = 0; %remove NaNs because they screw up the std function
o2error = std(o2mean_nonan,[],1)/sqrt(size(o2mean_nonan,1));
cmin2 = nanmean(o1mean(:))-(3*std(o1mean_nonan(:),[],1));
cmax2 = nanmean(o1mean(:))+(3*std(o1mean_nonan(:),[],1));
imagesc(o1mean_nonan, [cmin2 cmax2]);
set(gca,'YDir','normal');
sub7cb = colorbar; colormap(redblue);set(sub7cb,'FontSize',8);
cbfreeze(sub7cb);freezeColors;
title('Odor A df/f of rois with significant response');
xlabel('time (frames)');
ylabel('trial');

sub8 = subplot(3,3,8);
imagesc(o2mean_nonan, [cmin2 cmax2]);
set(gca,'YDir','normal');
sub8cb = colorbar; set(sub8cb,'FontSize',8);cbfreeze(sub8cb);
colormap(redblue);freezeColors;
title('Odor B df/f of rois with significant response');
xlabel('time (frames)');
ylabel('trial');

sub9 = subplot(3,3,9);
shadedErrorBar([],nanmean(o1mean,1), o1error, {'color', [.5, .5, 1]}, 1);hold on;
shadedErrorBar([],nanmean(o2mean,1), o2error,  {'color', [1, 0.5, 0.2]}, 1);hold on;
axis tight;
xLimits = get(sub9,'XLim');
yLimits = get(sub9,'YLim');
h = patch([120; 120; 150; 150], [yLimits(1); yLimits(2); yLimits(2); yLimits(1);], [.7 .7 .7]);
set(h, 'FaceAlpha', .4, 'EdgeColor', 'none');
hlegend = legend(mat2str(odor1), mat2str(odor2));
    hkids = get(hlegend,'Children');    %# Get the legend children
    htext = hkids(strcmp(get(hkids,'Type'),'text')); %# Select the legend children of type 'text'
    set(htext,{'Color'},{[1, 0.5, 0.2]; [.5, .5, 1]});
    leg_line=findobj(hlegend,'type','Line');
    set(leg_line, {'Color'}, {[1, 0.5, 0.2]; [.5, .5, 1]});
title('A vs. B mean df/f of ROIs with significant response to baseline');
xlabel('time (frames)');
ylabel('df/f');

%packcols(3,3);


%%% Do allROI subplots
if ALLROI == 1
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
end
%end

