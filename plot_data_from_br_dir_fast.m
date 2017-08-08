function plot_data_from_br_dir_fast()
dirf = uigetdir();

if exist(fullfile(dirf,'dataquicksave.mat'),'file')
    load(fullfile(dirf,'dataquicksave.mat'));
else
    ff = findFilesBVQX(dirf,'*MR*.txt');
    cnt = 1;
    dnld = 0;  % so first download incerment properly 
    for f = 1:length(ff)
        start = tic; 
        [pn, fn, ext ] = fileparts(ff{f});
        if any(strfind(ff{f},'raw')) % if its a raw file, get xml data from non raw xml
            xmlfnm = [ff{f}(1:end-4) '.xml'];
        else
            xmlfnm = [ff{f} '.xml'];
        end
        xmlstruc = xml2struct(xmlfnm);
        if isfield(xmlstruc,'RecordingItem')
            xmlstrucparsed = parseXMLstruc(xmlstruc);
        else
            xmlstrucparsed = parseXMLstruc2(xmlstruc);
        end
        xmlstrucparsed = xmlstrucparsed.RecordingItem;
        [Y, M, D, H, MN, S] = datevec(xmlstrucparsed.RecordingDuration,'HH:MM:SS');
        datevecraw = cellfun(@(x) str2num(x),regexp(fn,'[0-9]+','match'));
        datevecuse = datevecraw(2:end-1);
        recDurSec = H*3600+MN*60+S;
        srraw = regexp(xmlstrucparsed.SenseChannelConfig.TDSampleRate,'[0-9+]','match');
        sr = str2num([srraw{1},srraw{2},srraw{3}]);
        
        if  datevecraw(end) == 0 ; 
            dnld = dnld+1; 
        end
        data = importdata(ff{f});
        datout(cnt).sessionum = f;
        datout(cnt).download  = dnld; 
        datout(cnt).time      = datetime(datevecuse);
        datout(cnt).duration  = sprintf('%0.2d:%0.2d',MN, S);
        datout(cnt).sr        = sr;
        datout(cnt).ecog      = data(:,3);
        datout(cnt).ecog_elec = sprintf('+%s-%s',...
            xmlstrucparsed.SenseChannelConfig.Channel3.PlusInput,...
            xmlstrucparsed.SenseChannelConfig.Channel3.MinusInput);
        datout(cnt).lfp       = data(:,1);
        datout(cnt).lfp_elec  = sprintf('+%s-%s',...
            xmlstrucparsed.SenseChannelConfig.Channel1.PlusInput,...
            xmlstrucparsed.SenseChannelConfig.Channel1.MinusInput);
        datout(cnt).ismontage = strcmp(xmlstrucparsed.RecordingType,'Montage');
        cnt = cnt +1;
        fprintf('saved file %d out of %d in %f\n',f,length(ff),toc(start)); 
    end
    datTab = struct2table(datout);
    save(fullfile(dirf,'dataquicksave.mat'),'datTab');
end

 
figdir = fullfile(dirf,'figures');
mkdir(figdir); 
writetable(datTab(:,[1:5 7 9 10 ]),fullfile(figdir,'tabledat.csv'))

return; 
areas = {'ecog','lfp'};
fprintf('\n\n'); 
for s = 1:size(datTab,1)
    start = tic;
    for a = 1:length(areas)
        tmp   = datTab.(areas{a}){s}; 
        tmpt  = preproc_trim_data(tmp,5000,datTab.sr(s));
        params.sr = datTab.sr(s);
        params.lowcutoff = 1;  
        tmpth = preproc_dc_offset_high_pass(tmpt,params);
        preproc.(areas{a}) = tmpth; 
    end
    plotpsd(preproc.ecog,preproc.lfp,datTab(s,:),figdir,s)
    fprintf('plotted file %d out of %d in %f\n',s,size(datTab,1),toc(start)); 
%     plotSpectrogram(preproc.ecog,preproc.lfp,datTab(s,:))
end

end

function plotpsd(ecog,lfp,metadata,figdir,idx)
hfig = figure;
params.plottype = 'pwelch';
params.sr = metadata.sr;
params.noisefloor = params.sr/2;
%% plot lfp
subplot(3,2,1)
hold on;
[~,hplot] = plot_data_freq_domain(lfp',params,[]);
hax1 = gca;
hplot.LineWidth = 2;
legend(metadata.lfp_elec{1})
title('LFP');
%% plot ecog
subplot(3,2,2)
hold on;
[~,hplot] = plot_data_freq_domain(ecog',params,[]);
hplot.LineWidth = 2;
legend(metadata.ecog_elec{1})
title('ECOG');
hax2 = gca;
linkaxes([hax1 hax2]);

params.noisefloor = 100;

%% plot lfp
subplot(3,2,3)
hold on;
[~,hplot] = plot_data_freq_domain(lfp',params,[]);
hax1 = gca;
hplot.LineWidth = 2;
legend(metadata.lfp_elec{1})
title('LFP');
%% plot ecog
subplot(3,2,4)
hold on;
[~,hplot] = plot_data_freq_domain(ecog',params,[]);
hplot.LineWidth = 2;
legend(metadata.ecog_elec{1})
title('ECOG');
hax2 = gca;
linkaxes([hax1 hax2]);

subplot(3,2,5);
plot(lfp);
title('lfp raw'); 
subplot(3,2,6);
plot(ecog);
title('ecog raw'); 
ttlfig = sprintf('s-%d time %s dur - %d sec sr %d',...
    metadata.sessionum,...
    metadata.time,...
    metadata.duration,...
    metadata.sr);
suptitle(ttlfig);
%% save figure

fnmsv = sprintf('%0.2d.fig',metadata.sessionum(1));
saveas(hfig,fullfile(figdir,fnmsv));

hfig.PaperPositionMode = 'manual';
hfig.PaperSize = [14 8];
hfig.PaperPosition = [0 0 14 8];
fnmsv = sprintf('%0.2d.jpeg',metadata.sessionum(1));
print(hfig,fullfile(figdir,fnmsv),'-djpeg','-r600');

end