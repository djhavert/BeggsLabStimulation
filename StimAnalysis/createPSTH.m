function hf = createPSTH(spktimes, PS, ch, varargin)

% Defaults
Nbins = 100;
%period = PS(2,1)-PS(1,1);

% User defined overrides
ii = 1;
while (ii<=length(varargin))
  switch varargin{ii}
    case 'NumBins'
      Nbins = varargin{ii+1};
      ii=ii+2;
    case 'Period'
      period = varargin{ii+1};
      ii=ii+2;
  end
end

% Miscellaneous values needed
[stimCh, stimChOrder] = getStimChannels(PS);

% Count Spikes
edges = 0:(period/Nbins):period;
counts = zeros(Nbins,length(stimCh));
for jj = 1:Nbins
  for ss = 1:size(stim_times,1)
    lower = stim_times{ss,2} + edges(jj);
    upper = stim_times{ss,2} + edges(jj+1) - 1;
    counts(jj,ss) = sum(isInRange(spktimes,lower,upper));
  end
end

% Plot
hf = figure();
edges = edges/20; %to get x-axis in ms instead of samples
binMax = max(counts,[],'all');
binMax = ceil(binMax/10)*10;

subplot(2,2,1)
histogram('BinEdges', edges, 'BinCounts', counts(:,1));
xlim([edges(1),edges(end)]);
ylim([0,binMax]);
title(['Stimulation Site: ', num2str(stimCh(1))]);
xlabel('time (ms)');
%ylabel(['Ch ',num2str(ch),' response']);

subplot(2,2,2)
histogram('BinEdges', edges, 'BinCounts', counts(:,2));
xlim([edges(1),edges(end)]);
ylim([0,binMax]);
title(['Stimulation Site: ', num2str(stimCh(2))]);
xlabel('time (ms)');
%ylabel(['Ch ',num2str(ch),' response']);

sgtitle(['Ch ',num2str(ch),' PSTH']);