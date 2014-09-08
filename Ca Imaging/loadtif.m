function [FinalImage] = loadtif(img, rootdir)

%rootdir = 'C:\Users\7Z83H5J\Desktop\Matt Data\101413-03'; % full path to root directory of your tiff folders
%img = 'TSeries-12062013-1027-3019_stack.tif';

cd(rootdir);

InfoImage=imfinfo(img);
mImage=InfoImage(1).Width;
nImage=InfoImage(1).Height;
NumberImages=length(InfoImage);
FinalImage=zeros(nImage,mImage,NumberImages,'uint16');
TifLink = Tiff(img, 'r');

for i=1:NumberImages
    TifLink.setDirectory(i);
    FinalImage(:,:,i)=TifLink.read();
end

TifLink.close();

end