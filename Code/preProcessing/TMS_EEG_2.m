clear; close all; clc;

%##### STEP 2: REMOVE BAD TRIALS, CHECK BAD ELECTRODES #####

ID = {'001';'002';'003';'004';'005';'006';'007';'008';'009';'010';'011';'012';'013';'014';'015';'016';'017';'019';'020';'021'};
pathOut = '/Volumes/BACKUP_HD/MANA_TMS_EEG/Analyzed/';
eeglab;

for idx = 1:length(ID)
    
    % Clear EEG
    EEG = {};
    
    % Clear ALLEEG
    ALLEEG = [];
    
    % Load point
    EEG = pop_loadset('filepath',[pathOut,ID{idx,1},'/'],'filename', [ID{idx,1} '_all_blocks_ds.set']);
    
    % Find bad trials and bad channels
    EEG = pop_rejkurt(EEG,1,[1:EEG.nbchan] ,5,5,2,0);
    pop_rejmenu( EEG, 1);
    R1 = input('Highlight bad trials, update marks and then press enter');
    EEG.BadTr = unique([find(EEG.reject.rejkurt==1) find(EEG.reject.rejmanual==1)]);
    
    % Reject bad trials
    EEG = pop_rejepoch(EEG,EEG.BadTr,0);
    
    % Remove bad channels
    answer = inputdlg('Enter bad channels', 'Bad channel removal', [1 50]);
    str = answer{1};
    EEG.badChan = strsplit(str);
    close all;
    EEG = pop_select( EEG,'nochannel',EEG.badChan);
    
    % Save point
    EEG = pop_saveset( EEG, 'filename', [ID{idx,1} '_all_blocks_ds_reject'], 'filepath', [pathOut ID{idx,1}]);
    
end  
