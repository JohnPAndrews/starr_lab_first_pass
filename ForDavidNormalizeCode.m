%%  read 
fn = '/Users/roee/Starr_Lab_Folder/Data_Analysis/rcsanalysis/data/RCS_raw_data.csv';
ds = datastore(fn,'TreatAsMissing','NA');
%% read 2 
qqfigure;plot(dt.channel_1);

%% read csv Roee 
load /Users/roee/Starr_Lab_Folder/Data_Analysis/rcsanalysis/data/RawDataTD_2hour.mat
dtimes = outdatcomplete.derivedTimes;
rcs5hz = outdatcomplete.key1;
[b, a ]  =butter(3, [50 70] / (1e3/2),'stop');
% filter data
rcs5hzFilt  = filtfilt(b,a,rcs5hz);

rcsSecsRaw=  (dtimes-dtimes(1));
rcsSecsRaw = milliseconds(rcsSecsRaw); 
rcstimepoint = 12960;



dbsDelsys = dataArray{2};
% releveant time 10-20 seconds in the start; 
second5hz = seconds(time);
secDelsys = milliseconds(second5hz);
figure; plot(secDelsys,dbsDelsys);


secDelsys
dbsDelsys
dbstimepoint = 17579;

% plot 
figure;
hsb1 = subplot(2,1,1);
plot(secDelsys-dbstimepoint,dbsDelsys)
title('delsys');
hsb2 = subplot(2,1,2); 
title('rcs');
plot(rcsSecsRaw-rcstimepoint,rcs5hzFilt)
linkaxes([hsb1 hsb2],'x');

filenamsave = '/Users/roee/Starr_Lab_Folder/Data_Analysis/rcsanalysis/data/datToPlot.mat';

delSecs = secDelsys-dbstimepoint;
delDBS  = dbsDelsys; 
rcsSecs = rcsSecsRaw-rcstimepoint; 
rcsDBS  = rcs5hzFilt; 
save(filenamsave,'delSecs','delDBS','rcsSecs','rcsDBS');

hfig = figure; 
hold on;
hplt1 = plot(delSecs,mapminmax(delDBS,0, 0.5));
hplt1.Color =[0.8 0 0 0.7]; 
hplt1.LineWidth = 2; 
hplt2 = plot(rcsSecs,mapminmax(rcsDBS,0.5, 1));
hplt2.Color =[0 0 0.8 0.7]; 
hplt2.LineWidth = 2; 
xlim([-950 7.150e6]);
ylim([-1 3]); 
legend([hplt1 hplt2],{'Delsys','RC+S'});
xlabel('Microseconds'); 
set(gca,'FontSize',16); 
set(gca, 'YTick', []);

% breakxaxis(gca,[3e2 7.149e6])
title('Delsys - RC+S sync 2 hours'); 
hfig.PaperPositionMode = 'manual'; 
hfig.PaperOrientation  = 'landscape';
hfig.PaperUnits        = 'inches';
hfig.PaperSize         = [15 10]; 
hfig.PaperPosition     = [0 0 15 10]; 


figdir = '/Users/roee/Starr_Lab_Folder/Data_Analysis/rcsanalysis/data/';
fnmsv ='ro1fig-bnc1.jpeg';
print(hfig,fullfile(figdir,fnmsv),'-djpeg');

fnmsv ='ro1fig-bnc2.pdf';
print(hfig,fullfile(figdir,fnmsv),'-dpdf');



%% requires File Exchange function 
%% set plotting paramaters 
plotheight = 8.5;
plotwidth  = 16;


%% save data 
dbstime = 17579;


%% open delsys 
filename = '/Users/roee/Starr_Lab_Folder/Data_Analysis/rcsanalysis/data/delsys_5hz.csv';
ds = datastore(filename);
ds.TreatAsMissing = 'NA';
tt = tall(ds);
datTab = tt(100:1e5,:); 
gather(datTab);

save('/Users/roee/Starr_Lab_Folder/Data_Analysis/rcsanalysis/data/delsys_5hz.mat','datTab');


%{
fid = fopen(filename, 'rb');
%# Get file size.
fseek(fid, 0, 'eof');
fileSize = ftell(fid);
frewind(fid);
%# Read the whole file.
data = fread(fid, fileSize, 'uint8');
%# Count number of line-feeds and increase by one.
endRow = sum(data == 10) + 1;
fclose(fid);
%}

delimiter = ',';
startRow = 2;
endRow = 13846354;

%Read columns of data as text:
% For more information, see the TEXTSCAN documentation.
formatSpec = '%f%f%{yyyy-MM-dd HH:mm:ss.SSSSSSSSS}D';

% Open the text file.
fileID = fopen(filename,'r');

% Read columns of data according to the format.
% This call is based on the structure of the file used to generate this
% code. If an error occurs for a different file, try regenerating the code
% from the Import Tool.
dataArray = textscan(fileID, formatSpec,...
    endRow-startRow+1, 'Delimiter', delimiter, ...
    'TextType', 'string', 'HeaderLines', startRow-1,...
    'ReturnOnError', false, 'EndOfLine', '\r\n');
time=dataArray{1};
dbsDelsys = dataArray{2};
% releveant time 10-20 seconds in the start; 
second5hz = seconds(time);
secDelsys = milliseconds(second5hz);
figure; plot(secDelsys,dbsDelsys);
save('/Users/roee/Starr_Lab_Folder/Data_Analysis/rcsanalysis/data/delsys_5hz.mat','datTab');


%% Close the text file.
fclose(fileID);
%% filter 
% creat filter
[b, a ]  =butter(3, [50 70] / (1e3/2),'stop');
% filter data
dataorig  = filtfilt(b,a,dt.channel_1);
% creat filter 5 hz 
[b, a ]  =butter(3, [4 6] / (1e3/2),'bandpass');
% filter data
data  = filtfilt(b,a,dt.channel_1);


data = data - mean(data); 
data(data>0.4) = 0;
data(data<-0.2) = 0;
% figure;plot(data);
dataabs = abs(data);
idx = dataabs>0.04; 
datplot = data;
datplot(~idx) = 0;
idxuse = idx | datplot>0.15; 
figure;plot(datplot);


%% plot channel 0 
figure;
[b, a ]  =butter(3, [50 70] / (1e3/2),'stop');
dataorig  = filtfilt(b,a,dt.channel_0);
datdc = dataorig- mean(dataorig);
datcln = datdc; 
datcln(datcln>2) = 0; 
datcln(datcln<-2) = 0; 
figure;plot(datcln);

%% write table 
tout = table([datcln,datplot]);
fn = '/Users/roee/Starr_Lab_Folder/Data_Analysis/rcsanalysis/data/fordavid.csv';
writetable(tout,fn);

