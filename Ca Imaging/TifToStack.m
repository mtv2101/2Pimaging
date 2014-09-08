clear all

rootdir = 'D:\August-September 2014\2014-08-28'; % full path to root directory of your tiff folders
ImgExtension = '.tif'; % specify image extension
cd(rootdir);
List = dir;

i=1;
for a=3:length(List) %first 2 dirs are '.' and '..'
    if List(a).isdir % only look at folders
        datadirs(i) = List(a);
        %disp(['loading and saving folder ' num2str(List(a).name)]);
        cd(List(a).name);
        Ch1(i).ImgList_Ch1 = dir(['*_Ch1*' ImgExtension]); % get all tif file names
        Ch2(i).ImgList_Ch2 = dir(['*_Ch3*' ImgExtension]); % get all tif file names
        cd(rootdir) % go back to root directory
        i=i+1; %count folders
    end
end

% import images, write to a tif file simultaneously! (memory efficient)
for a=1:length(datadirs)
fprintf(1,'\nProcessing trial %i\n', a);
    cd(rootdir)
    cd(datadirs(a).name);
    for b=1:length(Ch1(a).ImgList_Ch1) % read in each file 
        try
            Img1 = imread(Ch1(a).ImgList_Ch1(b).name);
            Img2 = imread(Ch2(a).ImgList_Ch2(b).name);
        catch
            fprintf(1,'\nWrite Error, skipping file');
            fprintf(1,'\nIt was at folder %s, image %i\n', datadirs(a).name, b);
            continue;
        end

        % export as tif stack
        success = 0;
        while ~success
            try
                cd(rootdir) % write to root directory
                imwrite(Img1,[datadirs(a).name '_Ch1_stack.tif'],'tif','Compression','none','WriteMode','append');
                imwrite(Img2,[datadirs(a).name '_Ch2_stack.tif'],'tif','Compression','none','WriteMode','append');
                success = 1;
                cd(datadirs(a).name); % dive back into image directory
            catch
                fprintf(1,'\nWrite Error, skipping file');
                fprintf(1,'\nIt was at folder %s, image %i\n', datadirs(a).name, b);
                continue;
            end
        end
    end
end
cd(rootdir)
