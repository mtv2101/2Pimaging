%2014-10-01 Matt Valley and Kurt Sailor
%Script for duplicating affine transform with "Image stabilizer" plugin in
%FIJI. Transformation are first calculated on all the projected block images with the plugin and the
%transormations are logged as a txt file.

clear all

txtdir = 'D:\2014-Nov 1-day interval structural plasticity\071514-03\Projected tdtomato channel\Transformations';
cd(txtdir);
%txtname = 'TransformationMatrices.txt';
%Input number of images in each stack
%textoutname = 'blah.txt';
stacksize = 10000;




a1 = '252.7233737472991';
a2 = '129.95722722934735';
b1 = '119.9119990744595';
b2 = '385.90975336726433';
c1 = '376.23808844360786';
c2 = '389.9068285838732';
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
        g = {'256.0', '128.0'};
        h = {'128.0', '384.0'};
        i = {'384.0', '384.0'};
        j = {'', ''};
        %k = {'255.9999999998198', '127.99999998690437'};
        %l = {'127.99999998449702', '384.0000000142768'};
        %m = {'384.0000000151427', '384.00000001427907'};

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

                  
   