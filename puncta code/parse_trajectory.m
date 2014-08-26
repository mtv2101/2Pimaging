function [allpuncta, roi_valid] = parse_trajectory(rootdir, days_toanalyze)

%clear all 

%rootdir = 'C:\Users\supersub\Desktop\Data\text files\MC lateral';
    
cd(rootdir);
FullList = dir;
MaximaList = dir(['*.txt']);
roi = length(MaximaList); %number of rois

%days_toanalyze = (1:8); % [1..8]

for k = 1:roi %for each text file of maxima
    maximaname = MaximaList(k).name;
    
    % open .txt file of maxima
    delimiter = {'\t',' '};
    formatSpec = '%s%s%s%s%s%s%[^\n\r]';
    fileID = fopen(maximaname,'r');
    dataarray = textscan(fileID, formatSpec, 'Delimiter', delimiter, 'ReturnOnError', false);
    fclose(fileID);
    frame = dataarray{:, 1};
    s = strmatch('%%', frame);
    start = s(1);
    frame = frame((start+13):end);
    
    x = dataarray{:,2};
    x = x((start+13):end);
    y = dataarray{:,3};
    y = y((start+13):end);
    z = dataarray{:,4};
    z = z((start+13):end);
    
    total_indxs = strmatch('Frame ', dataarray{1,2});
    %total_indxs = total_indxs(2:(2+length(days))); %these are the "Frame" we want
    total_particles = dataarray{1,2};
    total_particles = total_particles(total_indxs+1);
    total_days = length(total_particles)/2; % detecting the number of days (frames)
    
%     if length(days_toanalyze) > total_days
%         disp 'skipped'
%         continue        
%     end    
    
    parens = strmatch('%%', frame);
    traj_idx = parens(1:2:end)+2; %every other "%%" marks trajectory start
    traj_idx = cat(1, 1, traj_idx);
        
    for t = 1:length(traj_idx) %for all trajectories
        firstobs = str2double(frame{traj_idx(t)});
        %interest_indx = find(puncta_interest==1);
        if t == length(traj_idx)
            puncta(t).lifetime = length(x) - traj_idx(t);
            framesobs = str2double(frame(traj_idx(t):end));
        else
            puncta(t).lifetime = traj_idx(t+1)-3 - traj_idx(t);
            framesobs = str2double(frame(traj_idx(t):(traj_idx(t+1)-3)));
        end
        framesobs_offset = framesobs - days_toanalyze(1)+1; %set first frame observation to 1
        framesobs_offset(framesobs_offset < 0) = []; % if observation before first day, make null
        framesobs_offset(framesobs_offset > length(days_toanalyze)) = [];
        if length(framesobs_offset) == 1
            framesobs_offset = [];
        end
        puncta(t).framesobs = framesobs_offset;
    end
    
    allpuncta_intraj = [];
    for d = 1:days_toanalyze(end)-1 %dont iterate to last day which is all single 
        for n = 1:length(puncta) 
            pun(d,n) = length(find(puncta(n).framesobs == d));
            allpuncta_intraj = cat(2, allpuncta_intraj, pun(d,n));
        end
    end
    
    sum_total_particles = sum(str2double(total_particles(days_toanalyze)));
    totpuncta_intraj = sum(allpuncta_intraj);      
    %for p = interest_indx
    %    ave_len(p) = puncta(p).lifetime;
    %end
    %mean_ave_len = mean(ave_len+1);
    %puncta_intraj = mean_ave_len*length(traj_s); % = average traj length * num trajectories
    %num_singles = sum_total_particles - totpuncta_intraj;
        
    for n = 1:length(traj_idx)
        ltime_cumhist(n) = length(puncta(n).framesobs); % get lifetime
    end
    %ltime_cumhist(ltime_cumhist > max(days_toanalyze)) = 4; %force liftimes into 4-day format
    %ltime_cumhist(ltime_cumhist < min(days_toanalyze)) = 1;

    %ltime_cumhist = cat(2, ltime_cumhist, zeros(1,num_singles)); %add non-trajectory single particles to cumulative histogram
    cumhist = ecdf(ltime_cumhist, 'function', 'survivor');
    
    allpuncta(k).puncta = puncta;
    allpuncta(k).maximaname = maximaname;
    allpuncta(k).cumhist = cumhist;
    allpuncta(k).lifetimes = ltime_cumhist;
    allpuncta(k).puncta_matrix = pun;
    
    roi_valid(k) = k;
    roi_valid(roi_valid==0) = [];
    clear puncta cumhist lentraj ltime_cumhist frame parens traj_idx puncta_interest interest_indx pun
end
% 
% all_lifetimes = [];
%     for k = 1:roi
%         all_lifetimes = cat(2, all_lifetimes, allpuncta(k).lifetimes);
%         all_cumhist = allpuncta(k).cumhist;
%         plot(all_cumhist(1:end-1), 'k'); ylim([0 1]); hold on;
%     end

end