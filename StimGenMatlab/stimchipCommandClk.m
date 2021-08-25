function ClkCommand=stimchipCommandClk()
vect=ones(1000,1)*(2^25);
for i=1:250
    vect(4*i-3)=0;
    vect(4*i-2)=0;
end

ClkCommand=vect;
end