%{
[PL, PLI, ES] = P_MultiSeqCh_FixAmp_FixFreq(filepath, varargin)

Beggs Lab
Danny Havert
May 2020

A P file (PATTERN file) produces the three necessary stimulatiion files for
a specific stimulation pattern.

This PATTERN file creates a stimulation with the following characteristics:
- MultiSeqCh (Sequential Channel) - The order in which the channels are
stimulated is sequential and cyclical and multiple channels are stimulated 
simultaneously. As an example, if three pairs of channels (doublets) are 
given ((1,11), (2,12), (3,13)), written in MATLAB like...
( 1,  2,  3;
 11, 12, 13 )
then the order in which the channels are stimulated is 
((1,11) (2,12) (3,13) (1,11) (2,12) (3,13) (1,11) (2,12) (3,13) ...) 
- FixAmp (Fixed Amplitude) - The stimulation amplitude is fixed and does
not change throughout the pattern.
- FixFreq (Fixed Frequency) - The stimulation frequency is fixed and does
not changed throughout the pattern

View Readme for description of three types of return files
PL - Pulse Library File - '.slf' suffix
PLI - Pulse Library Index File - '.sif' suffix
ES - Event Sequence File - '.sef' suffix
SaveLocation - Directory location to save each of the three files
nameFileLib - File Name for each of the three saved files
varargin - Optional Input of string 'Test' which marks the file as a _TEST
  file. This type of file does not disconnect the amplifiers during
  stimulation. It is purely for testing and should only be run when the
  chamber is dry. 
  NEVER RUN A _TEST FILE ON A WET CHAMBER

Hardware samples at 20,000 Hz, so each time bin is 50us long.
This means a value of 20 time bins is equivalent to 1ms

The computer talks to the electrode array in intervals of 250ms.
%}
function [PL, PLI, ES] = P_MultiSeqCh_FixAmp_FixFreq(filepath, varargin)
%% FILL IN THESE VALUES

%-------User Defined Variables-------%
%Channels = [129, 138, 148, 157, 167, 176];
Channels = [5, 10; 
            105, 110;
            205, 210;
            305, 310];
          % Each row represents a set of channels that can be
          % stimulated simultaneously (depending on if BinaryCounting is
          % enabled).
          % These sets will be presented in the order provided
          % Each set will be stimulated sequentially with the same time
          % between each stimulation

BinaryCounting = true; % Determines if each set of channels should be 
                       % broken up into 2^n smaller subsets of all possible
                       % combinations of firing. Example: A set of 3 has
                       % 2^3=8 possible combinations of firing those three
                       % channels (000 001 010 011 100 101 110 111).
                       % If FALSE, then it will only use (111) config
                     
          
CurrentRange = -4; % see readme for how values here correspond to Amps.
                   % Common Values:
                   % CurrentRange = -3 : CurrentRangeInAmps = 1uA
                   % CurrentRange = -4 : CurrentRangeInAmps = 4uA
                   
AmplitudesDAC = 20; % MAX 42. The actual current amplitude of the largest
                    % peak in the pulse is (3*x/128)*CurrentRangeInAmps

InterPulseDelay = 20 * 1000 * 2; % Time between stimulation of one channel 
                             % and the next.
                             % Note: All times are given in number of
                             % samples. Since the sample rate is 20000 HZ,
                             % one time unit here is equivalent to 50 us.
                             
GroupPulseDelay = 20 * 30; % Small delay between stimulating each CH in
                              % a grouping.

RepsPerSet = 100; % How many times the the stim pulse will be repeated for 
                  % each set of channels

OrderMatters = true; 
          % Meant to be used in combination with nonzero 'GroupPulseDelay'
          % As a simple example, if two electrodes are to be fired in a set
          % (11) then which electrode goes first? There are n! permutations
          % (01)->(10) and (10)->(01) in this simple example.          
          
IncludeSimultaneous = true;
          % Whether to include a grouping where channels are stimulated at
          % the same time in addition to the delayed pulses
          % ONLY WORKS WITH PAIRS OF ELECTRODES
          %   >generalization on my to-do list -DH
if GroupPulseDelay == 0
  OrderMatters = false;
end
if GroupPulseDelay==0 || size(Channels,2)~=2
  IncludeSimultaneous = false;
end
                 
%% THE FOLLOWING CODE CREATES ALL THREE FILES (PL, PLI, ES)              
%-------Constants: DO NOT CHANGE-------%
TimeBinWindow = 20 * 250; % Time between each message from computer
CommandPulseDelay = 5; % Delay before commands (i.e. setting current range)
                       % are given to Stim Chip.
