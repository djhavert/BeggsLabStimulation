# BeggsLabStimulation
Code to Create Stimulation Files to Run on 512 Multielectrode Array

REQUIREMENTS
MATLAB with following Toolbox:
Communications Toolbox
Fixed Point Designer

'main.m' is starting point. Choose which stim pattern file you want to use and define pathname/filename for the stim files the code will generate.

All stimulation parameters are defined in Pattern files (look for P_\*.m). Each pattern file has certain features and the user can customize those features at the beginning of each P_ file. Features include stimulation amplitude, frequency, which electrodes to stimulate, etc. The pattern files define the 'Pulse Library' (PL), 'Pulse Library Index' (PLI), and 'Event Sequence' (ES) arrays.

The rest of the code will convert the PL, PLI, and ES files into a singular binary file. This binary file is what gets streamed into LabView to actually stimulate on the electrode array. This conversion to binary file occurs in 'topFunction.m'
