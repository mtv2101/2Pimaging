clear all;

norm_dir = 'C:\Users\supersub\Desktop\Data\aggregate_all\norm templates\';
in_dir = 'C:\Users\supersub\Desktop\Data\aggregate_all\temp\';
out_dir = 'C:\Users\supersub\Desktop\Data\aggregate_all\temp_out\';

cd(norm_dir);
norm_list = dir;

for n = 3:length(norm_list)
    if ~ norm_list(n).isdir
    img = imread(norm_list(n).name);
    imghist(:,n) = hist(img(:), [0:255]);
    end
end

template_hist = (mean(imghist, 2));

cd(in_dir);
    in_list = dir;
for n = 3:length(in_list)
    if ~ in_list(n).isdir
        imgname = strcat(in_dir, '\', in_list(n).name);
        outname = strcat(out_dir, '\', in_list(n).name);
        img = imread(imgname);
        img_norm = histeq(img, template_hist);
    end    
    saveastiff(img_norm, outname);
end