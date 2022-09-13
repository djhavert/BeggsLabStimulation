function PS = GetPatternSeqFromStimStructArray(stim_struct)
%
% stim_struct : struct array returned from 'CreateStimStructArray()'
%
% PS : Pattern Sequence, same format as event sequence variable but for
%      multi-event sequences of activity.
%



times = [stim_struct.times];
p_idx = [];
for p = 1:length(stim_struct)
  p_idx = [p_idx,p*ones(size(stim_struct(p).times))];
end
[PS(:,1),I] = sort(times,'ascend');
PS(:,2) = p_idx(I);