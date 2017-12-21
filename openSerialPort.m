function sp = openSerialPort()
sp = [];
instrreset
if ismac
    % check to see if cable is connnected 
    serialInfo = instrhwinfo('serial');
    avportst = serialInfo.AvailableSerialPorts;
    sercheck  = cellfun(@(x) any(strfind(x,'/dev/cu.usbserial-DN17M98C')),...
        avportst);
    if sum(sercheck) == 0 
        error('trigger cable not connected');
    else
        sp = serial(avportst{sercheck},....
            'BaudRate',115200,...
            'DataBits',8,...
            'StopBits',1);
        fopen(sp);
    end
end
return; 

pause(3);


for i = 1:7
    fwrite(sp,uint8(2^i))
    pause(0.2);
end
pause(3);

for i = 1:40
    fwrite(sp,uint8(i))
    pause(0.2);
end

    fwrite(sp,uint8(1));
    fwrite(sp,uint8(2));
    pause(1);

% try sending 8 bit binary number with fwrite 
for i = 1:8
fprintf(sp,dec2bin(1,8));
pause(0.1);
end

pause(1);

% try sending 8 bit binary number with fwrite but flip pins 
for i = 1:8
fprintf(sp,fliplr(dec2bin(1,8)));
pause(0.1);
end

%  '/Volumes/ROEE/Testdata.bdf'
 
 
 addpath(genpath('/Users/roee/Starr_Lab_Folder/Data_Analysis/First_Pass_Data_Analysis/code/toolboxes/eeglab14_1_0b'));
 start = tic;
 [pn,fn,ext] = fileparts(bdffnms{b});
 EEG = pop_biosig('/Volumes/ROEE/Testdata2.bdf');
 
 type = [EEG.event.type];
 laten = [EEG.event.latency];
 for t = 1:length(type)-1
     fprintf('%0.3d %2.3f %2.3f\n',type(t),laten(t)/2048,laten(t+1)/2048 - laten(t)/2048)
 end
 
 labs = {EEG.chanlocs.labels};
 idxchan = find(cellfun(@(x) any(strfind(x,'EXG')),labs)==1) ;
 eegraw = [];
 for c = 1:length(idxchan)
     eegraw.(labs{idxchan(c)}) = EEG.data(idxchan(c),:);
 end
 idxchan = find(cellfun(@(x) any(strfind(x,'Erg')),labs)==1) ;
 for c = 1:length(idxchan)
     eegraw.(labs{idxchan(c)}) = EEG.data(idxchan(c),:);
 end
 eegraw.srate = EEG.srate;
 save(fullfile(pn,['EEGRAW_' fn '.mat']),'eegraw');
 fprintf('saved file %d out of %d in %f\n',b,length(bdffnms),toc(start));
 restoredefaultpath;
 rmpath(genpath('/Users/roee/Starr_Lab_Folder/Data_Analysis/First_Pass_Data_Analysis/code/toolboxes/eeglab14_1_0b'));

end