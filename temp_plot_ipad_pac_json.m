function temp_plot_ipad_pac_json()
load('/Users/roee/Starr_Lab_Folder/Data_Analysis/Raw_Data/BR_reorg_manual/brdy_11/v03_10_day/s_017_tsk-ipad/BRRAW_BRDY11_2018_02_01_10_51_41__MR_1.mat');
load('/Users/roee/Starr_Lab_Folder/Data_Analysis/Raw_Data/BR_reorg_manual/brdy_11/v03_10_day/s_017_tsk-ipad/EEGRAW_brdy11 ipad off meds off stim 001.mat');
load('/Users/roee/Starr_Lab_Folder/Data_Analysis/Raw_Data/BR_reorg_manual/brdy_11/v03_10_day/s_017_tsk-ipad/ipad_allign_info.mat');
load('/Users/roee/Starr_Lab_Folder/Data_Analysis/Raw_Data/BR_reorg_manual/brdy_11/v03_10_day/s_017_tsk-ipad/ipad_event_indices_from_json.mat');
idxuse = cellfun(@(x) strcmp(x,'prep_ON'),eventsTable.label);
beepsInIdxs = eventsTable.bridx(idxuse);
beepsInIdxs = beepsInIdxs(~isnan(beepsInIdxs));


params.PhaseFreqVector      = 5:2:50;
params.AmpFreqVector        = 5:4:100;
params.PhaseFreq_BandWidth  = 4;
params.AmpFreq_BandWidth    = 10;
params.computeSurrogates    = 0;
params.numsurrogate         = 100;
params.alphause             = 0.05;
params.plotdata             = 0;
params.useparfor            = 0; % if true, user parfor, requires parallel computing toolbox
params.regionnames = {'GPi','M1'} ;
params.filteruse = 'gaussian'; % 'filterls','fir1', 'gaussian';



sr = 794; 
results = [];
for i = 1:length(beepsInIdxs);
    % hold 
    idx = beepsInIdxs(i)-sr:beepsInIdxs(i); % hold 
    data(1,:) = brraw.ecog(idx); 
    data(2,:) = brraw.lfp(idx); 
     tmp = computePAC(data,sr,params); 
     hold(i,:,:) = tmp(2).Comodulogram;
    % prep 
    idx = beepsInIdxs(i):beepsInIdxs(i)+sr; % prep
    data = []; 
    data(1,:) = brraw.ecog(idx); 
    data(2,:) = brraw.lfp(idx); 
    tmp = computePAC(data,sr,params); 
    prep(i,:,:) = tmp(2).Comodulogram;
    % move 
    
    idx = beepsInIdxs(i)+3000:beepsInIdxs(i)+3000+sr; % move
    data = []; 
    data(1,:) = brraw.ecog(idx); 
    data(2,:) = brraw.lfp(idx); 
    tmp = computePAC(data,sr,params); 
    move(i,:,:) = tmp(2).Comodulogram;
end

    
    AmpFreq_BandWidth = tmp(2).AmpFreq_BandWidth;
    AmpFreqVector = tmp(2).AmpFreqVector;
    PhaseFreq_BandWidth  = tmp(2).PhaseFreq_BandWidth;
    PhaseFreqVector  = tmp(2).PhaseFreqVector;
    ttlAmp = tmp(2).ttlAmp;
    PhaseArea = tmp(2).PhaseArea;

    % hold 
    hfig = figure;
    holdmean = squeeze(mean(hold,1));
    contourf(PhaseFreqVector+PhaseFreq_BandWidth/2,AmpFreqVector+AmpFreq_BandWidth/2,holdmean',30,'lines','none')  % not sig
    title('hold'); 
    
    
    
        hfig = figure;
    contourf(PhaseFreqVector+PhaseFreq_BandWidth/2,AmpFreqVector+AmpFreq_BandWidth/2,tmp(4).Comodulogram',30,'lines','none')  % not sig

    
    % prep 
    hfig = figure;
    prepmean = squeeze(mean(prep,1));
    contourf(PhaseFreqVector+PhaseFreq_BandWidth/2,AmpFreqVector+AmpFreq_BandWidth/2,prepmean',30,'lines','none')  % not sig
    title('prep'); 
    
    
    % hold 
    hfig = figure;
    movemean = squeeze(mean(move,1));
    contourf(PhaseFreqVector+PhaseFreq_BandWidth/2,AmpFreqVector+AmpFreq_BandWidth/2,movemean',30,'lines','none')  % not sig
    title('move'); 

timeparams.start_epoch_at_this_time    = -2000;%-8000; % ms relative to event (before), these are set for whole analysis
timeparams.stop_epoch_at_this_time     =  5000; % ms relative to event (after)
timeparams.start_baseline_at_this_time = -2000;%-6500; % ms relative to event (before), recommend using ~500 ms *note in the msns folder there is a modified version where you can set baseline bounds by trial (good for varible times, ex. SSD)
timeparams.stop_baseline_at_this_time  = 0;%5-6000; % ms relative to event
timeparams.extralines                  = 1; % plot extra line
timeparams.extralinesec                = 3000; % extra line location in seconds
timeparams.analysis                    = 'hold_center';
