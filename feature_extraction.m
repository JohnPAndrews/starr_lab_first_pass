function feature_extraction()
%% The purpose of this function is to extract various features from the data 
%% Each feature will be saved as .mat file with the same name format as .txt file 

%% Feature list 

% Features for each channel 
% 1. rawdata = Raw Data 
% 2. fddata  = Freq Domain data at 1 hz resolution 
% 3. bpbeta  = 13 - 30 band passed data 
% 4. betaenv = envelope of beta 
% 5. bpgama  = 31 - 60 band passed gama 
% 6. gamaenv = 31 - 60 band passed gama envelope 

% Features between brain areas 
% 7. coher    = coherence beteween stn and m1 

%% Inclusion criteria 
% 1. at least 20 second recordings 
% 2. 800 Hz sampling rate 
% 3. recording of stn and m1 exists 

save_raw_data() 
save_freq_domain_data()
save_bp_beta_data()
save_beta_env_data()
save_bp_gama_data() 


rootdir  = '/Users/roee/Starr_Lab_Folder/Data_Analysis/Raw_Data/BR_reorganized';
resultsdir   = fullfile('..','results','mat_file_with_all_session_jsons');

% stnfigStimOn = fullfile(figdir,'stn_stimOn'); mkdir(stnfigStimOn)
% stnfigStimOff = fullfile(figdir,'stn_stimOff');mkdir(stnfigStimOff)
% m1figStimOn = fullfile(figdir,'m1_stimOn'); mkdir(m1figStimOn)
% m1figStimOff = fullfile(figdir,'m1_stimOff');mkdir(m1figStimOff)

[settings, params] = get_settings_params();
load(fullfile(resultsdir,'all_session_celldb.mat'),'outdb','sessiondb','symptomcat');
%% set params.
% inclusion criteria
logidxoverall = ...
    sessiondb.usevisit == 1 & ...
    ~strcmp(sessiondb.visitCategory,'000000') & ...
    logical(strcmp(sessiondb.StimOn,'on') |  strcmp(sessiondb.StimOn,'off') ) & ...
    logical(strcmp(sessiondb.patientcode,'brpd_04')) &  ...
    sessiondb.sr == 800;
newdb = sessiondb(logidxoverall,:);
fprintf('%d stim off, %d stim on\n',...
    sum(logical(strcmp(newdb.StimOn,'on'))),...
    sum(logical(strcmp(newdb.StimOn,'off'))));