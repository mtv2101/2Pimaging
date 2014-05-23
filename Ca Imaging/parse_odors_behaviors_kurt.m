% run this after parseROIs
% 2014-05-19 Code changed to remove loop bug when separating dff odor behaviors
% also OdONFrameIndx removed since valve timing has been corrected - Kurt
%
% 
% figure out repeated measures errors

clear all

rootdir = 'C:\Kurt\Pre-training study\031114-07\2014-04-25\Block1';
odor1 = 'VALEDHYD';
odor2 = 'CINEOLE';
% OdorON = 120; % frame odor was delivered
sig_win = 20; % test for significant changes in windows of this size
post_x = 8; % multiply sig_win by this to get number of post-baseline frames
pre_x = 5;
alpha = .01;
postframes = sig_win*post_x;
preframes = sig_win*pre_x;

cd(rootdir);

load 'ALLBLOCKS.mat'
load 'behaviors.mat'

% find what odors are used on what trials
odor1_indx = regexp(behaviors, odor1);
odor2_indx = regexp(behaviors, odor2);
o1_indx = odor1_indx(:,1);
o2_indx = odor2_indx(:,1);
for x = 1:length(o1_indx)
    if o1_indx{x} == 1
        o1(x) = 1;
    else
        o1(x) = 0;
    end
    if o2_indx{x} == 1
        o2(x) = 1;
    else
        o2(x) = 0;
    end
end
o1 = logical(o1);
o2 = logical(o2);
    
for b = 1:length(ALLBLOCKS)
    alldff = ALLBLOCKS(b).dff;
    it1 = 1;
    it2 = 1;
    trial = 1;
    % create seperate matrices for each odor
    for x = 1:size(ALLBLOCKS(b).dff,1) %for each trial
        if ALLBLOCKS(x).rejtrial
            
        if o1(trial)
            o1_all(it1,:,:) = alldff(trial,:,:);
            allblock_o1(it1,:,:,b) = o1_all(it1,:,:);
            it1=it1+1;
        elseif o2(trial)
            o2_all(it2,:,:) = alldff(trial,:,:);
            allblock_o2(it2,:,:,b) = o2_all(it2,:,:);
            it2=it2+1;
        end
        trial = trial+1;
        clear frmindx
    end  
    
    %%%%%% find rois with significant responses relative to baseline
    for r = 1:size(alldff,3) %for each roi
        baseline = 1:preframes;
        dffbase_o1 = nanmean(allblock_o1(:, baseline, r, b), 2);
        dffbase_o2 = nanmean(allblock_o2(:, baseline, r, b), 2);
        for w = 1:(pre_x+post_x)
            winstart = 1:sig_win:(preframes+postframes);
            indx = winstart(w):(winstart(w)+sig_win);
            [h_testo1(r,w), p_testo1(r,w)] = ttest2(dffbase_o1,...
                nanmean(allblock_o1(:, indx, r, b), 2), 'alpha', alpha);
            [h_testo2(r,w), p_testo2(r,w)] = ttest2(dffbase_o2,...
                nanmean(allblock_o2(:, indx, r, b), 2), 'alpha', alpha);
        end
    end
    ALLBLOCKS(b).o1response_sigs = p_testo1;
    ALLBLOCKS(b).o2response_sigs = p_testo2;
    
    %%%%%%% find rois with sig responses between two odors
    for r = 1:size(alldff,3) %for each roi
        for w = 1:size(o1_all,2)-1-sig_win %iterate all frames minus end pad
            indx = w:(sig_win+w); %sliding window
            o1stat = nanmean(o1_all(:, indx, r),2);
            o2stat = nanmean(o2_all(:, indx, r),2);
            [h(r,w), p(r,w)] = ttest2(o1stat, o2stat, 'alpha', alpha);
        end
    end
    ALLBLOCKS(b).tune_sigs = p;
    clear alldff;
end

