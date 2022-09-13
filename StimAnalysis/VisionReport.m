%generates a bunch of figures and statistics from vision files.  Works
%while the pwd folder contains all the processed vision files.  At some
%point can turn into a function and set 1 path for everything, but not
%really necessary for now.  

%plots Avalanche statistics, Avg FR distribution, FR vs time, image of
%neuron locations, and displays some basic info in top left.  Will also
%plot neuron locations overlayed with photo of slice, so long as photo is
%saved as "slicephoto.jpg".  Be careful with this image though, as it
%requires manual work to make it correct (as of 11/26/19 - planning to
%automate in future).  

%IMPORTANT: make sure you are using an ASDF file that has 3 elements in the
%last cell entry, and not 2 elements.  This file will generate a correct
%ASDF if you are unsure, so long as there is no "asdf.mat" already present
%in pwd folder.  


%% Files necessary to run this:
%1)  FindAvas
%2)  NeuronsToASDF - make sure this file is updated - line 29 should have
%variable "temp = ...".  Otherwise there is a mistake in the duration it
%gives the recording, which can drastically mess up results.
%3)  LoadVision2
%4)  LoadVisionFiles
%5)  ASDFToSparse
%6)  PlotArray
%7)  ASDFGetfrate
%8)  ASDFChangeBinning
%9)  getWildName
%10) isfullpath
%11) ASDFToRaster

%% VARIABLES TO SET BEFORE RUNNING (if you want to change them)
clear
clf
AvgFRTimeWindow = 5000; %number of time bins over which to average FR for Avg FR vs time plot
binsize = 1; %binsize used when calculating avalanches
%FRHistEdges = 0.01:0.01:max(fr); (~line 43) %gives resolution of firing rate distribution plots

%x and y in the photo section (~line 66) - can't be set here
%directory = pwd;

%%
LoadVision2 %ability to load vision files
spikes = LoadVisionFiles('*.spikes'); %loads *.spikes file
neurons = LoadVisionFiles('*.neurons'); %loads *.neurons file
pfile = LoadVisionFiles('*.params'); %loads *.params file

if (exist([pwd '/asdf.mat'],'file')) %will check that ASDF is in folder - else will create & load one
    load([pwd '/asdf.mat'])
else
    fileList = dir('*.neurons'); % *.neurons file must be in current folder
    NeuronsToASDF([pwd '/' fileList.name], 'asdf.mat', 512); %generates/saves ASDF file to current folder
    load([pwd '/asdf.mat']) %loads ASDF from current folder
end

fr = ASDFGetfrate(asdf_raw) * 1000;
FRHistEdges = 0.01:0.01:max(fr)+0.05; %gives resolution of firing rate distribution plots
raster1 = ASDFToSparse(asdf_raw);

spikecount = spikes.getSpikesCount; %pre-processed spike count
spikecountproc = length(find(raster1)); %processed spike count
threshold = spikes.getThreshold; %displays the threshold with which spike sorting was done
neurnum = neurons.getNumberOfNeurons; %displays number of processed neurons found

splotindex = 1;


%% Electrode plot
%f1 = figure(1);
subplot(3,3,splotindex)
splotindex = splotindex+1;
%figure
PlotArray(512);

% get EI location of neurons.
x=0; y=0;
for i = 1:length(IDs)
	if pfile.hasParameter('EIx0') & pfile.hasParameter('EIy0')
		try
			x(i) = pfile.getDoubleCell(IDs(i), 'EIx0');
			y(i) = pfile.getDoubleCell(IDs(i), 'EIy0');
		catch ME
			x(i) = location(i,1);
			y(i) = location(i,2);
    end
		%if (isnan(x(i))|isnan(y(i))) % either of them is nan
		%	x(i) = location(i,1);
		%	y(i) = location(i,2);
        %end
		%else
		%	x(i) = location(i,1);
		%	y(i) = location(i,2);
		%end
    end
end
hold on
plot(x,y,'o');
axis([-1000 1000 -500 500]);
ylabel('Location of neurons');
%save([pwd 'xy.mat'], 'x', 'y')


