function plot_odors(day, ALLDAYS, group1_data, group2_data, rootdir, group1_ids, group2_ids)

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
quartilerank = ceil(num_rois/4);
fill = zeros(size(has_tune,1), size(has_tune,2)-quartilerank);
for n = 1:num_rois %for each roi
    has_respg1_sort(:,n) = has_respg1(:,sortrespg1_indx(n));
    sort_respg1_amp(:,n) = squeeze(nanmean(allblock_1(:,:,sortrespg1_indx(n)),1));
    has_respg2_sort(:,n) = has_respg2(:,sortrespg2_indx(n));
    sort_respg2_amp(:,n) = squeeze(nanmean(allblock_2(:,:,sortrespg2_indx(n)),1));
    sort_has_tune(:,n) = has_tune(:,sortrespgall_indx(n));
end
has_respg1_upper = cat(2, has_respg1(:,sortrespgall_indx(1:quartilerank)), fill);
has_respg1_lower = cat(2, fill, has_respg1(:,sortrespgall_indx(end-quartilerank+1:end)));
has_respg2_upper = cat(2, has_respg2(:,sortrespgall_indx(1:quartilerank)), fill);
has_respg2_lower = cat(2, fill, has_respg2(:,sortrespgall_indx(end-quartilerank+1:end)));

color_map = redblue;

