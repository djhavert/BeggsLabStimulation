%{
[PL, PLI, ES] = P_SeqCh_FixAmp_FixFreq(saveLocation, nameFileLib, varargin)

Beggs Lab
Katy Hagen
September 2021

A P file (PATTERN file) produces the three necessary stimulatiion files for
a specific stimulation pattern.

This PATTERN file creates a stimulation with the following characteristics:
- Tetanization: Each channel will be rapidly stimulated at a specified
interval for a specified number of trains.
- IndCh (Independent Channels): Tetanization is performed for each channel
one at a time (ie. full tetanization protocol performed for one channel,
then the second, etc.)
- TrainInterval - The two channels will each fire a fixed number of times
to test network output prior to and following training. (eg. A A A A ... B
B B B ...) During training, channel A will fire, and then channel B will
fire after some delay (eg. A>B A>B ...). Any subsequent files will fire
after the delay. The number of times the testing and training files
are presented need not be the same. The total file, therefore, will consist
of:
     (eg. A A A ... B B B ... A>B A>B A>B ... A A A ... B B B).
- FixInterval (Fixed Training Interval) - The training interval between
each electrode is constant.
    (eg. A > (interval) > B > (interval) > C > ...)
- FixAmp (Fixed Amplitude) - The stimulation amplitude is fixed and does
not change throughout the pattern.

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
function [PL, PLI, ES] = P_Tetanization_IndCh_TrainInterval_FixInterval(filepath, varargin)
%% FILL IN THESE VALUES

%-------User Defined Variables-------%
Channels = [100,200];
          % Each channel will be stimulated [RepsPerCh] times for [Trains]
          % number of trains. It will repeat that pattern for the next
          % channel.

CurrentRange = -4; % see readme for how values here correspond to Amps.
                   % Common Values:
                   % CurrentRange = -3 : CurrentRangeInAmps = 1uA
                   % CurrentRange = -4 : CurrentRangeInAmps = 4uA
                   
AmplitudesDAC = 20; % MAX 42. The actual current amplitude of the largest
                    % peak in the pulse is (3*x/128)*CurrentRangeInAmps
                    
InterPulseDelay = 20 * 1000 * 5;  % Time between stimulation of one channel 
                             % or pair and the next.
                             % This is NOT the interval between A and B
                             % during training.
                             % Note: All times are given in number of
                             % samples. Since the sample rate is 20000 HZ,
                             % one time unit here is equivalent to 50 us.
                            
TetanicInterval = 20 * 1000 * (1/20); % Time between tetanic pulses within
                             % train (20 Hz in Jimbo et al, 1999)
                             
TrainingInterval = 20 * 100; %Interval between A, B, ... during training.
                             % (Tetanization using 10 20Hz pulses takes
                             % 0.05 s, so the training interval must be
                             % greater.)

RepsPerCh_tetanize = 10; % How many times the tetanic pulse will be repeated on
                 % each channel PER TRAIN
                 
RepsPerCh_test = 100; % How many times the the stim signal will be repeated
                 % on each channel during testing. (A A A ... B B B ...)
                 
RepsPerCh_train = 100; % How many times the stim signal will be repeated on
                 % two channels during training. (A>B A>B A>B ...)
                 
                 
                 
                 
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


%-------Dependent Variables-------%
% Find times of all the pulses.
% NumPulses = length(Channels) * Trains * RepsPerCh_tetanize; %total pulses
% TotalDuration = FirstPulseDelay + length(Channels) * Trains * InterPulseDelay;
% PulseTimes = zeros(1,NumPulses); %initialize
% PulseTimes(1) = FirstPulseDelay;
% pulsecount = 1; %initialize
% 
% for i=1:length(Channels)
%     for j=1:Trains
%         PulseTimes(pulsecount:(pulsecount+RepsPerCh_tetanize-1)) = (0:TetanicInterval:(TetanicInterval*RepsPerCh_tetanize-1)) + PulseTimes(pulsecount);
%         PulseTimes(pulsecount+RepsPerCh_tetanize) = PulseTimes(pulsecount) + InterPulseDelay;
%         pulsecount = pulsecount + RepsPerCh_tetanize;
%     end
% end
% PulseTimes(end) = []; %remove the last one; it's an extra

NumPulses_test = length(Channels) * RepsPerCh_test; %testing pulses (this number happens before and after training)
NumPulses_train = length(Channels) * RepsPerCh_train * RepsPerCh_tetanize; %total training pulses
NumPulses = 2*NumPulses_test + NumPulses_train; %total pulses
Time = FirstPulseDelay; %initialize
PulseTimes = zeros(1,NumPulses); %initialize
for i=1:NumPulses_test %first round of testing
    PulseTimes(i) = Time;
    Time = Time + InterPulseDelay;
end

for i=1:RepsPerCh_train %training
    for j=1:length(Channels)
        k=1; %initialize
        ind = find(PulseTimes==0,1);
        PulseTimes(ind) = Time;
        for k=2:RepsPerCh_tetanize
            PulseTimes(ind+k-1) = Time + (k-1)*TetanicInterval;
        end
        Time = PulseTimes(ind) + TrainingInterval;
    end
     Time = Time - TrainingInterval*length(Channels) + InterPulseDelay;
end

for i=1:NumPulses_test %second round of testing
    PulseTimes(i+NumPulses_test+NumPulses_train) = Time;
    Time = Time + InterPulseDelay;
end
TotalDuration = Time - InterPulseDelay;

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
% for jj = 1:length(Channels)
%   for ii = 1:(RepsPerCh_tetanize*Trains)
%     PulseCount = PulseCount + 1;
%     ES(PulseCount, 1) = PulseTimes(PulseCount-1);
%     ES(PulseCount, 2) = RecOffOnOthers * Channels(jj); 
%     ES(PulseCount, 3) = 1; % real pulse
%   end
% end
for jj = 1:length(Channels)
    for ii = 1:RepsPerCh_test
        PulseCount = PulseCount + 1;
        ES(PulseCount, 1) = PulseTimes(PulseCount-1);
        ES(PulseCount, 2) = RecOffOnOthers * Channels(jj);
        ES(PulseCount, 3) = 1; % real pulse
    end
end
for ii = 1:RepsPerCh_train
    for jj = 1:length(Channels)
        for kk = 1:RepsPerCh_tetanize
            PulseCount = PulseCount + 1;
            ES(PulseCount, 1) = PulseTimes(PulseCount-1);
            ES(PulseCount, 2) = RecOffOnOthers * Channels(jj);
            ES(PulseCount, 3) = 1; % real pulse
        end
    end
end
for jj = 1:length(Channels)
    for ii = 1:RepsPerCh_test
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
