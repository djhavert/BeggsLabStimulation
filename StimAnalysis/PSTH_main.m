



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
b_SavePlot = false;
b_HideFig = false;;
%for neur = 1:length(spktimes)
for neur = 1
%neur = HighSpkCh(1);
neurID = neurIDList(neur);
if mod(neur,10)==0
  disp(num2str(neur));
end

subcounts = [1:100];
for subID = 1:size(subcounts,1)


pat1 = 7;
pat2 = 8;
pat3 = 9;

ch1 = stim_times{pat1,1};
ch2 = stim_times{pat2,1};

plt_idx = 1;

for ii=1:3
  if ii == 2
    continue
  end
  [counts,psth_edges] = PSTHcounts(spktimes{neur},stim_times{pat1,2}(ii:3:end),'NumBins', 100, 'Range', range, 'Combine', false);
  counts = sum(counts(subcounts(subID,:),:),1);
  if b_AvgCount && sum(counts)>0
    counts = counts./sum(counts);
  end
  hf(plt_idx) = PSTHplot(counts,psth_edges);
  plt_idx = plt_idx + 1;
  ylabel(['Response on ',num2str(neurID)]);
  switch ii
    case 1
      title(['Stimulus on ',num2str(ch1),' only']);
    case 3
      title(['Stimulus on ',num2str(ch1),' then ',num2str(ch2)]);
      xline(30,'r');
  end
end

for ii=1:3
  if ii == 3
    continue
  end
  [counts,psth_edges] = PSTHcounts(spktimes{neur},stim_times{pat2,2}(ii:3:end),'NumBins', 100, 'Range', range, 'Combine', false);
  counts = sum(counts(subcounts(subID,:),:),1);
  if b_AvgCount && sum(counts)>0
    counts = counts./sum(counts);
  end
  hf(plt_idx) = PSTHplot(counts,psth_edges);
  plt_idx = plt_idx + 1;
  ylabel(['Response on ',num2str(neurID)]);
  switch ii
    case 1
      title(['Stimulus on ',num2str(ch2),' only']);
    case 2
      title(['Stimulus on ',num2str(ch2),' then ',num2str(ch1)]);
      xline(30,'r');
  end
end

[counts,psth_edges] = PSTHcounts(spktimes{neur},stim_times{pat3,2},'NumBins', 100, 'Range', range, 'Combine', false);
counts = sum(counts(subcounts(subID,:),:),1);
if b_AvgCount && sum(counts)>0
  counts = counts./sum(counts);
end
hf(plt_idx) = PSTHplot(counts,psth_edges);
plt_idx = plt_idx + 1;
ylabel(['Response on ',num2str(neurID)]);
title(['Stimulus on ',num2str(ch1),' and ',num2str(ch2),' simultaneously']);

f1 = figure();
%h(1) = subplot(2,1,1);
%h(2) = subplot(2,1,2);
%copyobj(allchild(get(hf(1),'CurrentAxes')),h(1));
%copyobj(allchild(get(hf(2),'CurrentAxes')),h(2));
ax1 = copyobj(hf(1).Children,f1);
ax2 = copyobj(hf(2).Children,f1);
ax3 = copyobj(hf(3).Children,f1);
ax4 = copyobj(hf(4).Children,f1);
ax5 = copyobj(hf(5).Children,f1);
subplot(3,2,1,ax1);
subplot(3,2,2,ax3);
subplot(3,2,3,ax2);
subplot(3,2,4,ax4);
%posn = mean(cell2mat(get([subplot(3,2,5),subplot(3,2,6)],'position')));
subplot(3,4,[10 11],ax5);

if b_SavePlot
  savefile = [dir,'figs/neurons/stim',num2str(ch1),'-',num2str(ch2),'_Read',num2str(neurID)];
  if size(subcounts,1) > 1
    savefile = [savefile,['_Sub',num2str(subID),'of',num2str(size(subcounts,1))]];
  end
  savefig(savefile);
end
if b_HideFig
  delete(findall(0))
end

end
end

clear subcounts

