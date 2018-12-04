function cleanUncleanCorrSource(pathOut,ID ,vertNum, timePoints, Orig_meanSourceTrials, correctedConds, correctedCondsNames, tepCond, peakWindNames)

% Correlation between clean and original TEPs at the selected timewindows (sensor level)
% Mana Biabani, Monash University

for filtConds = 1:length(correctedConds)
     
        for t = 1:length(peakWindNames)
             timeWind = [];
             
            for idx= 1:length(ID)
                 timeWind = (timePoints(idx,t):timePoints(idx,t+1));

                for j = 1:vertNum
                    [Orig_filt_TEP_temp_Corr.(correctedCondsNames{filtConds}).(peakWindNames{t}).(tepCond)(j,idx), pval_Orig_filt_TEP_temp_Corr.(correctedCondsNames{filtConds}).(peakWindNames{t}).(tepCond)(j,idx)] =...;
                        corr(squeeze(Orig_meanSourceTrials(j,idx,timeWind)),squeeze(correctedConds{filtConds}(j,idx,timeWind)),'type','Spearman');
                    r = Orig_filt_TEP_temp_Corr.(correctedCondsNames{filtConds}).(peakWindNames{t}).(tepCond)(j,idx);
                    
                    % Fisher's r to z transformation
                    fisherZ_Orig_filt_TEP_temp_Corr.(correctedCondsNames{filtConds}).(peakWindNames{t}).(tepCond)(j,idx)=.5.*log((1+r)./(1-r));
                    FisherZCorr(j,idx) = fisherZ_Orig_filt_TEP_temp_Corr.(correctedCondsNames{filtConds}).(peakWindNames{t}).(tepCond)(j,idx);
                    
                    % Fisher's z to r tranformation for each individual
                    rFromZ_Orig_filt_TEP_temp_Corr.(correctedCondsNames{filtConds}).(peakWindNames{t}).(tepCond)(j,idx) = (exp(1).^(2.*FisherZCorr(j,idx))-1)./(exp(1).^(2.*FisherZCorr(j,idx))+1);
                    r = [];
                end
                
            end
            
            % Average of z scores across subjects
            avZ_Orig_filt_TEP_temp_Corr.(correctedCondsNames{filtConds}).(peakWindNames{t}).(tepCond)= mean(FisherZCorr,2);
            FisherAvZCorr =  avZ_Orig_filt_TEP_temp_Corr.(correctedCondsNames{filtConds}).(peakWindNames{t}).(tepCond);
            
            % Fisher's z to r tranformation for mean values
            rFromZ_Av_Orig_filt_TEP_temp_Corr.(correctedCondsNames{filtConds}).(peakWindNames{t}).(tepCond) = (exp(1).^(2.*FisherAvZCorr)-1)./(exp(1).^(2.* FisherAvZCorr)+1);
        end
        
    end
    
save([pathOut, 'cleanUncleanCorr_sourceLevel_',tepCond],'Orig_filt_TEP_temp_Corr','fisherZ_Orig_filt_TEP_temp_Corr','rFromZ_Orig_filt_TEP_temp_Corr','avZ_Orig_filt_TEP_temp_Corr','rFromZ_Av_Orig_filt_TEP_temp_Corr');
end
