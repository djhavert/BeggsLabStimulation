function hf = PSTHplot(psth_counts, psth_edges, varargin)

% psth_counts - counts for a single stimulation type

%hf = figure('visible','off');
hf = figure();
%psth_edges = psth_edges/20; %to get x-axis in ms instead of samples
binMax = max(psth_counts,[],'all');
if binMax == 0
  binMax = 0.01;
end
%binMax = ceil(binMax/10)*10;

%subplot(2,2,1)
histogram('BinEdges', psth_edges, 'BinCounts', psth_counts);
xlim([psth_edges(1),psth_edges(end)]);
ylim([0,binMax]);
%title(['Stimulation Site: ', num2str(stim_times{1,1})]);
xlabel('time (ms)');
%ylabel(['Ch ',num2str(ch),' response']);