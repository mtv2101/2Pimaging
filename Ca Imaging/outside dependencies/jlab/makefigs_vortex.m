function[varargout]=makefigs_vortex(str)
%MAKEFIGS_VORTEX Makes figures for Lilly, Scott, and Olhede (2011).
%
%   MAKEFIGS_VORTEX  Makes all figures for 
%
%                   Lilly, Scott, and Olhede (2011)
%     "Extracting waves and vortices from Lagrangian trajectories"
%              Geophysical Research Letters, 38, L23605, 1--5.
%
%   To run this file you'll also need to download the data files, as they 
%   are rather large. You can get vortex.mat via anonymous ftp from 
%  
%        ftp://ftp.nwra.com/outgoing/lilly/vortex
%
%   This file should be put somewhere on your Matlab search path.  To run
%   the code that makes the movie, you'll also need to get vortexpv.mat.
%   The movie code is commented out, so you'll need to edit the file.
%
%   Type 'makefigs_vortex' at the matlab prompt to make all figures 
%   for this paper and print them as .eps files into the current directory.
%  
%   Type 'makefigs_vortex noprint' to supress printing to .eps files.
%   _________________________________________________________________
%   This is part of JLAB --- type 'help jlab' for more information
%   (C) 2011--2012 J.M. Lilly --- type 'help jlab_license' for details


if nargin==0
  str='print';
end

if exist('vortex.mat')==2
   makefigs_vortex_figures(str);
else 
    disp('Sorry, MAKEFIGS_VORTEX can''t find the file vortex.mat.')
end

function[]=makefigs_vortex_figures(str)

if strcmp(str,'--f')
     makefigs_vortex('noprint');return
end

disp('Making figures for Lilly, Scott, and Olhede (2011).')
disp('This may take a while.')

