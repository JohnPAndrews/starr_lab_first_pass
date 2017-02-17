function determineIfStimOnAllSessions()
%% This function tries to automatically detect if stim is and if file from session should be analyzed
% use with caution....
rootdir  = '/Users/roee/Starr_Lab_Folder/Data_Analysis/Raw_Data/BR_raw_data';
resultsdir   = fullfile('..','results','rest_mat_files_validation');
[settings, params] = get_settings_params();
mkdir(resultsdir);
%% save all data to temp results dir to make loading files faster
savedatatomat = 0; % save all data to temp directory...
if savedatatomat
    ff = findFilesBVQX(rootdir,'*session*.json');
    for f = 1:length(ff)
        start = tic;
        [pn, ~] =fileparts(ff{f});
        session  = loadjson(ff{f},'SimplifyCell',1);
        % find reasons to skip this file:
        skip = 0; % default don't skip
        if ~session.usevist; skip = 1; end; % if its a visit to skip - skip
        if ~strcmp(session.ConditionTask,'rest'); skip =1; end; % if its not a rest condition - skip
        if strcmp(session.visitCategory,'000000'); skip =1; end; % if its a v00000 skip.
        if ~skip
            data = importdata(fullfile(pn, [session.filename '.txt']));
            fnsavematfile = fullfile(resultsdir,[session.filename '.mat']);
            save(fnsavematfile,'data','session');
            fprintf('saves in %f secs file %s\n',toc(start),session.filename);
        end
    end
end

%% plot the data / try to classify data if it has / does not have stim on.
%% also try to find out if this is a session we should analyze / reject for various reasons.
ff = findFilesBVQX(resultsdir,'*.mat');
anatype = {'reg','pwelch'};

for f = 32%1:length(ff)
    [pn, ~] =fileparts(ff{f});
    load(ff{f}); 
    for i = 1:length(anatype);
        figfoldanatype  = fullfile('..','figures','figures_fft_initial_temp',anatype{i});
        figrejc  = fullfile(figfoldanatype,'reject_session'); % folder in which put rejects 
        figstimon = fullfile(figfoldanatype,'stimon');
        figstimoff = fullfile(figfoldanatype,'stimoff');
        evalc('mkdir(figrejc)');% to supress message that dir exists;         
        evalc('mkdir(figfoldanatype)');% to supress message that dir exists;   
        evalc('mkdir(figstimon)');% to supress message that dir exists;   
        evalc('mkdir(figstimoff)');% to supress message that dir exists;   
        
        fntosave = sprintf('p-%s_visit-%s_condition-%s_time-%s',...
            session.patientcode,session.visitCategory,session.ConditionTask,session.filename(19:26));
        figtitle = sprintf('p-%s visit-%s condition-%s time-%s',...
            session.patientcode,session.visitCategory,session.ConditionTask,session.filename(19:26));
        [reject, rejectreason] = checkDataFromSession(data,session,params);

        
        if reject
            figfold = figrejc;
        else
            stimon = checkIfStimOnDataDriven(data,session,params);
            if stimon == 1
                figfold = figstimon;
            elseif stimon == 0
                figfold = figstimoff;
            end
        end

        figtitle = strrep(figtitle,'_',' ');
        figtitle = sprintf('f-%0.3d %s',f, figtitle);
        ffnms = fullfile(figfold, fntosave);
        start = tic;
        sr_str = session.xmldata.SenseChannelConfig.TDSampleRate;
        params.sr = str2double(strrep(sr_str,'Hz',''));
        params.plottype = anatype{i};
        params.msec2trim = 5000;
        stndata = preproc_trim_data(data(:,1),params.msec2trim,params.sr);
        hfig = plot_data_freq_domain(stndata,params,figtitle);
        evalc('save_figure(hfig,figtitle,figfold,''jpeg'')');
        fprintf('fig %s saved in %f secs\n',figtitle,toc(start));
    end
    clear data session; 
end
end