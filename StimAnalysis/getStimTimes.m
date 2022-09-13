%{
function [channels, order] = getStimChannels(ES)
  channels = unique(ES(:,2));
  order = cell(length(channels),1);
  for ii = 1:length(channels)
    order{ii} = ES(:,2) == channels(ii);
  end
end
%}

% Get start times for each stimulus and group them by unique
% channel/pattern

%{
function [stim_times, stim_indices] = getStimTimes(ES)
  stim_indices = cell(512,1);
  stim_times = cell(512,1);
  for ch = 1:512
    [row_index,~] = find(ES(:,2) == ch);
    stim_indices{ch} = row_index;
    stim_times{ch} = ES(row_index,1);
  end
end
%}


% PS - Pattern Sequence, equivalent of Event Sequence except gives times of
% patterns (a specific grouping of events) rather than times of each 
% individual event
function [pattern_times, PS] = getStimTimes(ES)
  pattern_times = {};
  PS = [];
  PS_index = 1;
  
  ii = 1; % Loop through every element in ES
  while ii <= size(ES,1)
    time_now = ES(ii,1);
    ch = ES(ii,2);
    
    if ch < 1
      ii = ii + 1;
      continue
    end
    
    % check if next pulse is simultaneous
    if ii<size(ES,1)
      time_next = ES(ii+1,1);
      if (time_now==time_next)
        ii = ii+1;
        ch = [ch,ES(ii,2)];
      end
    end
    
    % check if it's a new pattern; if so, add it to patterns(:,1)
    pat_index = false(1,size(pattern_times,1));
    for jj = 1:size(pattern_times,1)
      pat_index(jj) = isequal(pattern_times{jj,1}, ch);
    end
    pat_index = find(pat_index);
    if isempty(pat_index)
      pattern_times{end+1,1} = ch;
      pat_index = size(pattern_times,1);
      pattern_times{pat_index,2} = [];
    elseif length(pat_index)>1
      error('ERROR in getStimTimes.m, index should not be this large!');
    end
        
    % Add the time to patterns(:,2)
    pattern_times{pat_index,2} = [pattern_times{pat_index,2};ES(ii,1)];
    
    % Add the pattern event to Pattern Sequence Variable (PS)
    PS(PS_index,1) = ES(ii,1);
    PS(PS_index,2) = pat_index;
    PS_index = PS_index+1;
    
    %increment ii
    ii = ii+1;
  end
end