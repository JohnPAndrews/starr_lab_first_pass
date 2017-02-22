function MAIN_data_organizer_brain_radio()
%% These set of functions copy raw brain radio data from the server and organize it. 
% The function relies on a mapped network connection to myresearch. '
% As a first step the function will download all the raw data to your
% computer. 
% As a second step, it will organize the data. 

%% params to set: 
% mapped network location of ECOG data 
params.networkdrive = '/Volumes/pstarr_shared/ECOG data';
% location on your computer where you want the data to go: 
params.destinfold  =  '/Users/roee/Starr_Lab_Folder/Data_Analysis/Raw_Data/test_copy_fold';

%% end params to set. 
end