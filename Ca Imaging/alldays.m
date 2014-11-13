clear all

numdays = 4;
cd('C:\Users\supersub\Claire Dropbox\Dropbox\Matlab\Difficult task');
ALLROI = 0; % if = 1 plot all data in huge graphs

odor1 = '6EB 4AA';
odor2 = '4EB 6AA';
%odor1 = 'HEXANONE';
%odor2 = 'ETHYL TIG';
%odor1 = 'VALEDHYD';
%odor2 = 'CINEOLE';
%odor1 = '4EB 6AA';
%odor2 = '6EB 4AA';
beh_types = {'HIT', 'CR', 'FA', 'MISS'};

% load "ALLBLOCKS'
[blockname, blockdir, filtindx] = uigetfile('ALLBLOCKS*', 'MultiSelect', 'on');
% load 'behaviors'
[behname, behdir, filtindx] = uigetfile('behaviors*', 'MultiSelect', 'on');

for day = 1:numdays
    load(blockname{day});
    load(behname{day});
    [ALLDAYS(day)] = parse_odors_behaviors(ALLBLOCKS, behaviors, odor1, odor2, beh_types);
end

for day = 1:numdays
    figure;
    plot_odors(day, ALLDAYS, blockdir, odor1, odor2);
end