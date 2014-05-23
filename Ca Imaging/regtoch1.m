function [signal_reg] = regtoch1(ref, signal, maxstep, FILT_SIG)

zdim = size(signal,3);
imagesize = [size(signal,1) size(signal,2)];
[optimizer,metric] = imregconfig('monomodal');
optimizer.MaximumStepLength = maxstep;
optimizer.MinimumStepLength = 1e-05;
optimizer.MaximumIterations = 100;
fprintf(1, ['\nregistering in-focus frame:    ']);
idx = 1:size(ref,3);
    tform = sbxalign(double(ref),idx);
% for n = 1:zdim
%     for x = 1:ceil(log10(n+1)), fprintf(1,'\b'); end %backspace for number of digits in counter
%     fprintf(1,'%d',n);
%     medref = medfilt2(ref(:,:,n));
%     if FILT_SIG == 1
%         medsig = medfilt2(signal(:,:,n));
%         else medsig = signal(:,:,n);
%     end
%     %tform = imregtform(medref,median_img,'translation',optimizer,metric, 'PyramidLevels', 4);
%     idx = 1:size(ref,3);
%     tform = sbxalign(double(ref),idx);
%     signal_reg(:,:,n) = imwarp(medsig, tform, 'linear', 'FillValues', 0, 'OutputView',imref2d(imagesize));
%     clear tform toreg img_reg
% end
signal_reg = tform;
end