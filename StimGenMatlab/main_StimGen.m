
% This code will take the parameters defined in the chosen pattern function
% and generate all necessary stimulation files.

% There will be 4 generated stim files in total, each with the same name
% but different extension. They are:
% 'FileName.slf'  (Pulse Library File)
% 'FileName.sif'  (Pulse Library Index File)
% 'FileName.sef'  (Event Sequence File)
% 'FileName.bin'  (Binary File)

%% CREATE STIM PATTERN FILES
% Define path and file names for the generated stim files
PathName = fullfile(pwd,'Binary Stim Files');
FileName = fullfile('9-24-2021','Slice1_TrainInterval_20msInterval_117_166');
filepath = fullfile(PathName,FileName);
%FileName = fullfile('12-16-20','TTX_Pairs_Slice4');
if ~exist(fileparts(filepath), 'dir')
  mkdir(fileparts(filepath))
end


% Choose which PATTERN function you want to use (uncomment)
% Only uncomment ONE function at a time. Leave the rest commented
% The PATTERN function will also create and save the .slf, .sif, and .sef
% files

% [PL, PLI, ES]=P_SeqCh_FixAmp_FixFreq(filepath);
%[PL, PLI, ES]=P_SeqCh_MultiAmp_FixFreq(filepath);
%[PL, PLI, ES]=P_MultiSeqCh_FixAmp_FixFreq(filepath);
%[PL, PLI, ES]=P_GroupsSeqCh_FixAmp_FixFreq(filepath);
%[PL, PLI, ES]=P_RandCh_FixAmp_RandFreq(filepath);
%[PL, PLI, ES]=P_Tetanization(filepath);
[PL, PLI, ES]=P_TrainInterval_MultiCh_FixInterval(filepath);
% [PL, PLI, ES]=P_Tetanization_SimCh(filepath);

%[PL, PLI, ES]=P_TTX_Subtraction(filepath);


% Display some useful information from the generate stim file.
disp(['Stimulation Duration = ',num2str(ES(end,1)/20000),' seconds']);

%% CREATE STIM BINARY FILE
% The rest of this code will generate the binary file from the three
% stimulation pattern files created above.
PathName = fullfile(PathName,filesep);
libraryPathname=struct('pulseLibraryPathname',PathName,'pulseLibraryIndexPathname', PathName,'eventLibraryFileNamePathname',PathName);
libraryFileName=struct('pulseLibraryfName',[FileName '.slf'],'pulseLibraryIndexVectorfName',[FileName '.sif'],'eventLibraryFileName',[FileName '.sef']);

dataStreamingPathname=PathName;
dataStreamingFileName=[FileName '.bin'];

TimeWindow=5000; %250 ms, don't change
topFunction(TimeWindow,libraryPathname,dataStreamingPathname,libraryFileName,dataStreamingFileName);
