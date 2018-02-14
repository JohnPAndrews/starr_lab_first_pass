function run_data_analysis_server()
if ismac
    rootdir = '/Users/roee/Starr_Lab_Folder/Data_Analysis/Raw_Data/BR_reorg_manual';
elseif ~ismac & isunix
    rootdir = '/home/starr/roee/BR_reorg_manual';
end
ff = findFilesBVQX(rootdir,'dataBR.mat'); 
for f = 1:length(ff)
    plot_data_from_each_session(ff{f});
end

end