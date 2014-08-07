clear all;

rootdir = 'C:\Users\supersub\Desktop\Data\2.3\OUT';
isize = 5; %radius of image kernal to take around each puncta

cd(rootdir);
FullList = dir;
MaximaList = dir(['*2dtseries*.txt']);
obs = length(MaximaList); %number of rois
ImgList = dir(['*2dtseries*.tif']);

for k = 1:obs %for each text file of maxima
    maximaname = MaximaList(k).name;
    imgname = ImgList(k).name;
    
    % open .txt file of maxima
    delimiter = {'\t',' '};
    formatSpec = '%s%s%s%*s%*s%*s%*s%*s%*s%*s%*s%*s%*s%*s%*s%*s%*s%*s%*s%*s%*s%*s%*s%*s%*s%*s%*s%*s%*s%*s%*s%*s%*s%*s%*s%*s%*s%*s%*s%*s%*s%*s%*s%*s%*s%*s%*s%*s%*s%*s%*s%*s%*s%*s%*s%*s%*s%*s%*s%*s%*s%*s%*s%*s%*s%*s%*s%*s%*s%*s%*s%*s%*s%*s%[^\n\r]';
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
        total_indxs = total_indxs(2:5);
    total_particles = dataarray{1,2};
        total_particles = total_particles(total_indxs+1);
        sum_total_particles = sum(str2double(total_particles));
        
    parens = strmatch('%%', frame);
    traj_start_indx = parens(1:2:end)+2;
    traj_start_indx = cat(1, 1, traj_start_indx);
    
    for t = 1:length(traj_start_indx) %for each trajectory
        if t == length(traj_start_indx)
            puncta(t).lifetime = length(x) - traj_start_indx(t);
        else
            puncta(t).lifetime = traj_start_indx(t+1)-2 - traj_start_indx(t);
        end
        for n = 1:puncta(t).lifetime
            puncta(t).x(n) = str2double(x{traj_start_indx(t+n-1)});
            puncta(t).y(n) = str2double(y{traj_start_indx(t+n-1)});
        end
        puncta(t).firstobs = str2double(frame{traj_start_indx(t)})+1;
    end
    
    % open .tif file of image
    image = imread(imgname,'tif');
    
    % Get cumulative histogram of trajectory lifetime
    for p = 1:length(puncta)
        ave_len(p) = puncta(p).lifetime;
    end
    ave_len = mean(ave_len);
    puncta_intraj = ave_len*length(puncta);
    num_singles = sum_total_particles - puncta_intraj;
    numtraj = length(puncta);
    
%     for n = 1:numtraj
%         pun = find(Trajectory == n);
%         lentraj = length(pun);
%         traj = Trajectory(pun(1));
%         cords = [];
%         for m = 1:lentraj
%              cords = cat(1,cords,[x(pun(m)), y(pun(m))]);
%         end
%         puncta(traj).xy = cords;
%         puncta(traj).lifetime = lentraj;
%     end
    
   
    for n = 1:numtraj
        ltime_cumhist(n) = puncta(n).lifetime-1;
    end
    ltime_cumhist = cat(2, ltime_cumhist, zeros(1,num_singles)); %add non-trajectory single particles to cumulative histogram
    cumhist = ecdf(ltime_cumhist);
    
    
    % find average image around each puncta
    for n = 1:numtraj
        img = zeros(11);
        for m = 1:puncta(n).lifetime
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
    
    allpuncta(k).puncta = puncta;
    allpuncta(k).imgname = imgname;
    allpuncta(k).maximaname = maximaname;
    allpuncta(k).cumhist = cumhist;
    allpuncta(k).lifetimes = ltime_cumhist;
    
    clear puncta cumhist mean_img image img lentraj Trajectory ltime_cumhist
end

all_lifetimes = [];
for k = 1:obs
    all_lifetimes = cat(2, all_lifetimes, allpuncta(k).lifetimes);
    all_cumhist(:,k) = allpuncta(k).cumhist;
end
[cumhist xaxis upconfidence downconfidence] = ecdf(all_lifetimes, 'bounds', 'on');
output = [cumhist, xaxis, upconfidence, downconfidence];
% mean_cumhist = mean(all_cumhist,2);
% sem_cumhist = std(all_cumhist,[],2)./sqrt(obs);
% 
% errorbar([0:length(mean_cumhist)-1], mean_cumhist,sem_cumhist);
