function MAIN_plot_ipad_from_json()
% params:
params.reportmissingbdf = 1;
params.reportToAnayze = 0;
addpath(genpath('/Users/roee/Starr_Lab_Folder/Data_Analysis/First_Pass_Data_Analysis/code/toolboxes/eeglab14_1_0b'));
rootdir = '/Users/roee/Starr_Lab_Folder/Data_Analysis/Raw_Data/BR_reorg_manual';
patdir  = findFilesBVQX(rootdir,'brpd_*',struct('dirs',1,'depth',1));
for p = 1:length(patdir)
    fprintf('[%d],%s\n',p,patdir{p});
end
cnt = 1;
plotdata = 1;
findbeeps = 0;
for p = [6 7 8]%1:length(patdir)
    [pn,patstr] = fileparts(patdir{p});
    visitdir = findFilesBVQX(patdir{p},'v*',struct('dirs',1,'depth',1));
    for v = 1:length(visitdir)
        [pn,visitstr] = fileparts(visitdir{v});
        ipaddir = findFilesBVQX(visitdir{v},'*tsk-ipad*',struct('dirs',1,'depth',1));
        if ~isempty(ipaddir)
            for i = 1:length(ipaddir)
                [pn,ipadsess] = fileparts(ipaddir{i});
                matfile = findFilesBVQX(ipaddir{i},'ipad_event_indices_from_json.mat');
                jsonfile = findFilesBVQX(ipaddir{i},'*.json');
                bdffile = findFilesBVQX(ipaddir{i},'*.bdf');
                brrfile = findFilesBVQX(ipaddir{i},'brpd*.txt');
                finalfile = findFilesBVQX(ipaddir{i},'*hold_centertim.jpeg');
                finalfile = findFilesBVQX(ipaddir{i},'*_freq_domain.jpeg');
                if findbeeps
                    if  ~isempty(bdffile) & ~isempty(brrfile)
                        try
                            if isempty(finalfile)
                                plot_ipad_from_json(ipaddir{i},0)
                            end
                        catch
                            fprintf('failed %s\n',ipaddir{i});
                        end
                    end
                end
                % for plotting
                if plotdata
                    if ~isempty(jsonfile) & ~isempty(bdffile) & ~isempty(brrfile)
                        if ~isempty(matfile)
                            try
%                                 if isempty(finalfile)
%                                     plot_ipad_from_json(ipaddir{i},1)
                                    plot_data_from_ipad_json_freq_domain(ipaddir{i})
%                                 end
                            catch
                                fprintf('failed %s\n',ipaddir{i});
                            end
                        end
                    end
                end
            end
        end
    end
end

end