axis('fill');
set(0,'DefaultAxesFontSize',10);
sub1 = subplot(4,3,1);
jimage(has_respg1_sort'); colormap(flipud(gray));
sub1cb = colorbar; set(sub1cb,'FontSize',8);
cbfreeze(sub1cb);freezeColors;
title('Sig Blocks Group1 vs. baseline');
xlabel('time (20 frames)');
ylabel('roi (ranked)');

sub2 = subplot(4,3,2);
jimage(has_respg2_sort'); colormap(flipud(gray));
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
cmin = nanmean(sort_respg1_amp(:))-(3*std(sort_respg1_amp(:),[],1));
cmax = nanmean(sort_respg1_amp(:))+(3*std(sort_respg1_amp(:),[],1));
imagesc(sort_respg1_amp', [cmin cmax]);
set(gca,'YDir','normal');
colormap(color_map);freezeColors;
sub4cb = colorbar; set(sub4cb,'FontSize',8);
colormap(color_map);cbfreeze(sub4cb);
title('Group1 ranked mean df/f of all trials per roi');
xlabel('time (20 frames)');
ylabel('roi (ranked)');

sub5 = subplot(4,3,5);
imagesc(sort_respg2_amp', [cmin cmax]);
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
has_anyo1_up = zeros(1,size(has_respg1_upper,2));
has_anyo1_up(any(has_respg1_upper)) = 1;
has_anyo1_up = logical(has_anyo1_up);
has_anyo2_up = zeros(1,size(has_respg2_upper,2));
has_anyo2_up(any(has_respg2_upper)) = 1;
has_anyo2_up = logical(has_anyo2_up);
    if ~isempty(allblock_1)
        o1mean = squeeze(nanmean(allblock_1(:,:,has_anyo1_up),3));
        o1mean_nonan = o1mean;
        o1mean_nonan(isnan(o1mean)) = 0; %remove NaNs because they screw up the std function
        o1error = std(o1mean_nonan,[],1)/sqrt(size(o1mean_nonan,1));
        o1mean_o2sig = squeeze(nanmean(allblock_1(:,:,has_anyo2_up),3));
        o1mean_o2sig_nonan = o1mean_o2sig;
        o1mean_o2sig_nonan(isnan(o1mean_o2sig)) = 0; %remove NaNs because they screw up the std function
        o1error_o2sig = std(o1mean_o2sig_nonan,[],1)/sqrt(size(o1mean_o2sig_nonan,1));
    end
    if ~isempty(allblock_2)
        o2mean = squeeze(nanmean(allblock_2(:,:,has_anyo2_up),3));
        o2mean_nonan = o2mean;
        o2mean_nonan(isnan(o2mean)) = 0; %remove NaNs because they screw up the std function
        o2error = std(o2mean_nonan,[],1)/sqrt(size(o2mean_nonan,1));
        o2mean_o1sig = squeeze(nanmean(allblock_2(:,:,has_anyo1_up),3));
        o2mean_o1sig_nonan = o2mean_o1sig;
        o2mean_o1sig_nonan(isnan(o2mean_o1sig)) = 0; %remove NaNs because they screw up the std function
        o2error_o1sig = std(o2mean_o1sig_nonan,[],1)/sqrt(size(o2mean_o1sig_nonan,1));
    end
cmin2 = nanmean(o1mean(:))-(3*std(o1mean_nonan(:),[],1));
cmax2 = nanmean(o1mean(:))+(3*std(o1mean_nonan(:),[],1));
imagesc(o1mean_nonan, [cmin2 cmax2]);
set(gca,'YDir','normal');
sub7cb = colorbar; colormap(redblue);set(sub7cb,'FontSize',8);
cbfreeze(sub7cb);freezeColors;
title('Odor A df/f of rois with significant response');
xlabel('time (frames)');
ylabel('trial');

sub8 = subplot(4,3,8);
shadedErrorBar([],nanmean(o1mean,1), o1error, {'color', [1, 0.5, 0.2]}, 1);hold on;
shadedErrorBar([],nanmean(o2mean_o1sig,1), o2error_o1sig,  {'color', [.5, .5, 1]}, 1);hold on;
axis tight;
xLimits = get(sub8,'XLim');
yLimits = get(sub8,'YLim');
h = patch([OdorOnTime; OdorOnTime; OdorOffTime; OdorOffTime], [yLimits(1); yLimits(2); yLimits(2); yLimits(1);], [.7 .7 .7]);
set(h, 'FaceAlpha', .4, 'EdgeColor', 'none');
hlegend = legend('group1', 'group2');
hkids = get(hlegend,'Children');    %# Get the legend children
htext = hkids(strcmp(get(hkids,'Type'),'text')); %# Select the legend children of type 'text'
title('High df/f significant group1 rois versus same rois in group2');
xlabel('time (frames)');
ylabel('df/f');

sub9 = subplot(4,3,9);
shadedErrorBar([],nanmean(o1mean_o2sig,1), o1error_o2sig, {'color', [1, 0.5, 0.2]}, 1);hold on;
shadedErrorBar([],nanmean(o2mean,1), o2error,  {'color', [.5, .5, 1]}, 1);hold on;
axis tight;
xLimits = get(sub9,'XLim');
yLimits = get(sub9,'YLim');
h = patch([OdorOnTime; OdorOnTime; OdorOffTime; OdorOffTime], [yLimits(1); yLimits(2); yLimits(2); yLimits(1);], [.7 .7 .7]);
set(h, 'FaceAlpha', .4, 'EdgeColor', 'none');
hlegend = legend('group1', 'group2');
hkids = get(hlegend,'Children');    %# Get the legend children
htext = hkids(strcmp(get(hkids,'Type'),'text')); %# Select the legend children of type 'text'
title('High df/f significant group2 rois versus same rois in group1');
xlabel('time (frames)');
ylabel('df/f');

sub10 = subplot(4,3,10);
has_anyo1_low = zeros(1,size(has_respg1_lower,2));
has_anyo1_low(any(has_respg1_lower)) = 1;
has_anyo1_low = logical(has_anyo1_low);
has_anyo2_low = zeros(1,size(has_respg2_lower,2));
has_anyo2_low(any(has_respg2_lower)) = 1;
has_anyo2_low = logical(has_anyo2_low);
    if ~isempty(allblock_1)
        o1mean = squeeze(nanmean(allblock_1(:,:,has_anyo1_low),3));
        o1mean_nonan = o1mean;
        o1mean_nonan(isnan(o1mean)) = 0; %remove NaNs because they screw up the std function
        o1error = std(o1mean_nonan,[],1)/sqrt(size(o1mean_nonan,1));
        o1mean_o2sig = squeeze(nanmean(allblock_1(:,:,has_anyo2_low),3));
        o1mean_o2sig_nonan = o1mean_o2sig;
        o1mean_o2sig_nonan(isnan(o1mean_o2sig)) = 0; %remove NaNs because they screw up the std function
        o1error_o2sig = std(o1mean_o2sig_nonan,[],1)/sqrt(size(o1mean_o2sig_nonan,1));
    end
    if ~isempty(allblock_2)
        o2mean = squeeze(nanmean(allblock_2(:,:,has_anyo2_low),3));
        o2mean_nonan = o2mean;
        o2mean_nonan(isnan(o2mean)) = 0; %remove NaNs because they screw up the std function
        o2error = std(o2mean_nonan,[],1)/sqrt(size(o2mean_nonan,1));
        o2mean_o1sig = squeeze(nanmean(allblock_2(:,:,has_anyo1_low),3));
        o2mean_o1sig_nonan = o2mean_o1sig;
        o2mean_o1sig_nonan(isnan(o2mean_o1sig)) = 0; %remove NaNs because they screw up the std function
        o2error_o1sig = std(o2mean_o1sig_nonan,[],1)/sqrt(size(o2mean_o1sig_nonan,1));
    end
cmin2 = nanmean(o1mean(:))-(3*std(o1mean_nonan(:),[],1));
cmax2 = nanmean(o1mean(:))+(3*std(o1mean_nonan(:),[],1));
imagesc(o1mean_nonan, [cmin2 cmax2]);
set(gca,'YDir','normal');
sub10cb = colorbar; colormap(redblue);set(sub10cb,'FontSize',8);
cbfreeze(sub10cb);freezeColors;
title('Odor A df/f of rois with significant response');
xlabel('time (frames)');
ylabel('trial');

sub11 = subplot(4,3,11);
shadedErrorBar([],nanmean(o1mean,1), o1error, {'color', [1, 0.5, 0.2]}, 1);hold on;
shadedErrorBar([],nanmean(o2mean_o1sig,1), o2error_o1sig,  {'color', [.5, .5, 1]}, 1);hold on;
axis tight;
xLimits = get(sub11,'XLim');
yLimits = get(sub11,'YLim');
h = patch([OdorOnTime; OdorOnTime; OdorOffTime; OdorOffTime], [yLimits(1); yLimits(2); yLimits(2); yLimits(1);], [.7 .7 .7]);
set(h, 'FaceAlpha', .4, 'EdgeColor', 'none');
hlegend = legend('group1', 'group2');
hkids = get(hlegend,'Children');    %# Get the legend children
htext = hkids(strcmp(get(hkids,'Type'),'text')); %# Select the legend children of type 'text'
title('Low df/f significant group1 rois versus same rois in group2');
xlabel('time (frames)');
ylabel('df/f');

sub12 = subplot(4,3,12);
shadedErrorBar([],nanmean(o1mean_o2sig,1), o1error_o2sig, {'color', [1, 0.5, 0.2]}, 1);hold on;
shadedErrorBar([],nanmean(o2mean,1), o2error,  {'color', [.5, .5, 1]}, 1);hold on;
axis tight;
xLimits = get(sub9,'XLim');
yLimits = get(sub9,'YLim');
h = patch([OdorOnTime; OdorOnTime; OdorOffTime; OdorOffTime], [yLimits(1); yLimits(2); yLimits(2); yLimits(1);], [.7 .7 .7]);
set(h, 'FaceAlpha', .4, 'EdgeColor', 'none');
hlegend = legend('group1', 'group2');
hkids = get(hlegend,'Children');    %# Get the legend children
htext = hkids(strcmp(get(hkids,'Type'),'text')); %# Select the legend children of type 'text'
title('Low df/f significant group2 rois versus same rois in group1');
xlabel('time (frames)');
ylabel('df/f');


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

