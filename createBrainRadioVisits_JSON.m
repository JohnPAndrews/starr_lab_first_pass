function createBrainRadioVisits_JSON()
%% This function creats a JSON for brain radion patients
%  The purpose of this function is to create machine readable
%  directory walkers for Brain radion patients.
%  in the future, it can also be used to easily save
%  brain radio in annonmyzed, structured way.

% input - below - names of patients and other details

% output - json with above information

% relies on this toolbox:

% find visit folders
global rootdir
rootdir  = '/Users/roee/Starr_Lab_Folder/Data_Analysis/Raw_Data/BR_raw_data';
fnmsave = fullfile(rootdir, 'patients-^^^^-.json');
Patients  = loadjson(fnmsave,'SimplifyCell',1); % this is how to read the data back in.
%% find all the visits and create a json for each visit
for p = 1:length(Patients) % loop on patients
    patientdir = fullfile(rootdir,Patients(p).PatientFolderName);
    % find out if visit exists:
    fv = findFilesBVQX(patientdir, '*visit-details-^^^^-.json');
    if ~isempty(fv) % visit json exists, just check if you need to add more visits
        Visits = loadjson(fv{1},'SimplifyCell',1); % this is how to read the data back in.
        visitfldrs = findFilesBVQX(patientdir, '', struct('dirs',1,'depth',1));
        if length(visitfldrs) == length(Visits) % no new visits 
        else % there is a new visit that must be added 
            % find the new visits: 
            [fn,allvisits,ext] = cellfun(@fileparts,visitfldrs,'UniformOutput',0);
            [~,oldvisits,ext] = cellfun(@fileparts,{Visits.visitFolderName}','UniformOutput',0);
            newvisits = setxor(allvisits,oldvisits);
            visidx = length(Visits) + 1; 
            for n = 1:length(newvisits)
                visitfldr = fullfile(fn{1},newvisits{n});
                txtfilesfound = findFilesBVQX(visitfldr,'brpd*.txt'); % raw medtronic files
                [unqdates, mostfreqdate] = findUniqueDatesInVisit(txtfilesfound);
                if isempty(txtfilesfound) % if no releveant files in this new folder 
                    break; 
                end
                Visits(visidx).visitFolderName = newvisits{n};
                Visits(visidx).daysSinceImplant = datenum(mostfreqdate) - datenum(Visits(1).mostfreqdate) +1; % to include present day;
                Visits(visidx).visitCategory   = [sprintf('v%0.2d_',visidx) getVisitCategory(Visits(visidx).daysSinceImplant)];
                Visits(visidx).visitDate       = mostfreqdate{1};
                Visits(visidx).usevisit        = 1;
                Visits(visidx).patientcode     = Patients(p).PatientCode;
                Visits(visidx).patientdir      = patientdir; 
                Visits(visidx).uniqueDatesFoundInFolder = length(unqdates);
                Visits(visidx).uniqueDatesDetail        = unqdates;
                Visits(visidx).mostfreqdate             = mostfreqdate;
                fxlsf = findFilesBVQX(visitfldr,'*.xls*');
                if isempty(fxlsf)
                    visits.xlsfilename = [];
                else
                    visits.xlsfilename =  fxlsf{1};
                end
                visidx = visidx + 1; 
            end
            Visits = fixMistakesManually(Visits);
            savejson('',Visits,fullfile(patientdir, 'visit-details-^^^^-.json'));
        end 
    else
        visitfldrs = fimndFilesBVQX(patientdir, '', struct('dirs',1,'depth',1));
        for v = 1:length(visitfldrs) % loop on visits
            [~, baseFileName, extension] = fileparts(visitfldrs{v});
            foldername = [baseFileName extension];
            
            % find activa pc+s file to extract data from
            txtfilesfound = findFilesBVQX(visitfldrs{v},'brpd*.txt'); % raw medtronic files
            [unqdates, mostfreqdate] = findUniqueDatesInVisit(txtfilesfound);
            if ~isempty(unqdates)
                if v == 1 % make new struc for first visit
                    Visits = addVisit([],foldername, unqdates, mostfreqdate,visitfldrs{v});
                else
                    Visits = addVisit(Visits,foldername, unqdates, mostfreqdate,visitfldrs{v});
                end
            end
        end
        
        % sort visits by date
        rawVisits = squeeze(struct2cell(Visits))';
        sortedVisits = sortrows(rawVisits,2);
        
        % put back into structure, compute some meta data:
        implantdate = sortedVisits{1,2};
        for v = 1:size(sortedVisits,1)
            Visits(v).patientcode              = Patients(p).PatientCode;
            Visits(v).patientdir               = Patients(p).PatientFolderName;
            Visits(v).visitFolderName          = sortedVisits{v,1};
            Visits(v).visitDate                = sortedVisits{v,2};
            Visits(v).uniqueDatesFoundInFolder = sortedVisits{v,3};
            Visits(v).uniqueDatesDetail        = sortedVisits{v,4};
            Visits(v).mostfreqdate             = sortedVisits{v,5};
            Visits(v).daysSinceImplant         = datenum(Visits(v).visitDate) - datenum(implantdate) +1; % to include present day;
            Visits(v).visitCategory            = [sprintf('v%0.2d_',v) getVisitCategory(Visits(v).daysSinceImplant)];
            Visits(v).usevisit                  = 1; % to fill out manually in json (change to zero to not include
            Visits(v).xlsfilename              = sortedVisits{v,6};
        end
        % fix some mistakes manually, mostly in visit categories
        Visits = fixMistakesManually(Visits);
        % reorder the fields within each visit so its more redable:
        fieldnamesused = fieldnames(Visits);
        for s = 1:length(fieldnamesused)
            fprintf('%0.2d\t %s\n',s,fieldnamesused{s});
        end
        neworder = [     1    10     2     9    11     7     8     3     4     5     6];
        Visits = orderfields(Visits,neworder);
        
        % options for json
        opt.ForceRootName = 0;
        savejson('',Visits,fullfile(patientdir, 'visit-details-^^^^-.json'));
        % Visits  = loadjson('test_visit.json','SimplifyCell',1); % this is how to read the data back in.
    end
end

end

function Ps = addVisit(Ps, name,uniqueDates, mostfreqdate,visitfldr)
visits.visitFolderName                = name;
if isempty(uniqueDates) % if no unique dates, there is no data, here can be videos, EEG data? etc.
    visits.visitDate = [];
    visits.uniqueDatesFoundInFolder = [];
    visits.uniqueDatesDetail = [];
    visits.mostfreqdate = [];
    visits.xlsfile     = []; % xls / xlsm filename describing data;
else
    visits.visitDate                = uniqueDates{end};
    visits.uniqueDatesFoundInFolder = length(uniqueDates);
    visits.uniqueDatesDetail        = uniqueDates;
    visits.mostfreqdate = mostfreqdate;
    % find .xls / .xlsm file detailing visit
    
    ff = findFilesBVQX(visitfldr,'*.xls*');
    if isempty(ff)
        visits.xlsfilename = [];
    else
        visits.xlsfilename =  ff{1};
    end
    
end

Ps = [Ps, visits];
end

function visitCategory = getVisitCategory(daysSinceImplant)
if daysSinceImplant < 5
    visitCategory = 'OR_day';
elseif 5 < daysSinceImplant && daysSinceImplant < 15
    visitCategory = '10_day';
elseif 16 < daysSinceImplant && daysSinceImplant < 25
    visitCategory = '03_wek';
elseif 26 < daysSinceImplant && daysSinceImplant< 40
    visitCategory = '01_mnt';
elseif 41 < daysSinceImplant && daysSinceImplant< 70
    visitCategory = '02_mnt';
elseif 71 < daysSinceImplant && daysSinceImplant< 120
    visitCategory = '03_mnt';
elseif 160 < daysSinceImplant && daysSinceImplant< 200
    visitCategory = '06_mnt';
elseif 201 < daysSinceImplant && daysSinceImplant< 380
    visitCategory = '01_yer';
elseif 381 < daysSinceImplant && daysSinceImplant< 740
    visitCategory = '02_yer';
else
    visitCategory = '000000'; % don't know....
end
end

function [unqdates, mostfreqdate] = findUniqueDatesInVisit(txtfiles)
if isempty(txtfiles)
    unqdates = []; % no data
    mostfreqdate = [];
else
    for u = 1:length(txtfiles)
        [~,filename] = fileparts(txtfiles{u});
        alldates{u} = datestr(datevec(filename(8:17),'yyyy_mm_dd'),29);
    end
    unqdates = unique(alldates);
    mostfreqdate = mode_cell_array(alldates);
end
end

function Visits = fixMistakesManually(Visits)
switch Visits(1).patientcode
    case 'brpd_01'
        for v = 1:length(Visits)
            if strcmp(Visits(v).visitCategory,'v03_000000')
                Visits(v).visitCategory = 'v03_03_wek';
            end
            if strcmp(Visits(v).visitCategory,'v06_000000')
                Visits(v).visitCategory = 'v06_03_mnt';
            end
            if strcmp(Visits(v).visitCategory,'v09_000000')
                Visits(v).visitCategory = 'v09_02_yer';
            end
        end
    case 'brpd_02'
    case 'brpd_03'
        for v = 1:length(Visits)
            if strcmp(Visits(v).visitCategory,'v02_OR_day')
                Visits(v).visitCategory = 'v02_predis';
            end
            if strcmp(Visits(v).visitCategory,'v10_02_yer')
                Visits(v).usevisit = 0;
            end
            if strcmp(Visits(v).visitCategory,'v12_000000')
                Visits(v).usevisit = 0;
            end
            if strcmp(Visits(v).visitCategory,'v13_000000')
                Visits(v).usevisit = 0;
            end
            if strcmp(Visits(v).visitCategory,'v14_000000')
                Visits(v).usevisit = 0;
            end
        end
    case 'brpd_04'
        for v = 1:length(Visits)
            if strcmp(Visits(v).visitCategory,'v02_OR_day')
                Visits(v).visitCategory = 'v02_predis';
            end
            if strcmp(Visits(v).visitCategory,'v11_02_yer')
                Visits(v).visitCategory = 'v11_000000';
                Visits(v).usevisit = 0;
            end
        end
    case 'brpd_05'
        for v = 1:length(Visits)
            if strcmp(Visits(v).visitCategory,'v02_OR_day')
                Visits(v).visitCategory = 'v02_predis';
            end
            if strcmp(Visits(v).visitCategory,'v07_03_mnt')
                Visits(v).visitCategory = 'v07_02_mnt';
            end
            if strcmp(Visits(v).visitCategory,'v11_01_yer')
                Visits(v).visitCategory = 'v11_000000';
                Visits(v).usevisit = 0;
            end
            if strcmp(Visits(v).visitCategory,'v12_02_yer')
                Visits(v).visitCategory = 'v12_01_yer';
            end
            if strcmp(Visits(v).visitCategory,'v13_02_yer')
                Visits(v).visitCategory = 'v13_000000';
                Visits(v).usevisit = 0;
            end
            if strcmp(Visits(v).visitCategory,'v14_000000')
                Visits(v).visitCategory = 'v12_02_yer';
            end
        end
    case 'brpd_06'
        for v = 1:length(Visits)
            if strcmp(Visits(v).visitCategory,'v02_OR_day')
                Visits(v).visitCategory = 'v02_predis';
            end
            if strcmp(Visits(v).visitCategory,'v05_000000')
                Visits(v).visitCategory = 'v05_000000';
                Visits(v).usevisit = 0;
            end
            if strcmp(Visits(v).visitCategory,'v06_01_mnt')
                Visits(v).visitCategory = 'v06_03_wek';
                Visits(v).usevisit = 1;
            end
            if strcmp(Visits(v).visitCategory,'v08_02_mnt')
                Visits(v).visitCategory = 'v06_01_mnt';
            end
            if strcmp(Visits(v).visitCategory,'v09_000000')
                Visits(v).visitCategory = 'v09_02_mnt';
            end
        end
    case 'brpd_07'
        for v = 1:length(Visits)
            if strcmp(Visits(v).visitCategory,'v02_OR_day')
                Visits(v).visitCategory = 'v02_predis';
            end
            if strcmp(Visits(v).visitCategory,'v04_000000')
                Visits(v).visitCategory = 'v02_03_wek';
            end
        end
    case 'brpd_08'
    case 'brpd_09'
        for v = 1:length(Visits)
            if strcmp(Visits(v).visitCategory,'v02_OR_day')
                Visits(v).visitCategory = 'v02_predis';
            end
            if strcmp(Visits(v).visitCategory,'v05_000000')
                Visits(v).visitCategory = 'v05_01_mnt';
            end
            if strcmp(Visits(v).visitCategory,'v09_01_yer')
                Visits(v).visitCategory = 'v09_000000';
                Visits(v).usevisit = 0;
            end
        end
end
end