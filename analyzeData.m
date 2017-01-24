function analyzeData(visits,settings,params)
%% this function computes some basic measures on a single visit (for a start) 
for v = 1:length(visits) % loop on visits
    for s = 1:length(visits(v)) % loop on sessions 
        plotInitialDataMeasures(visits(v).sessions(s),settings,params); 
    end
end

end 