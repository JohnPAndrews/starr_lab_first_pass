function determineIfStimOnAllSessions()
%% This is a utility function...
% use with caution....
rootdir  = '/Users/roee/Starr_Lab_Folder/Data_Analysis/Raw_Data/BR_raw_data';
anatype = {'reg','pwelch'};
for i = 1:length(anatype);
    figfold  = fullfile('..','figures','figures_fft_initial_temp',anatype{i});
    mkdir(figfold);
    [settings, params] = get_settings_params();
    ff = findFilesBVQX(rootdir,'*session*.json');
    for f = 1:length(ff)
        [pn, ~] =fileparts(ff{f});
        session  = loadjson(ff{f},'SimplifyCell',1);
        % find reasons to skip this file:
        skip = 0; % default don't skip
        if ~session.usevist; skip = 1; end; % if its a visit to skip - skip
        if ~strcmp(session.ConditionTask,'rest'); skip =1; end; % if its not a rest condition - skip
        if strcmp(session.visitCategory,'000000'); skip =1; end; % if its a v00000 skip. 
        % if don't skip, then plot data
        fntosave = sprintf('p-%s_visit-%s_condition-%s_time-%s',...
            session.patientcode,session.visitCategory,session.ConditionTask,session.filename(19:26));
        figtitle = sprintf('p-%s visit-%s condition-%s time-%s',...
            session.patientcode,session.visitCategory,session.ConditionTask,session.filename(19:26));
        figtitle = strrep(figtitle,'_',' ');
        ffnms = fullfile(figfold, fntosave);
        if ~skip
            start = tic;
            data = importdata(fullfile(pn, [session.filename '.txt']));
            sr_str = session.xmldata.SenseChannelConfig.TDSampleRate;
            params.sr = str2double(strrep(sr_str,'Hz',''));
            params.plottype = anatype{i};
            params.msec2trim = 5000;
            stndata = preproc_trim_data(data(:,1),params.msec2trim,params.sr);
            hfig = plot_data_freq_domain(stndata,params,figtitle);
            save_figure(hfig,figtitle,figfold,'jpeg');
            fprintf('fig %s saved in %f secs\n',figtitle,toc(start));
        end
    end
end
end