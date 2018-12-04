clear; close all; clc;

%##### STEP 7: Split Intensities, Average Reference, Reference to Mastoids, Laplacian (takes longer time, might need to consider not running it with the re-referencing methods)#####

% IDs of participants to analyse
ID = {'001';'002';'003';'004';'005';'006';'007';'008';'009';'010';'011';'012';'013';'014';'015';'016';'017';'019';'020';'021'};
pathOut = '/Volumes/BACKUP_HD/MANA_TMS_EEG/Analyzed/';
fileName = 'all_blocks_ds_reject_ICA1_clean_ICA2_clean.set';
condition = {'control';'low';'high'};
eeglab;

for idx = 1:length(ID)
    
    % Load data
    EEG = pop_loadset('filepath',[pathOut,ID{idx,1},'/'],'filename', [ID{idx,1},'_', fileName]);
    
    % Interpolate missing channels
    EEG = pop_interp(EEG, EEG.allchan, 'spherical');
    
    for conds =  1:length(condition)
        
        % Extract the data from each condition
        EEG1 = pop_selectevent( EEG, 'type',condition{conds},'deleteevents','on','deleteepochs','on','invertepochs','off');
        
        % Reference each condition's data to common average and save
        EEG1av = pop_reref(EEG1, []);
        EEG1av = pop_saveset(EEG1av, 'filename', [ID{idx,1},'_', condition{conds},'_avref_FINAL'],'filepath', [pathOut ID{idx,1}]);
          
    end
end