%%%%% find rois that have different responses between the two odors
for b = 1:length(ALLBLOCKS)
    for r = 1:size(ALLBLOCKS(b).tune_sigs,1) %for each roi
        if find(ALLBLOCKS(b).tune_sigs(r,:) < alpha) %if there are sig frames
            has_tune(r,b) = length(find(ALLBLOCKS(b).tune_sigs(r,:) < alpha)); %there are x sig frames
        else
            has_tune(r,b) = 0;
        end        
        if isempty(find(ALLBLOCKS(b).o1response_sigs(r,:) < alpha))
            has_respo1(r,b) = 0;
        else
            has_respo1(r,b) = 1;
        end
        if isempty(find(ALLBLOCKS(b).o2response_sigs(r,:) < alpha))
            has_respo2(r,b) = 0;
        else
            has_respo2(r,b) = 1;
        end
    end
    all_tune_sigs(:,:,b) = ALLBLOCKS(b).tune_sigs;
    o1_resp_sigs(:,:,b) = ALLBLOCKS(b).o1response_sigs;
    o2_resp_sigs(:,:,b) = ALLBLOCKS(b).o2response_sigs;
end


%%%%%%%%% sort ROIS
o1response_rank = sum(has_respo1,2);
[sort_respo1, sortrespo1_indx] = sort(o1response_rank);
for n = 1:size(o1_resp_sigs,1) %for each roi
    has_respo1_sort(n,:) = has_respo1(sortrespo1_indx(n),:);
    sort_respo1_sigs(n,:,:) = o1_resp_sigs(sortrespo1_indx(n),:,:);
    sort_tune_sigs(n,:,:) = all_tune_sigs(sortrespo1_indx(n),:,:);
end
o2response_rank = sum(has_respo2,2);
[sort_respo2, sortrespo2_indx] = sort(o2response_rank);
for n = 1:size(o2_resp_sigs,1) %for each roi
    has_respo2_sort(n,:) = has_respo2(sortrespo2_indx(n),:);
    sort_respo2_sigs(n,:,:) = o2_resp_sigs(sortrespo2_indx(n),:,:);
    sort_tune_sigs(n,:,:) = all_tune_sigs(sortrespo2_indx(n),:,:);
end

%%%%%% describe timecourse of ROIS over all trials
cat_allblock_o1 = [];
cat_allblock_o2 = [];
for k = 1:size(allblock_o1,4)
    cat_allblock_o1 = cat(1, cat_allblock_o1, allblock_o1(:,:,:,k));
    cat_allblock_o2 = cat(1, cat_allblock_o2, allblock_o2(:,:,:,k));
end
for m = 1:size(cat_allblock_o1,3) %for each roi
    win1 = [1:80]; %baseline
    win2 = [90:100]; %pre-odor
    win3 = [100:150]; %odor
    win4 = [150:200]; %post-odor
    trend_o1(:,:,m) = [squeeze(nanmean(cat_allblock_o1(:,win1,m),2)),...
        squeeze(nanmean(cat_allblock_o1(:,win2,m),2)),...
        squeeze(nanmean(cat_allblock_o1(:,win3,m),2)),...
        squeeze(nanmean(cat_allblock_o1(:,win4,m),2))];
    trend_o2(:,:,m) = [squeeze(nanmean(cat_allblock_o2(:,win1,m),2)),...
        squeeze(nanmean(cat_allblock_o2(:,win2,m),2)),...
        squeeze(nanmean(cat_allblock_o2(:,win3,m),2)),...
        squeeze(nanmean(cat_allblock_o2(:,win4,m),2))];
end
    

% plot_odors(rootdir, odor1, odor2, sortrespo1_indx, sortrespo2_indx, has_respo1_sort,...
%   has_respo2_sort, sort_respo1, sort_respo2, allblock_o1, allblock_o2,...
%  sort_respo1_sigs, sort_respo2_sigs, has_tune)

% plot averages of odorants
o1_ave = squeeze(nanmean(o1_all(:,:,:),1));
figure;imagesc(o1_ave');colormap(hot);title(odor1);
o2_ave = squeeze(nanmean(o2_all(:,:,:),1));
figure;imagesc(o2_ave');colormap(hot);title(odor2);
