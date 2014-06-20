function [ALLDAYS] =  parse_odors_behaviors(ALLBLOCKS, behaviors, odor1, odor2, beh_types)

% run this after parseROIs
% 2014-05-19 Code changed to remove loop bug when separating dff odor behaviors
% also OdONFrameIndx removed since valve timing has been corrected - Kurt
%
% 
% figure out repeated measures errors

BLOCKS = 1:length(ALLBLOCKS);

beh1 = beh_types{1}; %'HIT';
beh2 = beh_types{2}; %'CR';
beh3 = beh_types{3}; %'FA';
beh4 = beh_types{4}; %'MISS';
ALLROI = 0; % if =1 plot all traces in all rois
% OdorON = 120; % frame odor was delivered
triallen = 300;
sig_win = 20; % test for significant changes in windows of this size
post_x = 10; % multiply sig_win by this to get number of post-baseline frames
pre_x = 5;
alpha = .01;
postframes = sig_win*post_x;
preframes = sig_win*pre_x;
if postframes + preframes ~= triallen
    fprintf 'Please choose different "postframes" or "preframes" or "sig_win"';
    return
end
%cd(rootdir);

%load 'ALLBLOCKS.mat'
%load 'behaviors.mat'

% find what odors are used on what trials
o1_indx = regexp(behaviors, odor1);
o2_indx = regexp(behaviors, odor2);
o1_indx = o1_indx(:,1);
o2_indx = o2_indx(:,1);
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

% find what behavioral outcomes occur on what trials
b1_indx = regexp(behaviors, beh1);
b2_indx = regexp(behaviors, beh2);
b3_indx = regexp(behaviors, beh3);
b4_indx = regexp(behaviors, beh4);
b1_indx = b1_indx(:,2);
b2_indx = b2_indx(:,2);
b3_indx = b3_indx(:,2);
b4_indx = b4_indx(:,2);
for x = 1:length(b1_indx)
    if b1_indx{x} == 1
        b1(x) = 1;
    else
        b1(x) = 0;
    end
end
for x = 1:length(b2_indx)
    if b2_indx{x} == 1
        b2(x) = 1;
    else
        b2(x) = 0;
    end
end
for x = 1:length(b3_indx)
    if b3_indx{x} == 1
        b3(x) = 1;
    else
        b3(x) = 0;
    end
end
for x = 1:length(b4_indx)
    if b4_indx{x} == 1
        b4(x) = 1;
    else
        b4(x) = 0;
    end
end
b1 = logical(b1);
b2 = logical(b2);
b3 = logical(b3);
b4 = logical(b4);

% gather all trials of same odor and same behavior
allblocks_parsed.o1b1 = [];allblocks_parsed.o1b2 = [];allblocks_parsed.o1b3 = [];
allblocks_parsed.o1b4 = [];allblocks_parsed.o2b1 = [];allblocks_parsed.o2b2 = [];
allblocks_parsed.o2b3 = [];allblocks_parsed.o2b4 = [];
it1=1;it2=1;it3=1;it4=1;it5=1;it6=1;it7=1;it8=1;
trial = 1;
for b = BLOCKS
    alldff = ALLBLOCKS(b).dff;
    btrial = 1; %block trial
    % create seperate matrices for each odor
    for x = 1:size(ALLBLOCKS(b).dff,1) %for each trial
        if ALLBLOCKS(b).rejtrial(x) == 1
            continue
        end            
        if b1(trial) && o1(trial)
            o1b1_all(it1,:,:) = alldff(btrial,:,:);
            allblocks_parsed.o1b1 = cat(1, allblocks_parsed.o1b1, o1b1_all(it1,:,:));
            it1=it1+1;
        elseif b2(trial) && o1(trial)
            o1b2_all(it2,:,:) = alldff(btrial,:,:);
            allblocks_parsed.o1b2 = cat(1, allblocks_parsed.o1b2, o1b2_all(it2,:,:));
            it2=it2+1;
        elseif b3(trial) && o1(trial)
            o1b3_all(it3,:,:) = alldff(btrial,:,:);
            allblocks_parsed.o1b3 = cat(1, allallblocks_parsed.o1b3block_o1b3, o1b3_all(it3,:,:));
            it3=it3+1;
        elseif b4(trial) && o1(trial)
            o1b4_all(it4,:,:) = alldff(btrial,:,:);
            allblocks_parsed.o1b4 = cat(1, allblocks_parsed.o1b4, o1b4_all(it4,:,:));
            it4=it4+1;
        elseif b1(trial) && o2(trial)
            o2b1_all(it5,:,:) = alldff(btrial,:,:);
            allblocks_parsed.o2b1 = cat(1, allblocks_parsed.o2b1, o2b1_all(it5,:,:));
            it5=it5+1;
        elseif b2(trial) && o2(trial)
            o2b2_all(it6,:,:) = alldff(btrial,:,:);
            allblocks_parsed.o2b2 = cat(1, allblocks_parsed.o2b2, o2b2_all(it6,:,:));
            it6=it6+1;
        elseif b3(trial) && o2(trial)
            o2b3_all(it7,:,:) = alldff(btrial,:,:);
            allblocks_parsed.o2b3 = cat(1, allblocks_parsed.o2b3, o2b3_all(it7,:,:));
            it7=it7+1;
        elseif b4(trial) && o2(trial)
            o2b4_all(it8,:,:) = alldff(btrial,:,:);
            allblocks_parsed.o2b4 = cat(1, allblocks_parsed.o2b4, o2b4_all(it8,:,:));
            it8=it8+1;
        end
        btrial = btrial+1;
        trial = trial+1;
        clear frmindx
    end  
end
    
[ALLDAYS, ALLBLOCKS] = odor_stats(ALLBLOCKS, allblocks_parsed, sig_win,...
    post_x, pre_x, alpha, postframes, preframes);

[ALLDAYS, ALLBLOCKS] = beh_stats(ALLDAYS, ALLBLOCKS,...
    allblocks_parsed, post_x, pre_x, sig_win, alpha, postframes, preframes);

ALLDAYS.allblocks = allblocks_parsed;

end