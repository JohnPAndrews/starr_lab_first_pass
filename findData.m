function visit = findData(settings,params)
%% This function finds data from one patient 
% defintions: 
% a visit consist of a single day of recording on a particular day 
% a session is one recording session within a visit 
% step 1: loop on vists and find data 
visit = struct(); 
for v = 1%:length(settings.visits)
    visit(v).sessions = getSesssions(settings,v); 
end

end