%% SHOW A PHOTO - REQUIRES MANUAL CHECK/EDIT

if (exist([pwd '/slicephoto.jpg'],'file'))
    splotindex = splotindex+1
    subplot(3,3,splotindex)
    %figure
    data=imread('slicephoto.jpg'); %picture with slice and array
    imshow(data,'InitialMagnification','fit')
    h = gca;
    h.Visible = 'On';
%xy loaded from previous section.  match which coord is which according to the
%dimensions of array in pic.  
%to overlay x,y coords and pic of slice+array - find conversion from
%-500,500 (or -1000,1000) to scale of array in pic. I.e, find the conversion from pixels -> mm
%Then divide x,y by that.  Next, find center of array on pic and add those x,y coords to the
%x,y neuron location coords. 
%Not sure how to deal with image should rotations be necessary
    y = y/2.808; x = x/2.808;
    y = y+989; x = x+878;
    hold on
    scatter(y,x) %confirm that they closely overlap
else
    disp(['Could not find "slicephoto.jpeg" in folder, and so no image of neurons overlapped with' ... 
    ' picture of slice is displayed'])
end

%% distribution of firing rate & avg FR over time
subplot(3,3,splotindex)
splotindex = splotindex+1;
%histcounts(log(fr),log(FRHistEdges));
%plot(log(FRHistEdges(1:end-1)),ans)
%stem1 = stem(log(FRHistEdges(1:end-1)),ans,'Marker','none','LineWidth',12,'Color',[0 0.447 0.741]);
%set(gca,'XScale', 'log'); %do we want log scale?  
histogram(log10(fr),-3:0.25:2);
xlim([-inf inf])
xlabel('Log Firing Rate(Hz)');
ylabel('Counts');
title('Firing Rate Distribution')

currentRate = asdf_raw{end-1};
AvgFRTime = AvgFRTimeWindow/currentRate;
asdf = ASDFChangeBinning(asdf_raw, AvgFRTime); %firing rate averaged every () ms
frtime = full(sum(raster1));
frtimeavg = zeros(1,ceil(length(frtime)/AvgFRTime));
for i = 1:length(frtime)/AvgFRTime
    frtimeavg(i) = sum(frtime((AvgFRTime*(i-1)+1):(AvgFRTime*i)))*1000/(neurnum*AvgFRTime);
end
%figure
subplot(3,3,splotindex)
splotindex = splotindex+1;
X = (1:i+1)*AvgFRTimeWindow/1000;
plot(X,frtimeavg)
xlabel('Time (s)')
ylabel('Firing Rate per Neuron')
title(sprintf('Average Firing Rate (per %d ms)',AvgFRTimeWindow)) 

%% AVALANCHE ANALYSIS

[ ~, AvSzes, AvLens, ~] = findAvas(asdf_raw,binsize); %lens = time length, szes = #spikes
AvLens = AvLens+1;
hSzes = histcounts(AvSzes,1:1000);
hLens = histcounts(AvLens,1:1000);
ProbhSzes = hSzes./sum(hSzes);
ProbhLens = hLens./sum(hLens);

%figure
subplot(3,3,splotindex)
splotindex = splotindex+1;
scatter(1:length(ProbhSzes),ProbhSzes)
set(gca,'xscale','log','yscale','log')
%set(gca,'Ydir','reverse','Xdir','reverse')
title(['Avalanche Size Distribution (binsize = ',num2str(binsize),')'])
xlabel('Length of Avalanche (# of spikes)')
ylabel('Probability of Avalanche Length')
xlim([0 inf])

%figure
subplot(3,3,splotindex)
splotindex = splotindex+1;
scatter(1:length(ProbhLens),ProbhLens)
set(gca,'xscale','log','yscale','log')
%set(gca,'Ydir','reverse','Xdir','reverse')
title(['Avalanche Duration Distribution (binsize = ',num2str(binsize),')'])
xlabel('Duration of Avalanche (time)')
ylabel('Probability of Avalanche Duration')
xlim([0 inf])

