function spkTimes = spikeDetect(A,Th)

% Find eligible spikes in single electrode and return time
% NOTE: This will return bin number at which potential spikes occur.
%       Make sure to convert bin number to actual time using sample rate
%
% spkTimes - bin numbers when spikes occur
% A - raw voltage trace of single electrode
% Th - Threshold value
%
% Original Auther:
% R.V. Williams-Garcia 3/5/16
%
% Modified by:
% Danny Havert 1/10/20
%

%% First step is to find subthreshold segments, i.e. when 
% Find subthreshold times:
%[subCh,subTimes] = find(A < Th);
subTimes = find(A < Th);

if ~isempty(subTimes)
  % Find times between each subthreshold tick
  timeDiffs = diff(subTimes);
  timeDiffs = [timeDiffs; subTimes(end)];

  % Find subthreshold segment endpoints
  segEnds = find(timeDiffs ~= 1);
  segEnds = [0; segEnds];

  % Segment Durations
  segDurs = diff(segEnds);

  % Potential Spikes fall between 0.3-3 ms width
  spkPot = find(segDurs >= 6 & segDurs <= 60);

  %% Create asdf (
  spkTimes = zeros(length(spkPot)-1,1);
  for ii = 1:length(spkTimes)
    kk = spkPot(ii);

    % Find times of potential spike segment
    segTimes = subTimes(segEnds(kk)+1:segEnds(kk+1));

    % Find values of potential spike segment
    segVals = A(segTimes);

    % find peak,set as time of spike
    spkPeakTime = segTimes(segVals == min(segVals));
    if length(spkPeakTime) ~= 1
      spkPeakTime = round(mean(spkPeakTime));
    end
    spkTimes(ii) = spkPeakTime;
    
  end
else
  spkTimes = [];
end