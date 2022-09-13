function [ttx] = GetTtxTraces(TraceRange, ttx_stimfile_dir, ttx_datafile_dir)

% CONSTANTS
MaxSamplesPerFile = 20000*60*2; %2 min


% Get Stim File Information
stim_f = LoadStimFile(ttx_stimfile_dir);
stim_start_idx = find(stim_f.ES(:,2)>0,1,'first');
stim_end_idx = find(stim_f.ES(:,2)>0,1,'last');

% MANUAL FIX FOR BUG THAT CAUSED EVERYTHING TO SHIFT BY 250 MS
bad_shifts = find(diff(stim_f.ES(stim_start_idx:stim_end_idx))==5000);
bad_shift_idx = stim_start_idx + bad_shifts + 1;
for ii = bad_shift_idx
  t = stim_f.ES(ii,1);
  disp(['TTX Got Shifted at t = ',num2str(t/20000), ' s. Shifting back.'])
  stim_f.ES(t:end,1) = stim_f.ES(t:end,1) - 5000;
end
%ES(921:end,1) = ES(921:end,1) - 5000;

% Find uninterupted zeros
EsZerosUninterupted = GetUninteruptedZeros(stim_f.ES);
stim_f.ES_stim = stim_f.ES(stim_f.ES(:,2)>0,:);
%[stim_times, PS] = getStimTimes(ESreal);
stim = CreateStimStructArray(stim_f.ES_stim,'SequenceDuration',TraceRange);
PS = GetPatternSeqFromStimStructArray(stim);


% TTX DATA OBJECT
% Open ttx data file for reading
ttx_data_obj = LoadVisionFiles(ttx_datafile_dir);
% Extract some useful info
ttx_header = ttx_data_obj.getHeader();
num_samples = ttx_header.getNumberOfSamples();
num_files = ceil(num_samples/MaxSamplesPerFile);

%ttx_data=ttx_data_obj.getData(stim_times{1,1},0,num_samples);
%plot(ttx_data);
% Get Background Values for each Channel
ttx_data = [];
for ii = 1:length(EsZerosUninterupted)
  start_sample = EsZerosUninterupted{ii}(1);
  end_sample = EsZerosUninterupted{ii}(end);
  if end_sample > num_samples
    continue;
  end
  samples_in_file = end_sample - start_sample;
  ttx_data = [ttx_data; ttx_data_obj.getData(start_sample, samples_in_file)];
end
Background = mean(ttx_data(:,2:513),1);
disp(['Background evaluated from ',num2str(size(ttx_data,1)/20000),' seconds of data']);
clear ttx_data;

% Initialize
ttx_data = zeros(MaxSamplesPerFile, 513, 'int16');
%ttx_traces = cell(size(stim_times,1),1);
ttx = stim;
for s = 1:length(ttx)
  %ttx_traces{s}=zeros(TraceRange,512);
  ttx(s).trace = zeros(TraceRange,512);
end
index = 1;
overlap = [];
for ff = 1:num_files
  % READ (2 min at a time)
  start_sample = (ff-1)*MaxSamplesPerFile;
  if ff == num_files
    samples_in_file = num_samples - start_sample;
  else
    samples_in_file = MaxSamplesPerFile;
  end
  end_sample = start_sample + samples_in_file;
  ttx_data = ttx_data_obj.getData(start_sample, samples_in_file);
  
  % Check if overlap from previous subfile. If so, deal with it
  if ~isempty(overlap)
    overlap = double(ttx_data(1:size(overlap,1), 2:513));
    trace = [trace; overlap];
    ttx(s).trace = ttx(s).trace + trace;
    index = index+1;
    overlap = [];
  end
  
  while (index <= size(PS,1) && PS(index,1) <= end_sample)
    stim_time = PS(index,1);
    stim_range = stim_time:stim_time+TraceRange-1;
    s = PS(index,2);
    %amplitude = ESreal(index,3);
    
    % Save Traces
    if (stim_range(end) <= end_sample)
      trace = double(ttx_data(stim_range-start_sample, 2:513));
      %ttx_traces{s} = ttx_traces{s} + trace; %just add together
      ttx(s).trace = ttx(s).trace + trace;
      index = index+1;
    else % deal with potential overlap with next file
      trace = double(ttx_data((stim_time:end_sample)-start_sample, 2:513));
      overlap = zeros(stim_range(end) - end_sample, 512);
      break
    end
  end
end




%for s = 1:size(stim_times,1) %finish average by dividing trace by number of stims
%  ttx_traces{s} = (ttx_traces{s}./length(stim_times{s,2}))-Background;
%end
for s = 1:length(stim) %finish average by dividing trace by number of stims
  ttx(s).trace = int16((ttx(s).trace./length(stim(s).times))-Background);
end

%Patterns = cell(size(stim_times,1),1);
%for s = 1:size(stim_times,1)
%  Patterns{s} = stim_times{s,1};
%end



ttx_data_obj.close();
