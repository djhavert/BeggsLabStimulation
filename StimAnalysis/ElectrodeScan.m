% Brief Analysis of Stimulated Electrodes to find most effective stim sites
% and most responsive channels to each stim site.
% 
% Change your Matalb 'Current Folder' to be the folder where stim files and
% 'data00X' folder is.
% If data folder is not 'data000' then change line 


tic

% function ElectrodeScan(dir)
stim_dir = fullfile(pwd);
data_dir = fullfile(pwd,'data000');

% Get Stim Info
stim = LoadStimFile(stim_dir);
[pat_t,~] = getStimTimes(stim.ES);
num_pats = size(pat_t,1);

% Spike Finding
% this line finds all spike times on every electrode. It will a long time
% to run this (approx. equal to length of recording)
spike_times = SpikeDetect512(data_dir);


%% Count Post Stimulus Spikes
short_range = 20*5; 
long_range = 20*300;
short_count = zeros(num_pats,512);
long_count = zeros(num_pats,512);
response = struct('stim_site',[],'short_max',[],'short_avg',[],'short',[],'long_max',[],'long_avg',[],'long',[]);

% for each stimulated electrode...
for pat = 1:num_pats
  response(pat).stim_site = pat_t{pat,1};
  stim_times = pat_t{pat,2};
  % for each channel...
  for ch = 1:512
  % Count spikes before short_range value
  short_count(pat,ch) = sum(isInRange(spike_times{ch}',stim_times,stim_times+short_range))./length(stim_times);
  % Count spikes between short_range and long_range values
  long_count(pat,ch) = sum(isInRange(spike_times{ch}',stim_times+short_range,stim_times+long_range))./length(stim_times);
  end
  
  % Sort by number
  [S,I] = sort(short_count(pat,:),'descend');
  response(pat).short_max = [S(1)];
  response(pat).short_avg = mean(S);
  response(pat).short(:,1) = I';
  response(pat).short(:,2) = S';
  [S,I] = sort(long_count(pat,:),'descend');
  response(pat).long_max = [S(1)];
  response(pat).long_avg = mean(S);
  response(pat).long(:,1) = I';
  response(pat).long(:,2) = S';
  
  
end

% Sort 

 
 
 toc