%figure
subplot(3,3,splotindex)
splotindex = splotindex+1;
scatter(AvSzes,AvLens)
set(gca,'xscale','log','yscale','log')
%set(gca,'Ydir','reverse','Xdir','reverse')
title(['Avalanche Size Vs. Duration (binsize = ',num2str(binsize),')'])
xlabel('Duration of Avalanche (time)')
ylabel('Size of Avalanche (# spikes)')
xlim([0 inf])

%%

annotation('textbox',[0 .9, .1, .1], 'String',{'Pre-processed spikes' ...
    spikecount 'Post-processed spikes' spikecountproc 'Processing threshold' threshold ...
    'Number of neurons' neurnum, 'Time (hrs)', asdf_raw{end}(2)/3600000,'Number of Avalanches', ...
    length(AvSzes)})
%% getting spectrogram
% subplot(7,2,5:6);
% wleng = window / incr; % should be an even number
% hannwin = 0.5 * (1 - cos(2*pi * (0:(wleng-1)) / (wleng-1)));
% 
% spect = zeros((wleng/2), dur/window);
% for i = 0:wleng:(dur/incr-1);
% 	fftwin = fft(frtime1hincr((i+1):(i+wleng)).*hannwin);
% 	spect(:,(i/wleng) + 1) = (abs(fftwin(2:(wleng/2+1)))).^2;
% end
% 
% fincr = 1000/window; % min frequency
% Nf = 1000/incr/2;
% yran = fincr:fincr:Nf;
% %imagesc(xran, yran, log(spect)); disabled since it's heavy
% %set(gca,'YScale', 'linear');
% ylabel('Frequency(Hz)');
% 
% fullwin = 1000; % ms
% fulldur =  floor(length(frtime)/fullwin) * fullwin;
% frtime_amp = frtime(1:fulldur);
% frtimewindow = sum(reshape(frtime_amp, fullwin, fulldur/fullwin)) / nNeu / fullwin * 1000;
% 
% figure
% xran = (fullwin/2000):(fullwin/1000):(fulldur/1000);
% plot(xran, frtimewindow, 'LineWidth', 0.3);
% ylabel('Firing Rate(Hz/neuron)')
% xlim([0,fulldur/1000])
% xlabel('time (s)')
% title(pwd);
% 
% 
% % make it 1hour
% dur = 3600000; % 1 hour
% frtime1h = zeros(dur, 1);
% 
% if length(frtime) > dur
% 	frtime1h = frtime(1:dur);
% else
% 	frtime1h(1:length(frtime)) = frtime;
% end
% 
% % reshape to get proper sum
% incr = 5; % this number sets Nyquist frequency
% window = 1000; % this number should be multiple of incr.
% 
% frtime1hincr = sum(reshape(frtime1h, incr, dur/incr));
% frtime1hwindow = sum(reshape(frtime1h, window, dur/window));
% 
% frtime1hwindow = frtime1hwindow/nNeu/window * 1000;  % normalized to get Hz / neuron
% 
% 
% subplot(7, 2, 3:4)
% xran = (window/2000):(window/1000):(dur/1000);
% plot(xran, frtime1hwindow, 'LineWidth', 0.3);
% %ylabel('Firing Rate(Hz/neuron)')
% xlim([0,dur/1000])
% xlabel('time (s)')


%% SAVE
if ~exist('figure/', 'dir')
  mkdir('figure/');
end
set(gcf, 'Position', get(0, 'Screensize'));
saveas(gcf,['figure/','report_binsize_',num2str(binsize)],'fig');
saveas(gcf,['figure/','report_binsize_',num2str(binsize)],'jpeg');

