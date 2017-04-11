function compareStimOnStimOff_machine_learning()
rootdir  = '/Users/roee/Starr_Lab_Folder/Data_Analysis/Raw_Data/BR_reorganized';
resultsdir   = fullfile('..','results','mat_file_with_all_session_jsons');
figdir = fullfile('..','figures','stimOnVsOffDataDriven');
evalc('mkdir(figdir)');

stnfigStimOn = fullfile(figdir,'stn_stimOn'); mkdir(stnfigStimOn)
stnfigStimOff = fullfile(figdir,'stn_stimOff');mkdir(stnfigStimOff)
m1figStimOn = fullfile(figdir,'m1_stimOn'); mkdir(m1figStimOn)
m1figStimOff = fullfile(figdir,'m1_stimOff');mkdir(m1figStimOff)

[settings, params] = get_settings_params();
load(fullfile(resultsdir,'all_session_celldb.mat'),'outdb','sessiondb','symptomcat');
%% set params.
% inclusion criteria
logidxoverall = ...
    sessiondb.usevisit == 1 & ...
    ~strcmp(sessiondb.visitCategory,'000000') & ...
    logical(strcmp(sessiondb.StimOn,'on') |  strcmp(sessiondb.StimOn,'off') ) & ...
    logical(strcmp(sessiondb.Medication,'on'))| logical(strcmp(sessiondb.Medication,'off')) & ...
    logical(strcmp(sessiondb.patientcode,'brpd_01')) &  ...
    sessiondb.sr == 800;
newdb = sessiondb(logidxoverall,:);
fprintf('%d stim off, %d stim on\n',...
    sum(logical(strcmp(newdb.StimOn,'on'))),...
    sum(logical(strcmp(newdb.StimOn,'off'))));

fprintf('%d meds on, %d meds off\n',...
    sum(logical(strcmp(newdb.Medication,'on'))),...
    sum(logical(strcmp(newdb.Medication,'off'))));

labelarea = {'stn','m1'};
chanidx = [1 3];
params.noisefloor = 400;
params.cvfold         = 5; 
% hfig = figure('visible','on','position',[170        -330        2264        1056]);
cntdat = 1;
for i = 1:size(newdb,1)
    for cu = 1%:2 % only use stn data 
        ticOpen = tic;
        start = tic;
        data = importdata(newdb.datafullpath{i});
        data = data(:,(chanidx(cu)));
        params.sr = newdb.sr(i);
        data_tr = preproc_trim_data(data,params.msec2trim,params.sr);
        data_tr_prp = preproc_dc_offset_high_pass(data_tr,params);
        clear data; 
        %% data valiation: 
        analyzesession = ~isempty(data_tr_prp(~isnan(data_tr_prp))); % check NaN's 
        % length 
        if length(data_tr)/params.sr < 20; analyzesession = 0; end; 
        if sum(data_tr_prp) == 0; analyzesession = 0; end; % empty channel 
        %% get data 
        if analyzesession
            data_no_out = zscore(deleteoutliers(data_tr_prp,0.05));
            %% split into training set and testing set  
            c = cvpartition( length(data_no_out),'Kfold',params.cvfold); 
            for cc = 1:c.NumTestSets
                cvec(:,cc) = c.test(cc).* cc; 
            end
            testsets = sort(sum(cvec,2)); 
            for cc = 1:c.NumTestSets
                testsetlog(:,cc) = testsets == cc; 
                trainsetlog(:,cc) = testsets ~= cc; 
            end
            
            for cc = 1:c.NumTestSets
                %% extract some features
                % 1. rawdata = Raw Data
                % 2. fddata  = Freq Domain data at 1 hz resolution
                % 3. bpbeta  = 13 - 30 band passed data
                % 4. betaenv = envelope of beta
                % 5. bpgama  = 31 - 60 band passed gama
                % 6. gamaenv = 31 - 60 band passed gama envelope
                % 7. spectrogram in 5-60 range
                
                % 2. fddata  = Freq Domain data at 1 hz resolution
                % trim data so it outputs same number of freq output
                
                NFFT = 512;
                segLength = 1024;
                
                rawdata(cc).train = data_no_out(trainsetlog(:,cc));
                rawdata(cc).test  = data_no_out(testsetlog(:,cc));
                [dataout(cc).train(cntdat,:),freq] = pwelch(rawdata(cc).train,segLength,NFFT,1:2:400,params.sr,'psd');
                [dataout(cc).test(cntdat,:),freq] = pwelch(rawdata(cc).test,segLength,NFFT,1:2:400,params.sr,'psd');
                if sum(dataout(cc).train(cntdat,:)) == 0 
                    x = 2; 
                end
                
            end
            clear cvec c testsetlog trainsetlog testsets
            mlrow(cntdat,:) = newdb(i,:); 
            cntdat = cntdat + 1; 

            figname = sprintf('%0.3d_%s_p-%s_v-%s_stim-%s_serial-%d',...
                i,...
                labelarea{cu},...
                newdb.patientcode{i},...
                newdb.visitCategory{i},...
                newdb.StimOn{i},...
                newdb.sessionSerialNum(i));
        end
        fprintf('%d out of %d done in %f\t %f to go\n',...
            i,...
            size(newdb,1),...
            toc(ticOpen),... 
            toc(ticOpen) * (size(newdb,1) - i));
    end
end
save('temp_ml_ds.mat','dataout','mlrow'); 

%% classify stim on / stim off 
% try to balance the classifier 
unqelec = unique(mlrow.stn_electrodes);
for i = 1:length(unqelec)
    ucnt(i) = sum(strcmp(mlrow.stn_electrodes,unqelec{i}));
end
max(ucnt)
% loop on visits 
unqvisits = unique(mlrow.visitCategory); 
for v = 1:length(unqvisits)
    logvis = strcmp(unqvisits,
    
end

fprintf('%d stim off, %d stim on\n',...
    sum(logical(strcmp(mlrow.StimOn,'on'))),...
    sum(logical(strcmp(mlrow.StimOn,'off'))));

fprintf('%d meds on, %d meds off\n',...
    sum(logical(strcmp(mlrow.Medication,'on'))),...
    sum(logical(strcmp(mlrow.Medication,'off'))));

% get labels 
for i = 1:params.cvfold
    labels = strcmp(mlrow.StimOn,'on');
    model = svmtrain(double(labels),dataout(i).train, '-t 0' );
    [predicted_label, accuracy, third] = svmpredict(double(labels), dataout(i).test, model);
    acc(i) = accuracy(1);  
end

labels = strcmp(mlrow.Medication,'on');

for i = 1:params.cvfold
    labels = strcmp(mlrow.Medication,'on');
    model = svmtrain(double(labels),dataout(i).train, '-t 0' );
    [predicted_label, accuracy, third] = svmpredict(double(labels), dataout(i).test, model);
    acc(i) = accuracy(1);  
end

end