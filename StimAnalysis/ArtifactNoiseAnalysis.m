% Analysis of artifact size in PBS 1X solution
stim_dir = pwd;
stim_file = LoadStimFile(stim_dir);
stim = CreateStimStruct(stim_file.ES_stim,'SequenceDuration', 10);

data_dir = fullfile(pwd,'data000',filesep);
LoadVision2;
data_obj = LoadVisionFiles(data_dir);
% Extract some useful info
header = data_obj.getHeader();
num_samples = header.getNumberOfSamples();

data = data_obj.getData(0, num_samples);
%%
wf = cell(length(stim.sequence),1);
%for ii = 1:length(stim.sequence)
stim_ch = 8;
  ch = stim.sequence{stim_ch}(2);
  times = stim.sequence_times{stim_ch};
  waveforms = zeros(512,length(-20:20*15),length(times));
  for jj = 1:length(times)
    waveforms(:,:,jj) = transpose(data(times(jj)-20:times(jj)+20*15,2:513));
  end
  waveforms_pos = mean(waveforms,3);
  wf{stim_ch} = waveforms;
%end

%%
load('/home/ADS_djhavert/Documents/IU/BeggsLab/Vision/electrodemaprect.mat');
x = -1:.05:15;
chs = 1:512;
chs(chs == stim_ch) = [];
amps = zeros(size(emap_rect));
for ii = 1:length(chs)
  ch = chs(ii);
  maxes(ii) = max(waveforms(ch,:));
  mins(ii) = min(waveforms(ch,:));
  [row,col] = find(emap_rect == ch);
  amps(row,col) = maxes(ii) - mins(ii);
end
[row,col] = find(emap_rect == stim_ch);

Max = max(maxes);
Min = min(mins);
bar3(amps)


