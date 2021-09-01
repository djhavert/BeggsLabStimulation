function [channels, order] = getStimChannels(ES)
  channels = unique(ES(:,2));
  order = cell(length(channels),1);
  for ii = 1:length(channels)
    order{ii} = ES(:,2) == channels(ii);
  end
end