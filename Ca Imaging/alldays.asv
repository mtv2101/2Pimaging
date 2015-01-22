clear all

cd('C:\Users\supersub\Claire Dropbox\Dropbox\Matlab\Difficult task');
rootdir = cd;
ALLROI = 0; % if = 1 plot all data in huge graphs

beh_types = {'HIT', 'CR', 'FA', 'MISS'};
odor_types = {'6EB 4AA', '4EB 6AA'}; % must be 2 odors
%odor1 = 'HEXANONE';
%odor2 = 'ETHYL TIG';
%odor1 = 'VALEDHYD';
%odor2 = 'CINEOLE'; 
%odor1 = '4EB 6AA';
%odor2 = '6EB 4AA';

first_day = 1; %if multiple days are selected, this is day of the first selection
triallen = 300;
sig_win = 20; % test for significant changes in windows of this size
post_x = 10; % multiply sig_win by this to get number of post-baseline frames
pre_x = 5;
alpha = .001;
parse_params = [triallen, sig_win, post_x, pre_x, alpha];

% Assign trials to groups.  
% Odor1:behavior1-4 are 1-4, odor2:behavior1-4 are 5-8; any arbirary grouping works
group1 = (1:4); 
group2 = (5:8);

% load "ALLBLOCKS" and "behaviors"
[blockname, blockdir, filtindx] = uigetfile('ALLBLOCKS*', 'MultiSelect', 'on');
[behname, behdir, filtindx] = uigetfile('behaviors*', 'MultiSelect', 'on');
if ischar(blockname)
    numdays = 1;
else
    numdays = size(blockname,2);
end

postframes = sig_win*post_x;
preframes = sig_win*pre_x;
if postframes + preframes ~= triallen
    fprintf 'Please choose different "postframes" or "preframes" or "sig_win"';
    return
end

for day = first_day:numdays+(first_day-1)
    disp(['analyzing day ', num2str(day)]);
    if numdays > 1
        load(blockname{day});
        load(behname{day});
    else
        load(blockname)
        load(behname)
    end
    
    [alldays_day, group1_data, group2_data, group1_ids, group2_ids] = parse_odors_behaviors(...
        ALLBLOCKS, behaviors, group1, group2, odor_types, beh_types, parse_params);
    
    [alldays_day, ALLBLOCKS] = odor_stats(alldays_day, ALLBLOCKS, sig_win, post_x, pre_x, alpha,...
        postframes, preframes, group1_data, group2_data);

    [alldays_day, ALLBLOCKS] = beh_stats(alldays_day, ALLBLOCKS,...
        post_x, pre_x, sig_win, postframes, preframes,group1_data, group2_data);
    
    ALLDAYS(day) = alldays_day;
    
    figure;
    plot_odors(day, ALLDAYS, group1_data, group2_data, rootdir, group1_ids, group2_ids);
end