function stimStop=CommandStop()
H=[1 0 1 0]; %header
OC=[0 1 1]; %operating code
IA=[1,0,0,0,0,0];
NULL = zeros(1,12);
stop=[H, IA, OC, NULL];
stimStop=zeros(1,100);
for i=1:length(stop)
    stimStop(4*i-1)=stop(i);
    stimStop(4*i-2)=stop(i);
    stimStop(4*i-3)=stop(i);
    stimStop(4*i)=stop(i);
end
end