FirstPulseDelay = 20 * 1000 * 40; % Delay before the first pulse

            
if contains(lower(filepath),'test') % if test is in file name
  RecOffOnStim = 0;
  disp('TEST FILE');
elseif strcmpi(varargin,'test') % if a test file
  RecOffOnStim = 0;
  disp('TEST FILE');
  filepath = [filepath,'_TEST'];
else
  RecOffOnStim = 1;
end         % Determine whether channel being stimulated will record
            % data during the length of the pulse.
            % 1 for recording=OFF(use if liquid will be in chamber)
            % 0 for recording=ON (use if chamber will be dry, for testing)
            
         
             
RecOffOnOthers = +1; % Determines whether all of the other channels will 
             % record data while a channel is stimulated. This value
             % changes the sign in the 2nd column of Event Sequence
             % +1 for recording=OFF. (other channels disconnected)
             % -1 for recording=ON (other channels connected)
PulseShape = [2 -3 1]; % triphasic shape. Probably don't change this                
Duration = 2; % Duration of each phase. In general duration of each phase 
              % may be different, but typically we keep pulses at 100 us 
              % per phase (Duration = 2)

if BinaryCounting
  BinaryCounts = dec2bin(0:1:2^size(Channels,2)-1) - '0';
elseif GroupPulseDelay == 0
  BinaryCounts = ones(1,size(Channels,2));
else
  BinaryCounts = 1:size(Channels,2);
end
             
if OrderMatters
  temp = BinaryCounts;
  BinaryCounts = [];
  Perms = perms(1:size(temp,2)); 
  for ii = 1:size(temp,1)
    for jj = 1:size(Perms,1)
      % Get the combination of channels
      temp2 = Perms(jj,:).*temp(ii,:);
      % Check to see if it is a valid combination. If so, add it
      if ~ismember(1,diff(ismember(1:size(Perms,2),temp2)))
        BinaryCounts = [BinaryCounts; temp2];
      end
    end
  end
  BinaryCounts = unique(BinaryCounts, 'rows');
  
  if IncludeSimultaneous && size(Channels,2) == 2
      BinaryCounts = [BinaryCounts; 1 1];
  end
end

%-------Dependent Variables-------%
% Find times of all the pulses.
NumPulses = size(BinaryCounts,1) * size(Channels,1) * RepsPerSet;
TotalDuration = (NumPulses-1) * InterPulseDelay;
PulseTimes = FirstPulseDelay + (0:InterPulseDelay:TotalDuration);

% Find Bins with no pulses given. We need to fill those empty bins with
% zero amplitude pulses to prevent the stim software from giving a real
% pulse in the empty bin.
BinEdges = 0:TimeBinWindow:(TotalDuration + 20000);
[BinCounts,~] = histcounts(PulseTimes, BinEdges);
EmptyBins = find(BinCounts == 0);
ZeroAmpPulseTimes = (EmptyBins - 1) * TimeBinWindow + CommandPulseDelay;

%% 1. Generate the Pulse Library File and the Pulse Library Index File.
PL = [];
PLI = [];
for i=1:length(AmplitudesDAC)    % for each pulse amplitude...
  PLI = [PLI, size(PL,1)+1]; % PLI (Pulse Library Index)
  
  % PRE-PHASE %
  % Disconnect the stimulating channel from recording and charge the DAC
  % It is better to charge the DAC value for the first pulse phase in the
  % pre-phase,
  DAC7b = AmplitudesDAC(i) * PulseShape(1);
  if abs(DAC7b) > 127 % 7 bits means limited to 128 values (0-127)
    error('The requested value of 7-bit DAC is out of range');
  end
  % Define the state of the stimchip - disconnect the channels; 
  % the structure is: [0 0 0 0 Connect Record 0 0 polarity DAC7b] 
  % see documentation for clarification on what each bit does
  state = [0 0 0 0 0 RecOffOnStim 0 0 0 de2bi(abs(DAC7b),7,'left-msb')];
  PL = [PL; state];

  % MAIN-PHASE %
  for phase = 1:length(PulseShape)  % for each phase of the pulse...
    DAC7b = AmplitudesDAC(i) * PulseShape(phase);
    if abs(DAC7b)>127
      error('The requested value of 7-bit DAC is out of range');
    end
    % The 8th bit of the DAC is the polarity (0=pos, 1=neg)
    if DAC7b > 0
      polarity=0;
    else
      polarity=1;
    end
    % ...set the state for duration of pulse segment 
    for j=1:Duration
      state=[0 0 0 0 1 RecOffOnStim 0 0 polarity de2bi(abs(DAC7b),7,'left-msb')];
      PL=[PL; state];
    end
  end

  % POST-PHASE
  % keep the stimulating channel disconnected for one frame; if one 
  % records during the pulse, this has no effect
  state=[0 0 0 0 0 RecOffOnStim 0 0 0 de2bi(abs(DAC7b),7,'left-msb')];
  PL=[PL; state];
