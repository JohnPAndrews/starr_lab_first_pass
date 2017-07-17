function quickAndDirty()
fn = uigetdir('find dir');
ff = findFilesBVQX(fn,'*.txt'); 
hfig = figure; 

%% time domain 
for f = 1:length(ff)
    [pn,fn,ext] = fileparts(ff{f}); 
    data = importdata(ff{f}); 
    subplot(1,2,1); 
    plot(data(:,1));
    title('lfp');
    xlabel('time');
    ylabel('voltage');
    subplot(1,2,2); 
    plot(data(:,3));
    title('ecog');
    xlabel('time');
    ylabel('voltage');
end
hfig.PaperPositionMode = 'manual';
hfig.PaperSize         = [15 8]; 
hfig.PaperPosition     = [ 0 0 15 8]; 
[rootdir,tsknm,ext] = fileparts(pn);
% make fig duration 
figdir = fullfile(rootdir,'figures');
mkdir(figdir); 
suptitle(strrep(tsknm,'_',' '));
fnmsv = sprintf('%s_.jpeg',tsknm);
print(hfig,fullfile(figdir,fnmsv),'-djpeg');
fnmsv = sprintf('%s_.fig',tsknm);
saveas(hfig,fullfile(figdir,fnmsv));
close(hfig); 

[settings,params] = get_settings_params();
%% freq domain 
for f = 1:length(ff)
    [pn,fn,ext] = fileparts(ff{f}); 
    [pn,fn,ext] = fileparts(ff{f});
    if any(strfind(fn,'raw')) % if its a raw file, get xml data from non raw xml
        xmlfnm = [fn(1:end-4) '.xml'];
    else
        xmlfnm = [fn '.xml'];
    end
    xmlstruc = xml2struct(fullfile(pn,xmlfnm));
    if isfield(xmlstruc,'RecordingItem')
        xmlstrucparsed = parseXMLstruc(xmlstruc);
    else
        xmlstrucparsed = parseXMLstruc2(xmlstruc);
    end
    xmldata = xmlstrucparsed.RecordingItem;
    params.sr = 800; 
    data = importdata(ff{f}); 
    % lfp 
    subplot(1,2,1); 
    dattime = preproc_trim_data(data(:,1),params.msec2trim,params.sr);
    prpcdat = preproc_dc_offset_high_pass(dattime,params);
    plot_data_freq_domain(prpcdat,params,[]);
    title('LFP');
    
    % ecog 
    subplot(1,2,2); 
    dattime = preproc_trim_data(data(:,3),params.msec2trim,params.sr);
    prpcdat = preproc_dc_offset_high_pass(dattime,params);
    plot_data_freq_domain(prpcdat,params,[]);
    title('ECOG');
end
hfig.PaperPositionMode = 'manual';
hfig.PaperSize         = [15 8]; 
hfig.PaperPosition     = [ 0 0 15 8]; 
[rootdir,tsknm,ext] = fileparts(pn);
% make fig duration 
figdir = fullfile(rootdir,'figures');
mkdir(figdir); 
suptitle(strrep(tsknm,'_',' '));
fnmsv = sprintf('%s_PSD.jpeg',tsknm);
print(hfig,fullfile(figdir,fnmsv),'-djpeg');
fnmsv = sprintf('%s_PSD.fig',tsknm);
saveas(hfig,fullfile(figdir,fnmsv));
close(hfig); 

return; 
%% montage 
fn = uigetdir('find dir');
% params = 
for f = 1:length(ff)
    data = importdata(ff{f}); 
    preprocdat = preproc_dc_offset_high_pass(data,params);
    subplot(1,2,1); 
    plot_data_freq_domain(data(:,1),params,[])
    hold on; 
    subplot(1,2,2); 
    plot(data(:,3));
    title('ecog');
    xlabel('time');
    ylabel('voltage');
end

end