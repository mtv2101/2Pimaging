%2014-10-01 Matt Valley and Kurt Sailor
%Script for duplicating affine transform with "Image stabilizer" plugin in
%FIJI. Transformation are first calculated on all the projected block images with the plugin and the
%transormations are logged as a txt file.

clear all

txtdir = 'D:\August-September 2014\052014-04\Day zAlign';
cd(txtdir);
%txtname = 'TransformationMatrices.txt';
%Input number of images in each stack
%textoutname = 'blah.txt';
stacksize = 5563;


a1 = '256.288003085137';
a2 = '126.77158180394743';
b1 = '128.4290627538085';
b2 = '383.31802820029327';
c1 = '384.0604842552291';
c2 = '383.4769253097821';
%formatSpecin = '%s%s%[^\n\r]';
formatSpecout = '%s\t%s\n';
%delimiter = '\t';
fileID = fopen('blahkk.txt', 'w');

%For header and first alignment
txtout = [];
    header = vertcat({'MultiStackReg Transformation File', ''},...
        {'File Version 1.0', ''}, {'0', ''});
        aaa = {'AFFINE', ''};
        bbb = {['Source img: 2 Target img: 1'], ''};
        aa1 = {a1, a2};
        bb1 = {b1, b2};
        cc1 = {c1, c2};
        g = {'256.288003085137', '126.77158180394743'};
        h = {'128.4290627538085', '383.31802820029327'};
        i = {'384.0604842552291', '383.4769253097821'};
        j = {'', ''};
        out1 = [header;aaa;bbb;aa1;bb1;cc1;j;g;h;i;j];
%For making no shift duplications
   for n = 2:stacksize-1;
        b = {['Source img: ' num2str(n+1) ' Target img: 1'], ''};
        out2 = [aaa;b;g;h;i;j;g;h;i;j];
        txtout = vertcat(txtout, out2);
        outfinal = vertcat(out1, txtout);       
   end
[nrows,ncols] = size(outfinal);
for row = 1:nrows
    fprintf(fileID, formatSpecout, outfinal{row,:});
end

                  
   