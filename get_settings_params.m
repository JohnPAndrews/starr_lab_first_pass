function [settings, params] = get_settings_params()
% settings :define data locations for input and output (file walking) 
% params   :define params for data analysis 

%% params 
params.cond2analyze    = 'rest'; % condition to analyze 
params.channel2anlyze  = 1; 

% preprocess settings 
params.lowcutoff       = 3; 
params.highcutoff      = 800; 
params.msec2trim       = 5000; % trim first x msec of raw data file 
params.minlength       = 1e4; % min file length in msec's 
params.noisefloor      = 100; % noise floor of medtronic system in Htz (disregard above) 


% filters 
params.filterorder     = 3; % order of Butterworth filter 
params.notch_filter    = [60]; % frequencies to notch filter 
params.delta_notch     = 2; % spacing around notch filter to use (e.g. for 60Hz notch between 58-62]; 

% plotting 
params.plottype        = 'pwelch'; % 'reg' - regular fft , 'pwelch' use pwelch methods 

%% settings 
settings.rootdir       = '/Users/roee/Starr_Lab_Folder/Data_Analysis/Raw_Data/BR_reorganized';
% rootdir of raw data, dir under  this is patient dirs 
settings.raw_data_fold = fullfile('..','..','Raw_Data','Ryder'); 
settings.resdir        = fullfile('..','results');
settings.visits        = {'10_day','3_week','1_month','2_month_visit','3_month',...
                          '6_month','1_year_visit','2_year_visit'}; 
settings.figout        = fullfile('..','figures','ryder_first_pass');
settings.figformat     = 'jpeg'; % jpeg pdf tiff                        

end 