function cleanUncleanCorrSensors(pathOut,ID ,eeglabChans, timePoints, Orig_meanTrials, correctedConds, correctedCondsNames, tepConds, peakWindNames)

% The temporal correlations between uncorrected and corrected TEPs at scalp level
% 1 - Calculates the temporal correlations between uncorrected and corrected TEPs at each individualized time range(early: from baseline to the time of P60; mid = from time of P60 to N180 and late = from P180 to N280). Peaks are individualizes.
% 2 - Transforms rho values to Z (Fisher's)
% 3 - Calculates the avrerage of z

% Mana Biabani, Monash University
% Nigel Rogasch, Monash University

    for filtConds = 1:length(correctedConds)
        
        for t = 1:length(peakWindNames)
            timeWind = [];
            
            for j = 1:length(eeglabChans)
                
                for idx = 1:length(ID)
                    
                    timeWind = (timePoints(idx,t):timePoints(idx,t+1));
                    [Orig_filt_TEP_temp_Corr.(correctedCondsNames{filtConds}).(peakWindNames{t}).(tepConds)(j,idx), pval_Orig_filt_TEP_temp_Corr.(correctedCondsNames{filtConds}).(peakWindNames{t}).tepConds(j,idx)] =...;
                        corr(squeeze(Orig_meanTrials(j,idx,timeWind)),squeeze(correctedConds{filtConds}(j,idx,timeWind)),'type','Spearman');
                    r = Orig_filt_TEP_temp_Corr.(correctedCondsNames{filtConds}).(peakWindNames{t}).(tepConds)(j,idx);
                    
                    % Fisher's r to z transformation
                    fisherZ_Orig_filt_TEP_temp_Corr.(correctedCondsNames{filtConds}).(peakWindNames{t}).(tepConds)(j,idx)=.5.*log((1+r)./(1-r));
                    FisherZCorr(j,idx) = fisherZ_Orig_filt_TEP_temp_Corr.(correctedCondsNames{filtConds}).(peakWindNames{t}).(tepConds)(j,idx);
                    
                    % Fisher's z to r tranformation for each individual
                    rFromZ_Orig_filt_TEP_temp_Corr.(correctedCondsNames{filtConds}).(peakWindNames{t}).(tepConds)(j,idx) = (exp(1).^(2.*FisherZCorr(j,idx))-1)./(exp(1).^(2.*FisherZCorr(j,idx))+1);
                    r = [];
                end
                
                % One sample permutaion test for each window of time and each channel across subjects
                Pval_oneSample_Orig_filt_TEP_Corr.(correctedCondsNames{filtConds}).(peakWindNames{t}).(tepConds)(j) = mult_comp_perm_t1(FisherZCorr(j,:)',10000,1);
            end
            
            % Average of z scores across subjects
            avZ_Orig_filt_TEP_temp_Corr.(correctedCondsNames{filtConds}).(peakWindNames{t}).(tepConds)= mean(FisherZCorr,2);
            FisherAvZCorr =  avZ_Orig_filt_TEP_temp_Corr.(correctedCondsNames{filtConds}).(peakWindNames{t}).(tepConds);
            
            % Fisher's z to r tranformation for mean values
            rFromZ_Av_Orig_filt_TEP_temp_Corr.(correctedCondsNames{filtConds}).(peakWindNames{t}).(tepConds) = (exp(1).^(2.*FisherAvZCorr)-1)./(exp(1).^(2.* FisherAvZCorr)+1);
            
        end
        
    end

save([pathOut, 'cleanUncleanCorr_sensorLevel_',tepConds],'Orig_filt_TEP_temp_Corr','fisherZ_Orig_filt_TEP_temp_Corr','rFromZ_Orig_filt_TEP_temp_Corr','Pval_oneSample_Orig_filt_TEP_Corr','avZ_Orig_filt_TEP_temp_Corr','rFromZ_Av_Orig_filt_TEP_temp_Corr');
end