end

% Create a NULL state (giving zero current) at end of PL and pli
PLI = [PLI, size(PL,1)+1];
state = [0 0 0 0 1 RecOffOnStim 0 0 0 de2bi(0,7,'left-msb')];
PL = [PL; state];

% convert to decimal before saving the file
for ii=1:size(PL,1)
    PL_dec(ii) = typecast(uint16(bi2de(PL(ii,:))),'int16'); 
end
             
% Save both files
fid = fopen([filepath '.slf'], 'w', 'l');
fwrite(fid, PL_dec, 'int16');
fclose(fid);

fid = fopen([filepath '.sif'], 'w', 'l');
fwrite(fid, PLI, 'int32');
fclose(fid);

%% 2. Generate the Event Sequence File

% Event Sequence Structure:
%ES(i,1) = Time (frame number of event)
%ES(i,2) = Channel #
%ES(i,3) = PulseID (positive -> selected from pulse library)
%                  (negative -> changes current range)
%
% Count how many indices are used per repition of a full set of electrodes
temp = 0;
for ii = 1:size(BinaryCounting,1)
  if sum(BinaryCounting(ii,:))==0
    temp = temp + 1;
  else
    temp = temp + sum(BinaryCounting(ii,:)>0);
  end
end
% Initialize Event Sequence array
ES=zeros(1 + temp*size(Channels,1)*RepsPerSet + length(ZeroAmpPulseTimes), 3);
%{
if BinaryCounting
  ES=zeros(1 + size(Channels,2)/2*length(PulseTimes) + length(ZeroAmpPulseTimes), 3);
else
  ES=zeros(1 + size(Channels,2)*length(PulseTimes) + length(ZeroAmpPulseTimes), 3);
end
%}
% a command - define current range in all the channels (see documentation)
ES(1,:)=[CommandPulseDelay 0 CurrentRange]; 

% Create Event Sequence
PulseCount = 0;
EsIndex = 1;
% Real Pulses
for ii = 1:size(Channels,1) %for each group...
  %for jj = 1:RepsPerSet  %for each repition of the group...
    % Choose order in which binary combos are given
    BinaryCountOrder = 1:size(BinaryCounts,1);  %same order every time
    %BinaryCountOrder = randperm(size(BinaryCounts,2)); %random order
  for kk = 1:size(BinaryCounts,1) %for each binary combo in the set...
    for jj = 1:RepsPerSet
      PulseCount = PulseCount + 1;
      if sum(BinaryCounts(kk,:)) == 0 %if they are all zero
          EsIndex = EsIndex + 1;
          ES(EsIndex, 1) = PulseTimes(PulseCount);
          ES(EsIndex, 2) = -1;
          ES(EsIndex, 3) = 2; %fake pulse
      else
        %count = 0;
        for ll = 1:size(Channels,2) %for each set in the group...
          count = BinaryCounts(BinaryCountOrder(kk),ll);
          if count %if channel  is nonzero
            EsIndex = EsIndex + 1;
            ES(EsIndex, 1) = PulseTimes(PulseCount) + (count-1)*GroupPulseDelay; %
            ES(EsIndex, 2) = RecOffOnOthers * Channels(ii,ll); 
            ES(EsIndex, 3) = 1; %real pulse
          end
        end  
      end
    end
  end
end
% Zero Amplitude Pulses
for ii = 1:length(ZeroAmpPulseTimes)
  EsIndex = EsIndex + 1;
  ES(EsIndex, 1) = ZeroAmpPulseTimes(ii);
  ES(EsIndex, 2) = -1; % channel doesn't really matter
  ES(EsIndex, 3) = 2; % zero amp pulse
end

% Event Sequence needs to be in order of increasing time
[~,SortByTimeOrder] = sort(ES(:,1));
ES = ES(SortByTimeOrder,:);

% Save File
fid = fopen([filepath '.sef'], 'w', 'l');
fwrite(fid, ES, 'int32');
fclose(fid);
