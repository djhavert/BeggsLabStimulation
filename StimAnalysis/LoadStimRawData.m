



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
% Initialize
%data = zeros(MaxSamplesPerFile, 513, 'int16');


%% Load Spike File
spkFile = LoadVisionFiles([[data_dir,'data000.bin(5-50000)/'],'*.spikes']);
spktimes = spkFile.getSpikeTimes();
spktimes = spktimes(2:end);

%% SIMPLE SPIKE CLEANING
% Get rid of any spikes that occur during a window (Tartifact) after each
% stimulation pulse

Tstep = 10;
Tartifact = [20000; ESreal(:,1)];
for ii = 1:512
  oldSpkTimes = double(spktimes{ii});
  spktimes{ii} = oldSpkTimes(not(isInRange(oldSpkTimes, Tartifact, Tartifact+Tstep)));
end
clear oldSpkTimes Tartifact
%}
Nspikes = cellfun(@(x) length(x), spktimes);
HighSpkCh = find(Nspikes>(mean(Nspikes)+2*std(Nspikes)));
%}
%% Create PSTH
ch = 187;
if mod(ch,10)==0
  disp(num2str(ch));
end


subcounts = [1:50;
             51:100];
subcounts = [1:25;
             26:50;
             51:75;
             76:100];
subcounts = [1:10;
             11:20;
             21:30;
             31:40;
             41:50;
             51:60;
             61:70;
             71:80;
             81:90;
             91:100];

%subcounts = [1:100];
for subID = 1:4
%{
for pat = 1:size(stim_times,1)
  [psth_counts(:,pat),psth_edges] = PSTHcounts(spktimes{ch},stim_times{pat,2},'NumBins', 100, 'Range', range);
end

for pat = 7:9
  hf = PSTHplot(psth_counts(:,pat),psth_edges);
end
%}

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
  [counts,psth_edges] = PSTHcounts(spktimes{ch},stim_times{pat1,2}(ii:3:end),'NumBins', 100, 'Range', range, 'Combine', false);
  counts = sum(counts(subcounts(subID,:),:),1);
  counts = counts./sum(counts);
  hf(plt_idx) = PSTHplot(counts,psth_edges);
  plt_idx = plt_idx + 1;
  ylabel(['Response on ',num2str(ch)]);
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
  [counts,psth_edges] = PSTHcounts(spktimes{ch},stim_times{pat2,2}(ii:3:end),'NumBins', 100, 'Range', range, 'Combine', false);
  counts = sum(counts(subcounts(subID,:),:),1);
  counts = counts./sum(counts);
  hf(plt_idx) = PSTHplot(counts,psth_edges);
  plt_idx = plt_idx + 1;
  ylabel(['Response on ',num2str(ch)]);
  switch ii
    case 1
      title(['Stimulus on ',num2str(ch2),' only']);
    case 2
      title(['Stimulus on ',num2str(ch2),' then ',num2str(ch1)]);
      xline(30,'r');
  end
end

[counts,psth_edges] = PSTHcounts(spktimes{ch},stim_times{pat3,2},'NumBins', 100, 'Range', range, 'Combine', false);
counts = sum(counts(subcounts(subID,:),:),1);
counts = counts./sum(counts);
hf(plt_idx) = PSTHplot(counts,psth_edges);
plt_idx = plt_idx + 1;
ylabel(['Response on ',num2str(ch)]);
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

savefile = [dir,'figs/stim',num2str(ch1),'-',num2str(ch2),'_Read',num2str(ch)];
if size(subcounts,1) > 1
  savefile = [savefile,['_Sub',num2str(subID),'of',num2str(size(subcounts,1))]];
end
%savefig(savefile);
%delete(findall(0))

end


clear subcounts

%{
hf = cell(length(HighSpkCh),1);
for ii=1:length(HighSpkCh)
  ch = HighSpkCh(ii);
  hf{ii} = createPSTH(spktimes{ch},stim_times,'NumBins', 100, 'Range', range);
end
%}

%% Get Post Stim Raw Data
%{
Pat_ID = 1;
ch = 300;

post_stim_data = GetPostStimRawData(data_obj, stim_file_struct, Pat_ID, ch, range);

%{
PS_raw = cell(512,1);
for ii=1:1 %length(stimCh)
  PS_raw{ch} = getPostStimRawData(datastruct, datastruct_ttx, Pat_ID, ch, range);
end
%}

%% Plot Post Stim Data
T = period/20; %Time to plot from beginning in ms
for ii = 1:length(HighSpkCh)
  ch = HighSpkCh(ii);
  figure(hf{ii}.Number);
  x=(0.05:0.05:T)';
  subplot(2,2,3); 
  plot(x,PS_raw{ch}(1:20*T,(ESreal(:,2)==stimCh(1))));
  subplot(2,2,4); 
  plot(x,PS_raw{ch}(1:20*T,(ESreal(:,2)==stimCh(2))));
end
%}