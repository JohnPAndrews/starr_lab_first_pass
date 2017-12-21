function report_missing_json_files()
% params:
params.reportmissingbdf = 1;
params.reportToAnayze = 0;

rootdir = '/Users/roee/Starr_Lab_Folder/Data_Analysis/Raw_Data/BR_reorg_manual';
patdir  = findFilesBVQX(rootdir,'brpd_*',struct('dirs',1,'depth',1));
fidanalyze = fopen('report_ipad_sessions_to_analyze.txt','w+');
fidanalyze = fopen('report_missing_files_json_filesipad_task.txt','w+');
cnt = 1;
for p = 1:length(patdir)
    [pn,patstr] = fileparts(patdir{p});
    visitdir = findFilesBVQX(patdir{p},'v*',struct('dirs',1,'depth',1));
    for v = 1:length(visitdir)
        [pn,visitstr] = fileparts(visitdir{v});
        ipaddir = findFilesBVQX(visitdir{v},'*tsk-ipad*',struct('dirs',1,'depth',1));
        if ~isempty(ipaddir)
            for i = 1:length(ipaddir)
                [pn,ipadsess] = fileparts(ipaddir{i});
                bdffile = findFilesBVQX(ipaddir{i},'*.json');
                
                if params.reportmissingbdf
                    if isempty(bdffile)
                        fprintf(fidanalyze,'%0.2d p-%s v-%s s-%s\n',...
                            cnt,patstr,visitstr,ipadsess);
                        cnt = cnt +1;
                    end
                end
                if params.reportToAnayze
                    if ~isempty(bdffile)
                        eventfile = findFilesBVQX(ipaddir{i},'ipad*.fig');
                        if  isempty(eventfile)
                            plot_ipad_data_semi_auto(ipaddir{i});
                            fprintf(fidanalyze,'%0.2d p-%s v-%s s-%s\n',...
                                cnt,patstr,visitstr,ipadsess);
                            cnt = cnt +1;
                        end
                    end
                end
            end
        end
    end
    fprintf(fidanalyze,'\n\n');
end
fclose(fidanalyze);
end