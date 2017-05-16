Analyze iPad movement functions from Nicki 
==========================

Introduction: 
-------------

This is code to analyze movement shared from Nicki 

Important functions to take note of: 

There are two sections here, the first has to do with importing EEG data (which has EMG, 
AUX etc.) 
The second involves syncing this with the brain radio data. 

First run these 3 functions 
* `convert_data_with_EEG_current()` - This converts BDF to mat format 	 
* `synchronization_rubric_different_sample_rates_current_shorten()` - Sync the EMG to brain radio data 
* `find_beeps_and_movement_times_share()` - Find the movement onsets 


Then, the rest of the scripts (add detail) average the data into spectrograms 