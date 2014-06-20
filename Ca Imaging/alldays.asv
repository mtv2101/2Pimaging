clear all

numdays = 2;
cd('G:\Kurt\Training in Metch olfactometer study\031114-05\Easy task2 comparison');
ALLROI = 0; % if = 1 plot all data in huge graphs

odor1 = 'ETHYLTIG';
odor2 = 'HEXANONE';
%odor1 = 'CINEOLE';
%odor2 = 'VALEDHYD';
%odor1 = '6EB 4AA';
%odor2 = '4EB 6AA';
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