



% USER INPUT - directory info
dir = [pwd, '/02_Stim_ThreePairsAmp10_PostTTX/'];
data_dir = [dir, 'data000/'];
stim_file_dir = dir;




%--------------------------------------------------------------------------
% CONSTANTS ---------------------------------------------------------------
MaxSamplesPerFile = 20000*60*2; %2 min
range = 20*200;

% STIM FILE PROPERTIES ----------------------------------------------------
stim_file_struct = LoadStimFile(stim_file_dir);
ESreal = stim_file_struct.ES(stim_file_struct.ES(:,2)>0,:);
[stim_times,PS] = getStimTimes(stim_file_struct.ES(find(stim_file_struct.ES(:,2)>0),:));


% Find channels that were stimulated and in what order.
%[stimCh, stimChOrder] = getStimChannels(ESreal);
%ES_indices = getStimChannels(ESreal);

% DATA --------------------------------------------------------------------
% Load Vision
LoadVision2;

% CREATE JAVA OBJECTS TO ACCESS VISION READ AND WRITE FUNCTIONS -----------
% ORIGINAL DATA OBJECT
% Open original data file for reading
data_obj = LoadVisionFiles(data_dir);
% Extract some useful info
header = data_obj.getHeader();
num_samples = header.getNumberOfSamples();
num_files = ceil(num_samples/MaxSamplesPerFile);


%% Load Spike File
neurFile = LoadVisionFiles([[data_dir,'data000.bin(5-50000)/'],'*.neurons']);
numNeur = neurFile.getNumberOfNeurons();
neurIDList = neurFile.getIDList();
spktimes = cell(numNeur,1);
for ii = 1:numNeur
  spktimes{ii} = neurFile.getSpikeTimes(neurIDList(ii));
end

%% SIMPLE SPIKE CLEANING
% Get rid of any spikes that occur during a window (Tartifact) after each
% stimulation pulse

Tstep = 10;
Tartifact = [20000; ESreal(:,1)];
for ii = 1:length(spktimes)
  oldSpkTimes = double(spktimes{ii});
  spktimes{ii} = oldSpkTimes(not(isInRange(oldSpkTimes, Tartifact, Tartifact+Tstep)));
end
clear oldSpkTimes Tartifact
%}
Nspikes = cellfun(@(x) length(x), spktimes);
HighSpkCh = find(Nspikes>(mean(Nspikes)+2*std(Nspikes)));
%}
%% Create PSTH
b_AvgCount = false;
b_SavePlot = true;
b_HideFig = true;

range = 200*20;
Nbins = 100;

% Define the different patterns and sort the stimulation times for each
% pattern into appropriate bin
Patterns{1,1} = [295, 0];
Patterns{2,1} = [306, 0];
Patterns{3,1} = [295, 0; 306, 600];
Patterns{4,1} = [306, 0; 295, 600];
Patterns{5,1} = [295, 0; 306, 0];
Patterns{6,1} = [35, 0];
Patterns{7,1} = [27, 0];
Patterns{8,1} = [35, 0; 27, 600];
Patterns{9,1} = [27, 0; 35, 600];
Patterns{10,1} = [35, 0; 27, 0];
Patterns{11,1} = [75, 0];
Patterns{12,1} = [95, 0];
Patterns{13,1} = [75, 0; 95, 600];
Patterns{14,1} = [95, 0; 75, 600];
Patterns{15,1} = [75, 0; 95, 0];

  % Order of stimulation is patterns 1,2,4,3,5
Patterns{1,2} = stim_times{1,2}(1:3:end);
Patterns{2,2} = stim_times{2,2}(1:3:end);
Patterns{3,2} = stim_times{1,2}(3:3:end);
Patterns{4,2} = stim_times{2,2}(2:3:end);
Patterns{5,2} = stim_times{3,2};
Patterns{6,2} = stim_times{4,2}(1:3:end);
Patterns{7,2} = stim_times{5,2}(1:3:end);
Patterns{8,2} = stim_times{4,2}(3:3:end);
Patterns{9,2} = stim_times{5,2}(2:3:end);
Patterns{10,2} = stim_times{6,2};
Patterns{11,2} = stim_times{7,2}(1:3:end);
Patterns{12,2} = stim_times{8,2}(1:3:end);
Patterns{13,2} = stim_times{7,2}(3:3:end);
Patterns{14,2} = stim_times{8,2}(2:3:end);
Patterns{15,2} = stim_times{9,2};



