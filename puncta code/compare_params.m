clear all;

rootdir = 'G:\Matt\20140226';

cd(rootdir);
FullList = dir;
MaximaList = dir(['*roi*.txt']);
obs = length(MaximaList); %number of rois

for k = 1:obs %for each text file of maxima
    maximaname = MaximaList(k).name;
    
    % open .txt file of maxima
    delimiter = '\t';
    startRow = 2;
    formatSpec = '%f%f%f%f%f%f%f%f%f%f%f%f%[^\n\r]';
    fileID_max = fopen(maximaname,'r');
    dataArray = textscan(fileID_max, formatSpec, 'Delimiter', delimiter, 'HeaderLines' ,startRow-1, 'ReturnOnError', false);
    fclose(fileID_max);
    VarName1 = dataArray{:, 1};
    Trajectory = dataArray{:, 2};
    Frame = dataArray{:, 3};
    x = dataArray{:, 4};
    y = dataArray{:, 5};
    z = dataArray{:, 6};
    total_particles = dataArray{:, 13};
    total_particles = str2num(total_particles{1,1});
    
    % Get cumulative histogram of trajectory lifetime
    numdetections = length(Trajectory);
    num_singles = total_particles - numdetections;
    for n = 1:numdetections
        traj = Trajectory(n);
        lentraj(n) = length(find(Trajectory == traj));
        for m = 1:lentraj(n)
            puncta(traj).xy(m,:) = [x(n), y(n)];
        end
        puncta(traj).lifetime = lentraj(n);
    end
    max_trajlen = max(lentraj); % find the longest trajectory
    
    numtraj = max(Trajectory);
    for n = 1:numtraj
        ltime_cumhist(n) = puncta(n).lifetime;
    end
    ltime_cumhist = cat(2, ltime_cumhist, ones(1,num_singles)); %add non-trajectory single particles to cumulative histogram
    cumhist = ecdf(ltime_cumhist);
    
    allpuncta(k).puncta = puncta;
    allpuncta(k).maximaname = maximaname;
    allpuncta(k).cumhist = cumhist;
    allpuncta(k).lifetimes = ltime_cumhist;
    
        clear puncta cumhist lentraj Trajectory ltime_cumhist
end

for k = 1:obs
    param_outcomes(:,k) = ecdf(allpuncta(k).lifetimes);
end

plot(param_outcomes(2:5,:)');
