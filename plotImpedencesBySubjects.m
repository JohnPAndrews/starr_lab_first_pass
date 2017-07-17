function plotImpedencesBySubjects()
rootdir = '/Users/roee/Starr_Lab_Folder/Data_Analysis/Raw_Data/CRF/CRF';
figdir = '/Users/roee/Starr_Lab_Folder/Data_Analysis/First_Pass_Data_Analysis/figures/impedences';
fdirs = findFilesBVQX(rootdir,'Sub*',struct('dirs',1,'depth',1));
visits =   {
    'OR_day'
    'predis'
    '10_day'
    '03_wek'
    '01_mnt'
    '02_mnt'
    '03_mnt'
    '06_mnt'
    '01_yer'
    '02_yer'
    };
for d = 1:length(fdirs) % loop on subs
    ff = findFilesBVQX(fdirs{d},'*.mat');
    for f = 1:length(ff) % loop on viists
        load(ff{f});
        [pn,fn,ext] = fileparts(ff{f});
        % get udprs stats 
        [udon(f), udoff(f)] = getudprs(crfstruc); 
        % meta details
        visit = fn(27:32);
        idxvisitcheck = any(strcmp(visit,visits) == 1);
        idxvisit = find(strcmp(visit,visits)==1);
        pat = fn(9:15);
        if idxvisitcheck
            % voltage
            if isfield(crfstruc,'voltage_and_impedance')
                vol1 = crfstruc.voltage_and_impedance.voltage1;
                vol2 = crfstruc.voltage_and_impedance.voltage2;
                vol3 = crfstruc.voltage_and_impedance.voltage3;
                % monopolar impedences
                allfn = fieldnames(crfstruc.voltage_and_impedance);
                idxmono = cellfun(@(x) any(strfind(x,'mono')), allfn);
                fnuse = allfn(idxmono);
                for sf = 1:length(fnuse)
                    if ~isempty( crfstruc.voltage_and_impedance.(fnuse{sf}))
                        toplot(sf,f) = crfstruc.voltage_and_impedance.(fnuse{sf});
                        legnms{sf} = sprintf('e%s',fnuse{sf}(end-1:end));
                    end
                end
                if ~isempty( crfstruc.voltage_and_impedance.(fnuse{sf}))
                    idxuse(f) = idxvisit;
                end
            end
        end
    end
    %% plot udprs 
    xvals = repmat(idxuse,size(udon,1),1);
    hfig = figure;
    hline = line(xvals',udon');
    hold on; 
    hline = line(xvals',udoff');
    % set visit x labels 
    visittemp = cellfun(@(x) strrep(x,'_','-'),visits,'UniformOutput',false);
    visitsuse = [' ' ;visittemp ;' ']; 
    xlim([0 length(visitsuse)-1]);
    xticks(0:1:length(visitsuse)-1);
    xticklabels(visitsuse );
    set(gca,'XTickLabelRotation',45);
    
    % set legends 
    legend('UPDRS ON meds','UPDRS OFF meds');
    ttl =sprintf('UPDRS %s',pat);
    ylabel('updrs score');
    title(strrep(ttl,'_','-'));
    fnmuse = strrep(sprintf('updrs-%s',pat),'_','-');
    fnmsave = fullfile(figdir, fnmuse);
    hfig.PaperPositionMode = 'manual';
    hfig.PaperSize = [8.5 16/2];
    hfig.PaperPosition = [ 0 0 8.5 16/2];
    print(hfig,fnmsave,'-dpdf');
    
    
    %% plot impedences 
    xvals = repmat(idxuse,size(toplot,1),1);
    hfig = figure;
    hline = line(xvals',toplot');
    
    visittemp = cellfun(@(x) strrep(x,'_','-'),visits,'UniformOutput',false);
    visitsuse = [' ' ;visittemp ;' '];
    xlim([0 length(visitsuse)-1]);
    xticks(0:1:length(visitsuse)-1);
    xticklabels(visitsuse );
    set(gca,'XTickLabelRotation',45);
    
    
    legend(legnms);
    ttl =sprintf('impedences %s',pat);
    ylabel('impedence');
    title(strrep(ttl,'_','-'));
    fnmuse = strrep(sprintf('impdences-%s',pat),'_','-');
    fnmsave = fullfile(figdir, fnmuse);
    hfig.PaperPositionMode = 'manual';
    hfig.PaperSize = [8.5 16/2];
    hfig.PaperPosition = [ 0 0 8.5 16/2];
    print(hfig,fnmsave,'-dpdf');
end
idxuse =[];
toplot = [];
close(hfig); 
end

function [udon, udoff] = getudprs(crfstruc)
ud1 = crfstruc.updrs;
ud2 = crfstruc.updrs1;
if isfield(ud1,'x18_speech') & isfield(ud2,'x18_speech')
    udfnmsraw = fieldnames(ud1); 
    idxuse = cellfun(@(x) any(strcmp(x(1),'x')),udfnmsraw); 
    fnms = udfnmsraw(idxuse);
    scr = []; 
    for f = 1:length(fnms)
        for s = 1:2
            if isnumeric(eval(sprintf('ud%d.%s',s,fnms{f}))) & ~isempty(eval(sprintf('ud%d.%s',1,fnms{f})))
                scr(f,s) = eval(sprintf('ud%d.%s',s,fnms{f}));
            else
                 scr(f,s) = 0; 
            end
        end
    end
    udon = sum(scr(:,1));
    udoff = sum(scr(:,2));
else
    udon = 0;
    udoff = 0; 
end
end