%% For each pattern
for pat = 11:size(Patterns,1)
  counts = zeros(numNeur,Nbins,length(Patterns{pat,2}));
  % For each neuron
  %counts{pat,1} = zeros(length(spktimes),Nbins);
  for neur = 1:numNeur
    neurID = neurIDList(neur);
    if mod(neur,20)==0
      disp([num2str(pat),'. ',num2str(neur)]);
    end

    subcounts = [1:100];
    % For each subdivision
    for subID = 1:size(subcounts,1)  
      [counts_temp,psth_edges] = PSTHcounts(spktimes{neur},Patterns{pat,2},'NumBins', Nbins, 'Range', range, 'Combine', false);
      counts(neur,:,:) = transpose(counts_temp);
      %counts{pat,1}(neur,:) = sum(counts_temp(subcounts(subID,:),:),1);
      
      
      %{
      for ii = 1:size(Patterns{pat},1)
        chs(ii,1) = Patterns{pat}(ii,1);
      end
      
      switch pat
        case 1
          start_indx = 1;
        case 2
          start_indx = 1;
        case 3
          start_indx = 1;
        case 4
          start_indx = 1;
        case 5
          start_indx = 1;
      end
      %}


    end
  end
  %stim.psth_counts{pat} = counts;
end
clear subcounts

%% GET POSITIONS/DISTANCES
elmap = edu.ucsc.neurobiology.vision.electrodemap.Rectangular512ElectrodeMap();
ch1 = 75;
ch2 = 95;
ch1_pos = [elmap.getXPosition(ch1),elmap.getYPosition(ch1)];
ch2_pos = [elmap.getXPosition(ch2),elmap.getYPosition(ch2)];
dist1 = zeros(numNeur,1);
dist2 = zeros(numNeur,1);
distance = zeros(numNeur,1);
for ii = 1:numNeur
  dist1(ii) = norm(asdf.location(ii,:)-ch1_pos);
  dist2(ii) = norm(asdf.location(ii,:)-ch2_pos);
  distance(ii) = min(dist1(ii),dist2(ii));
end

[~,SortByDist] = sort(distance);

%% MAKE RASTER
for pat = 11:15
xcell = cell(numNeur,1);
for neur = 1:numNeur
  [counts_temp,psth_edges] = PSTHcounts(spktimes{neur},Patterns{pat,2},'NumBins', range, 'Range', range, 'Combine', false);
  %num = sum(sum(counts_temp));
  [~,time] = find(counts_temp);
  xcell{neur} = time;
  %x = [x; time];
  %y = [y; neur*ones(length(time),1)];
  %avgs = [avgs;mean(time)];
end

x = [];
y = [];
avgs = [];
for neur = 1:numNeur
  x = [x;xcell{neur}./20];
  y = [y;neur*ones(length(xcell{neur}),1)];
  avgs = [avgs;mean(xcell{neur})./20];
end

%% Plot Rasters

figure();
plot(x(:)',y, '.', 'MarkerSize', 6);
title 'Post Stimulus Raster'
xlabel 'Time (ms)'
ylabel 'Neuron'
axis tight
savefig([dir,'figs/Rasters/PSTH Raster_pat',num2str(pat)]);
  
ySortByDist = SortByDist(y);
figure();
plot(x,ySortByDist, '.', 'MarkerSize', 6);
title 'Post Stimulus Raster Sorted By Distance' 
xlabel 'Time (ms)'
ylabel 'Neuron (bottom->closest, top->farthest)'
axis tight
savefig([dir,'figs/Rasters/PSTH Raster SortByDistance_pat',num2str(pat)]);

figure();
plot(distance,avgs,'.')
title 'Mean Spike Time vs Distance'
xlabel 'Distance from Either Stim Site (um)'
ylabel 'Average Spike Time After Stimulus (ms)'
lsline;
savefig([dir,'MeanSpikeTimeVsDistance_pat',num2str(pat)]);

end