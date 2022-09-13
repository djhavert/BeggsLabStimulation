% DEPENDENCIES
%1) CreateASDF.m
%2) LoadStimFile.m
%3) CreateStimStruct.m
%4) ASDFGetfrate.m
%5) PSTHcounts.m

% change Matlab current directory to the top of the data folder 
% (i.e. '...9-30-21/Slice1/TrainInterval'

% directory where Vision outputs are saved (where the .neurons file is)
data_dir = [pwd,'/data000/data000.bin(5-50000)'];
% directory where the four stimulation files are saved
stim_dir = pwd;

% Create (if not done so prior) and load the asdf.mat file
CreateASDF(data_dir);
load([data_dir '/asdf.mat']);
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
for ii = 1:length(stim.sequence)
  % For each neuron
  for neur = 1:num_neur
    % count number of spikes for each stimulation and time bin
    [counts_post,edges] = PSTHcounts(asdf_raw{neur}, stim.sequence_times{ii}, 'NumBins',bins,'Range',range,'Combine',0);
    % sum over all time bins. Gives total number of post stimulus spikes
    % for each stimulation
    counts_post = sum(counts_post,2); 
    % sum over all stimulations. Total mumber of post stimulus spikes for
    % all 100 stimulations
    counts_post_totals(neur,ii) = sum(counts_post);
    % Average post stimulus firing rate for each stimulation
    FR_post = counts_post./(range/20000);
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