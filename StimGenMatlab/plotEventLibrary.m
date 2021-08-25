clc
clear all
pos=5
T=0.000005

channel=1
saveLocation='C:\Users\Admin\Desktop\Beata\PracaMagisterska_Projekt\fwdrestreaming\testy';

nameFile='\grotTest.bin';
%brak rejestracji na nieparzytych kanalach
fid=fopen([saveLocation nameFile],'r','l');
MyCreatedData1=fread(fid,'uint32')';
fclose(fid);
a=MyCreatedData1(2300:3000)

% header1=MyCreatedData1(1:3);
% data1=MyCreatedData1(4:header1(2)*7+3);
% reshapeData1=reshape(data1,[7,header1(2)])';
% 
% data1Col12=reshapeData1(:,1:2);
% 
% % time1=(data1Col12(:,1)-10000000)/1000;
% % channel1=(rem(data1Col12(:,1)-10000000,1000)-42)/6+1;
% time1=(data1Col12(:,1))/1000;
% channel1=(rem(data1Col12(:,1),1000)-42)/6+1;
% indexTime1=find(channel1(:,1)==channel);
% data1Col2channel=data1Col12(indexTime1,2)
% 
% 
% bi_data1Col2channel=de2bi(data1Col2channel,32)
% a1=bi_data1Col2channel(:,21:24)
% ostatni1=reshapeData1(pos,:);
% binOstatni1=de2bi(ostatni1(2:7),32)';
% realTimeBinOstatni1=binOstatni1(21:24,1)';
% 
% 
% 
% % nameFile='\RandomPattern_Overlap_Test_2_rec0.bin';
% nameFile='\RandomPattern_Overlap_Test_11_20.bin';
% %rejestracjia na wszystkich kaalach kanalach
% fid=fopen([saveLocation nameFile],'r','l');
% MyCreatedData2=fread(fid,'uint32')';
% fclose(fid);
% 
% header2=MyCreatedData1(1:3);
% data2=MyCreatedData2(4:header2(2)*7+3);
% reshapeData2=reshape(data2,[7,header2(2)])';
% 
% data2Col12=reshapeData2(:,1:2)
% 
% % time2=(data2Col12(:,1)-10000000)/1000;
% % channel2=(rem(data2Col12(:,1)-10000000,1000)-42)/6+1;
% time2=(data2Col12(:,1))/1000;
% channel2=(rem(data2Col12(:,1),1000)-42)/6+1;
% indexTime2=find(channel2(:,1)==channel);
% data2Col2channel=data2Col12(indexTime2,2)
% 
% 
% bi_data2Col2channel=de2bi(data2Col2channel,32)
% a2=bi_data2Col2channel(:,21:24)
% 
% 
% ostatni2=reshapeData2(pos,:);
% 
% binOstatni2=de2bi(ostatni2(2:7),32)';
% realTimeBinOstatni2=binOstatni2(21:24,1)';
% 
% plot(a1(:,3)-a2(:,3))