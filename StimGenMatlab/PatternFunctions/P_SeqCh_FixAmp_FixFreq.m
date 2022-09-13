%{
[PL, PLI, ES] = P_SeqCh_FixAmp_FixFreq(filepath, varargin)

Beggs Lab
Danny Havert
May 2020

A P file (PATTERN file) produces the three necessary stimulatiion files for
a specific stimulation pattern.

This PATTERN file creates a stimulation with the following characteristics:
- SeqCh (Sequential Channel) - The order in which the channels are
stimulated is sequential and cyclical. As an example, if three channels are 
given (1, 2, 3), then the order in which the channels are stimulated is 
(1 2 3 1 2 3 1 2 3 ...) until the pattern ends
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
function [PL, PLI, ES] = P_SeqCh_FixAmp_FixFreq(filepath, varargin)
%% FILL IN THESE VALUES

%-------User Defined Variables-------%
Channels = [1:64:512];
          % Each channel will be stimulated sequentailly (in the order 
          % given) with the same time between each stimulation.

CurrentRange = -4; % see readme for how values here correspond to Amps.
                   % Common Values:
                   % CurrentRange = -3 : CurrentRangeInAmps = 1uA
                   % CurrentRange = -4 : CurrentRangeInAmps = 4uA
                   
AmplitudesDAC = 20; % MAX 42. The actual current amplitude of the largest
                    % peak in the pulse is (3*x/128)*CurrentRangeInAmps

InterPulseDelay = 20 * 250 * 1; % Time between stimulation of one channel 
                             % and the next.
                             % Note: All times are given in number of
                             % samples. Since the sample rate is 20000 HZ,
                             % one time unit here is equivalent to 50 us.

RepsPerCh = 10; % How many times the the stim pulse will be repeated on 
                 % each channel.

                 
                 
                 
                 
%% THE FOLLOWING CODE CREATES ALL THREE FILES (PL, PLI, ES)              
%-------Constants: DO NOT CHANGE-------%
TimeBinWindow = 20 * 250; % Time between each message from computer
CommandPulseDelay = 5; % Delay before commands (i.e. setting current range)
                       % are given to Stim Chip.
FirstPulseDelay = 100; % Delay before the first pulse

            
if (nargin > 2 && varargin{1} == 'Test')
  RecOffOnStim = 0;
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


%-------Dependent Variables-------%
% Find times of all the pulses.
NumPulses = length(Channels) * RepsPerCh;
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
  % PLI (Pulse Library Index) %
  PLI = [PLI, size(PL,1)+1];
  
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

ES=zeros(1 + length(PulseTimes) + length(ZeroAmpPulseTimes), 3); 
% a command - define current range in all the channels (see documentation)
ES(1,:)=[CommandPulseDelay 0 CurrentRange]; 

% Create Event Sequence
PulseCount = 1;
for ii = 1:RepsPerCh
  for jj = 1:length(Channels)
    PulseCount = PulseCount + 1;
    ES(PulseCount, 1) = PulseTimes(PulseCount-1);
    ES(PulseCount, 2) = RecOffOnOthers * Channels(jj); 
    ES(PulseCount, 3) = 1; % real pulse
  end
end

for ii = 1:length(ZeroAmpPulseTimes)
  PulseCount = PulseCount + 1;
  ES(PulseCount, 1) = ZeroAmpPulseTimes(ii);
  ES(PulseCount, 2) = -1; % channel doesn't really matter
  ES(PulseCount, 3) = 2; % zero amp pulse
end

% Event Sequence needs to be in order of increasing time
[~,SortByTimeOrder] = sort(ES(:,1));
ES = ES(SortByTimeOrder,:);

% Save File
fid = fopen([filepath '.sef'], 'w', 'l');
fwrite(fid, ES, 'int32');
fclose(fid);
