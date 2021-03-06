n = 2;

%newlost = img_dat(n).last_lifetime;

[f, x] = ecdf(img_dat(n).last_peak);
[f1, x1] = ecdf(img_dat(n).img_lastm1);
[f2, x2] = ecdf(img_dat(n).img_lastm2);
[f3, x3] = ecdf(img_dat(n).img_lastm3);
[f4, x4] = ecdf(img_dat(n).img_lastm4);
[f5, x5] = ecdf(img_dat(n).img_lastm5);
[f6, x6] = ecdf(img_dat(n).img_lastm6);

laststat(1,:) = [nanmean(img_dat(n).last_peak), nanstd(img_dat(n).last_peak)/sqrt(length(img_dat(n).last_peak))];
laststat(2,:) = [nanmean(img_dat(n).img_lastm1), nanstd(img_dat(n).img_lastm1)/sqrt(length(img_dat(n).img_lastm1))];
laststat(3,:) = [nanmean(img_dat(n).img_lastm2), nanstd(img_dat(n).img_lastm2)/sqrt(length(img_dat(n).img_lastm2))];
laststat(4,:) = [nanmean(img_dat(n).img_lastm3), nanstd(img_dat(n).img_lastm3)/sqrt(length(img_dat(n).img_lastm3))];
laststat(5,:) = [nanmean(img_dat(n).img_lastm4), nanstd(img_dat(n).img_lastm4)/sqrt(length(img_dat(n).img_lastm4))];
laststat(6,:) = [nanmean(img_dat(n).img_lastm5), nanstd(img_dat(n).img_lastm5)/sqrt(length(img_dat(n).img_lastm5))];
laststat(7,:) = [nanmean(img_dat(n).img_lastm6), nanstd(img_dat(n).img_lastm6)/sqrt(length(img_dat(n).img_lastm6))];
figure;
errorbar(laststat(:,1), laststat(:,2));

figure;
plot(x,f,'color',  plotcolors(1,:));hold on;
plot(x1,f1,'color',  plotcolors(2,:));
plot(x2,f2,'color',  plotcolors(3,:));
plot(x3,f3,'color',  plotcolors(4,:));
plot(x4,f4,'color',  plotcolors(5,:));
plot(x5,f5,'color',  plotcolors(6,:));
plot(x6,f6,'color',  plotcolors(7,:));


[m, k] = ecdf(img_dat(n).first_peak);
[m1, k1] = ecdf(img_dat(n).second_peak);
[m2, k2] = ecdf(img_dat(n).third_peak);
[m3, k3] = ecdf(img_dat(n).fourth_peak);

figure;
plot(k,m,'color',  plotcolors(1,:));hold on;
plot(k1,m1,'color',  plotcolors(2,:));hold on;
plot(k2,m2,'color',  plotcolors(3,:));hold on;
plot(k3,m3,'color',  plotcolors(4,:));hold on;

% n=3;a = [img_dat(n).first_peak'; img_dat(n).second_peak'; img_dat(n).third_peak'; img_dat(n).fourth_peak'; img_dat(n).five_peak'; img_dat(n).six_peak'];
% b = [repmat(1, length(img_dat(n).first_peak'),1); repmat(2, length(img_dat(n).second_peak'),1); repmat(3, length(img_dat(n).third_peak'),1); repmat(4, length(img_dat(n).fourth_peak'),1); repmat(5, length(img_dat(n).five_peak'),1); repmat(6, length(img_dat(n).six_peak'),1)];
% c = [b,a];