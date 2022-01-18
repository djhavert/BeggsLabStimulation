% This function loads post stimulus raw voltage traces from a single
% channel for a given length of time after each stimulation pulse.
% datatruct - received from using LoadVisionFiles on Data Folder
% ESreal - Event Sequence for Stimulation, with all Fake Stims removed
% ch - Channel (1-512)
% period - length of time to save after each stimulation

function data = getPostStimRawSignal(datastruct, datastruct_ttx, ESreal, ch, period)
  data = zeros(period,size(ESreal,1),'int16');
  % Get Average Reading from TTX
  for ii=1:size(ESreal,1)
    Tstim = ESreal(ii,1);
    Channel = ESreal(ii,2);
    stimType = ESreal(ii,3);
    data(:,ii) = getData(datastruct_ttx, ch, Tstim, period);
  end
  ttx_average = int16(mean(data(:,ESreal(:,2)==ch),2));
  
  % 
  data = zeros(period,size(ESreal,1),'int16');
  for ii=1:size(ESreal,1)
    Tstim = ESreal(ii,1);
    Channel = ESreal(ii,2);
    stimType = ESreal(ii,3);
    data_nottx = getData(datastruct, ch, Tstim, period);
    %data_ttx = getData(datastruct_ttx, ch, Tstim, period);
    data(:,ii) = data_nottx - ttx_average;
  end
end
