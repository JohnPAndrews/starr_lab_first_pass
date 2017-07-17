function MAIN_machine_learning_evals()
%% This function plots machine learning (models (AUC) resposned
% Its aim is to create summery graphs of the various subjects
[settings, params] = get_settings_params();
resultsdir = fullfile(settings.resdir,'mat_file_with_all_session_jsons');
load(fullfile(resultsdir,'all_session_celldb.mat'),'outdb','sessiondb','symptomcat');
% addpath(genpath('/Users/roee/Starr_Lab_Folder/Data_Analysis/First_Pass_Data_Analysis/code/from_andy/eeglab14_1_0b'));
patexist = unique(sessiondb.patientcode);
%% set params
params.fontsize                   = 12;
%% loop on subjects (faster to parpool for loading and saving
% p = parpool('mac');
patexist = ...
    {   'brpd_01'
    'brpd_03'
    'brpd_05'
    'brpd_06'
    'brpd_07'
    'brpd_09'
    };
freqsuse = { 'Delta'    'Theta' 'Alpha'...
    'LowBeta' 'HighBeta' 'Beta' ...
    'LowGamma'    'HighGamma'};

freqsuse = { 'Beta' ...
 };

varuseshell = {
    '%s_coh_mag_lin'
    '%s_coh_phase_lin'
    'm1_%s_avg'
    'm1_%s_max'
    'stn_%s_avg'
    'stn_%s_max'
    };

% varuseshell = {
%     'stn_%s_avg'
%     'm1_%s_avg'
%     };
comparisons = {'Medication','Med On/Off','on','off';...
    'StimOn','Stim On/Off','on','off';...
    'ConditionTask','rest / ipad','rest','ipad';...
    'ConditionTask','rest / walking','rest','walking';...
    'ConditionTask','walking / ipad','walking','ipad';...
    'sessionSerialNum','odd / even','odd','even'};

comparisons = {
    'ConditionTask','walking / ipad','walking','ipad';...
    };

%% add a pure chance condition 
for p = 1:length(patexist)
    params.patuse      = patexist{p};
    fnmsave = sprintf('pP-%s_db.mat',params.patuse);
    load(fullfile(resultsdir,fnmsave),'brdb');
    fprintf('%s \n\n',params.patuse);
    %% roc example
    % take sub samples of table
    %         loguse = strcmp(brdb.StimOn,'off');
    % choose what variables to incldue
    
    
    %     varuseshell = {
    %         'm1_%s_avg'
    %         'stn_%s_avg'
    %         'm1_%s_max'
    %         'stn_%s_max'
    %         };
    for c = 1:length(comparisons)  % last compariosn is chance , hard coded 
        for f = 1:length(freqsuse)
            varuse = {};
            for v = 1:length(varuseshell)
                varuse{v} = sprintf(varuseshell{v},freqsuse{f});
            end
            
            
            %         varuse = {
            %             'stn_Beta_avg'
            %             };
            % extract data from table in double format
            predraw = [] ;
            for v = 1:length(varuse)
                tmp = brdb{:,varuse{v}};
                for r = 1:length(tmp)
                    if iscell(tmp(r))
                        if isempty(tmp{r} )
                            predraw(r,v) = NaN;
                        else
                            predraw(r,v) = tmp{r};
                        end
                    else
                        predraw(r,v) = tmp(r);
                    end
                end
            end
            % data validation 
            loguse = sum(isnan(predraw),2) ==  0; 
            
            %         figure;scatter(pred(resp,1),pred(resp,2)); hold on; scatter(pred(~resp,1),pred(~resp,2));
            % labels
            %% XX add code to choose responses + add a logical conditions case 
            %% add code to display in title % positive classees 
            % get respone column 
            rawresp = brdb.(comparisons{c,1});
            outstr = {}; 
            if c == 6 
                temp = logical(mod(rawresp,2));
                for t = 1:length(temp)
                    if temp(t)
                        outstr{t,1} = 'even';
                    else
                        outstr{t,1} = 'odd';
                    end
                end
                rawresp = outstr; 
            end
            pos = strcmp(rawresp, comparisons{c,3}); 
            neg = strcmp(rawresp, comparisons{c,4}); 
            logresp = pos | neg; 
            loguseidx = loguse & logresp; 
            pred = predraw(loguseidx,:);
            % change negative to negative 
            resp = pos(loguseidx);
%             resp = strcmp(brdb.Medication(loguse),'on');
            mdl = fitglm(pred,resp,'Distribution','binomial','Link','logit');
            scores = mdl.Fitted.Probability;
            [X,Y,T,AUC] = perfcurve(resp,scores,1);
                    hfig = figure;
                    plot(X,Y)
                    xlabel('False positive rate')
                    ylabel('True positive rate')
                    title('ROC for Classification by Logistic Regression')
%             logistic regression
            mdl = fitglm(pred,resp,'Distribution','binomial','Link','logit');
            score_log = mdl.Fitted.Probability; % Probability estimates
            [Xlog,Ylog,Tlog,AUClog] = perfcurve(resp,score_log,'true');
            %svm
            mdlSVM = fitcsvm(pred,resp,'Standardize',true);
            [~,score_svm] = resubPredict(mdlSVM);
            [Xsvm,Ysvm,Tsvm,AUCsvm] = perfcurve(resp,score_svm(:,mdlSVM.ClassNames),'true');
            % naive baise
            mdlNB = fitcnb(pred,resp);
            [~,score_nb] = resubPredict(mdlNB);
            [Xnb,Ynb,Tnb,AUCnb] = perfcurve(resp,score_nb(:,mdlNB.ClassNames),'true');
                    hfig2 = figure;
                    plot(Xlog,Ylog)
                    hold on
                    plot(Xsvm,Ysvm)
                    plot(Xnb,Ynb)
                    legend('Logistic Regression','Support Vector Machines','Naive Bayes','Location','Best')
                    xlabel('False positive rate'); ylabel('True positive rate');
                    title('ROC Curves for Logistic Regression, SVM, and Naive Bayes Classification')
            fprintf('AUC %s - log - %f svm %f - nb - %f\n',...
                freqsuse{f}, AUClog , AUCsvm, AUCnb);
            auclog(f,c,p) = AUClog;
            aucsvm(f,c,p) = AUClog;
            aucnb(f,c,p) = AUClog;
            ratios(c,p) = sum(resp)/length(resp);
            datasize(c,p) = length(resp);
        end
    end
end



patexist = ...
    {   'brpd_01'
    'brpd_03'
    'brpd_05'
    'brpd_06'
    'brpd_07'
    'brpd_09'
    };
for p =  1:size(auclog,3) % loop on patients 
    hfig = figure;
    hfig.Position = [375         640        1233         698]; 
    cntplt = 1;
    for c = 1:size(auclog,2) % loop on conditions
        subplot(2,3,cntplt);cntplt = cntplt +1;
        hbar = bar(auclog(:,c,p));
        ylim([0.5 1]); 
        ttltext = sprintf('%s (%0.2f)',...
            comparisons{c,2},ratios(c,p));
        title(ttltext);
        set(gca,'XTickLabel',...
            freqsuse);
        set(gca,'XTickLabelRotation',45);
        ylabel('AUC'); 
    end
    spttl = sprintf('%s Log. Reg',...
        strrep(patexist{p},'_',' '));
    suptitle(spttl);
    figdir = fullfile('..','figures','beta_over_time',patexist{p});
    mkdir(figdir);
    %% save figure
    %         hfig.PaperOrientation = 'landscape';
    figname = sprintf('%s AUClog ',...
        patexist{p} );
  
    hfig.PaperPositionMode = 'manual'; 
    hfig.PaperSize = [  16 8.5];
    hfig.PaperPosition = [ 0 0 16 8.5];
    save_figure(hfig,figname,figdir, 'pdf');
    close(hfig);

end
% delete(p);

%% plot predictors 
figure;
scatter3(pred(resp,1),pred(resp,2), pred(resp,3));
hold on;
scatter3(pred(~resp,1),pred(~resp,2), pred(~resp,3));
xlabel('coh mag');
ylabel('coh phase');
zlabel('m1 avg');
scatter(pred(~resp,1),pred(~resp,2),'r');
end