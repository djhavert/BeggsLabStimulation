% NOTE: IN ORDER FOR THIS CODE TO WORK YOU MUST CHANGE YOUR SETTINGS IN
% MATLAB TO GIVE JAVA MORE HEAP MEMORY. TO DO THIS:
% CLICK ON PREFERENCES UNDER THE HOME TAB
% UNDER GENERAL -> JAVA HEAP MEMORY, INCREASE TO 4 GB. THEN RESTART MATLAB
% 2 GB should theoretically work, but I only tested on 4 GB.

% VALUES SET BY USER ------------------------------------------------------
orig_dir = [pwd, '/04_TrainInterval/'];
orig_data_dir = [orig_dir, 'data000/'];
stim_file_dir = orig_dir;

ttx_dir = [pwd, '/06_TTX/'];
ttx_stimfile_dir = ttx_dir;
ttx_datafile_dir = [ttx_dir,'data000/'];

new_data_dir = [pwd, '/04_TrainInterval_PostTTX/data000/'];


% CONSTANTS ---------------------------------------------------------------
MaxSamplesPerFile = 20000*60*2; %2 min
TraceRange = 20*20; % 20 ms

% Load Vision
LoadVision2;
%% GET STIM_FILE PROPERTIES ------------------------------------------------
stim_file_struct = LoadStimFile(stim_file_dir);
ESreal = stim_file_struct.ES(stim_file_struct.ES(:,2)>0,:);
[stim_times,PS] = getStimTimes(stim_file_struct.ES(find(stim_file_struct.ES(:,2)>0),:));

%% GET TTX TRACES ----------------------------------------------------------
[ttx_traces,Patterns] = GetTtxTraces(TraceRange, ttx_stimfile_dir, ttx_datafile_dir);
ttx_traces = cellfun(@(x) int16(x), ttx_traces, 'UniformOutput', false);

% Find indices of ttx Patterns that correspond to stim patterns in current
% file
stim2ttx = zeros(size(stim_times,1),1);
for ii = 1:length(stim2ttx)
  for jj = 1:length(Patterns)
    if isequal(stim_times{ii,1},Patterns{jj,1})
      stim2ttx(ii) = jj;
    end
  end
end

%% CREATE JAVA OBJECTS TO ACCESS VISION READ AND WRITE FUNCTIONS -----------
% ORIGINAL DATA OBJECT
% Open original data file for reading
orig_data_obj = LoadVisionFiles(orig_data_dir);
% Extract some useful info
orig_header = orig_data_obj.getHeader();
num_samples = orig_header.getNumberOfSamples();
num_files = ceil(num_samples/MaxSamplesPerFile);
% Initialize
orig_data = zeros(MaxSamplesPerFile, 513, 'int16');

% NEW DATA OBJECT
% Create and open new file for writing
if ~exist(new_data_dir, 'dir')
  mkdir(new_data_dir);
end
% Create the first subfile with header
new_data_obj = edu.ucsc.neurobiology.vision.io.ModifyRawDataFile(new_data_dir, orig_header);
% Create the rest of the subfiles. Each subfile is 1.8 GB
for ff = 1:(num_files-1)
  new_data_obj.addFile();
end


%% READ ORIGINAL DATA, SUBTRACT TTX TRACES, AND WRITE TO NEW FILE ----------
index = 1;
overlap = [];
tic;
for ff = 1:num_files
  % READ ------------------------------------------------------------------
  start_sample = (ff-1)*MaxSamplesPerFile;
  if ff == num_files
    samples_in_file = num_samples - start_sample;
  else
    samples_in_file = MaxSamplesPerFile;
  end
  end_sample = start_sample + samples_in_file;
  orig_data = orig_data_obj.getData(start_sample, samples_in_file);
  % data is alyways in a 2400000 x 513 int16 array. First column is all 0.
  
  
  % MODIFY ----------------------------------------------------------------
  new_data = orig_data;
  
  % deal with overlap from previous file if needed
  while ~isempty(overlap)
    pat = overlap(end).pattern;
    count = overlap(end).count;
    stim_range = 1:count;
    new_data(stim_range,2:513) = orig_data(stim_range,2:513) - ttx_traces{pat}(end-count+1:end,:);
%    LOG(overlap(end).index).indx_end = stim_range(end);
    overlap(end) = [];
  end
  
  % loop through every stimulation that occurs within current file
  while (index <= size(PS,1) && PS(index,1) <= end_sample)
    stim_time = PS(index,1);
%    LOG(index).stim_time = stim_time;
    stim_range = (stim_time:stim_time+TraceRange-1)-start_sample;
%    LOG(index).indx_start = stim_range(1);
    pat = PS(index,2);
    pat = stim2ttx(pat);
%    LOG(index).stim_ch = Patterns{pat};
    %amplitude = ESreal(index,3);
%    LOG(index).orig_start = orig_data(stim_range(1),2:513);
    % subtract ttx traces from raw data
    if (stim_range(end) <= samples_in_file)
      new_data(stim_range,2:513) = orig_data(stim_range,2:513) - ttx_traces{pat};
      
      
%      LOG(index).indx_end = stim_range(end);
%      LOG(index).new_start = new_data(stim_range(1),2:513);
      index = index+1;
    else % if dealing with overlapping data with next file
      overlap(end+1).index = index;
      overlap(end).pattern = pat;
      overlap(end).count = stim_range(end)-samples_in_file;
      stim_range = stim_range(1):samples_in_file;
      new_data(stim_range,2:513) = orig_data(stim_range,2:513) - ttx_traces{pat}(1:length(stim_range),:);
%      LOG(index).new_start = new_data(stim_range(1),2:513);
      index = index + 1;
    end
  end
  
  % WRITE -----------------------------------------------------------------
  new_data_obj.appendDataToFile(ff-1,new_data);
end
toc;

new_data_obj.close();
clear new_data_obj;
rewrite_data_obj = LoadVisionFiles(new_data_dir);