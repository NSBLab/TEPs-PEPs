function tepSep_TemporalCorr (pathOut,ID ,condition, meanTrials, eeglabChans, indivPeaks,preTr,postInterpol,winds)

% Confidence intervals of SEPs-TEPs spatial correlation (using Fisher's transformation)
% Mana Biabani, Monash University 
% Nigel Rogasch, Monash University

% Preallocate variables
EachSubj_spearman_early = cell(length(condition)-1);
EachSubj_Pval_spearman_early = cell(length(condition)-1);
EachSubj_spearman_mid = cell(length(condition)-1);
EachSubj_Pval_spearman_mid = cell(length(condition)-1);
EachSubj_spearman_late = cell(length(condition)-1);
EachSubj_Pval_spearman_late = cell(length(condition)-1);

for conds = 2:length(condition)
    peakT = indivPeaks{conds-1}(:,winds);
    
%------------------------------------ Temporal correlations ---------------------------------------- 

    for idx= 1:length(ID)
        % Correlation across conditions for Each electrode each subject(at the individualized intervals based on individuals' peaks)
        a = cell2mat(meanTrials{1}(idx));
        b = cell2mat(meanTrials{conds}(idx));
        t1 = preTr+peakT(idx,1);
        t2 = preTr+peakT(idx,2);
        t3 = preTr+peakT(idx,3);
        for j = 1:length(eeglabChans)
            [EachSubj_spearman_early{conds-1}(j,idx), EachSubj_Pval_spearman_early{conds-1}(j,idx)] = corr(a(j,preTr+postInterpol:t1)',b(j,preTr+postInterpol:t1)','type','Spearman');%excluding 20ms post trigger time
            [EachSubj_spearman_mid{conds-1}(j,idx), EachSubj_Pval_spearman_mid{conds-1}(j,idx)] = corr(a(j,t1:t2)',b(j,t1:t2)','type','Spearman');
            [EachSubj_spearman_late{conds-1}(j,idx), EachSubj_Pval_spearman_late{conds-1}(j,idx)] = corr(a(j,t2:t3)',b(j,t2:t3)','type','Spearman');
        end
    end
    
% -------------------- Fisher's transformation for averaging and t-Tests ---------------------------

    % Fisher's r to z transformation
    zEarly{conds-1} = .5.*log((1+EachSubj_spearman_early{conds-1})./(1-EachSubj_spearman_early{conds-1}));
    zMid{conds-1} = .5.*log((1+EachSubj_spearman_mid{conds-1})./(1-EachSubj_spearman_mid{conds-1}));
    zLate{conds-1} = .5.*log((1+EachSubj_spearman_late{conds-1})./(1-EachSubj_spearman_late{conds-1}));
    
    %  Meansubjects from z
    meanzEarly{conds-1} = mean(zEarly{conds-1},2) ;
    meanzMid{conds-1} = mean(zMid{conds-1},2);
    meanzLate{conds-1} = mean(zLate{conds-1},2) ;
    
    % Transform meansubjects' z back to r for plotting
    for j = 1:length(eeglabChans)
        rmeanzEarly{conds-1}(j,1) = (exp(1)^(2.*meanzEarly{conds-1}(j))-1)/(exp(1)^(2.*meanzEarly{conds-1}(j))+1);
        rmeanzMid{conds-1}(j,1) = (exp(1)^(2.*meanzMid{conds-1}(j))-1)/(exp(1)^(2.*meanzMid{conds-1}(j))+1);
        rmeanzLate{conds-1}(j,1) = (exp(1)^(2.*meanzLate{conds-1}(j))-1)/(exp(1)^(2.*meanzLate{conds-1}(j))+1);
    end
    
    % Reorder subjects and variables for the permutation test (observation x variable)
    zEarlyTtest{conds-1} = (zEarly{conds-1})';
    zMidTtest{conds-1} = (zMid{conds-1})';
    zLateTtest{conds-1} = (zLate{conds-1})';
    
    % One sample permutaion test
    [pvalEarly{conds-1}] = mult_comp_perm_t1(zEarlyTtest{conds-1},10000,1);
    [pvalMid{conds-1}] = mult_comp_perm_t1(zMidTtest{conds-1},10000,1);
    [pvalLate{conds-1}] = mult_comp_perm_t1(zLateTtest{conds-1},10000,1);
end

% save
save([pathOut, 'tepSepTemporalCorr']);
end