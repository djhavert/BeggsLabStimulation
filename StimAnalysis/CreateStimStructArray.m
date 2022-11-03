function stim = CreateStimStructArray(ES,varargin)

MAX_SEQUENCE_DURATION = 5000; % (5,000 = 250 ms)
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
    case 'SequenceDuration'
      MAX_SEQUENCE_DURATION = varargin{ii+1};
      ii=ii+2;
  end
end

% CONSTANTS
if b_is_poisson
  MAX_SEQUENCE_DURATION = 200; % (200 = 10 ms)
end

% Intitialize Return variable.
stim = struct('seq',{},'times',{});

% Start Loop
ii = 1; % Which pulse we are currently looped onto
while ii <= size(ES,1)
  
  % Find current sequence
  times = [];
  jj = 1; % how many pulses in a sequence
  current_seq = struct('timing',[],'chs',[]);
  while ES(ii+jj-1,2) > 0
    times(jj) = ES(ii+jj-1,1); 
    current_seq.timing = [current_seq.timing, times(jj)-times(1)];
    current_seq.chs = [current_seq.chs, ES(ii+jj-1,2)];
    
    if ii + jj > size(ES,1)
      break
    end
    time_next = ES(ii+jj,1);
    if time_next - times(jj) >= MAX_SEQUENCE_DURATION
      break
    else
      jj = jj + 1;
      continue
    end
  end
  ii = ii + jj;
  
  % Add any new sequnces to sequnces list
  seq_index = [];
  for s = 1:length(stim)
    seq_index(s) = isequal(current_seq, [stim(s).seq]);
  end
  seq_index = find(seq_index);
  if isempty(seq_index) % then it's new, so add it to sequences
    seq_index = length(stim) + 1;
    stim(seq_index).seq.timing = current_seq.timing;
    stim(seq_index).seq.chs = current_seq.chs;
    stim(seq_index).times = [];
  elseif length(seq_index)>1
    error('ERROR in getStimTimes.m, duplicate sequence in stim.sequence!');
  end
  
  % Add start time of sequence to list of times
  stim(seq_index).times = [stim(seq_index).times, times(1)];
  
  
end

if b_time_in_ms
  for n = 1:length(stim)
    stim(n).seq.timing = stim(n).seq.timing/20;
    stim(n).times = stim(n).times/20;
  end
end


end