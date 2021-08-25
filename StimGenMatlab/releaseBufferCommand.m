function releaseBufferCommand(bufferCommand,fidData)

    [rowBufferCommand,colBufferCommand]=size(bufferCommand);
    data=reshape(bufferCommand',rowBufferCommand*colBufferCommand,1);
    fwrite(fidData, data, 'uint32');

end