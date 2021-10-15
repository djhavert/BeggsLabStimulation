orig_dir = [pwd, '/02_Stim_StaticPairWith30msDelay/'];
orig_data_dir = [orig_dir, 'data000/'];
stim_file_dir = orig_dir;

ttx_dir = [pwd, '/TTX/'];
ttx_stimfile_dir = ttx_dir;
ttx_datafile_dir = [ttx_dir,'data000/'];

new_data_dir = [pwd, '/02_Stim_StaticPairWith30msDelay_PostTTX/data000/'];

LoadVision2
TraceRange=200;
orig_data_obj = LoadVisionFiles(orig_data_dir);
rewrite_data_obj = LoadVisionFiles(new_data_dir);
stim_file_struct = LoadStimFile(stim_file_dir);
ESreal = stim_file_struct.ES(stim_file_struct.ES(:,2)>0,:);
[stim_times,PS] = getStimTimes(stim_file_struct.ES(find(stim_file_struct.ES(:,2)>0),:));

[ttx_traces,Patterns] = GetTtxTraces(TraceRange, ttx_stimfile_dir, ttx_datafile_dir);
ttx_traces = cellfun(@(x) int16(x), ttx_traces, 'UniformOutput', false);

stim2ttx = zeros(size(stim_times,1),1);
for ii = 1:length(stim2ttx)
  for jj = 1:length(Patterns)
    if isequal(stim_times{ii,1},Patterns{jj,1})
      stim2ttx(ii) = jj;
    end
  end
end
%%
pat_stim=2;
ch_read=166;


x=0:0.05:(TraceRange-1)*0.05;
PostStimData = GetPostStimRawData(orig_data_obj, stim_file_struct, pat_stim, ch_read, TraceRange);
PostStimData_PostTTX = GetPostStimRawData(rewrite_data_obj, stim_file_struct, pat_stim, ch_read, TraceRange);
figure(1);
subplot(3,1,1); 
plot(x, PostStimData); ylabel('Raw Data'); 
ylimits = get(gca,'YLim');
subplot(3,1,3); 
plot(x, PostStimData_PostTTX); 
%ylim(ylimits);
ylabel('After TTX Subtraction'); xlabel('ms');
subplot(3,1,2); 
plot(x, ttx_traces{stim2ttx(pat_stim)}(:,ch_read)); ylabel('TTX Trace');