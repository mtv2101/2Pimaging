clear all;

rootdir = 'G:\Matt\20140226';
isize = 5; %radius of image kernal to take around each puncta

cd(rootdir);
FullList = dir;

% sequentially import all channels
[pathname_txt] = uipickfiles('refilter', '\.txt$', 'type', {'*.txt', 'text-files'},...
    'prompt', 'Select all .txt files', 'output', 'cell');
[pathname_img] = uipickfiles('refilter', '\.tif$', 'type', {'*.tif', 'image-files'},...
    'prompt', 'Select all .tif files', 'output', 'cell');
obs = length(pathname_txt);

ImgList = dir(['*roi*.tif']);

for k = 1:obs %for each text file of maxima
    maximaname = pathname_txt(k);
    imgname = pathname_img(k);
    
    % open .txt file of maxima
    delimiter = '\t';
    startRow = 2;
    formatSpec = '%f%f%f%f%f%f%f%f%f%f%f%f%[^\n\r]';
    fileID_max = fopen(maximaname{1},'r');
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
    
    % open .tif file of image
    image = imread(imgname{1},'tif');
    
    % Get cumulative histogram of trajectory lifetime
    numdetections = length(Trajectory);
    num_singles = total_particles - numdetections;
    numtraj = max(Trajectory);
    for n = 1:numtraj
        pun = find(Trajectory == n);
        lentraj = length(pun);
        traj = Trajectory(pun(1));
        cords = [];
        for m = 1:lentraj
             cords = cat(1,cords,[x(pun(m)), y(pun(m))]);
        end
        puncta(traj).xy = cords;
        puncta(traj).lifetime = lentraj;
        puncta(traj).firstobs = Frame(pun(1));
    end
    
    for n = 1:numtraj
        ltime_cumhist(n) = puncta(n).lifetime-1;
    end
    ltime_cumhist = cat(2, ltime_cumhist, zeros(1,num_singles)); %add non-trajectory single particles to cumulative histogram
    cumhist = ecdf(ltime_cumhist);
    
    
    % find average image around each puncta
    for n = 1:numtraj
        img = [];
        for m = 1:puncta(n).lifetime
            xrange = ceil([(puncta(n).xy(m,1)-isize):(puncta(n).xy(m,1)+isize)]);
            yrange = ceil([(puncta(n).xy(m,2)-isize):(puncta(n).xy(m,2)+isize)]);
            if min(xrange) <= 0 || min(yrange) <= 0 || ...
                max(xrange)+isize > size(image,1) || ...
                max(yrange)+isize > size(image,2)
                allpuncta(k).allimg(n).img(:,:,m) = NaN((isize*2)+1);
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
    %all_cumhist(:,k) = allpuncta(k).cumhist;
end
[cumhist xaxis upconfidence downconfidence] = ecdf(all_lifetimes, 'bounds', 'on');
output = [cumhist, xaxis, upconfidence, downconfidence];
%mean_cumhist = mean(all_cumhist,2);
%sem_cumhist = std(all_cumhist,[],2)./sqrt(obs);

%errorbar([0:length(mean_cumhist)-1], mean_cumhist,sem_cumhist);
