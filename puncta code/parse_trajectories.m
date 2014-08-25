clear all;

rootdir = 'C:\Users\supersub\Desktop\Data\text files\MC lateral';
isize = 5; %radius of image kernal to take around each puncta
days = (1:4); %days to analyze

cd(rootdir);
FullList = dir;
MaximaList = dir(['*.txt']);
obs = length(MaximaList); %number of rois

for k = 1:obs %for each text file of maxima
    maximaname = MaximaList(k).name;
    
    % open .txt file of maxima
    delimiter = {'\t',' '};
    formatSpec = '%s%s%s%s%s%s%*s%*s%*s%*s%*s%*s%*s%*s%*s%*s%*s%*s%*s%*s%*s%*s%*s%*s%*s%*s%*s%*s%*s%*s%*s%*s%*s%*s%*s%*s%*s%*s%*s%*s%*s%*s%*s%*s%*s%*s%*s%*s%*s%*s%*s%*s%*s%*s%*s%*s%*s%*s%*s%*s%*s%*s%*s%*s%*s%*s%*s%*s%*s%*s%*s%*s%*s%*s%[^\n\r]';
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
    
    total_indxs = strmatch('Frame', dataarray{1,2});
        total_indxs = total_indxs(2:5); %these are the "Frame" we want 
    total_particles = dataarray{1,2};
        total_particles = total_particles(total_indxs+1);
        sum_total_particles = sum(str2double(total_particles));
        
    parens = strmatch('%%', frame);
    traj_start_indx = parens(1:2:end)+2;
    traj_start_indx = cat(1, 1, traj_start_indx);
    
    for t = 1:length(traj_start_indx) %for each trajectory
        if t == length(traj_start_indx)
            puncta(t).lifetime = length(x) - traj_start_indx(t);
            puncta(t).framesobs = str2double(frame(traj_start_indx(t):end));
        else
            puncta(t).lifetime = traj_start_indx(t+1)-3 - traj_start_indx(t);
            puncta(t).framesobs = str2double(frame(traj_start_indx(t):(traj_start_indx(t+1)-3)));            
        end
        puncta(t).firstobs = str2double(frame{traj_start_indx(t)});        
    end
    
    numtraj = length(puncta);       
    for n = 1:numtraj
        ltime_cumhist(n) = puncta(n).lifetime;
    end
    %num_singles = length(strmatch('-1', dataarray{:, 6}));
    %ltime_cumhist = cat(2, ltime_cumhist, zeros(1,num_singles)); %add non-trajectory single particles to cumulative histogram
    cumhist = ecdf(ltime_cumhist, 'function', 'survivor');
    
    allpuncta(k).puncta = puncta;
    allpuncta(k).maximaname = maximaname;
    allpuncta(k).cumhist = cumhist;
    allpuncta(k).lifetimes = ltime_cumhist;
    
    clear puncta cumhist mean_img image img lentraj Trajectory ltime_cumhist
end

all_lifetimes = [];
for k = 1:obs
    all_lifetimes = cat(2, all_lifetimes, allpuncta(k).lifetimes);
    all_cumhist = allpuncta(k).cumhist;
    plot(all_cumhist(2:end-1), 'k'); ylim([0 1]); hold on;    
    fitx = 1:(length(all_cumhist)-2);
    fity = all_cumhist(2:end-1)';
    fitcoeffs(:,k) = polyfit(fitx, fity, 1);
    %regresscoeffs(:,k) = regress(fity', fitx');
    clear all_cumhist;
end
[cumhist xaxis upconfidence downconfidence] = ecdf(all_lifetimes, 'bounds', 'on');
output = [cumhist, xaxis, upconfidence, downconfidence];
