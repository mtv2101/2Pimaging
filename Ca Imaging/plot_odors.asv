function plot_odors(day, ALLDAYS, group1_data, group2_data, rootdir, group1_ids, group2_ids, group_diff_rank)

% Dependency: shadedErrorBar.m
% http://www.mathworks.com/matlabcentral/fileexchange/26311-shadederrorbar

ALLROI = 0;
OdorOnTime = 103; %Frame that odor valve opens
OdorOffTime = 133; %Frame that odor valve closes
takewin = 6:10; %time window containing odor response data

%%%%%%%%% get data
has_respg1 = [];has_respg2 = [];has_tune = [];gp1_resp_amp = [];gp2_resp_amp = [];
for roi = 1:length(ALLDAYS(day).stats) % for each roi
    has_respg1 = cat(2, has_respg1, ALLDAYS(day).stats(roi).sig_o1all);
    has_respg2 = cat(2, has_respg2, ALLDAYS(day).stats(roi).sig_o2all);
    has_tune = cat(2, has_tune, ALLDAYS(day).stats(roi).sig_odortuned);
    gp1_resp_amp = cat(2,gp1_resp_amp, nanmean(nanmean(ALLDAYS(day).stats(roi).mean_times_gp1(takewin)),2));
    gp2_resp_amp = cat(2,gp2_resp_amp, nanmean(nanmean(ALLDAYS(day).stats(roi).mean_times_gp2(takewin)),2));
end
allblock_1 = group1_data;
allblock_2 = group2_data;
    
%%%%%%%%% sort ROIS
statfields = {'sig_o1all', 'sig_o2all', 'sig_odortuned'};
for d = 1:length(ALLDAYS)
    %alldays_fields = fieldnames(ALLDAYS(d).stats);
    for roi = 1:length(ALLDAYS(day).stats)
        for k = 1:length(statfields)
            ns(k,roi,d) = nansum(ALLDAYS(d).stats(roi).(statfields{k}));
        end        
    end
end
numsigs = squeeze(nansum(nansum(ns,3),1));
resp_amp_diff = gp1_resp_amp-gp2_resp_amp;
[s_g1, sortrespg1_indx] = sort(gp1_resp_amp);
[s_g2, sortrespg2_indx] = sort(gp2_resp_amp);
[s_gall, sortrespgall_indx] = sort(resp_amp_diff);

num_rois = length(ALLDAYS(day).stats);
takerank = ceil(num_rois*group_diff_rank);
fill = zeros(size(has_tune,1), size(has_tune,2)-takerank);
for n = 1:num_rois %for each roi sort by group
    sig_respg1(:,n) = has_respg1(:,sortrespg1_indx(n));
    sig_respg1_amp(:,n) = squeeze(nanmean(allblock_1(:,:,sortrespg1_indx(n)),1));
    sig_respg2(:,n) = has_respg2(:,sortrespg2_indx(n));
    sig_respg2_amp(:,n) = squeeze(nanmean(allblock_2(:,:,sortrespg2_indx(n)),1));
    sort_has_tune(:,n) = has_tune(:,sortrespgall_indx(n));
end

% build full matrix containing only indices of desired rois
hasdiff_g1_up = cat(2, has_respg1(:,sortrespgall_indx(1:takerank)), fill);
hasdiff_g1_low = cat(2, fill, has_respg1(:,sortrespgall_indx(end-takerank+1:end)));
hasdiff_g2_up = cat(2, has_respg2(:,sortrespgall_indx(1:takerank)), fill);
hasdiff_g2_low = cat(2, fill, has_respg2(:,sortrespgall_indx(end-takerank+1:end)));

% convert matrices for logical indexing
sig_g1_idx = zeros(1,size(sig_respg1,2));
sig_g1_idx(any(sig_respg1)) = 1;
sig_g2_idx = zeros(1,size(sig_respg2,2));
sig_g2_idx(any(sig_respg2)) = 1;
diffidx_g1_up = zeros(1,size(hasdiff_g1_up,2));
diffidx_g1_up(any(hasdiff_g1_up)) = 1; %tests if any nonzero values along first dimension
diffidx_g1_up = logical(diffidx_g1_up); 
diffidx_g2_up = zeros(1,size(hasdiff_g2_up,2));
diffidx_g2_up(any(hasdiff_g2_up)) = 1;
diffidx_g2_up = logical(diffidx_g2_up);
diffidx_g1_low = zeros(1,size(hasdiff_g1_low,2));
diffidx_g1_low(any(hasdiff_g1_low)) = 1;
diffidx_g1_low = logical(diffidx_g1_low);
diffidx_g2_low = zeros(1,size(hasdiff_g2_low,2));
diffidx_g2_low(any(hasdiff_g2_low)) = 1;
diffidx_g2_low = logical(diffidx_g2_low);

color_map = redblue;

