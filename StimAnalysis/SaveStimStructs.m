stim_file_dir = pwd;

stim_file_struct = LoadStimFile(stim_file_dir);
ESreal = stim_file_struct.ES(stim_file_struct.ES(:,2)>0,:);
stim = CreateStimStruct(ESreal,'ms');
savefile = fullfile(stim_file_dir,filesep,'stim.mat');
save(savefile,'stim');
