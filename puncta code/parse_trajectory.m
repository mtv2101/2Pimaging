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
    total_particles = str2double(total_particles(1:length(total_particles)/2)); % cut out text data trailing particle data
    total_days = length(total_particles)/2; % detecting the number of days (frames)
    
    parens = strmatch('%%', frame);
    traj_idx = parens(1:2:end)+2; %every other "%%" marks trajectory start
    traj_idx = cat(1, 1, traj_idx);
    
    for t = 1:length(traj_idx) %for all trajectories
        firstobs = str2double(frame{traj_idx(t)});
        if t == length(traj_idx)
            framesobs = str2double(frame(traj_idx(t):end));
        else
            framesobs = str2double(frame(traj_idx(t):(traj_idx(t+1)-3))); %subtract 3 to index past the two "%%" marks
        end
        framesobs_offset = framesobs - days_toanalyze(1)+2; %shift so first frame eq 1 - add 2 because we call day 1 as 1 even though mosaic calls it day0
        framesobs_offset(framesobs_offset <= 0) = []; % if observation before first day, make null
        framesobs_offset(framesobs_offset > length(days_toanalyze)) = [];
        if length(framesobs_offset) == 1 || ~isnumeric(framesobs_offset)
            framesobs_offset = [];
        end
        puncta(t).framesobs = framesobs_offset;  
    end
    
    i=0;
    for t = 1:length(puncta)
        if isnumeric(puncta(t).framesobs(1)) %skip trajectories that are set to [];
            [nn, fr_intsect, nm] = intersect(puncta(t).framesobs, days_toanalyze); %get index of only days that have trajectories that are in desired date range
            for n = 1:length(puncta(t).framesobs)
                allx(n) = str2double(x{traj_idx(t)+n-1});
                ally(n) = str2double(y{traj_idx(t)+n-1});
                allz(n) = str2double(z{traj_idx(t)+n-1});
            end
            puncta(t).x = allx(fr_intsect);
            puncta(t).y = ally(fr_intsect);
            puncta(t).z = allz(fr_intsect);            
            i=i+1;
            numtrajs = i;
        end            
    end    
    puncta = puncta(1:numtrajs);
    
    allpuncta_intraj = [];
    for d = 1:days_toanalyze(end)-1 %dont iterate to last day which is all single
        for n = 1:length(puncta)
            pun(d,n) = length(find(puncta(n).framesobs == d)); % get each roi with a puncta detected that day            
        end
        allpuncta_intraj = cat(2, allpuncta_intraj, pun(d,:));
    end
    
    sum_total_particles = sum(total_particles(days_toanalyze(1:end-1))); % dont get trajectories from last day - single also not counted from last day
    totpuncta_intraj = sum(allpuncta_intraj);
    num_singles = sum_total_particles - totpuncta_intraj;
    
    for n = 1:length(puncta) %length puncta may be shorter than traj_indx because some puncta lie aoutside day range
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
    allpuncta(k).numsingles = num_singles;
    
    roi_valid(k) = k;
    roi_valid(roi_valid==0) = [];
    clear dataarray puncta cumhist lentraj ltime_cumhist frame parens traj_idx allpuncta_intraj pun
end
%
% all_lifetimes = [];
%     for k = 1:roi
%         all_lifetimes = cat(2, all_lifetimes, allpuncta(k).lifetimes);
%         all_cumhist = allpuncta(k).cumhist;
%         plot(all_cumhist(1:end-1), 'k'); ylim([0 1]); hold on;
%     end

end