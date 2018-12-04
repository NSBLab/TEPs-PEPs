function removeSEPs_ICA(pathIn, fileName, pathOut, ID, condition)

% Suppress SEPs using ICA
% Mana Biabani, Monash University 
% Nigel Rogasch, Monash University

eeglab;
for idx = 1:length(ID)
    
    % Load data
    EEG = pop_loadset('filepath',[pathIn],'filename', [ID{idx,1},'_', fileName]);
    eegSeps = pop_selectevent( EEG, 'type','control','deleteevents','on','deleteepochs','on','invertepochs','off');
    
    % Calculate the sources of components from SEPs
    eegSeps.icaact = (eegSeps.icaweights*eegSeps.icasphere)*eegSeps.data(eegSeps.icachansind,:);
    eegSeps.icaact = reshape( eegSeps.icaact, size(eegSeps.icaact,1), eegSeps.pnts, eegSeps.trials);
    
    % Calculate the percentage of variance from mean trials of SEPs
    vars = [];
    for x = 1:size(eegSeps.icaact,1)
        vars(x) = var(mean(eegSeps.icaact(x,:,:),3));
    end
    varsPerc = vars/sum(vars)*100;
    
    % Select the components which explain more than 90% of variance
    compsToRemove{idx} = find(cumsum(varsPerc)<90);
    
    % Remove SEPs selected components from all conditions
    EEG = pop_subcomp( EEG, compsToRemove{idx}, 0);
    
    % Interpolate missing channels
    EEG = pop_interp(EEG, EEG.allchan, 'spherical');
    
    for conds =  1:length(condition)
        
        % Extract the data from each condition
        EEG1 = pop_selectevent( EEG, 'type',condition{conds},'deleteevents','on','deleteepochs','on','invertepochs','off');
        
        % Reference each condition's data to common average and save
        EEG1av = pop_reref(EEG1, []);
        
        % save all subjects' ICA data in one matrix
        meanIcaTrials{conds}(:,idx,:)  = double(mean(EEG1av.data,3));
    end
    
end

% Average of ICA-cleaned TEPs across subjects
meanIcaSubject{conds} =  squeeze(mean(meanTrials{conds},2));
sdIcaSubject{conds} = squeeze(std(meanTrials{conds},0,2));

% save
save([pathOut, 'ICA_cleaned_SEPs.mat'],'meanIcaTrials','meanIcaSubject','sdIcaSubject');
end