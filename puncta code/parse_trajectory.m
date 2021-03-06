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
    image = loadtif(imgname, rootdir);
    
    % open .txt file of maxima
    delimiter = {'\t',' '};
    formatSpec = '%s%s%s%s%s%s%[^\n\r]';
    fileID = fopen(maximaname,'r');
    dataarray = textscan(fileID, formatSpec, 'Delimiter', delimiter, 'ReturnOnError', false);
    fclose(fileID);
    frame = dataarray{:, 1};
    s = strmatch('%%', frame);
    start_traj = s(1);
    frame = frame((start_traj+13):end);
    
    total_indxs = strmatch('Frame ', dataarray{1,2})+1; % add one to move past a missing "%%" in txt format
    total_particles = dataarray{1,2};
    total_particles = total_particles(total_indxs); % first use of "frame" does not accompagny data
    total_particles = str2double(total_particles(1:length(total_particles)/2)); % cut out text data trailing particle data
    total_days = length(total_particles); % detecting the number of days (frames)
    day_index = intersect(days_toanalyze, 1:total_days); % "day_index" correct any mismatch between "days_toanalyze" and actual number of days
    if isempty(day_index) % must assume first day is always day 1
        continue % skip to next .txt file
    elseif length(day_index) == 1 %if there is only one frame of the roi in your day range skip it
        continue        
    end
    
    % get .txt file indexes for xyz coordinates
    x = dataarray{:,2}; 
    x_traj = x((start_traj+13):end); %trajectory coordinates
    x_all = dataarray{:,3}; % all coordinates
    y = dataarray{:,3};
    y_traj = y((start_traj+13):end);
    y_all = dataarray{:,4}; 
    z = dataarray{:,4};
    z_traj = z((start_traj+13):end);
    z_all = dataarray{:,5}; 
    
    % get indexes of all pucnta detections
    for n = 1:length(day_index)
        allcords_indx(n) = total_indxs(day_index(n))+3+total_particles(day_index(n)); % coordinates start 4 after "Frame" and 1 after first coordiante list
        all_coords{1,n} = x_all(allcords_indx(n):(allcords_indx(n)+total_particles(day_index(n)))-1);
        all_coords{2,n} = y_all(allcords_indx(n):(allcords_indx(n)+total_particles(day_index(n)))-1);
        all_coords{3,n} = z_all(allcords_indx(n):(allcords_indx(n)+total_particles(day_index(n)))-1);
    end
    
    % get indexes of trajectories
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
        if isempty(intersect(framesobs, day_index)); % must assume first day is always day 1
            continue % skip to next trajectory
        else
            [nn, fr_intsect, nm] = intersect(framesobs, day_index); %fr_intsect indexes the text file to get trajectory info
            if length(fr_intsect) >= 1
                for n = 1:length(framesobs)
                    allx(n) = str2double(x_traj{traj_idx(t)+n-1});
                    ally(n) = str2double(y_traj{traj_idx(t)+n-1});
                    allz(n) = str2double(z_traj{traj_idx(t)+n-1});
                end
                trajectory(t).x = allx(fr_intsect);
                trajectory(t).y = ally(fr_intsect);
                trajectory(t).z = allz(fr_intsect);
            end
            trajectory(t).allframesobs = framesobs;
            trajectory(t).framesobs = framesobs(fr_intsect);
            trajectory(t).fr_intsect = fr_intsect;
            trajectory(t).lifetime = length(framesobs(fr_intsect));
            trajectory(t).firstobs = framesobs(1);
        end
    end    
    
    % define solo puncta coordiantes and trajectory puncta coordinates  
    for n = 1:length(day_index)-1 %dont count solo puncta on last day as single
        % put trajectory "x" puncta into a vector
        for t = 1:length(trajectory) %for all trajectories
            if length(trajectory(t).x) >= n
                xtrajs(t) = trajectory(t).x(n);
            else
                xtrajs(t) = NaN;             
            end
        end
        all_coords_tocompare = str2double(all_coords{1,n});     
        for m = 1:length(all_coords_tocompare)
            issolo(m,n) = ~ismember(all_coords_tocompare(m), xtrajs); % now find which elements from the all_coordinates are in a trajectory
        end
        clear all_coords_tocompare xtrajs
    end        
    
    sum_nonend_particles = sum(total_particles(day_index(1):day_index(end)-1)); % dont get trajectories from last day - single also not counted from last day
    sum_total_particles = sum(total_particles(day_index(1):day_index(end)));
    num_singles = sum(sum(issolo));
    
    % find image around each trajectory puncta
    for n = 1:length(trajectory)
        for m = 1:length(trajectory(n).fr_intsect) %for lifetime of trajectory
            xrange_t = ceil([(trajectory(n).x(m)-isize):(trajectory(n).x(m)+isize)]); %range for trajectory images
            yrange_t = ceil([(trajectory(n).y(m)-isize):(trajectory(n).y(m)+isize)]); %range for trajectory images
            if min(xrange_t) <= 0 || min(yrange_t) <= 0 || ...
                    max(xrange_t)+isize > size(image,1) || ...
                    max(yrange_t)+isize > size(image,2)
                allpuncta(k).trajimg(n).img(:,:,m) = NaN((isize*2)+1); % fill image with NaNs if it crosses FOV border
                continue
            end
            allpuncta(k).trajimg(n).img(:,:,m) = image(xrange_t,yrange_t,trajectory(n).fr_intsect(m)); %get the frame with the puncta
        end
    end
    
    % find image around each puncta (including solo puncta)
    for d = 1:length(day_index)
        for n = 1:length(all_coords{1,d}) %for each puncta
            xcord = str2double(all_coords{1,d}{n,1});
            ycord = str2double(all_coords{2,d}{n,1});
            xcord_rng = ceil([(xcord-isize):(xcord+isize)]);
            ycord_rng = ceil([(ycord-isize):(ycord+isize)]);
            if min(xcord_rng) <= 0 || min(ycord_rng) <= 0 || ...
                    max(xcord_rng)+isize > size(image,1) || ...
                    max(ycord_rng)+isize > size(image,2)
                allpuncta(k).allimg(d).img(:,:,n) = NaN((isize*2)+1); % fill image with NaNs if it crosses FOV border
                continue
            end
            allpuncta(k).allimg(d).img(:,:,n) = image(xcord_rng, ycord_rng, day_index(d));
        end
    end
            
    %%%%% calculate percentage of puncta that persist from day 1 to day d
    for d = 1:length(day_index)
        persist = zeros(length(trajectory),1);
        if d == 1
            percent_persistant(d) = 1; %all observations start day 1
        else
            for n = 1:length(trajectory)
                len = length(intersect(trajectory(n).framesobs, day_index(1:d))); % find trajectories with length 1:d
                if len == d
                    persist(n) = 1;
                end
            end            
            percent_persistant(d) = sum(persist)/total_particles(day_index(1));
        end  
        clear persist
    end
    
    %%%% get number of trajectory puncta present on each day
    hastraj = zeros(length(trajectory), length(day_index));
    for n = 1:length(trajectory)
        for d = 1:length(trajectory(n).framesobs)
            idx = length(day_index(day_index <= trajectory(n).framesobs(d))); %faster way to find matching index
            %[val, idx, blah] = intersect(day_index, trajectory(n).framesobs(d)); %slower way to find matching index
            hastraj(n,idx) = 1;
        end
    end
    traj_perday = sum(hastraj, 1);
    clear hastraj
                 
    %%%% caluclate number of new and lost trajectories in middle-observed days
    %%%% only count trajectories that persist for >= 2 days
    for d = 2:length(day_index) %all puncta new on first observation so ignore
        for n = 1:length(trajectory)
            trajectory(n).new(d) = 0;  
            trajectory(n).lost(d) = 0;
            if length(trajectory(n).framesobs) < 2 % ignore solo observations
                continue
            else
                if isempty(setdiff(trajectory(n).framesobs(1:2), [day_index(d):(day_index(d))+1]')) % if the first two observations dont begin the first day. Their difference should be empty
                    trajectory(n).new(d) = 1;
                end
                if day_index(d) < day_index(end)
                    if trajectory(n).framesobs(end) == day_index(d) % if the last trajectory observation is on day d (but not the last day)
                        trajectory(n).lost(d) = 1;
                    end
                end
            end
        end        
    end
    for d = 2:length(day_index)
        for n = 1:length(trajectory)
            all_new(n) = trajectory(n).new(d);
            all_lost(n) = trajectory(n).lost(d);
        end
        sum_all_new(d) = sum(all_new);
        sum_all_lost(d) = sum(all_lost);
    end                      
    
    allpuncta(k).trajectory = trajectory;
    allpuncta(k).maximaname = maximaname;
    allpuncta(k).imgname = imgname;
    allpuncta(k).numsingles = num_singles;
    allpuncta(k).totalpuncta = total_particles;
    allpuncta(k).traj_perday = traj_perday;
    allpuncta(k).propsingle = num_singles/sum_nonend_particles;
    allpuncta(k).percent_persistant = percent_persistant;
    allpuncta(k).new = sum_all_new;
    allpuncta(k).lost = sum_all_lost;
    allpuncta(k).all_coords = all_coords;
    allpuncta(k).issolo = issolo;
    
    roi_valid(k) = k;
    roi_valid(roi_valid==0) = [];
    clear day_index dataarray lentraj ltime_cumhist frame 
    clear parens traj_idx allpuncta_intraj persist issolo
    clear trajectory maximaname imgname cumhist ltime_cumhist 
    clear censor_vec pun all_singles percent_persistant sum_all_new
    clear sum_all_lost all_coords all_new all_lost traj_perday
end

end