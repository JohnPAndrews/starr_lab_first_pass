function MAIN_plot_data_from_results_files()
% choose parent dir
% relies on output of this code:
% MAIN_plot_visit_quick_figures
% and sub functions from above code
% organize_brain_radio_data()
% get_idxs_brain_radio_clean_data()
% save_brain_radio_results() % no plotting
% run in that order

% takes a bunch of brain radio data and plots this for interactive viewing

%% concatenat all results files - get data
fprintf('choose patient directory\n');
datadir = uigetdir('choose data dir');
rfs = findFilesBVQX(datadir,'resultsBR.mat');
for rf = 1:length(rfs)
    load(rfs{rf});
    if rf ==1
        resTabAll = resTab;
    else
        resTabAll = [resTabAll; resTab];
    end
end
%% set up figure controls
hFig = figure ( 'windowstyle', 'normal',...
    'units','normalized');
hax1 = subplot(1,2,1);
hax2 = subplot(1,2,2);

%% plot data 
areas = {'lfp','ecog'}; 
for a = 1:2
    for s = 1:size(resTabAll,1)
        hax = subplot(1,2,a);
        psd = eval(sprintf('resTabAll.psd%s{s}',areas{a}));
        f   = eval(sprintf('resTabAll.psd%sF{s}',areas{a}));
        hlns(s,a) = line(f, log10(psd),...
            'ButtonDownFcn',@MouseDown);
        dat = resTabAll(s,{'visit','task','sessionum','med','stim','duration','sr','ecog_elec','lfp_elec','time'});
        legstr{s} = sprintf('%s T-%s %s M %s S %s',...
            dat.visit{1},...
            dat.task{1}(1:2),...
            char((dat.med)*'on ' + ~(dat.med)*'off'),...
            char((dat.stim)*'on ' + ~(dat.stim)*'off'),...
            dat.ecog_elec{1});
        dat.legstr = legstr{s};
        dat.hax = eval(sprintf('hax%d',a));
        hlns(s,a).UserData = dat;
        hlns(s,a).Visible = 'off';
    end
end

% linkaxes([hax1 hax2],'x');
formatLines(hlns) % format the lines 
resetHandles(hlns,resTabAll,legstr) % select what to show 
dat.hlns = hlns;
dat.resTabAll = hlns;
dat.resTabAll = legstr;
hFig.UserData = dat;
end


function resetHandles(hlns,resTabAll,legstr)% reset handles
for s = 1:size(hlns,1)
    hlns(s).Visible = 'off';
end

taskuse = {'rest','ipad','walking'};
taskuse = {'rest'};
% taskuse = {'home-recording'};
% taskuse = {'rest'};
medstat = [1 0]; % on /off
medstat = [1 ]; % on /off
stimsta = [1 0];
stimsta = [ 0];
visuse  = {'2 day' '10 day'  '3 week' '1 month'};
visuse  = { '2 day' '10 day'  '3 week' '1 month'};

% get idixes lit up
idxkeep = logical(zeros(size(resTabAll,1),1));
for t = 1:length(taskuse)
    for v = 1:length(visuse)
        for m = 1:length(medstat)
            for s = 1:length(stimsta)
                idxuse = strcmp(resTabAll.task,taskuse(t)) & ...
                    strcmp(resTabAll.visit, visuse{v} ) & ...
                    resTabAll.med == medstat(m) & ...
                    resTabAll.stim == stimsta(s) ;
                idxkeep = idxkeep | idxuse ;
            end
        end
    end
end

idxset = find(idxkeep==1);
for x = 1:length(idxset)
    for a= 1:2
        hlns(idxset(x),a).Visible = 'on';
    end
end
legend(hlns(idxset,1),legstr(idxset));
legend(hlns(idxset,2),legstr(idxset));
end

function formatLines(hlns)
for h = 1:length(hlns)
    for a = 1:2
    hlns(h,a).LineWidth = 2; 
    if hlns(h,a).UserData.med
        hlns(h,a).Color = [0 0.9 0 0.7];
    else
        hlns(h,a).Color = [0.9  0 0 0.8];
    end
    if hlns(h,a).UserData.stim
        hlns(h,a).LineStyle = '-.';
    end
    end
end
end

function MouseDown(gcbo,event)
dat = get(gcbo,'UserData');
fprintf('%s \n %s\n',dat.legstr, dat.time{1});
end

