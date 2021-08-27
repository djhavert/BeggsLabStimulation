function clk=clkSignal(saveLocationClkSignal,saveFile)

[fid,errmsg]=fopen(fullfile(saveLocationClkSignal,[saveFile '.bin']),'r','l');
if fid<1
  error([errmsg ' File: ' saveFile])
end
clk=fread(fid,'uint32');
fclose(fid);

end

