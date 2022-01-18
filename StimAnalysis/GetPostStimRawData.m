% This function loads post stimulus raw voltage traces from a single
% channel for a given length of time after each stimulation pulse.
% data_struct - received from using LoadVisionFiles on Data Folder
% stim_struct - 
% PatStim - Pattern ID (which pattern to load post stim data for)
% ChRead - Which Channel (1-512) to read post stim activity from
% Range - length of time to load after each stimulation

function PostStimRawData = GetPostStimRawData(data_struct, stim_struct, PatStim, ChRead, Range)
  ESreal = stim_struct.ES(stim_struct.ES(:,2)>0,:);
  stim_times = getStimTimes(ESreal);
  PostStimRawData = zeros(Range,length(stim_times{PatStim,2}),'int16');
  for ii=1:size(PostStimRawData,2)
    stim_time = stim_times{PatStim,2}(ii);
    PostStimRawData(:,ii) = data_struct.getData(ChRead, stim_time-1, Range);
  end
end
