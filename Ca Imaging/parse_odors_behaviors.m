function [ALLDAYS, group1_data, group2_data] =  parse_odors_behaviors(...
    ALLBLOCKS, behaviors, group1, group2, odor_types, beh_types, parse_params)

% run this after parseROIs


BLOCKS = 1:length(ALLBLOCKS);

triallen = parse_params(1);
sig_win = parse_params(2);
post_x = parse_params(3);
pre_x = parse_params(4);
alpha = parse_params(5);

% find what odors are used on what trials
o1_indx = regexp(behaviors, odor_types{1});
o2_indx = regexp(behaviors, odor_types{2});
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
b1_indx = regexp(behaviors, beh_types{1});
b2_indx = regexp(behaviors, beh_types{2});
b3_indx = regexp(behaviors, beh_types{3});
b4_indx = regexp(behaviors, beh_types{4});
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
fieldnames = {'o1b1','o1b2','o1b3','o1b4','o2b1','o2b2','o2b3','o2b4'};
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
            allblocks_parsed.o1b3 = cat(1, allblocks_parsed.o1b3, o1b3_all(it3,:,:));
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

group1_data = [];
for i = 1:length(group1)
    group1_data = cat(1, group1_data, allblocks_parsed.(fieldnames{group1(i)}));
end
group2_data = [];
for i = 1:length(group2)
    group2_data = cat(1, group2_data, allblocks_parsed.(fieldnames{group2(i)}));
end

ALLDAYS.allblocks = allblocks_parsed;

end