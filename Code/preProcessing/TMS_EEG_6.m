clear; close all; clc;

%##### STEP 6: Remove all other artifacts #####

ID = {'001';'002';'003';'004';'005';'006';'007';'008';'009';'010';'011';'012';'013';'014';'015';'016';'017';'019';'020';'021'};
pathOut = '/Volumes/BACKUP_HD/MANA_TMS_EEG/Analyzed/';

for idx = 1:length(ID)
    
    % Load data
    EEG = pop_loadset('filepath',[pathOut,ID{idx,1},'/'],'filename', [ID{idx,1} '_all_blocks_ds_reject_ICA1_clean_ICA2.set']);
    
    % Run FastICA (round 2)
    EEG = pop_tesa_compselect( EEG,'comps',[],'figSize','small','plotTimeX',[-200 500],'plotFreqX',[1 100],'tmsMuscle','on','tmsMuscleThresh',8,'tmsMuscleWin',[11 30],'tmsMuscleFeedback','off','blink','on','blinkThresh',2.5,'blinkElecs',{'Fp1','Fp2'},'blinkFeedback','off','move','on','moveThresh',2,'moveElecs',{'F7','F8'},'moveFeedback','off','muscle','on','muscleThresh',0.6,'muscleFreqWin',[30 100],'muscleFeedback','off','elecNoise','on','elecNoiseThresh',4,'elecNoiseFeedback','off' );
    
    % Save point
    EEG = pop_saveset( EEG, 'filename', [ID{idx,1} '_all_blocks_ds_reject_ICA1_clean_ICA2_clean'], 'filepath', [pathOut ID{idx,1}]);
    
end
