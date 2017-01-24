function [settings, params] = get_settings_params()
% settings define data locations for input and output 
% params define params for data analysis 
%% params 
params.cond2analyze    = 'rest'; % condition to analyze 
params.channel2anlyze  = 1; 

% preproces settings 
params.lowcutoff       = 1; 
params.highcutoff      = 800; 
params.msec2trim       = 5000; %trim first x msec of raw data file 
%% settings 
settings.raw_data_fold = fullfile('..','..','Raw_Data','Ryder'); 
settings.visits        = {'10_day','3_week','1_month','2_month_visit','3_month',...
                          '6_month','1_year_visit','2_year_visit'}; 
settings.figout        = fullfile('..','figures','ryder_first_pass');
settings.figformat     = 'jpeg'; % jpeg pdf tiff                        

end 