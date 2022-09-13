function PlotTTXTraces(ttx, ch, range)
%
% ttx : single entry from ttx struct array outputted from
% TTX_Subtraction2Int16_func.m
%
% ch : channel to plot stim responses and corresponding ttx traces and
% subtraction results
%
%

MAX_TRACES_TO_DISPLAY = 10;

TraceRange = size(ttx.trace,1);
if range > TraceRange
  disp("Value assigned to 'range' too large. Using maximum allowable instead.");
else
  TraceRange = range;
end
x = 1:TraceRange;
X = x/20;

numstim = length(ttx.data_orig);
if numstim <= MAX_TRACES_TO_DISPLAY % select all
  subset = 1:numstim;
else % random sampling
  subset = randsample(numstim,MAX_TRACES_TO_DISPLAY);
end

chs = ttx.seq.chs;
if length(chs) > 1
  ch_str = 'Channels';
else
  ch_str = 'Channel';
end
for c = chs
  ch_str = [ch_str,' ',num2str(c)];
end

f = figure('Position', get(0, 'ScreenSize'));
t = tiledlayout(3,1);

% PRE TTX-SUBTRACTION POST STIM TRACES
ax(1) = nexttile;
hold on
for p = subset
  plot(X,ttx.data_orig{p}(x,ch));
end
ylabel(ax(1),'Pre TTX-Sub');

% POST TTX-SUBTRACTION POST STIM TRACES
ax(2) = nexttile;
hold on
for p = subset
  plot(X,ttx.data_new{p}(x,ch));
end
ylabel(ax(2),'Post TTX-Sub');

% TTX TRACES
ax(3) = nexttile;
plot(X,ttx.trace(x,ch));
ylabel(ax(3),'TTX Trace');

% Finish Plot
linkaxes([ax(1) ax(2)]);
title(t,['TTX Subtraction on Electrode ',num2str(ch),' from Stimulation on ',ch_str]);
xlabel(t,'Time After Stimulation (ms)');

