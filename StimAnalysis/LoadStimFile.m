function stim_file_struct = LoadStimFile(stim_file_dir)

% Check Input is formatted correctly
if (stim_file_dir(end) ~= filesep)
  stim_file_dir = fullfile(stim_file_dir,filesep);
end

stim_file_struct.PL = readAndConvertPulseLibrary(stim_file_dir,dir([stim_file_dir,'*.slf']).name);
stim_file_struct.PLI = readAndConvertPulseLibraryIndex(stim_file_dir,dir([stim_file_dir,'*.sif']).name);
ES = readAndConvertEventSequence(stim_file_dir,dir([stim_file_dir,'*.sef']).name);
ES(:,1) = ES(:,1) + 20000; % This accounts for the 1 sec offset 'bug'
stim_file_struct.ES = ES;
% save just the stimulation events. Ignore commands and 'zero' pulses
stim_file_struct.ES_stim = ES(ES(:,2)>0,:);