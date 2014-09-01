clear all;

in_dir = 'C:\Users\supersub\Desktop\Data\aggregate_all';
out_dir = 'C:\Users\supersub\Desktop\Data\aggregate_all\normalized\';

cd(in_dir);
list = dir;

for n = 3:length(list)
    if ~ list(n).isdir
    img = imread(list(n).name);
    imghist(:,n) = hist(img(:), [0:255]);
    end
end

meanhist = (mean(imghist, 2));

cd(out_dir);
for n = 3:length(list)
    if ~ list(n).isdir
    imgname = strcat(in_dir, '\', list(n).name);
    img = imread(imgname);
    img_norm = histeq(img, meanhist);
    end
    saveastiff(img_norm, list(n).name);
end