% EEGLAB history file generated on the 16-May-2017
% ------------------------------------------------
[ALLEEG, ~, ~, ALLCOM] = eeglab;
EEG = pop_fileio('/Users/roee/Starr_Lab_Folder/Data_Analysis/Raw_Data/BR_raw_data/Ryder/6_month/pdbr03_ipad_ondbs_pre.bdf');
[ALLEEG EEG CURRENTSET] = pop_newset(ALLEEG, EEG, 0,'setname','test','gui','off'); 
eeglab redraw;
