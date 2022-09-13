% Given an asdf (list of spike times for each neuron), a list of start
% times, and a list of end times, find all spikes that occur in each of the
% ranges for each neuron

% DEPENDENCIES
% isInRange.m
function asdf_in_range = ASDFInRange(asdf, start_times, end_times)

if min(size(start_times)) ~= 1 || min(size(end_times)) ~= 1
  error('start_times and end_times must be either row or column vectors');
end
if length(start_times) ~= length(end_times)
  disp('Error: start_times and end_times must be same length');
end

num_neur = length(asdf) - 2;
num_times = length(start_times);
asdf_in_range = cell(num_neur,num_times);

for neur = 1:num_neur
  spike_times = asdf{neur};
  for ii = 1:num_times
    asdf_in_range{neur,ii} = spike_times(isInRange(spike_times,start_times(ii),end_times(ii)));
  end
end