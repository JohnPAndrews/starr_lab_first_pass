function showBetaVariability()
load /Users/roee/Starr_Lab_Folder/Data_Analysis/First_Pass_Data_Analysis/data/database/predictors.mat
pdcts = struct2table(sout);
pat = unique(pdcts.patient);
task = unique(pdcts.task);
tasksuse = {'rest','ipad','walking'};

freqs = {'Beta','LowBeta','HighBeta'};
avgType = {'avg','max','avgnorm','maxnorm'};
areas = {'ecog','lfp'};
meds = {'' '~'};
stims= {'' '~'};
mrktsk   = {'o','^','s'};
cmed     = [0 0.9 0; 0.9 0 0];
stimc    = [0.5 0.5 0.5; 0 0 0];
linw     = [4, 0.5];
visits = unique(pdcts.visit);
visitsord = [4 3 8 1 5 7 9 2 6];
visitlbls = visits(visitsord);
avgs  = {};
for aa = 1:length(avgType)
    for f = 1:length(freqs)
        for a = 1:length(areas)
            hfig = figure('Position',[720         371        1521         972]);
            for p = 1:length(pat)
                hsub = subplot(3,3,p);
                for t = 1:length(tasksuse)
                    for v = 1:length(visitlbls)
                        for m = 1:2
                            for s = 1:2
                                idxchoose = strcmp(pdcts.patient,pat{p}) & strcmp(pdcts.task,tasksuse{t});
                                elecs     = pdcts.([areas{a} '_elec'])(idxchoose);
                                [unique_strings, ~, string_map]=unique(elecs);
                                most_common_elec = unique_strings(mode(string_map));
                                idxelec   = strcmp(pdcts.([areas{a} '_elec']),most_common_elec);
                                idxvisit  = strcmp(pdcts.visit,visitlbls{v});
                                idxmed    = eval(sprintf('%s%s',meds{m},'pdcts.med'));
                                idxstm    = eval(sprintf('%s%s',stims{s},'pdcts.stim'));
                                idxuse = idxchoose & idxelec & idxvisit & idxmed & idxstm;
                                if sum(idxuse) ~=0
                                    fieldstr = sprintf('%s%s%s',areas{a},avgType{aa},freqs{f});
                                    vals = eval(sprintf('pdcts.%s(idxuse)',fieldstr));
                                    hs = scatter(repmat(v,length(vals),1),vals);
                                    hs.Marker = mrktsk{t};
                                    hs.MarkerFaceColor = cmed(m,:);
                                    hs.MarkerFaceAlpha = 0.6;
                                    hs.MarkerEdgeColor = stimc(s,:);
                                    hs.MarkerEdgeAlpha = 0.6;
                                    hs.LineWidth       = linw(s);
                                    hs.SizeData = 200;
                                    hold on;
                                    x = 2;
                                end
                            end
                        end
                    end
                end
                fprintf('\n');
                hsub.XLim = [0 10];
                hsub.XTick = [0:1:10];
                hsub.XTickLabel = [' '; visitlbls; ' '];
                hsub.XTickLabelRotation = 45;
                ttlstr = sprintf('%s %s %s %s',pat{p},areas{a},avgType{aa},freqs{f});
                title(ttlstr);
                ylabel('Voltage');
            end
            fprintf('\n\n');
        end
    end
end

%                         fprintf('area %s pat %s task %s -M-S %d -M+S %d +M+S %d +M-S %d \n',areas{a},  pat{p},tasksuse{t},...
%                             sum(idxuse & ~pdcts.med & ~pdcts.stim),...
%                             sum(idxuse & ~pdcts.med & pdcts.stim),...
%                             sum(idxuse & pdcts.med & pdcts.stim),...
%                             sum(idxuse & pdcts.med & ~pdcts.stim));

end