clear; close all; clc;

%##### STEP 3: Remove TMS pulse artifact and run FASTICA round 1 #####

ID = {'001';'002';'003';'004';'005';'006';'007';'008';'009';'010';'011';'012';'013';'014';'015';'016';'017';'019';'020';'021'};
pathOut = '/Volumes/BACKUP_HD/MANA_TMS_EEG/Analyzed/';
eeglab;

for idx = 1:length(ID)
    
    % Load data
    EEG = pop_loadset('filepath',[pathOut,ID{idx,1},'/'],'filename', [ID{idx,1} '_all_blocks_ds_reject.set']);
    
    % Remove TMS pulse artifact
    EEG = pop_tesa_removedata( EEG, [-2 15] );

    % Run FastICA (round 1)
    EEG = pop_tesa_fastica( EEG,'approach', 'symm', 'g', 'tanh', 'stabilization', 'off' );
    
    % Save point
    EEG = pop_saveset( EEG, 'filename', [ID{idx,1} '_all_blocks_ds_reject_ICA1'], 'filepath', [pathOut ID{idx,1}]);
    
end