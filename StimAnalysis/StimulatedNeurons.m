% Find which neurons have higher than chance activity in the range 1-10 ms
% after a stimulation pulse
% Uses a Fisher Test to determine whether spike count is significant or not

function ids = StimulatedNeurons(asdf, stim_times, varargin)

% DEFAULTS
range = [1 10]; %ms
alpha = 0.05; %Confidence Interval
small_range = 10;
big_range = 100; %ms

% HANDLE VARIABLE USER ARGUMENTS

% Info from input data
num_stim = length(stim_times);
num_neur = length(asdf) - 2;
duration = asdf{end}(2);

% ANALYSIS
%
% Get a bunch of random times that are more than 100 ms after any 
% stimulations and more than 10 ms before any stimulations
rand_nonstim_times = zeros(1000,1);
for n = 1:1000
  while 1
    t = randi(duration - big_range);
    if (~isInRange(t,stim_times-small_range,stim_times+big_range))
      rand_nonstim_times(n) = t;
      break;
    end
  end
end
%
% For each neuron find number of spikes in the range specificed after 
% each of the random non-stimulation times
asdf_in_range_nonstim = ASDFInRange(asdf, rand_nonstim_times + range(1), rand_nonstim_times + range(2));
num_in_range_nonstim = cellfun(@length, asdf_in_range_nonstim);
%
% For each neuron find number of spikes in the range specificed after 
% each of the stimulation times
asdf_in_range_stim = ASDFInRange(asdf, stim_times + range(1), stim_times + range(2));
num_in_range_stim = cellfun(@length, asdf_in_range_stim);
%%
ids = [];
for neur = 1:num_neur
  if neur == 16
    disp('stuff');
  end
  stim_events = length(find(num_in_range_stim(neur,:)));
  stim_nonevents = length(stim_times) - stim_events;
  nonstim_events = length(find(num_in_range_nonstim(neur,:)));
  nonstim_nonevents = length(rand_nonstim_times) - nonstim_events;
  x = [stim_events, nonstim_events; stim_nonevents, nonstim_nonevents];
  [h,~,~] = fishertest(x,'Alpha',alpha);
  if h
    ids = [ids;neur];
  end
end