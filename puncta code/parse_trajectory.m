function [allpuncta, roi_valid] = parse_trajectory(rootdir, days_toanalyze)

%clear all

%rootdir = 'C:\Users\supersub\Desktop\Data\text files\MC lateral';

cd(rootdir);
FullList = dir;
MaximaList = dir(['*.txt']);
roi = length(MaximaList); %number of rois

%days_toanalyze = (1:8); % [1..8]

allpuncta = [];
roi_valid = [];
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
    total_particles = dataarray{1,2};
    total_particles = total_particles(total_indxs+1);
    total_particles = str2double(total_particles(1:length(total_particles)/2)); % cut out text data trailing particle data
    total_days = length(total_particles); % detecting the number of days (frames)
    if isempty(intersect(days_toanalyze, 1:total_days)) % must assume first day is always day 1
        continue % skip to next .txt file
    end
    
    parens = strmatch('%%', frame);
    traj_idx = parens(1:2:end)+2; %every other "%%" marks trajectory start
    traj_idx = cat(1, 1, traj_idx);
    
    for t = 1:length(traj_idx) %for all trajectories
        if t == length(traj_idx)
            framesobs = str2double(frame(traj_idx(t):end));
        else
            framesobs = str2double(frame(traj_idx(t):(traj_idx(t+1)-3))); %subtract 3 to index past the two "%%" marks
        end
        framesobs = framesobs + 1; %add 1 so that first observation is day 1 not day 0
        if isempty(intersect(framesobs, days_toanalyze)); % must assume first day is always day 1
            continue % skip to next trajectory
        else
            [nn, fr_intsect, nm] = intersect(framesobs, days_toanalyze);
            if length(fr_intsect) >= 1
                for n = 1:length(framesobs)
                    allx(n) = str2double(x{traj_idx(t)+n-1});
                    ally(n) = str2double(y{traj_idx(t)+n-1});
                    allz(n) = str2double(z{traj_idx(t)+n-1});
                end
                puncta(t).x = allx(fr_intsect);
                puncta(t).y = ally(fr_intsect);
                puncta(t).z = allz(fr_intsect);
            end
            puncta(t).allframesobs = framesobs;
            puncta(t).framesobs = framesobs(fr_intsect);
            puncta(t).fr_intsect = fr_intsect;
        end
    end
    
    allpuncta_intraj = [];
    for d = 1:length(days_toanalyze)-1 %dont iterate to last day which is all single
        for n = 1:length(puncta)
            pun(d,n) = length(find(puncta(n).framesobs == days_toanalyze(d))); % get each roi with a puncta detected that day            
        end
    end
    allpuncta_intraj = sum(sum(pun,2),1);
    sum_total_particles = sum(total_particles(1:length(days_toanalyze)-1)); % dont get trajectories from last day - single also not counted from last day
    num_singles = sum_total_particles - allpuncta_intraj;
    
    ni = 1;
    censor_vec = [];
    for n = 1:length(puncta) %length puncta may be shorter than traj_indx because some puncta lie aoutside day range
        if isempty(puncta(n).framesobs)
            continue
        else
            ltime_cumhist(ni) = length(puncta(n).framesobs); % get lifetimes, over 4 observations max lifetime is 3 days
            if puncta(n).framesobs(end) == days_toanalyze(end)
                censor_vec(ni) = 1; % note whenever the trajectory hits the "wall" (is right censored)
            else
                censor_vec(ni) = 0;
            end
            ni=ni+1;
        end
    end
%     if isempty(censor_vec)
%         continue
%     end
    censor_vec = logical(cat(2, censor_vec, zeros(1, num_singles)));    
    ltime_cumhist = cat(2, ltime_cumhist, ones(1, num_singles)); %add non-trajectory single particles to cumulative histogram
    cumhist = ecdf(ltime_cumhist, 'function', 'survivor', 'censoring', censor_vec);
    
    allpuncta(k).puncta = puncta;
    allpuncta(k).maximaname = maximaname;
    allpuncta(k).cumhist = cumhist;
    allpuncta(k).lifetimes = ltime_cumhist;
    allpuncta(k).puncta_matrix = pun;
    allpuncta(k).numsingles = num_singles;
    allpuncta(k).propsingle = num_singles/length(puncta);
    
    roi_valid(k) = k;
    roi_valid(roi_valid==0) = [];
    clear dataarray puncta cumhist lentraj ltime_cumhist frame parens traj_idx allpuncta_intraj pun censor_vec
end

end