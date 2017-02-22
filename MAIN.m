function MAIN()
%% This function attempts a bare bones analysis of Ryder data
clc; close all; 
addpath(genpath(pwd)); 
[settings, params] = get_settings_params(); 
visits             = findData(settings,params);
analyzeData(visits,settings,params); % compute some initial measures on the data 
end 