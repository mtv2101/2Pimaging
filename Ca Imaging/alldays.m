clear all

cd('C:\Users\supersub\Claire Dropbox\Dropbox\Matlab\Difficult task');
ALLROI = 0; % if = 1 plot all data in huge graphs

beh_types = {'HIT', 'CR', 'FA', 'MISS'};
odor_types = {'6EB 4AA', '4EB 6AA'}; % must be 2 odors
%odor1 = 'HEXANONE';
%odor2 = 'ETHYL TIG';
%odor1 = 'VALEDHYD';
%odor2 = 'CINEOLE';
%odor1 = '4EB 6AA';
%odor2 = '6EB 4AA';

% load "ALLBLOCKS" and "behaviors"
[blockname, blockdir, filtindx] = uigetfile('ALLBLOCKS*', 'MultiSelect', 'on');
[behname, behdir, filtindx] = uigetfile('behaviors*', 'MultiSelect', 'on');
numdays = size(blockname,1);

group1 = (1:4); %odor1:behavior1-4 are 1-4, odor2:behavior1-4 are 5-8; any arbirary grouping works
group2 = (5:8);

for day = 1:numdays
    if numdays > 1
        load(blockname{day});
        load(behname{day});
    else
        load(blockname)
        load(behname)
    end
    [ALLDAYS(day), group1_data, group2_data] = parse_odors_behaviors(...
        ALLBLOCKS, behaviors, group1, group2, odor_types, beh_types);
end

day = 4;
figure;
plot_odors(day, ALLDAYS, group1_data, group2_data);