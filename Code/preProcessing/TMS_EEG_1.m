clear; close all; clc;

% ###### STEP 1 : Epoch, Remove TMS artifact, Down sample #####

% IDs of participants to analyse
 ID = {'001';'002';'003';'004';'005';'006';'007';'008';'009';'010';'011';'012';'013';'014';'015';'016';'017';'019';'020';'021'};

% Filename identifiers
sufix = {'SP_EEG';'SHAM'};

% Suffix for filePathlog
suf3 = '_trigger.mat';

% The number of blocks
blockNum = {'1';'2';'3';'4'};

% File path where data is stored
pathIn = '/Volumes/BACKUP_HD/MANA_TMS_EEG/Raw/';
pathOut = '/Volumes/BACKUP_HD/MANA_TMS_EEG/Analyzed/';

% EEGLAB
[ALLEEG, EEG, CURRENTSET, ALLCOM, blockIndex] = eeglab;

for     idx = 1:length(ID)
    
    % Makes a subject folder
    if ~isequal(exist([pathOut,ID{idx,1}], 'dir'),7)
        mkdir(pathOut,ID{idx,1});
    end
    
    % Clear EEG
    EEG = {};
    
    % Clear ALLEEG
    ALLEEG = [];
    
    for suf = 1:length(sufix)
        
        % Include exceptions to blockNum
        if  strcmp(sufix{suf},'SHAM') && strcmp(ID{idx,1},'002')
            blockNum = {'1'};
        elseif not(strcmp(sufix{suf}, 'SHAM'))&& strcmp(ID{idx,1},'002')
            blockNum = {'1';'2';'3'};
        elseif  not(strcmp(sufix{suf}, 'SHAM'))&& strcmp(ID{idx,1},'012')
            blockNum = {'1';'2';'3'};
        elseif strcmp(sufix{suf}, 'SHAM')&& not(strcmp(ID{idx,1},'002'))
            blockNum = {'1';'2'};
       
        else
            blockNum = {'1';'2';'3';'4'};
        end
        
        
        for     block = 1:length(blockNum)
            
            % File path where data is stored
            filePath = [pathIn,ID{idx,1},'/',ID{idx,1},'_EEG/'];
            
            % File path where log files are stored
            filePathLog = [pathIn,ID{idx,1},'/',ID{idx,1},'_EEG'];
            
            
            % Load Curry files
            EEG = loadcurry( [pathIn,ID{idx,1}, '/',ID{idx,1}, '_EEG/', ID{idx,1}, '_', sufix{suf,1},'_', blockNum{block}, '.dap'],'CurryLocations', 'False');
                   

            % Load channel locations
            EEG = pop_chanedit(EEG, 'lookup','/Users/manabiabanimoghadam/Desktop/Functions/eeglab14_1_0b/plugins/dipfit2.3/standard_BESA/standard-10-5-cap385.elp');
            
            % Find TMS pulse and include some exceptions to TMS pulse detection
            if strcmp(ID{idx,1}, '013' )
                EEG = pop_tesa_findpulse( EEG, 'C3', 'refract', 20, 'rate', 10000, 'tmsLabel', 'TMS', 'plots', 'on');
            elseif (strcmp(sufix{suf}, 'SP_EEG')) && strcmp(ID{idx,1},'005')
                 EEG = pop_tesa_findpulse( EEG, 'C3', 'refract', 10, 'rate', 1000000, 'tmsLabel', 'TMS', 'plots', 'on');
             elseif (strcmp(sufix{suf}, 'SP_EEG')) && strcmp(ID{idx,1},'012')    
                 EEG = pop_tesa_findpulse( EEG, 'C3', 'refract', 10, 'rate', 1000000, 'tmsLabel', 'TMS', 'plots', 'on');
                 elseif (strcmp(sufix{suf}, 'SP_EEG')) && strcmp(ID{idx,1},'019')    
                 EEG = pop_tesa_findpulse( EEG, 'C4', 'refract', 10, 'rate', 1000000, 'tmsLabel', 'TMS', 'plots', 'on');
                 elseif  strcmp(ID{idx,1},'020')    
                 EEG = pop_tesa_findpulse( EEG, 'C4', 'refract', 20, 'rate', 100000, 'tmsLabel', 'TMS', 'plots', 'on');
            else
                EEG = pop_tesa_findpulse( EEG, 'C3', 'refract', 10, 'rate', 10000, 'tmsLabel', 'TMS', 'plots', 'on');
            end
            
            % Load mat files
            fileLogName = [filePathLog,'/',ID{idx,1},'_', sufix{suf}, '_' ,blockNum{block,1},suf3];
            load(fileLogName);
            
            % Align EEG events with the corresponding TMS pulses and remove extra events
            if   strcmp(sufix{suf},'SP_EEG')
                
                % Compute cross correlation between EEG events latency and TMS intervals;
                A = ([EEG.event.latency]).';
                B = (cfg.isi);
                r = xcorr(A,B);
                [r,lag] = xcorr(A,B);
                [~,I] = max(abs(r));
                
                % Find the shift from the maximum correlation
                timeDiff = lag(I);
            end
            
            % Correct the shift
            if   strcmp(sufix{suf},'SP_EEG') && timeDiff~=1
                EEG.event = circshift(EEG.event,(-timeDiff));
            end
            
            % Remove extra events
            while length(EEG.event)>length(cfg.amp)
                EEG.event(end) = [];
            end
            
            % Epoch the data
            EEG = pop_epoch( EEG, {  'TMS'  }, [-1  1], 'newname', 'ep', 'epochinfo', 'yes');
            
            % Remove baseline
            EEG = pop_rmbase( EEG, [-500  -10]);
            
            % Remove unused channels
            EEG = pop_select( EEG,'nochannel',{'31' '32' 'Trigger'});
            
            % Save the original EEG locations for use in interpolation later
            EEG.allchan = EEG.chanlocs;
            
            % Remove TMS artifact
            EEG = pop_tesa_removedata( EEG, [-2 15] );%[-1 10]
            
            % Interpolate missing data
            EEG = pop_tesa_interpdata( EEG, 'cubic', [1 1] );
            
            % Downsample data
            EEG = pop_resample( EEG, 1000);
            
            % Label the mplitude as 'low' for 80% rMT and 'high' for 120%rmt
            minamp = min(cfg.amp);
            maxamp = max(cfg.amp);
            if   strcmp(sufix{suf},'SHAM')
                for i = 1 : EEG.trials
                    EEG.event(i).type = 'control';
                end
        
            elseif strcmp(sufix{suf},'SP_EEG')
                for i = 1 : EEG.trials
                    if   cfg.amp(i) == minamp
                        EEG.event(i).type = 'low';
                    else EEG.event(i).type = 'high';
                    end;
                end;
            end
            
            % Save EEG for each block type for each participant
            [ALLEEG, EEG,blockIndex] = eeg_store(ALLEEG,EEG,block);
            
        end;
        
        ALL{suf} = ALLEEG;
        
        % Merge the same blocks ('SP_EEG' or 'SHAM') for each subject
        storeEEG {suf,1} = pop_mergeset(  ALL{suf}, 1:size(blockNum,1), 0);
        
    end;
    
    % Merge all blocks for each subject
    EEG = pop_mergeset( storeEEG{1}, storeEEG{2},0);
    
    % save data
    EEG = pop_saveset( EEG, 'filepath',[pathOut,ID{idx,1},'/'],'filename', [ID{idx,1} '_' 'all_blocks' '_' 'ds']);
end
