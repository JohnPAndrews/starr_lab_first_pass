function ployRyderCL_quickDirty()
rootdir = '/Users/roee/Starr_Lab_Folder/Data_Analysis/Raw_Data/BR_reorganized/brpd_03/v14_dlbst/Session_2017_06_27_Tuesday'; 

protfn = 'protocol-details-^^^^.json'; 
protocol  = loadjson(fullfile(rootdir,protfn),'SimplifyCell',1);

fdirs = findFilesBVQX(rootdir, 's*',struct('depth',1,'dirs',1));
for i = 1:length(fdirs)
    [~,~,~,H,mm,ss] = datevec(datetime(protocol(i).time));
    datetime([H mm ss],'Format','HH:mm:ss');
    dat(i).time = datetime(datevec(datetime(protocol(i).time)),'Format','HH:mm:ss');
    dat(i).timeDec = H+mm/60; 
    fnmf = findFilesBVQX(fdirs{i},'*.txt');
    dat(i).data = importdata(fnmf{1}); 
end

concatDatPower = []; 
concatDatStim = []; 
for i = 1:size(dat,2)
    concatDatStim = [concatDatStim; dat(i).data(:,2)];
    concatDatPower = [concatDatPower ;dat(i).data(:,4)];
    hold on; 
end

hfig = figure; 
for i = 1:size(dat,2)
    % stim 
    subplot(1,2,1); 
    datplotstim = dat(i).data(:,2);
    datplotstimnoout = deleteoutliers(datplotstim,0.1);
    timesuse = linspace(dat(i).timeDec,dat(i).timeDec+1/12, length(datplotstimnoout));
    plot(timesuse, datplotstimnoout); 
    hold on;
    % power 
    subplot(1,2,2); 
    datplotpower = dat(i).data(:,4);
    datplotpowernoout = deleteoutliers(datplotpower,0.1);
    timesuse = linspace(dat(i).timeDec,dat(i).timeDec+1/12, length(datplotpowernoout));
    plot(timesuse, datplotpowernoout); 
    hold on; 
end
set(gcf,'PaperSize',[50 50]); 
xtickformat('HH:mm')
end
