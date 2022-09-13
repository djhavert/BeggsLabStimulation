% DEPENDENCIES
%1) CreateASDF.m
%2) LoadStimFile.m
%3) CreateStimStruct.m
%4) ASDFGetfrate.m
%5) PSTHcounts.m

% change Matlab current directory to the top of the data folder 
% (i.e. '...9-30-21/Slice1/TrainInterval'

% directory where Vision outputs are saved (where the .neurons file is)
%KSout_dir = fullfile(pwd,'KSoutput');
KSout_dir = fullfile(pwd,'data000_KSoutput');
% directory where the four stimulation files are saved
stim_dir = pwd;

% Create (if not done so prior) and load the asdf.mat file
%[spikestruct, rez] = KStoASDF(KSout_dir);
load([pwd '/asdf.mat']);
num_neur = length(asdf_raw)-2;

% Load Stim Files
stim_file = LoadStimFile(stim_dir);
% Create the stim struct, which is my own custom variable that identifies
% and separates out stimulation 'sequences' and their times, which I define
% as a unique set of stimulation pulses that occur within a 250ms period. 
% A 'sequence' could be a single channel being stimulated or a series of
% channels stimulated in quick succession like in the Interval Training
% protocol.
stim = CreateStimStruct(stim_file.ES_stim,'ms');

% Separate stimulation pulses into pre-train, train, and post-train.
% First 100 of each solo channel stimulation is pre train
% Second 100 is post train.
% Sequences with 2 channels being stimulated in quick succession are train.
% This will give 5 elements to the stim sequence struct. 
% (2 x pre train, 1 x train, 2 x post train)
pre_train = 1:100;
post_train = 101:200;
for ii = 1:length(stim.sequence)
  if size(stim.sequence{ii}) == [1,2]
    pre_train_times = stim.sequence_times{ii}(pre_train);
    post_train_times = stim.sequence_times{ii}(post_train);
    stim.sequence{end+1} = stim.sequence{ii};
    stim.sequence_times{ii} = pre_train_times;
    stim.sequence_times{end+1} = post_train_times;
  end
end

%% Histogram
hist_dir = fullfile(stim_dir,'figure','PSTH');
if (~isdir(hist_dir))
  mkdir(hist_dir);
end

% HISTOGRAM OF ALL NEURONS COMBINED
range = 10;
cutoff = 0.0;
[response_times, ids] = PSTHtimesBest(asdf_raw,stim.sequence_times,'Range',range,'Cutoff',cutoff);
ids = IDs(ids);
edges = 0:range/40:range;

for ii = 1:size(response_times,2)
  temp = response_times(:,ii);
  response_all{1,ii} = [temp{:}];
end
figure();
title(['All Neuron Response']);
hold on;
ax = subplot(3,4,[1 2]);
histogram(ax, response_all{1,1},edges);
title(['Pattern 1 PRE (',num2str(length(response_all{1,1})),' spikes)']);

ax = subplot(3,4,[3 4]);
histogram(ax, response_all{1,2},edges);
title(['Pattern 2 PRE (',num2str(length(response_all{1,2})),' spikes)']);

ax = subplot(3,4,[6 7]);
histogram(ax, response_all{1,3},edges);
title(['Pattern [1 2] TRAIN (',num2str(length(response_all{1,3})),' spikes)']);

ax = subplot(3,4,[9 10]);
histogram(ax, response_all{1,4},edges);
title(['Pattern 1 POST (',num2str(length(response_all{1,4})),' spikes)']);

ax = subplot(3,4,[11 12]);
histogram(ax, response_all{1,5},edges);
title(['Pattern 2 POST (',num2str(length(response_all{1,5})),' spikes)']);

saveas(gcf,fullfile(hist_dir,['all_',num2str(range),'ms']),'fig');
saveas(gcf,fullfile(hist_dir,['all_',num2str(range),'ms']),'jpeg');

%% HISTOGRAM OF TOP NEURONS SEPARATED BY NEURON
range = 40;
cutoff = 0.1;
[response_times, ids] = PSTHtimesBest(asdf_raw,stim.sequence_times,'Range',range,'Cutoff',cutoff);
ids = IDs(ids);
edges = 0:range/40:range;

for n = 1:length(ids)
  figure('visible','off');
  title(['Neuron ID: ',ids(n),' Response']);
  hold on;
  ax = subplot(3,4,[1 2]);
  histogram(ax, response_times{n,1},edges);
  title('Pattern 1 PRE');

  ax = subplot(3,4,[3 4]);
  histogram(ax, response_times{n,2},edges);
  title('Pattern 2 PRE');

  ax = subplot(3,4,[6 7]);
  histogram(ax, response_times{n,3},edges);
  title('Pattern [1 2] TRAIN');

  ax = subplot(3,4,[9 10]);
  histogram(ax, response_times{n,4},edges);
  title('Pattern 1 POST');

  ax = subplot(3,4,[11 12]);
  histogram(ax, response_times{n,5},edges);
  title('Pattern 2 POST');

  
  saveas(gcf,fullfile(hist_dir,num2str(ids(n))),'fig');
  saveas(gcf,fullfile(hist_dir,num2str(ids(n))),'jpeg');
end



%% Count spikes in a period after stimulation
% Background firing rate
FR_background = ASDFGetfrate(asdf_raw)*1000; % in Hz

% Histogram settings
bins = 100;
range = 20*100;
deltaT = range/bins/20000;
% Initialize arrays
counts_post_totals = zeros(num_neur,length(stim.sequence));
counts_pre_totals = zeros(num_neur,length(stim.sequence));
FR_post_mean = zeros(num_neur,length(stim.sequence));
FR_post_stdev = zeros(num_neur,length(stim.sequence));
FR_pre_mean = zeros(num_neur,length(stim.sequence));
FR_pre_stdev = zeros(num_neur,length(stim.sequence));
% For each separate stimulation (2 x pre train, 1 x train, 2 x post train)
counts_post = cell(5,1);
for ii = 1:length(stim.sequence)
  % For each neuron
  for neur = 1:num_neur
    % count number of spikes for each stimulation and time bin
    [counts_post{num_neur,ii},edges] = PSTHcounts(asdf_raw{neur}, stim.sequence_times{ii}, 'NumBins',bins,'Range',range,'Combine',0);
    % sum over all time bins. Gives total number of post stimulus spikes
    % for each stimulation
    counts_post_summed = sum(counts_post{num_neur,ii},2); 
    % sum over all stimulations. Total mumber of post stimulus spikes for
    % all 100 stimulations
    counts_post_totals(neur,ii) = sum(counts_post_summed);
    % Average post stimulus firing rate for each stimulation
    FR_post = counts_post_summed./(range/20000);
    % Average post stimulus firing rates averaged over all stimulations
    FR_post_mean(neur,ii) = mean(FR_post);
    % Standard deviation of firing rates over all stimulations
    FR_post_stdev(neur,ii) = std(FR_post);
    
    % Do all the same stuff as above but for the region of time right
    % before each stimulus
    counts_pre = PSTHcounts(asdf_raw{neur}, stim.sequence_times{ii}, 'NumBins', 1, 'Range', [-range-1,-1],'Combine',0);
    counts_pre = sum(counts_pre,2); 
    counts_pre_totals(neur,ii) = sum(counts_pre);
    FR_pre = counts_pre./(range/20000);
    FR_pre_mean(neur,ii) = mean(FR_pre);
    FR_pre_stdev(neur,ii) = std(FR_pre);
    
    % Difference in firing rate pre and post stimulus. Don't really know
    % what to do with this yet.
    FR_modulation = FR_post - FR_pre;
    FR_modulation_mean(neur,ii) = mean(FR_modulation);
    FR_modulation_stdev(neur,ii) = std(FR_modulation);
  end
end

% Difference in post stimulus firing rate before and after training divided
% by standard deviation. Ideally this will give some sort of measure of how
% significantly the firing rate for a given nueron changed because of the
% training pulses.
FR_pre_post_training_diff = zeros(num_neur,1);
for ii = 1:2
  stdev = max(FR_post_stdev(:,ii),FR_post_stdev(:,ii+3));
  FR_pre_post_training_diff(:,ii) = (FR_post_mean(:,ii+3) - FR_post_mean(:,ii))./stdev;
end

%% Plot 
for ii = 1:2
  figure();
  hold on
  x = 1:num_neur;
  y1 = FR_post_mean(:,ii); % Pre training
  y2 = FR_post_mean(:,ii+3); % Post training
  err1 = FR_post_stdev(:,ii);
  err2 = FR_post_stdev(:,ii+3);
  scatter(x,y1,'r','MarkerFaceColor','r'); % Plot pre training
  %errorbar(x,y1,err1,'-ro','MarkerSize',10,'MarkerEdgeColor','r','MarkerFaceColor','r');
  scatter(x,y2,'b','MarkerFaceColor','b'); % Plot post training
  %errorbar(x,y2,err2,'-bo','MarkerSize',10,'MarkerEdgeColor','b','MarkerFaceColor','b');
  xlabel('Neurons');
  title(['Average Post Stimulus Firing rate from all 100 stimulations on channel ',num2str(stim.sequence{ii}(2))]);
  legend('Pre training','Post training');
end