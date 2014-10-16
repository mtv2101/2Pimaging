n = 3;

[f, x] = ecdf(img_dat(n).last_peak);
[f1, x1] = ecdf(img_dat(n).img_lastm1);
[f2, x2] = ecdf(img_dat(n).img_lastm2);
[f3, x3] = ecdf(img_dat(n).img_lastm3);
[f4, x4] = ecdf(img_dat(n).img_lastm4);
[f5, x5] = ecdf(img_dat(n).img_lastm5);
[f6, x6] = ecdf(img_dat(n).img_lastm6);

plot(x,f,'color',  plotcolors(1,:));hold on;
%plot(x1,f1,'color',  plotcolors(2,:));
plot(x2,f2,'color',  plotcolors(3,:));
%plot(x3,f3,'color',  plotcolors(4,:));
plot(x4,f4,'color',  plotcolors(5,:));
%plot(x5,f5,'color',  plotcolors(6,:));
plot(x6,f6,'color',  plotcolors(7,:));