axis('fill');
set(0,'DefaultAxesFontSize',10);
sub1 = subplot(4,3,1);
jimage(sig_respg1'); colormap(flipud(gray));
sub1cb = colorbar; set(sub1cb,'FontSize',8);
cbfreeze(sub1cb);freezeColors;
title('Sig Blocks Group1 vs. baseline');
xlabel('time (20 frames)');
ylabel('roi (ranked)');

sub2 = subplot(4,3,2);
jimage(sig_respg2'); colormap(flipud(gray));
sub2cb = colorbar; set(sub2cb,'FontSize',8);cbfreeze(sub2cb);
freezeColors;
title('Sig Blocks Group2 vs. baseline');
xlabel('time (20 frames)');
ylabel('roi (ranked)');

sub3 = subplot(4,3,3);
jimage(sort_has_tune'); colormap(flipud(gray));
sub3cb = colorbar; set(sub3cb,'FontSize',8);cbfreeze(sub3cb);
freezeColors;
title('Tuned Blocks A vs. B (sorted by group1 ranking)');
xlabel('time (20 frames)');
ylabel('roi (ranked)');

sub4 = subplot(4,3,4);
cmin = nanmean(sig_respg1_amp(:))-(3*std(sig_respg1_amp(:),[],1));
cmax = nanmean(sig_respg1_amp(:))+(3*std(sig_respg1_amp(:),[],1));
imagesc(sig_respg1_amp', [cmin cmax]);
set(gca,'YDir','normal');
colormap(color_map);freezeColors;
sub4cb = colorbar; set(sub4cb,'FontSize',8);
colormap(color_map);cbfreeze(sub4cb);
title('Group1 ranked mean df/f of all trials per roi');
xlabel('time (20 frames)');
ylabel('roi (ranked)');

sub5 = subplot(4,3,5);
imagesc(sig_respg2_amp', [cmin cmax]);
set(gca,'YDir','normal');
colormap(color_map);freezeColors;
sub5cb = colorbar; set(sub5cb,'FontSize',8);
colormap(color_map);cbfreeze(sub5cb);
title('Group2 ranked mean df/f of all trials per roi');
xlabel('time (20 frames)');
ylabel('roi (ranked)');

sub6 = subplot(4,3,6);axis off;
text(.1, .9, rootdir, 'Interpreter', 'none', 'Fontsize', 10);
text(.1, .5, ['Group1 = ' group1_ids], 'Fontsize', 10);
text(.4, .5, ['Group2 = ' group2_ids], 'Fontsize', 10);

sub7 = subplot(4,3,7);
plot(s_gall, 'k');
set(gca,'YDir','normal');
title('Ranked difference group1 vs. group2 in the odor response period');
xlabel('ROI#');
ylabel('diff. mean df/f');

sub8 = subplot(4,3,8);
    if ~isempty(allblock_1)
        o1mean = squeeze(nanmean(allblock_1(:,:,diffidx_g1_up),3));
        o1mean_nonan = o1mean;
        o1mean_nonan(isnan(o1mean)) = 0; %remove NaNs because they screw up the std function
        o1error = std(o1mean_nonan,[],1)/sqrt(size(o1mean_nonan,1));
    end
    if ~isempty(allblock_2)
        o2mean = squeeze(nanmean(allblock_2(:,:,diffidx_g2_up),3));
        o2mean_nonan = o2mean;
        o2mean_nonan(isnan(o2mean)) = 0; %remove NaNs because they screw up the std function
        o2error = std(o2mean_nonan,[],1)/sqrt(size(o2mean_nonan,1));
    end
shadedErrorBar([],nanmean(o1mean,1), o1error, {'color', [1, 0.5, 0.2]}, 1);hold on;
shadedErrorBar([],nanmean(o2mean,1), o2error,  {'color', [.5, .5, 1]}, 1);hold on;
axis tight;
xLimits = get(sub8,'XLim');
yLimits = get(sub8,'YLim');
h = patch([OdorOnTime; OdorOnTime; OdorOffTime; OdorOffTime], [yLimits(1); yLimits(2); yLimits(2); yLimits(1);], [.7 .7 .7]);
set(h, 'FaceAlpha', .4, 'EdgeColor', 'none');
hlegend = legend('group1', 'group2');
hkids = get(hlegend,'Children');    %# Get the legend children
htext = hkids(strcmp(get(hkids,'Type'),'text')); %# Select the legend children of type 'text'
set(htext,{'Color'},{[.5, .5, 1]; [1, 0.5, 0.2]});
leg_line=findobj(hlegend,'type','Line');
set(leg_line, {'Color'}, {[.5, .5, 1]; [1, 0.5, 0.2]});
title('Group1 rois with greater mean df/f');
xlabel('time (frames)');
ylabel('df/f');

sub9 = subplot(4,3,9);
    if ~isempty(allblock_1)
        o1mean = squeeze(nanmean(allblock_1(:,:,diffidx_g1_low),3));
        o1mean_nonan = o1mean;
        o1mean_nonan(isnan(o1mean)) = 0; %remove NaNs because they screw up the std function
        o1error = std(o1mean_nonan,[],1)/sqrt(size(o1mean_nonan,1));
    end
    if ~isempty(allblock_2)
        o2mean = squeeze(nanmean(allblock_2(:,:,diffidx_g2_low),3));
        o2mean_nonan = o2mean;
        o2mean_nonan(isnan(o2mean)) = 0; %remove NaNs because they screw up the std function
        o2error = std(o2mean_nonan,[],1)/sqrt(size(o2mean_nonan,1));
    end
shadedErrorBar([],nanmean(o1mean,1), o1error, {'color', [1, 0.5, 0.2]}, 1);hold on;
shadedErrorBar([],nanmean(o2mean,1), o2error,  {'color', [.5, .5, 1]}, 1);hold on;
axis tight;
xLimits = get(sub9,'XLim');
yLimits = get(sub9,'YLim');
h = patch([OdorOnTime; OdorOnTime; OdorOffTime; OdorOffTime], [yLimits(1); yLimits(2); yLimits(2); yLimits(1);], [.7 .7 .7]);
set(h, 'FaceAlpha', .4, 'EdgeColor', 'none');
hlegend = legend('group1', 'group2');
hkids = get(hlegend,'Children');    %# Get the legend children
htext = hkids(strcmp(get(hkids,'Type'),'text')); %# Select the legend children of type 'text'
set(htext,{'Color'},{[.5, .5, 1]; [1, 0.5, 0.2]});
leg_line=findobj(hlegend,'type','Line');
set(leg_line, {'Color'}, {[.5, .5, 1]; [1, 0.5, 0.2]});
title('Group2 rois with greater mean df/f');
xlabel('time (frames)');
ylabel('df/f');

sub10 = subplot(4,3,10);
cmin2 = nanmean(o1mean(:))-(3*std(o1mean_nonan(:),[],1));
cmax2 = nanmean(o1mean(:))+(3*std(o1mean_nonan(:),[],1));
plot(s_g1, [.5, .5, 1]);hold on;plot(s_g2, [1, 0.5, 0.2]);
set(gca,'YDir','normal');
title('Ranked rois for each group by mean df/f in odor response window');
xlabel('ROI#');
ylabel('mean df/f');
% 
% sub11 = subplot(4,3,11);
% shadedErrorBar([],nanmean(o1mean,1), o1error, {'color', [1, 0.5, 0.2]}, 1);hold on;
% shadedErrorBar([],nanmean(o2mean_o1sig,1), o2error_o1sig,  {'color', [.5, .5, 1]}, 1);hold on;
% axis tight;
% xLimits = get(sub11,'XLim');
% yLimits = get(sub11,'YLim');
% h = patch([OdorOnTime; OdorOnTime; OdorOffTime; OdorOffTime], [yLimits(1); yLimits(2); yLimits(2); yLimits(1);], [.7 .7 .7]);
% set(h, 'FaceAlpha', .4, 'EdgeColor', 'none');
% hlegend = legend('group1', 'group2');
% hkids = get(hlegend,'Children');    %# Get the legend children
% htext = hkids(strcmp(get(hkids,'Type'),'text')); %# Select the legend children of type 'text'
% title('Low df/f significant group1 rois versus same rois in group2');
% xlabel('time (frames)');
% ylabel('df/f');
% 
% sub12 = subplot(4,3,12);
% shadedErrorBar([],nanmean(o1mean_o2sig,1), o1error_o2sig, {'color', [1, 0.5, 0.2]}, 1);hold on;
% shadedErrorBar([],nanmean(o2mean,1), o2error,  {'color', [.5, .5, 1]}, 1);hold on;
% axis tight;
% xLimits = get(sub9,'XLim');
% yLimits = get(sub9,'YLim');
% h = patch([OdorOnTime; OdorOnTime; OdorOffTime; OdorOffTime], [yLimits(1); yLimits(2); yLimits(2); yLimits(1);], [.7 .7 .7]);
% set(h, 'FaceAlpha', .4, 'EdgeColor', 'none');
% hlegend = legend('group1', 'group2');
% hkids = get(hlegend,'Children');    %# Get the legend children
% htext = hkids(strcmp(get(hkids,'Type'),'text')); %# Select the legend children of type 'text'
% title('Low df/f significant group2 rois versus same rois in group1');
% xlabel('time (frames)');
% ylabel('df/f');


%%% Do allROI subplots
if ALLROI == 1
    cat_allblock_o1 = [];
    cat_allblock_o2 = [];
    for k = 1:size(allblock_1,4)
        cat_allblock_o1 = cat(1, cat_allblock_o1, allblock_1(:,:,:,k));
        cat_allblock_o2 = cat(1, cat_allblock_o2, allblock_2(:,:,:,k));
    end
    numsubplots = size(allblock_1, 3); %number of ROIs
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
end

function [c] = redblue
%figure(h);
m=256;
nn = fix(0.5*m);
r = [(0:1:nn-1)/nn,ones(1,nn)];
g = [(0:nn-1)/nn, (nn-1:-1:0)/nn];
b = [ones(1,nn),(nn-1:-1:0)/nn];
c = [r(:), g(:), b(:)];
%colormap(c);
redblue = c;
end

