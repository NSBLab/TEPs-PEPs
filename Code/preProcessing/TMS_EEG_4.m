clear; close all; clc;

%##### STEP 4: Remove TMS-evoked muscle / decay #####

 ID = {'001';'002';'003';'004';'005';'006';'007';'008';'009';'010';'011';'012';'013';'014';'015';'016';'017';'019';'020';'021'};
 pathOut = '/Volumes/BACKUP_HD/MANA_TMS_EEG/Analyzed/';

for idx = 1:length(ID)
    
    % Load data
    EEG = pop_loadset('filepath',[pathOut,ID{idx,1},'/'],'filename', [ID{idx,1} '_all_blocks_ds_reject_ICA1.set']);
    
    % Remove
    EEG = pop_tesa_compselect( EEG,'comps',10,'figSize','small','plotTimeX',[-200 500],'plotFreqX',[1 100],'tmsMuscle','on','tmsMuscleThresh',8,'tmsMuscleWin',[16 30],'tmsMuscleFeedback','off','blink','off','blinkThresh',2.5,'blinkElecs',{'Fp1','Fp2'},'blinkFeedback','off','move','off','moveThresh',2,'moveElecs',{'F7','F8'},'moveFeedback','off','muscle','off','muscleThresh',0.6,'muscleFreqWin',[30 100],'muscleFeedback','off','elecNoise','off','elecNoiseThresh',4,'elecNoiseFeedback','off' );
    
    % Interpolate removed data
    EEG = pop_tesa_interpdata( EEG, 'linear' );
    
    % Bandpass (1-100 Hz) and bandstop (48-52 Hz) filter data
    EEG = pop_tesa_filtbutter( EEG, 1, 100, 4, 'bandpass' );
    EEG = pop_tesa_filtbutter( EEG, 48, 52, 4, 'bandstop' );
    
    % Save point
    EEG = pop_saveset( EEG, 'filename', [ID{idx,1} '_all_blocks_ds_reject_ICA1_clean'], 'filepath', [pathOut ID{idx,1}]);
    
end