load vortex
%/************************************************************************
use vortex.drifters

disp('Computing wavelet transforms using generalized Morse wavelets.')
ga=3;be=2; 
fs=morsespace(ga,be,{.2 pi},pi./300,8); 
%[psi,psif]=morsewave(length(x),1,ga,be,fs);
[wx,wy]=wavetrans(unwrap(x/L)*L,y,{1,ga,be,fs,'bandpass'},'mirror');

make vortex.drifters wx wy
clear ir jr kr xr fr br cr fbar kappa lambda theta phi R V
for k=1:size(x,2),
   disp(['Wavelet ridge analysis for drifter #' int2str(k) ' of 101.'])
   %The physical cutoff is 400/1000 km = 0.4 km
   [ir{k},jr{k},xr{k},fr{k},br{k},cr{k}]=ridgewalk(dt,wx(:,:,k),wy(:,:,k),fs,{2*morseprops(ga,be)/pi,L*1e-3,'amp'});
   
   %Keep track of which number drifter we're on, for future reference
   kr{k}=k+0*ir{k};
   
   %This is the joint instantaneous frequency, see Lilly and Olhede (2010)
   fbar{k}=jointfreq(xr{k},fr{k},2); 
   
   %Calculate ellipse parameters from ridges
   [kappa{k},lambda{k},theta{k},phi{k}]=ellparams(xr{k});
   R{k}=ellrad(kappa{k},lambda{k},phi{k});
   V{k}=ellvel(dt*24*3600,kappa{k},lambda{k},theta{k},phi{k},1e5);
end

%Ridge length
lr=ridgelen(ir,jr,fr);

make vortex.ridges ir jr kr lr xr fr br cr fbar kappa lambda theta phi R V
%\************************************************************************


%/************************************************************************
disp('Mapping ridges back into time series.')

xhat=nan*x;
yhat=nan*y;

clear fhat bhat chat mult 
for k=1:size(x,2)    
    %RIDGEMAP sums over all ridges and forms properties the same size as the original time series
    [zhat,fhat{k},bhat{k},chat{k},mult{k}]=ridgemap([length(x) 2],xr{k},fr{k},br{k},cr{k},ir{k},'collapse');
    
    %This is the estimate of the aggregate oscillatory signals
    xhat(:,k)=real(zhat(:,1));
    yhat(:,k)=real(zhat(:,2));
end

%Careful to form x-residual from unwrapped x, then re-wrap
xres=L*angle(rot((L*unwrap(x/L)-vswap(xhat,nan,0))/L));
yres=y-vswap(yhat,nan,0);

%Calculate residual value appropriate for each ridge
xresr=ir;yresr=ir;
for k=1:size(x,2)
    xresr{1,k}(~isnan(ir{k}))=xres(ir{k}(~isnan(ir{k})),k);
    yresr{1,k}(~isnan(ir{k}))=yres(ir{k}(~isnan(ir{k})),k);
end

x(abs(x-vshift(x,1,1))>L*pi)=nan;
xres(abs(xres-vshift(xres,1,1))>L*pi)=nan;

make vortex.ridges xresr yresr 
make vortex.drifters x y xres yres xhat yhat
%\************************************************************************



%That's the end of the processing, on to the figure making
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%



%/************************************************************************

figure
use vortex.snapshot
pcolor(x,y,abs(q)),shading interp,axis equal,axis square,axis tight,caxis([1 9]),hold on
colormap(squared(flipud(colormap('gray'))))
use vortex.ridges
vcellcat(ir,jr,kr,fbar,R,V,kappa,theta,lambda,xresr,yresr,lr);
kk=68; %That's the time index into the snapshot
index=find(ir==(kk-1)*20+1); 
h=ellipseplot(kappa,lambda,theta,xresr+sqrt(-1)*yresr,[1 1],'index',index);linestyle -h h 3w
index=find(ir==(kk-1)*20+1&abs(lambda)>0.8223); 
h=ellipseplot(kappa,lambda,theta,xresr+sqrt(-1)*yresr,[1 1],'index',index);linestyle -h h 1.5g
index=find(ir==(kk-1)*20+1&abs(lambda)<0.8223&V>0); 
h=ellipseplot(kappa,lambda,theta,xresr+sqrt(-1)*yresr,[1 1],'index',index);linestyle -h h 1.5r
index=find(ir==(kk-1)*20+1&abs(lambda)<0.8223&V<0); 
h=ellipseplot(kappa,lambda,theta,xresr+sqrt(-1)*yresr,[1 1],'index',index);linestyle -h h 1.5b

    
use vortex.drifters
plot(x((kk-1)*20+1,:),y((kk-1)*20+1,:),'o','markerfacecolor','w','markeredgecolor','k','markersize',4)
index=find(~isnan(xhat((kk-1)*20+1,:)));
plot(x((kk-1)*20+1,index),y((kk-1)*20+1,index),'o','markerfacecolor','k','markeredgecolor','w','markersize',4)
%text(-550*2,550*2,'Day 240','color','w')
axis off,xlabel('Distance East (km)'),ylabel('Distance North (km)')
%title('Snapshot of Unstable Jet with Lagrangian Ellipses')
h=colorbar('South','xcolor','w','ycolor','w');
axes(h)
xlabel('Potential Vorticity Magnitude')

orient portrait
fontsize 14 12 12 12

cd_figures
if strcmp(str,'print')
   print -depsc vortex-snapshot.eps
end
%\************************************************************************
   
%/************************************************************************
%Wavelet transform, for supplementary materials

jj=80;  %This is the drifter I'm using 
use vortex.drifters
figure
h=wavespecplot(num,x(:,jj)+sqrt(-1)*y(:,jj),2*pi./fs.*dt,log10(abs(wx(:,:,jj)).^2+abs(wy(:,:,jj)).^2));
axes(h(1)),hold on,linestyle 2b 2r
ylim([-900 900]),xlim([0 250]),ytick([-750:250:750])
uvplot(num,xres(:,jj)+sqrt(-1)*yres(:,jj),'g')
uvplot(num,vswap(xhat(:,jj),nan,0)+sqrt(-1)*vswap(yhat(:,jj),nan,0));hlines(0,'k:')
title('Example of Wavelet Ridge Analysis'),ylabel('Position (km)')
axes(h(1))
vlines([80 125],'k:')
axes(h(2)),hold on,xlim([0 250]),caxis([-2.75 4.25]),ytick([1 10 100])

%Time index
use vortex.ridges
numr=nan*ir{jj};numr(~isnan(ir{jj}))=num(ir{jj}(~isnan(ir{jj})));
plot(col2mat(numr),2*pi./col2mat(fbar{jj}));
linestyle b g c m
vlines([80 125],'k:')

ylabel('Period (days)'),xlabel('Time (days)')
letterlabels(4)

hc=colorbar('eastoutside');
axes(hc),ylabel('Signal Stength (Log10 km)')
pos1=get(h(1),'position');pos2=get(h(2),'position');
set(h(1),'position',[pos1(1:2) pos2(3) pos1(4)])

orient landscape
fontsize 22 18 18 18
cd_figures
if strcmp(str,'print')
   print -depsc vortex-transform.eps
end
%\************************************************************************




%/************************************************************************
use vortex.ridges
%Make the ridges into one long column
vcellcat(ir,jr,kr,fbar,R,V,kappa,theta,lambda,xresr,yresr,lr);

figure
xbin=[0:2:160];ybin=[-130:2:130];

subplot(1,2,1)
[matm,xmid,ymid]=twodhist(R,V,xbin,ybin);
pcolor(xmid,ymid,log10(matm)),shading flat
colormap jet,map=colormap;map(1,:)=[1 1 1];colormap(map);
caxis([0 3]),hold on
xlabel('Radius (km)'),ylabel('Velocity (cm/s)')

%text(45,140,'Distributions of Estimated Oscillations in Unstable Jet Trajectories')

subplot(1,2,2)
[matm,xmid,ymid]=twodmed(R,V,ecconv(abs(lambda),'lin2ecc').^2,xbin,ybin);
pcolor(xmid,ymid,matm),shading flat
caxis([0 1]),hold on


for i=1:2
    subplot(1,2,i)
    axis([0 145 -180 130]),xtick([0:25:125]),ytick([-125:25:125]),%hlines(-32.5,'k')
    xlabel('Radius (km)'),ylabel('Velocity (cm/s)')
        
    %Ro= 2 V/Rf   so V/R =Ro f/2 vm/rm = (1/2)*0.8*
    %2*sind(45)*7.292e-5*100*1000  = 4.12
    
    plot([0+sqrt(-1)*0;10.5+10.5*sqrt(-1)*maxmax(fs)*100*1000/24/3600/dt],'k','linewidth',2)
    plot([0+sqrt(-1)*0;10.5-10.5*sqrt(-1)*maxmax(fs)*100*1000/24/3600/dt],'k','linewidth',2)   
    plot([0+sqrt(-1)*0;150+150*sqrt(-1)*minmin(fs)*100*1000/24/3600/dt],'k','linewidth',2)
    plot([0+sqrt(-1)*0;150-150*sqrt(-1)*minmin(fs)*100*1000/24/3600/dt],'k','linewidth',2)
    
    h1=plot([0+sqrt(-1)*0;30+sqrt(-1)*4.16*30]);linestyle -h h1 2D
    h1=plot([0+sqrt(-1)*0;30-sqrt(-1)*4.16*30]);linestyle -h h1 2D
end
letterlabels(2)
ha=packcols(1,2);

for i=1:2
    axes(ha(i))
    h=colorbar('South');
    axes(h)
    switch i 
        case 1
            xlabel('Log10 Number of Ridge Points')
        case 2 
            xlabel('Median Squared Eccentricity \epsilon^2')
            xtick([0:0.2:1])
    end
    pos=get(h,'position');
    set(h,'position',[pos(1) pos(2)+0.01 pos(3) pos(4)/2]);
end
orient tall
fontsize 12 10 10 12
set(gcf,'paperposition',[0.5 1 8 6])
 
%Seriously that is not cool Matlab set(gcf,'renderer','opengl')
set(gcf,'renderer','zbuffer')
%set(gcf,'renderer','painters')
 
cd_figures
if strcmp(str,'print')
   print -depsc vortex-distributions.eps
end
%\************************************************************************

%/************************************************************************
figure

use vortex.drifters
ha(1)=subplot(2,2,1);
plot(x+sqrt(-1)*y),axis([-1 1 -1 1]*pi*L),set(gca,'dataaspectratio',[1 1 1])
ha(2)=subplot(2,2,2);
plot(xres+sqrt(-1)*yres),axis([-1 1 -1 1]*pi*L),set(gca,'dataaspectratio',[1 1 1])

use vortex.ridges
%Make the ridges into one long column
vcellcat(ir,jr,kr,fbar,R,V,kappa,theta,lambda,xresr,yresr,lr);

%0.8223=ecconv(0.95,'ecc2lin')

ha(3)=subplot(2,2,3);
index=periodindex(dt,fbar,3)';
ii=find(lambda(index)<0.8223&V(index)<0);
h=ellipseplot(kappa,lambda,theta,xresr+sqrt(-1)*yresr,[1 1],'index',index(ii));hold on;
linestyle -h h b
ii=find(lambda(index)<0.8223&V(index)>0);
h=ellipseplot(kappa,lambda,theta,xresr+sqrt(-1)*yresr,[1 1],'index',index(ii));hold on;
linestyle -h h r
index=periodindex(dt,fbar,1/2)';
ii=find(lambda(index)>0.8223);
h=ellipseplot(kappa,lambda,theta,xresr+sqrt(-1)*yresr,[1 1],'index',index(ii));hold on
linestyle -h h 2w
h=ellipseplot(kappa,lambda,theta,xresr+sqrt(-1)*yresr,[1 1],'index',index(ii));hold on
linestyle -h h g
axis([-1 1 -1 1]*pi*L)


ha(4)=subplot(2,2,4);
index=periodindex(dt,fbar,3)';
ii=find(lambda(index)<0.8223&V(index)<0);
map=colormap(jet);
h=ellipseplot(kappa,lambda,theta,xresr+sqrt(-1)*yresr,[1 1],'index',index(ii));hold on;
temp=ceil([log10(2*pi./fbar(index(ii)))-0.25]*64/1.4);
temp(temp>64)=64;temp(temp<1)=1;
    for i=1:length(h),
      set(h(i),'color',map(temp(i),:));
    end
ii=find(lambda(index)<0.8223&V(index)>0);
h=ellipseplot(kappa,lambda,theta,xresr+sqrt(-1)*yresr,[1 1],'index',index(ii));hold on;
temp=ceil([log10(2*pi./fbar(index(ii)))-0.25]*64/1.4);
temp(temp>64)=64;temp(temp<1)=1;
    for i=1:length(h),
      set(h(i),'color',map(temp(i),:));
    end
index=periodindex(dt,fbar,1/2)';
ii=find(lambda(index)>0.8223);
h=ellipseplot(kappa,lambda,theta,xresr+sqrt(-1)*yresr,[1 1],'index',index(ii));hold on
linestyle -h h 2w
h=ellipseplot(kappa,lambda,theta,xresr+sqrt(-1)*yresr,[1 1],'index',index(ii));hold on
temp=ceil([log10(2*pi./fbar(index(ii)))-0.25]*64/1.4);
temp(temp>64)=64;temp(temp<1)=1;
    for i=1:length(h),
      set(h(i),'color',map(temp(i),:));
    end
axis([-1 1 -1 1]*pi*L)

for i=1:4
    set(ha(i),'xtick',[-1000:500:1000])
    set(ha(i),'ytick',[-1000:500:1000])
end
letterlabels(1);
packboth(2,2)

axes(ha(4))
h=colorbar('south');
axes(h)
xtick([ceil([log10([2.5 5 10 20 40 80])-.25]*64/1.4)]/64)
set(gca,'xticklabel',['2.5';'5  ';'10 ';'20 ';'40 ';'80 '])
xlabel('Log10 Oscillation Period')
pos=get(h,'position');
set(h,'position',[pos(1) pos(2) pos(3) pos(4)/2]);

orient tall
fontsize 12 10 10 10
set(gcf,'paperposition',[1 1 8.3 8.5])

cd_figures
if strcmp(str,'print')
   print -depsc vortex-decomposition.eps
end
%\************************************************************************


if false  %To make the movie, change this line to 'if true'  
%/**********************************************************
figure
load vortexpv

use vortex.ridges
%Make the ridges into one long column
vcellcat(ir,jr,kr,fbar,R,V,kappa,theta,lambda,xresr,yresr,lr);

n=0;%
cd_figures
cd vortexmovie
colors=[0 0 1;0 1/2 0;1 0 0; 0 .75 .75; .75 0 .75;.75 .75 0];   
for k=[(1:101) 101-1:-1:2] 
    clf
    use vortexpv
    pcolor(x,y,abs(q(:,:,k))),shading interp,axis equal,axis square,axis tight,caxis([1 9]),hold on
    colormap(squared(flipud(colormap('gray'))))
    index=find(ir==(k-1)*20+1); 
    h=ellipseplot(kappa,lambda,theta,xresr+sqrt(-1)*yresr,[1 1],'index',index);linestyle -h h 3w
    h=ellipseplot(kappa,lambda,theta,xresr+sqrt(-1)*yresr,[1 1],'index',index);%linestyle -h h colors2
    
    for i=1:length(index)
        set(h(i),'color',colors(mod(kr(index(i))-1,6)+1,:),'linewidth',2)
    end
    
    index=find(ir==(k-1)*20+1&kr==80);   %... the one I use later
    h=ellipseplot(kappa,lambda,theta,xresr+sqrt(-1)*yresr,[1 1],'index',index);
    if ~isempty(h), linestyle -h h 2k, end
        
    use vortex.drifters
    plot(x((k-1)*20+1,:),y((k-1)*20+1,:),'o','markerfacecolor','w','markeredgecolor','k','markersize',4)
    index=find(~isnan(xhat((k-1)*20+1,:)));
    plot(x((k-1)*20+1,index),y((k-1)*20+1,index),'o','markerfacecolor','k','markeredgecolor','w','markersize',4)
    plot(x((k-1)*20+1,80),y((k-1)*20+1,80),'o','markerfacecolor','m','markeredgecolor','k','markersize',4)

    use vortexpv
    text(-550*2,550*2,['Day ' int2str(floor(num(k))) '.' int2str(floor(10*(num(k)-floor(num(k)))))],'color','w')
    %axis off,
    xlabel('Distance East (km)'),ylabel('Distance North (km)')
    title('Movie of Unstable Jet with Lagrangian Ellipses')
    h=gca;
    hc=colorbar('South','xcolor','w','ycolor','w');
    axes(hc)
    xlabel('Potential Vorticity Magnitude')
    n=n+1;
    print('-djpeg',['movieframe' int2str(n)])
    %MakeQTMovie addaxes 
end
    
M = getframe;
aviobj = addframe(aviobj,M);
aviobj = close(aviobj);


end
  
%\**********************************************************


%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
if false
%To double-check parameter values
load vortexpv
use vortexpv
figure
plot(y,detrend(q(:,:,1))),hold on
plot(y,-vdiff(squared(cos(y./40*pi/2)),1)*130,'g')
hold on
vlines([-40 40])


load vortex
use  vortex.drifters
cv=vdiff(unwrap(x/L)*L,1)./dt+sqrt(-1)*vdiff(y,1)./dt;
figure,plot(abs(cv))

zeta=pi*2.08/(80*1000)
2*2*omega*sind(45)./radearth*80/zeta
1/10/piS
%ok
%1.6*L*1000/(T*3600*24)=2.08
end

