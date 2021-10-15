% function spike_times = SpikeDetect512(data_dir, varargin)
% The purpose of this function is to do a simple spike finding on the data
% in the given directory. It is meant for data from the 512 system.
% Inputs:
%   data_dir - directory where data00_00_.bin files are located
% Optional Inputs:
%   ('Theshold',threshold_alpha)
%         - how many sigma away from baseline is considered a spike?
% Outputs:
%   spike_times - 512x1 cell array with list of spike times found on each
%     electrode.


function spike_times = SpikeDetect512(data_dir, varargin)

threshold_alpha = 5;

for ii = 1:2:length(varargin)
  switch varargin{ii}
    case 'Threshold'
      threshold_alpha = varargin{ii+1};
    otherwise
      error(['Unknown input "',varargin{ii},'"']);
  end
end
     

% Check Input is formatted correctly
if (data_dir(end) ~= filesep)
  data_dir = fullfile(data_dir,filesep);
end

% Load Vision
LoadVision2;

% Constant Valsues
MAX_SAMPLES_PER_FILE = 20000*60*2; %2 min

% CREATE JAVA OBJECTS TO ACCESS VISION READ AND WRITE FUNCTIONS -----------
% ORIGINAL DATA OBJECT
% Open original data file for reading
data_obj = LoadVisionFiles(data_dir);
% Extract some useful info
header = data_obj.getHeader();
num_samples = header.getNumberOfSamples();
num_files = ceil(num_samples/MAX_SAMPLES_PER_FILE);
% Initialize
data = zeros(MAX_SAMPLES_PER_FILE, 513, 'int16');

% Determine Threshold
data = data_obj.getData(20150, 79950);
avg = mean(data(:,2:513),1);
sigma = std(double(data(:,2:513)),1);
threshold = transpose(avg - threshold_alpha * sigma);
clear data avg

%% Spike Finding
spike_times = cell(513,1);
% For each file
for ff = 1:num_files
  % READ ------------------------------------------------------------------
  start_sample = (ff-1)*MAX_SAMPLES_PER_FILE;
  if ff == num_files
    samples_in_file = num_samples - start_sample;
  else
    samples_in_file = MAX_SAMPLES_PER_FILE;
  end
  end_sample = start_sample + samples_in_file;
  data = data_obj.getData(start_sample, samples_in_file);
  % Data will be in a T x 513 int16 array (T = # time steps in file)
  % Sample rate of device is 20000 Hz, so each time step is 50 us.
  % First column corresponds to the grounding ring and is all 0.
  % Columns 2:513 correspond to electrodes 1:512
  
  
  % SPIKE DETECT-----------------------------------------------------------
  for ch_read = 1:512
    spikes = transpose(spikeDetect(data(:,ch_read+1),threshold(ch_read)));
    spike_times{ch_read} = [spike_times{ch_read},spikes];
    % Spike times will be in units of 50 us each (i.e. 1 ms = 20)
  end
  
end
data_obj.close();
clear data data_obj

spike_times{513} = num_samples;