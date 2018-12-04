function tepSep_spatialCorr (pathOut,ID ,condition, meanTrials)

% SEPs-TEPs spatial correlation and confidence interval calculations (using Fisher's transformation)
% Mana Biabani, Monash University 
% Nigel Rogasch, Monash University

%------------------------------------ Spatial correlations -----------------------------------------  
% Preallocate variables
EachSubj_timepoint_conds_spearman = cell(length(condition),length(condition));
EachSubj_timepoint_conds_Pval_spearman = cell(length(condition),length(condition));
EachSubj_timepoint_conds_pearson = cell(length(condition),length(condition));
EachSubj_timepoint_conds_Pval_pearson = cell(length(condition),length(condition));

for condA = 1:length(condition)
    
    for condB = 1:length(condition)
        
        for idx= 1:length(ID)
            e = cell2mat(meanTrials{condA}(idx));
            f = cell2mat(meanTrials{condB} (idx));
            
            for t = 1: length(e)
                [EachSubj_timepoint_conds_spearman{condA,condB}(idx,t), EachSubj_timepoint_conds_Pval_spearman{condA,condB}(idx,t)] = corr(e(:,t),f(:,t),'type','Spearman');
            end
            
        end
        
    end
    
end


%------------------------------ Fisher's transformation for averaging and CI -----------------------

% Spatial correlation data (Select the spatial correlations between control and each TEP condition)
data = cell(length(condition)-1,1);

for i = 2:length(condition)
    data(i-1,:) = {EachSubj_timepoint_conds_spearman{1,i}};
end

% Fisher transformation of r values and calculate Confidence intervals of correlations across subjects
for conds = 1:length(data)

    for t = 1:length(data{1})

        for idx = 1:length(ID)
            r =[];
            r{conds}(idx,t)= data{conds}(idx,t);

            % Fisher's r to z transformation
            z{conds}(idx,t)=.5.*log((1+r{conds}(idx,t))./(1-r{conds}(idx,t)));
        end

        % CI of z scores
        CI{conds}(:,t)= confidence_intervals(z{conds}(:,t),95);

        % Average of z scores
        avZ{conds}(t) = mean(z{conds}(:,t),1);

        % Fisher's z to r tranformation
        rFromZ{conds}(t) = (exp(1)^(2.*avZ{conds}(t))-1)/(exp(1)^(2.* avZ{conds}(t))+1);

        % Fisher's z to r tranformation for CI
        rCIrFromZ{conds}(1,t) = (exp(1)^(2.*CI{conds}(1,t))-1)/(exp(1)^(2.* CI{conds}(1,t))+1);
        rCIrFromZ{conds}(2,t) =(exp(1)^(2.*CI{conds}(2,t))-1)/(exp(1)^(2.* CI{conds}(2,t))+1);
    end

end

% Save
save([pathOut, 'tepSepSpatialCorr']);
end