%% JUST AVALANCHES
%{
binsize = 1;

%offset = 4800*1000/binsize;
%offset = 0;
%range = floor(7194919/binsize - offset - 2);
%range = floor(7194919*2/3/binsize - offset - 2);

%[ ~, AvSzes, AvLens, ~] = findAvas(asdf_raw, binsize,'offset',offset,'range',range); %lens = time length, szes = #spikes
[ ~, AvSzes, AvLens, ~] = findAvas(asdf_raw,binsize); %lens = time length, szes = #spikes


figure()
title('Avalanches (Binsize 1)')
%[ ~, AvSzes, AvLens, ~] = findAvas(asdf_raw,binsize); %lens = time length, szes = #spikes
AvLens = AvLens+1;
hSzes = histcounts(AvSzes,1:1000);
hLens = histcounts(AvLens,1:1000);
ProbhSzes = hSzes./sum(hSzes);
ProbhLens = hLens./sum(hLens);

%figure
subplot(4,3,[4,7])
splotindex = splotindex+1;
scatter(1:length(ProbhSzes),ProbhSzes)
set(gca,'xscale','log','yscale','log')
%set(gca,'Ydir','reverse','Xdir','reverse')
title(['Avalanche Size Distribution'])
xlabel('Length of Avalanche (# of spikes)')
ylabel('Probability of Avalanche Length')
xlim([0 inf])

%figure
subplot(4,3,[5,8])
splotindex = splotindex+1;
scatter(1:length(ProbhLens),ProbhLens)
set(gca,'xscale','log','yscale','log')
%set(gca,'Ydir','reverse','Xdir','reverse')
title(['Avalanche Duration Distribution'])
xlabel('Duration of Avalanche (time)')
ylabel('Probability of Avalanche Duration')
xlim([0 inf])

%figure
subplot(4,3,[6,9])
splotindex = splotindex+1;
scatter(AvSzes,AvLens)
set(gca,'xscale','log','yscale','log')
%set(gca,'Ydir','reverse','Xdir','reverse')
title(['Avalanche Size Vs. Duration'])
xlabel('Duration of Avalanche (time)')
ylabel('Size of Avalanche (# spikes)')
xlim([0 inf])

set(gcf, 'Position', get(0, 'Screensize'));
saveas(gcf,['figure/','Aval_binsize_',num2str(binsize)],'fig');
saveas(gcf,['figure/','Aval_binsize_',num2str(binsize)],'jpeg');
%}
%% AVALANCHE ANALYSIS
%{
figure();
for ii = 1:4

binsize = ii;

[ ~, AvSzes, AvLens, ~] = findAvas(asdf_raw,binsize); %lens = time length, szes = #spikes
AvLens = AvLens+1;
hSzes = histcounts(AvSzes,1:1000);
hLens = histcounts(AvLens,1:1000);
ProbhSzes = hSzes./sum(hSzes);
ProbhLens = hLens./sum(hLens);

%figure
subplot(4,3,(ii-1)*3 + 1)
splotindex = splotindex+1;
scatter(1:length(ProbhSzes),ProbhSzes)
set(gca,'xscale','log','yscale','log')
%set(gca,'Ydir','reverse','Xdir','reverse')
title(['Avalanche Size Distribution (binsize = ',num2str(binsize),')'])
xlabel('Length of Avalanche (# of spikes)')
ylabel('Probability of Avalanche Length')
xlim([0 inf])

%figure
subplot(4,3,(ii-1)*3 + 2)
splotindex = splotindex+1;
scatter(1:length(ProbhLens),ProbhLens)
set(gca,'xscale','log','yscale','log')
%set(gca,'Ydir','reverse','Xdir','reverse')
title(['Avalanche Duration Distribution (binsize = ',num2str(binsize),')'])
xlabel('Duration of Avalanche (time)')
ylabel('Probability of Avalanche Duration')
xlim([0 inf])

%figure
subplot(4,3,(ii-1)*3 + 3)
splotindex = splotindex+1;
scatter(AvSzes,AvLens)
set(gca,'xscale','log','yscale','log')
%set(gca,'Ydir','reverse','Xdir','reverse')
title(['Avalanche Size Vs. Duration (binsize = ',num2str(binsize),')'])
xlabel('Duration of Avalanche (time)')
ylabel('Size of Avalanche (# spikes)')
xlim([0 inf])

end
set(gcf, 'Position', get(0, 'Screensize'));
saveas(gcf,['figure/','Aval_binsize1-4'],'fig');
saveas(gcf,['figure/','Aval_binsize1-4'],'jpeg');
%}