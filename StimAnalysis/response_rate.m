%%
% Make sure working direction is where the 'data000' folder is


LoadVision2

data_dir = fullfile(pwd,'data000',filesep);
fig_dir = fullfile(pwd,'figs',filesep);
analysis_dir = fullfile(pwd,'Analysis',filesep);
neuron_file = [[data_dir,'data000.bin(5-50000)/'],'*.neurons']; % filepath
params_file = [[data_dir,'data000.bin(5-50000)/'],'*.params']; % filepath
nfile = LoadVisionFiles(neuron_file); % load *.neurons file
pfile = LoadVisionFiles(params_file); % load *.params file
asdf = load([analysis_dir,'asdf.mat']);
load([analysis_dir, 'stim.mat']);
numNeur = nfile.getNumberOfNeurons();
numStimPats = length(stim.sequence);

%%
%if exist([analysis_dir,'activated_neurs.mat'],'file')
%  load([analysis_dir,'activated_neurs.mat']);
%else
  % Background Firing rate (FR but excluding spikes within 400 ms after stim)
  stim_times_all = cell2mat(stim.times);
  T_post_stim = 2*stim.psth_edges(end)/20; % ms
  num_spikes_nostim = cellfun(@(x) sum(isInRange(x',stim_times_all,stim_times_all+T_post_stim*20)),asdf.asdf_raw(1:end-2));
  fr_nostim = num_spikes_nostim./(asdf.asdf_raw{end}(2) - length(stim_times_all)*T_post_stim)*1000;
  % firing rate(Hz) = #spikes / time(ms) * 1000 (ms/s)

  p_val = cell(numStimPats,1);
  sig_neurs = cell(numStimPats,1);
  for pat = 1:numStimPats
    partial = 5;
    T_post_stim = stim.psth_edges(partial+1)/20; % ms
    ps_num_spikes = reshape(sum(stim.psth_counts{pat}(:,1:partial,:),2),numNeur,length(stim.times{pat}));
    % post-stim firing rate(Hz) = #post-stim spikes / post-stim time (ms) * 1000 (ms/s)
    
    psfr = ps_num_spikes./T_post_stim*1000;
    psfr_mean = mean(psfr,2);
    psfr_err = std(psfr,0,2);

    % Global firing rate
    %num_spikes_global = cellfun(@sum, asdf.asdf_raw);
    %fr_global = num_spikes_global(1:end-2)./asdf.asdf_raw{end}(2)*1000;


    % Calculate p value, 
    alpha = 0.05;
    %z_acc = norminv(1-alpha);
    z_score = (psfr_mean-fr_nostim)./psfr_err;
    p_val{pat} = 1-normcdf(z_score);
    sig_neurs{pat} = find(p_val{pat}<alpha & ~isinf(z_score));
  end
%  save([analysis_dir,'activated_neurs.mat'],sig_neurs);
%end
%% Plot
figure()
hold on
% Norm
xmax = min(ceil(max(z_score)),4);
xnorm = 0:((xmax+0)/1000):xmax;
ynorm = normpdf(xnorm,0,1);
plot(xnorm,ynorm,'k');
% Fill Accepted region
x_acc = xnorm(xnorm>=z_acc);
y_acc = normpdf(x_acc,0,1);
fill([x_acc,fliplr(x_acc)],[zeros(size(x_acc)),fliplr(y_acc)],[230/255, 159/255, 0]);
% Lines for both accepted and not accepted
x_acc = z_score(z_score>=z_acc & z_score < xmax);
y_acc = normpdf(x_acc,0,1);
x_ref = z_score(z_score<z_acc);
y_ref = normpdf(x_ref,0,1);
stem(x_acc,y_acc,'Marker','none','Color',[213/255, 94/255, 0]);
stem(x_ref,y_ref,'Marker','none','Color',[86/255, 180/255, 233/255]);
% Labels
xlabel('Z-score between Post Stimulus Firing Rate and Resting Firing Rate');
title(['Post Stimulus and Resting Firing Rate Distribution Comparison, Pattern ',num2str(pat)]);
ylabel('Standard Normal PDF');
str = [num2str(length(sig_neurs{pat})),' out of ',num2str(numNeur),' neurons accepted'];
text(3,.25,str,'FontSize',14);
savefile = [fig_dir,'Firing Rate/Zscore_pat',num2str(pat)];
savefig(savefile);
%end

%% GET AND PLOT LOCATIONS OF ACTIVATED NEURONS
% Get Neuron Locations
%neur_el = GetNeuronEl(neuron_file);
numNeur = length(IDs);
neur_x=0; neur_y=0;
for i = 1:length(IDs)
	if pfile.hasParameter('EIx0') & pfile.hasParameter('EIy0')
		
			neur_x(i) = pfile.getDoubleCell(IDs(i), 'EIx0');
			neur_y(i) = pfile.getDoubleCell(IDs(i), 'EIy0');
		if (isnan(neur_x(i)) | isnan(neur_y(i)))
			neur_x(i) = location(i,1);
			neur_y(i) = location(i,2);
    end
  end
end

figure()
t = tiledlayout(3,5);
for pat = 1:15
h = nexttile;
hold on
PlotArray(512);
% All electrode locations
%x = ch_pos_x;
%y = ch_pos_y;
%plot(ch_pos_x,ch_pos_y,'LineStyle','none','Marker','o','Color','k');
% Electrodes that were stimulated
sequence = stim.sequence{pat};
ch = [];
x = []; y = [];
emapc = edu.ucsc.neurobiology.vision.electrodemap.Rectangular512ElectrodeMap();
for i = 1:size(sequence,1)
  ch = sequence(i,1);
  x(i) = emapc.getXPosition(ch-1);
  y(i) = emapc.getYPosition(ch-1);
end
plot(x, y, '*','MarkerSize', 3, 'Color', [0 0 1]);
%x = ch_pos_x([ch1,ch2]);
%y = ch_pos_y([ch1,ch2]);
%plot(x,y,'LineStyle','none','Marker','o','MarkerFaceColor','b');
% Electrodes with non significant neurons
x = neur_x(setdiff(1:numNeur,activated_neurs{pat}));
y = neur_y(setdiff(1:numNeur,activated_neurs{pat}));
plot(x,y,'LineStyle','none','Marker','o','MarkerEdgeColor','k');
% ELectrodes with significant neurons
x = neur_x(activated_neurs{pat});
y = neur_y(activated_neurs{pat});
plot(x,y,'LineStyle','none','Marker','o','MarkerEdgeColor','r');

title(['pattern ',num2str(pat),' (N = ',num2str(length(x)),')']);
end
title(t,'Locations of Significant Neurons in Red')
%% SPIKE COUNT VS STIM NUMBER
figure()
t = tiledlayout(3,5);
time_depth = 10/2;

for pat = 1:15
NumSpikes = reshape(sum(stim.psth_counts{pat}(:,:,:),[1 2]),100,1);

h = nexttile;
plot(1:100,NumSpikes)
title(['Pattern ',num2str(pat)]);
end

title(t,'Global Number of Spikes within 200 ms after stimulus');
xlabel(t,'Number of times Stimulated by Pattern');
ylabel(t,'Spike Count');

savefile = [fig_dir,'Firing Rate/SPIKECOUNTvsSTIMNUM_allpats'];
%savefig(savefile);
%% SPIKE COUNT VS Time
figure()
t = tiledlayout(3,5);
time_depth = 10/2;

for pat = 1:15
NumSpikes = reshape(sum(stim.psth_counts{pat}(:,:,:),[1 3]),100,1);

h = nexttile;
plot(1:2:200,NumSpikes)
title(['Pattern ',num2str(pat)]);
end

title(t,'Global Number of Spikes within 200 ms after stimulus');
xlabel(t,'Time (ms)');
ylabel(t,'Spike Count');

savefile = [fig_dir,'Firing Rate/SPIKECOUNTvsSTIMNUM_allpats'];
%savefig(savefile);

%% SPIKE COUNT OF 20 SAMPLE CHUNKS
figure()
t = tiledlayout(3,5);
for pat = 1:15

NumSpikes = zeros(20,5);
for ii = 1:5
NumSpikes(:,ii) = reshape(sum(stim.psth_counts{pat}(:,:,(ii-1)*20+1:ii*20),[1 2]),20,1);
end  
NumSpikes_mean = mean(NumSpikes,1);
NumSpikes_err = std(NumSpikes,0,1);

x = categorical({'1-20','21-40','41-60','61-80','81-100'});
x = reordercats(x,{'1-20','21-40','41-60','61-80','81-100'});
%h = subplot(3,5,pat);
h = nexttile;
hold on
bar(x,NumSpikes_mean);
set(h,'xticklabel',x);
title(['Pattern ',num2str(pat)]);

er = errorbar(x,NumSpikes_mean,NumSpikes_err);
er.Color = [0 0 0];
er.LineStyle = 'none';
hold off


end

title(t,'Global Number of Spikes within 10 ms after stimulus');
xlabel(t,'Number of times Stimulated');
ylabel(t,'Spike Count');

savefile = [fig_dir,'Firing Rate/SPIKECOUNTvsSTIMNUM_all'];
savefig(savefile);

%% GLOBAL SPIKE COUNT FOR EACH PATTERN
for pat=1:15

NumSpikes = reshape(sum(stim.psth_counts{pat},[1 2]),100,1);
NumSpikes_mean(pat) = mean(NumSpikes);
NumSpikes_err(pat) = std(NumSpikes);

end

figure()
hold on
bar(1:15,NumSpikes_mean);
xlabel('Pattern');
ylabel('Spike Count');
title('Number of Spikes within 200 ms after stimulus');
er = errorbar(1:15,NumSpikes_mean,NumSpikes_err);
er.Color = [0 0 0];
er.LineStyle = 'none';
hold off

savefile = [fig_dir,'Firing Rate/SPIKECOUNTvsPATTERN'];
savefig(savefile);