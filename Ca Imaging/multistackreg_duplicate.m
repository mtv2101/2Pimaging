%2014-10-01 Matt Valley
%Script for duplicating affine transform with "Image stabilizer" plugin in
%FIJI. Transformation are first calculated on all the projected block images with the plugin and the
%transormations are logged as a txt file.

clear all

txtdir = 'D:\August-September 2014\052014-04\Day zAlign';
txtname = 'TransformationMatrices.txt';
%Input number of images in each stack
stacksize = 10;
formatSpecin = '%s%s%[^\n\r]';
formatSpecout = '%s%s%[^\n\r]';
delimiter = '\t';
startRow = 3;

cd(txtdir);
fileIDin = fopen(txtname, 'r');
text = textscan(fileIDin, formatSpecin, 'Delimiter', delimiter, 'ReturnOnError', false);
%fclose(fileID);
numblocks = length(find(ismember(text{1}, 'AFFINE')));

%Input affine values

idx = [6:8:(numblocks*8)-2];
for bb = 1:numblocks
    textoutname = ['blah_' num2str(bb+1) '.txt'];
    fileIDout = fopen(textoutname, 'a+');
    header = vertcat({'MultiStackReg Transformation File', ''},...
        {'File Version 1.0', ''}, {'0', ''});
    for n = 1:stacksize;
        a = {'AFFINE', ''};
        b = {['Source img: ' num2str(n+1) ' Target img: 1'], ''};
        c = {text{1,1}{idx(bb), 1}, text{1,2}{idx(bb), 1}};
        d = {text{1,1}{idx(bb)+1, 1}, text{1,2}{idx(bb)+1, 1}};
        e = {text{1,1}{idx(bb)+2, 1}, text{1,2}{idx(bb)+2, 1}};
        f = {'',''};
        g = {text{1,1}{idx(bb)+3, 1}, text{1,2}{idx(bb)+3, 1}};
        h = {text{1,1}{idx(bb)+4, 1}, text{1,2}{idx(bb)+4, 1}};
        i = {text{1,1}{idx(bb)+5, 1}, text{1,2}{idx(bb)+5, 1}};
        j = {'',''};
        %f = {text{1,1}{idx(bb)+3, 1}, text{1,2}{idx(bb)+3, 1}};
        %g = {text{1,1}{idx(bb)+4, 1}, text{1,2}{idx(bb)+4, 1}};
        %h = {text{1,1}{idx(bb)+5, 1}, text{1,2}{idx(bb)+5, 1}};
        out = [a;b;c;d;e;f;g;h;i;j];
        if n == 1
            txtout = vertcat(header,out);
        end
        txtout = vertcat(txtout, out);
    end            
    %for k = 1:size(txtout,1)
        %fprintf(fileIDout, formatSpecout, txtout{k,1}, txtout{k,2});
    %end
    all(bb).txtout = txtout;
end

%Make matrix with duplicated values for each image in the stack