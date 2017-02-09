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
rootdir = '/Volumes/Starr_Lab_H/Starr_Lab/BR_raw_data';
fnmsave = fullfile(rootdir, 'patients-^^^^-.json');
Patients  = loadjson(fnmsave,'SimplifyCell',1); % this is how to read the data back in.
%% find all the visits and create a json for each visit
for p = 1:length(Patients) % loop on patients
    patientdir = fullfile(rootdir,Patients(p).PatientFolderName);
    visitfldrs = findFilesBVQX(patientdir, '', struct('dirs',1,'depth',1));
    for v = 1:length(visitfldrs) % loop on visits
        [~, baseFileName, extension] = fileparts(visitfldrs{v});
        foldername = [baseFileName extension]; 
        if strcmp(foldername,'2.13')
            x = 2; 
        end
        % find neuromega file to extract data from
        txtfilesfound = findFilesBVQX(visitfldrs{v},'brpd*.txt'); % raw medtronic files
        [unqdates, mostfreqdate] = findUniqueDatesInVisit(txtfilesfound);
        if ~isempty(unqdates)
            if v == 1 % make new struc for first visit
                Visits = addVisit([],foldername, unqdates, mostfreqdate);
            else
                Visits = addVisit(Visits,foldername, unqdates, mostfreqdate);
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
        Visits(v).visitCategory            = getVisitCategory(Visits(v).daysSinceImplant);
    end
    
    % options for json
    opt.ForceRootName = 0;
    savejson('',Visits,fullfile(patientdir, 'visit-details-^^^^-.json'));
    % Visits  = loadjson('test_visit.json','SimplifyCell',1); % this is how to read the data back in.
end

end

function Ps = addVisit(Ps, name,uniqueDates, mostfreqdate)
visits.visitFolderName                = name;
if isempty(uniqueDates) % if no unique dates, there is no data, here can be videos, EEG data? etc.
    visits.visitDate = [];
    visits.uniqueDatesFoundInFolder = [];
    visits.uniqueDatesDetail = [];
    visits.mostfreqdate = [];
else
    visits.visitDate                = uniqueDates{end};
    visits.uniqueDatesFoundInFolder = length(uniqueDates);
    visits.uniqueDatesDetail        = uniqueDates;
    visits.mostfreqdate = mostfreqdate;
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
elseif 41 < daysSinceImplant && daysSinceImplant< 120
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