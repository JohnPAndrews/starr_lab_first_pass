function plotRMS1year2year()
rootdir = '/Users/roee/Starr_Lab_Folder/Data_Analysis/First_Pass_Data_Analysis/results/mat_file_with_all_session_jsons';
figdir = '/Users/roee/Starr_Lab_Folder/Data_Analysis/First_Pass_Data_Analysis/figures/impedences';

ff = findFilesBVQX(rootdir,'P-*.mat');
clrsuse =[215,48,39;
    252,141,89;
    254,224,144;
    255,255,191;
    224,243,248;
    145,191,219;
    69,117,180]./255;
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

visitsname =   {
    'OR day'
    '1 day'
    '10 day'
    '3 week'
    '1 month'
    '2 month'
    '3 month'
    '6 month'
    '1 year'
    '2 year'
    };
areasuse = {'m1','s1'};

hfig = figure;
hold on;
for f = 1:length(ff)
    load(ff{f});
    m1cnt = 1; s1cnt = 1;
    m1= []; s1 = [];
    lineuse = [];errorus = [] ;
    pat = brdb.patientcode{1};
    for v = 1:length(visits)
        for a = 1:2
            if a ==2
                idxuse = strcmp(brdb.visitCategory,visits{v}) & ...
                    strcmp(brdb.Medication,'off') & ...
                    strcmp(brdb.StimOn,'off') & ...
                    ~cellfun(@(x) any(strfind(x,'pE0')),brdb.stn_electrodes) & ...
                    strcmp(brdb.ConditionTask,'rest');
                newdb = brdb(idxuse,{'visitCategory','m1_rawdata','stn_rawdata', 'stn_electrodes','m1_electrodes', 'ConditionTask','Medication'});
            else
                idxuse = strcmp(brdb.visitCategory,visits{v}) & ...
                    strcmp(brdb.Medication,'off') & ...
                    strcmp(brdb.StimOn,'off') & ...
                    strcmp(brdb.ConditionTask,'rest');
                newdb = brdb(idxuse,{'visitCategory','m1_rawdata','stn_rawdata', 'stn_electrodes','m1_electrodes', 'ConditionTask','Medication'});
            end
            if ~isempty(newdb)
                for n = 1:size(newdb,1)
                    if a == 1
                        data = eval(sprintf('newdb.%s_rawdata{n}',areasuse{a}));
                    else
                        data = eval('newdb.stn_rawdata{n}');
                    end
                    params.lowcutoff = 1;
                    params.sr = 800;
                    dat_hp = preproc_dc_offset_high_pass(data,params);
                    dat_hp_tr = preproc_trim_data(dat_hp,5e3,800);
                    rmsval = rms(dat_hp_tr);
                    eval(sprintf('%s(%scnt,1)=rmsval;',areasuse{a},areasuse{a}));
                    eval(sprintf('%s(%scnt,2)=v;',areasuse{a},areasuse{a}) );
                    eval(sprintf('%scnt = %scnt + 1;',areasuse{a},areasuse{a}) );
                end
            end
        end
    end
    % create a line for each unique area
    areasuse = {'m1','s1'};
    styleuse = {'-','--'};
    for a = 1:2
        areadat = eval(areasuse{a});
        unqvisits = unique(areadat(:,2));
        lineuse = []; errorus = []; 
        for uv = 1:length(unqvisits)
            dat = areadat(unqvisits(uv) == areadat(:,2),1);
            lineuse(uv) = mean(dat).*1000;
            errorus(uv) = std( dat.*1000 ) / sqrt( length( dat ));
        end
        hline = line(unqvisits',lineuse,...
            'LineWidth',3,...
            'Color',clrsuse(f,:),...
            'LineStyle',styleuse{a});
        hold on;
        %         errorbar(unqvisits,lineuse,errorus,...
        %             'LineWidth',3,...
        %             'Color',clrsuse(f,:),...
        %             'LineStyle',styleuse{a})
        %         hold on;
    end
    %
    %     stderror = std( data ) / sqrt( length( data ));
    %     scatter(s1(:,2), s1(:,1),50,'r','filled')
    %
    %
    %     subplot(1,2,2);
    %     scatter(s1(:,2), m1(:,1),50,'r','filled')
    %         xticks(0:1:9);
    %     xlim([0 9]);
    %     visitsuse = cellfun(@(x) strrep(x,'_','-'),visits,'UniformOutput',false);
    %     xticklabels([' '; visitsuse ;' ']);
    %     set(gca,'XTickLabelRotation',45);
    %     ylabel('rms');
    %     title('ecog');
    %     suptitle(strrep(pat,'_','-'));
    % save
end
% set visit x labels
visittemp = cellfun(@(x) strrep(x,'_','-'),visitsname,'UniformOutput',false);
visitsuse = [' ' ;visittemp ;' '];
xlim([0 length(visitsuse)-1]);
xticks(0:1:length(visitsuse)-1);
xticklabels(visitsuse );
set(gca,'XTickLabelRotation',45);


ylabel('RMS Voltage (\muV)');
title('RMS over time');

fnmuse = 'rmsAllPatients.pdf';
fnmsave = fullfile(figdir, fnmuse);
hfig.PaperPositionMode = 'manual';
hfig.PaperSize = [8.5 16/2];
hfig.PaperPosition = [ 0 0 8.5 16/2];
print(hfig,fnmsave,'-dpdf');

end