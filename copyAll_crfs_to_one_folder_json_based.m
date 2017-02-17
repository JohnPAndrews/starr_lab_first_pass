function copyAll_crfs_to_one_folder_json_based()
[settings, params] = get_settings_params();
rootdir = settings.rootdir; 
addpath(genpath(pwd));
outdir = fullfile('..','results','renamed_pdfs_for_digitizing');
mkdir(outdir); 
fnmout = 'README_logfile.txt'; 
fid = fopen(fullfile(outdir,fnmout),'w+'); 
fprintf(fid,'original file name\toriginal path\tnew file name\n'); 
% get subject json 
fnmsave = fullfile(rootdir, 'patients-^^^^-.json'); 
Patients = loadjson(fnmsave,'SimplifyCell',1); % this is how to read the data back in.
for p = 1:length(Patients)
    visitfnm = fullfile(rootdir, Patients(p).PatientFolderName,'visit-details-^^^^-.json'); 
    visits = loadjson(visitfnm,'SimplifyCell',1); % this is how to read the data back in.
    for v = 1:length(visits) % loop on each visit to find sesssions 
        foldersrc = fullfile(rootdir, Patients(p).PatientFolderName,visits(v).visitFolderName);
        foundpdf = findFilesBVQX(foldersrc,'*.PDF');
        for f = 1:length(foundpdf)
            if visits(v).usevist
                pdfname = sprintf('patient-%s_visit-%s_pdf%0.2d.pdf',...
                    Patients(p).PatientCode,visits(v).visitCategory,f);
                [pn,fn] = fileparts(foundpdf{f}); 
                fprintf(fid,'%s\t%s\t%s\t\n',...
                    fn,pn,pdfname);
                newpdffn = fullfile(outdir,pdfname); 
                copyfile(foundpdf{f},newpdffn);
            end
        end
    end
end
fclose(fid); 
end