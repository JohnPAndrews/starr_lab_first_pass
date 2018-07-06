function plot_brpd10_montage_counting()
load /Users/roee/Starr_Lab_Folder/Data_Analysis/Raw_Data/BR_reorg_manual/brpd_10/v09_extra_visit/data/results/resultsBR.mat
idxuse = cellfun(@(x) strcmp(x,'montage'),resTab.task); 
resTab = resTab(idxuse,:);
resTabRest = resTab(resTab.sessionum ==6,:);
resTabCont = resTab(resTab.sessionum ==7,:);

xaxfnms = {'psdlfpF', 'psdecogF', 'coherfreq'};
yaxfnms = {'psdlfp','psdecog','cpherpower'};
elcfnms = {'lfp_elec', 'ecog_elec','ecog_elec'};
axuse   = {1 , 2, 3:4};
uselog = 1;
orderlog = 5;
for i = 1:6
    figure('Position',[539         319        1481         851]);
    for a = 1:3
        subplot(2,2,axuse{a});
        hold on;
        %% rest
        f   = eval(sprintf('resTabRest.%s{i}',xaxfnms{a}));
        if a<3
            psd = log10(eval(sprintf('resTabRest.%s{i}',yaxfnms{a})));
        else
             psd = eval(sprintf('resTabRest.%s{i}',yaxfnms{a}));
        end
        if uselog
        f = log10(f);
        end
        hln = line(f,psd);
        hln.Color = [0 1 0.2 0.7];
        hln.LineWidth = 2; 

        str1 = sprintf('%s %s',...
            'rest',...
            eval(sprintf('resTabRest.%s{i}',elcfnms{a})));
        
        %% fit polynomial
        if ~uselog
            idxuse = logical(f>10 & f<100);
        else
            idxuse = logical(ones(length(f),1)');
        end
        p = polyfit(f(idxuse),psd(idxuse),orderlog);
        f1 = polyval(p,f(idxuse));
        hln = line(f(idxuse),f1);
        hln.Color = [0 1 0.2 0.3];
        hln.LineWidth = 4; 

        %% counting back 
        f   = eval(sprintf('resTabCont.%s{i}',xaxfnms{a}));
        if a < 3
            psd = log10(eval(sprintf('resTabCont.%s{i}',yaxfnms{a})));
        else
            psd = eval(sprintf('resTabCont.%s{i}',yaxfnms{a}));
        end
        if uselog
        f = log10(f);
        end
        hln = line(f,psd);
        hln.Color = [0 0.2 1 0.7];
        hln.LineWidth = 2; 
        
        str2 = sprintf('%s %s',...
            'counting',...
            eval(sprintf('resTabCont.%s{i}',elcfnms{a})));
        
        %% fit polynomial
        if ~uselog
            idxuse = logical(f>10 & f<100);
        else
            idxuse = logical(ones(length(f),1)');
        end
        p = polyfit(f(idxuse),psd(idxuse),orderlog);
        f1 = polyval(p,f(idxuse));
        hln = line(f(idxuse),f1);
        hln.Color = [0 0.2 1 0.4];
        hln.LineWidth = 4; 
        
        %% set legends and limits 
        legend({str1 str2});
        if uselog
            xlim([0 2]);
        else
            xlim([2 100]);
        end
        if a==3 
            ylim([0 1]);
        end
    end
end

