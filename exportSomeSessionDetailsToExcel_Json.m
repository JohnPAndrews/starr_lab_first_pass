function exportSomeSessionDetailsToExcel_Json()
%% find all raw files that don't have regular text files
skipthis = 0;
if ~skipthis
    rootdir  = '/Users/roee/Starr_Lab_Folder/Data_Analysis/Raw_Data/BR_raw_data';
    ffs = findFilesBVQX(rootdir,'brpd*raw.txt');
    % ffs = findFilesBVQX(rootdir,'*session*^^^^-.json');
    fid = fopen('all_session_filenames.csv','w+');
    fprintf(fid,'session fn \t patien \t visit \t Raw condition task\n');
    for s = 1:length(ffs)
        trunfile = [ffs{s}(1:end-8) '.txt'];
        [pn,fn] = fileparts(ffs{s});
        if ~exist(trunfile,'file')
            jsonfn = findFilesBVQX(pn,[fn(1:25) '*.json']);
            if isempty(jsonfn) % I don't have json for these files...
                fprintf(fid,'%s \t %s \t %s \t %s \t \n', ...
                    [fn '.txt'],...
                    pn,...
                    '',...
                    '');
            else
                session  = loadjson(jsonfn{1},'SimplifyCell',1);
                fprintf(fid,'%s \t %s \t %s \t %s \t \n', ...
                    [fn '.txt'],...
                    session.patientcode,...
                    session.visitCategory,...
                    session.RawConditionTask);
            end
        end
    end
    fclose(fid);
end
%% export medication state from jsons
skipthis = 1;
if ~skipthis
    rootdir  = '/Users/roee/Starr_Lab_Folder/Data_Analysis/Raw_Data/BR_raw_data';
    ffs = findFilesBVQX(rootdir,'*session*^^^^-.json');
    fid = fopen('all_session_medication_state_filenames.csv','w+');
    fprintf(fid,'session fn \t session full path\t patient \t visit \t visit time \t medication state \t medication raw \t condition \t Raw condition task\n');
    fnmsave = fullfile(rootdir, 'patients-^^^^-.json');
    Patients = loadjson(fnmsave,'SimplifyCell',1); % this is how to read the data back in.
    for p = 1:length(Patients)
        visitfnm = fullfile(rootdir, Patients(p).PatientFolderName,'visit-details-^^^^-.json');
        visits = loadjson(visitfnm,'SimplifyCell',1); % this is how to read the data back in.
        for v = 1:length(visits) % loop on each visit to find sesssions
            visitdir = fullfile(rootdir,Patients(p).PatientFolderName,visits(v).visitFolderName);
            ffs = findFilesBVQX(visitdir,'*session*^^^^-.json');
            for s = 1:length(ffs)
                session  = loadjson(ffs{s},'SimplifyCell',1);
                fprintf(fid,'%s \t %s\t  %s \t %s \t %s \t %s \t %s \t %s \t %s \t     \n', ...
                    [session.filename '.txt'],...
                    session.fulltemppath,...
                    session.patientcode,...
                    session.visitCategory,...
                    session.recordingdate,...
                    session.Medication,...
                    session.MedicationNotes,...
                    session.ConditionTask,...
                    session.ConditionNotes);
                clear session;
            end
        end
    end
    fclose(fid);
end