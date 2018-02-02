function db = getBrainRadioDataBase()
%%
rootdir = '/Users/roee/Starr_Lab_Folder/Data_Analysis/Raw_Data/BR_reorg_manual';
patdir  = findFilesBVQX(rootdir,'brpd_*',struct('dirs',1,'depth',1));
db = []; 
for p = 1:length(patdir)
    visdir  = findFilesBVQX(patdir{p},'v*',struct('dirs',1,'depth',1));
    for v = 1:length(visdir)
        
        rfs = findFilesBVQX(visdir{v},'resultsBR.mat');
        dff = findFilesBVQX(visdir{v},'dataBR.mat');
        if ~isempty(rfs) & ~isempty(dff)
            for rf = 1:length(rfs)
                load(rfs{1}); load(dff{1});
                newtb = [datTab(:,{'patient'}), resTab.visit, datTab(:,2:end)];
                newtb.Properties.VariableNames{'Var2'} = 'visit';
                db = [db ; newtb]; 
            end
        end
    end
end
end