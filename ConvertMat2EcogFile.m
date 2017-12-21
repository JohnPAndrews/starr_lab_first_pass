function ConvertMat2EcogFile(EcogFileName)
%% This program convert Neuoro Omega files to LFP files 
% define structures
params.lfp_module  = 4;
params.lfp_num     = 4;
params.lfp_first   = 1;

params.emg_module  = 3;
params.emg_num     = 4;
params.emg_first   = 1;

params.aux_module  = 0;
params.aux_num     = 3;
params.aux_first   = 1;

params.ecog_module  = 1;
params.ecog_num    = 4;
params.ecog_first   = 1;
params.raw2_rec_on_module2=1; % raw 1 and 2 recorded on different modules

params.raw1_module = 1;
params.raw2_module = 2;

%% data types 
dtypes = {'lfp','emg','aux', 'ecog'}; 

%% loop on data types and load data: 
for dt = 1:length(dtypes)
    eval(dtypes{dt}) = loadData(params,dtypes{dt},EcogFileName); 
end


save(name,'ecog','lfp','aux','emg','name')

end 

function dat = loadData(params,dtype,EcogFileName)
load(EcogFileName); 
module     = params.([dtype '_module']);
num_chan   = params.([dtype '_num']);
first_chan = params.([dtype '_first']);
for chidx = 1:num_chan
    fnm = sprintf('CECOG_%d___%0.2d___Array_%d___%0.2d',...
        module,chidx, module, chidx);
    srfnm = sprintf('CECOG_%d___%d___Array_%d___%d_KHz*1000',...
        module,chidx,module,chidx);
    if exist(fnm,'var')
        dat.chan(chidx).raw_signal = double(eval(fnm));
        dat.Fs(chidx) = eval(srfnm);
    else
        dat.chan(chidx).raw_signal = double(eval(fnm));
        dat.Fs(chidx) = eval(srfnm);
    end
end

end
