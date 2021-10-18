function stim = CreateStimStruct(ES,varargin)

b_time_in_ms = false; % by default function will return time in multiples 
                      % of the system's base time unit (50 us)
b_is_poisson = false;
ii = 1;
while (ii<=length(varargin))
  switch varargin{ii}
    case 'ms'
      b_time_in_ms = true;
      ii=ii+1;
    case 'Poisson'
      b_is_poisson = true;
      ii=ii+1;
  end
end

% CONTSTANTS
if b_is_poisson
  MAX_SEQUENCE_DURATION = 200; % (200 = 10 ms)
else
  MAX_SEQUENCE_DURATION = 5000; % (5,000 = 250 ms)
end

% Intitialize Return variables.
stim.sequence = cell(0);
stim.sequence_times = cell(0);

% Start Loop
ii = 1; % Which pulse we are currently looped onto
while ii <= size(ES,1)
  
  % Find current sequence
  times = [];
  jj = 1; % how many pulses in a sequence
  current_sequence = [];
  while ES(ii+jj-1,2) > 0
    times(jj) = ES(ii+jj-1,1); 
    current_sequence(jj,:) = [times(jj)-times(1),ES(ii+jj-1,2)];
    
    if ii + jj > size(ES,1)
      break
    end
    time_next = ES(ii+jj,1);
    if time_next - times(1) > MAX_SEQUENCE_DURATION
      break
    else
      jj = jj + 1;
      continue
    end
  end
  ii = ii + jj;
  
  % Add any new sequnces to sequnces list
  seq_index = [];
  for s = 1:size(stim.sequence,1)
    seq_index(s) = isequal(current_sequence, stim.sequence{s});
  end
  seq_index = find(seq_index);
  if isempty(seq_index) % then it's new, so add it to sequences
    stim.sequence{size(stim.sequence,1)+1,1} = current_sequence;
    seq_index = size(stim.sequence,1);
    stim.sequence_times{seq_index,1} = [];
  elseif length(seq_index)>1
    error('ERROR in getStimTimes.m, duplicate sequence in stim.sequence!');
  end
  
  % Add start time of sequence to list of times
  stim.sequence_times{seq_index,1} = [stim.sequence_times{seq_index,1}, times(1)];
  
  
end

if b_time_in_ms
  for n = 1:size(stim.sequence,1)
    stim.sequence{n}(:,1) = stim.sequence{n}(:,1)/20;
    stim.sequence_times{n} = stim.sequence_times{n}./20;
  end
end


end