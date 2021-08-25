function stimStart=CommandStimStart()
H=[1 0 1 0]; %header
IA=[1,0,0,0,0,0];
OC=[0 1 0]; %operating code
NULL = zeros(1,12);
start=[H, IA, OC, NULL];
stimStart=zeros(1,100);
for i=1:length(start)
    stimStart(4*i-1)=start(i);
    stimStart(4*i-2)=start(i);
    stimStart(4*i-3)=start(i);
    stimStart(4*i)=start(i);
end
end