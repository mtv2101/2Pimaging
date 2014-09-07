function [allpuncta, roi_valid] = parse_trajectory(rootdir, days_toanalyze)

%clear all

%rootdir = 'C:\Users\supersub\Desktop\Data\text files\MC lateral';

isize = 5; %radius of image kernal to take around each puncta
cd(rootdir);
FullList = dir;
MaximaList = dir(['*.txt']);
ImgList = dir(['*2dtseries*.tif']);
roi = length(MaximaList); %number of rois

%days_toanalyze = (1:8); % [1..8]

allpuncta = [];
roi_valid = [];
for k = 1:roi %for each text file of maxima
    maximaname = MaximaList(k).name;
    imgname = ImgList(k).name;
    image = imread(imgname,'tif');
    
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
    day_index = intersect(days_toanalyze, 1:total_days);
    if isempty(day_index) % must assume first day is always day 1
        continue % skip to next .txt file
    elseif length(day_index) == 1 %if there is only one frame of the roi in your day range skip it
        continue        
    end
    
    parens = strmatch('%%', frame);
    traj_idx = parens(1:2:end)+2; % in the .txt file every other "%%" marks trajectory start
    traj_idx = cat(1, 1, traj_idx);
    
    %%%%% arrange data from text input
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
            [nn, fr_intsect, nm] = intersect(framesobs, days_toanalyze); %fr_intsect indexes the text file to get trajectory info
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
    sum_total_particles = sum(total_particles(day_index(1):day_index(end)-1)); % dont get trajectories from last day - single also not counted from last day
    num_singles = sum_total_particles - allpuncta_intraj;    
        
    % find average image around each puncta
    for n = 1:length(puncta)
        img = zeros(11);
        for m = 1:length(puncta(n).framesobs) %for lifetime of trajectory
            xrange = ceil([(puncta(n).x(m)-isize):(puncta(n).x(m)+isize)]);
            yrange = ceil([(puncta(n).y(m)-isize):(puncta(n).y(m)+isize)]);
            if min(xrange) <= 0 || min(yrange) <= 0 || ...
                    max(xrange)+isize > size(image,1) || ...
                    max(yrange)+isize > size(image,2)
                allpuncta(k).allimg(n).img(:,:,m) = NaN((isize*2)+1); % fill image with NaNs if it crosses FOV border
                continue
            end
            allpuncta(k).allimg(n).img(:,:,m) = image(xrange,yrange);
        end
    end
    
    %%%%% calculate empirical cumulative density function of puncta lifetimes
    extra_singles = 0;
    e=1;
    ni = 1;
    censor_vec = [];
    for n = 1:length(puncta) %length puncta may be shorter than traj_indx because some puncta lie outside day range
        if isempty(puncta(n).framesobs)
            continue
        elseif puncta(n).allframesobs(end) == days_toanalyze(1) % if the trajectory ends on the first day of obseravation don't count it as a trajectory even if it was observed earlier.  
            extra_singles = e;
            e=e+1;
            continue
        elseif puncta(n).allframesobs(1) == days_toanalyze(end) % the converse must be taken care of as well.  These will be treated as single obseravations
            extra_singles = e;
            e=e+1;
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
    all_singles = num_singles+extra_singles; %add on vector observations with just one day of observation within the day range
    censor_vec = logical(cat(2, censor_vec, zeros(1, all_singles)));    
    ltime_cumhist = cat(2, ltime_cumhist, ones(1, all_singles)); %add non-trajectory single particles to cumulative histogram
    cumhist = ecdf(ltime_cumhist, 'function', 'survivor', 'censoring', censor_vec);
    
    %%%%% calculate percentage of puncta that persist from day 1 to day d
    for d = 1:length(days_toanalyze)
        persist = zeros(length(puncta),1);
        if d == 1
            percent_persistant(d) = 1; %all observations start day 1
        else
            for n = 1:length(puncta)
                len = length(intersect(puncta(n).framesobs, days_toanalyze(1:d))); % find trajectories with length 1:d
                if len == d
                    persist(n) = 1;
                end
            end            
            percent_persistant(d) = sum(persist)/total_particles(days_toanalyze(1));
        end  
        clear persist
    end
    
    %%%%% caluclate number of new and lost trajectories in middle-observed days
    %%%%% only count trajectories that persist for > 2 days
    for d = 2:length(days_toanalyze) %all puncta new on first observation so ignore
        for n = 1:length(puncta)
            puncta(n).new(d) = 0;  
            puncta(n).lost(d) = 0;
            if length(puncta(n).framesobs) < 2 % ignore solo observations
                continue
            else
                if isempty(setdiff(puncta(n).framesobs(1:2), [days_toanalyze(d):(days_toanalyze(d)+1)]')) % if the first two observations dont begin the first day. Their difference should be empty
                    puncta(n).new(d) = 1;
                end
                if days_toanalyze(d) < days_toanalyze(end) 
                    if puncta(n).framesobs(end) == days_toanalyze(d) % if the last trajectory observation is on day d (but not the last day)
                        puncta(n).lost(d) = 1;
                    end
                end
            end
        end        
    end
    num_new = sum([puncta.new]);
    num_lost = sum([puncta.lost]);                        
    
    allpuncta(k).puncta = puncta;
    allpuncta(k).maximaname = maximaname;
    allpuncta(k).imgname = imgname;
    allpuncta(k).cumhist = cumhist;
    allpuncta(k).lifetimes = ltime_cumhist;
    allpuncta(k).censor_vec = censor_vec;
    allpuncta(k).puncta_matrix = pun;
    allpuncta(k).numsingles = all_singles;
    allpuncta(k).propsingle = all_singles/length(puncta);
    allpuncta(k).percent_persistant = percent_persistant;
    allpuncta(k).new = num_new;
    allpuncta(k).lost = num_lost;
    
    roi_valid(k) = k;
    roi_valid(roi_valid==0) = [];
    clear dataarray puncta cumhist lentraj ltime_cumhist frame parens traj_idx allpuncta_intraj pun censor_vec persist
end

end