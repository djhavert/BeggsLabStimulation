TimeWindow=5000; %250 ms, don't change

PathName='C:\Users\Daniel Havert\Documents\Beggs Lab\Stimulation\streaming_classes\';
FileName='devTesting\IntervalTest1_TTX';
%FileName='12-16-20\TTX_Pairs_Slice4';
if ~exist(fileparts([PathName,FileName]), 'dir')
  mkdir(fileparts([PathName,FileName]))
end
% Choose which PATTERN function you want to use
%[PL, PLI, ES]=P_SeqCh_FixAmp_FixFreq(PathName, FileName);
%[PL, PLI, ES]=P_SeqCh_MultiAmp_FixFreq(PathName, FileName);
%[PL, PLI, ES]=P_MultiSeqCh_FixAmp_FixFreq(PathName, FileName);
%[PL, PLI, ES]=P_GroupsSeqCh_FixAmp_FixFreq(PathName, FileName);
%[PL, PLI, ES]=P_RandCh_FixAmp_RandFreq(PathName, FileName);
%[PL, PLI, ES]=P_Tetanization(PathName, FileName);
[PL, PLI, ES]=P_TTX_Subtraction(PathName, FileName);

libraryPathname=struct('pulseLibraryPathname',PathName,'pulseLibraryIndexPathname', PathName,'eventLibraryFileNamePathname',PathName);
libraryFileName=struct('pulseLibraryfName',[FileName '.slf'],'pulseLibraryIndexVectorfName',[FileName '.sif'],'eventLibraryFileName',[FileName '.sef']);

dataStreamingPathname=PathName;
dataStreamingFileName=[FileName '.bin'];

tic
topFunction(TimeWindow,libraryPathname,dataStreamingPathname,libraryFileName,dataStreamingFileName);  
toc

disp(['Duration = ',num2str(ES(end,1)/20000),' seconds']);