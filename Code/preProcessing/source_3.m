close all; clc; clear

% Subject ID
ID = {'001';'002';'003';'004';'005';'006';'007';'008';'009';'010';'011';'012';'013';'014';'015';'016';'017';'019';'020';'021'};

% Conditions
condition = {'control';'low';'high'};

% Data path
pathData = '/Volumes/BACKUP_HD/MANA_TMS_EEG/Analyzed/';

% Data file suffix
sufData = '_avref_FINAL.set';

% Electrode path
pathElec = '/Volumes/BACKUP_HD/MANA_TMS_EEG/Analyzed/';


% The protocol name has to be a valid folder name (no spaces, no weird characters...)
ProtocolName = 'StudyI_spPP';

% Initiate Brainstorm GUI
if ~brainstorm('status')
    brainstorm nogui
end

% Brainstorm data path
pathBSdata = '/Volumes/RAW_DATA/Mana/brainstorm_db/StudyI_spPP/data/';

% Brainstorm anatomy path
pathBSanat = '/Volumes/RAW_DATA/Mana/brainstorm_db/StudyI_spPP/anat/';

% Get the protocol index
iProtocol = bst_get('Protocol', ProtocolName);
if isempty(iProtocol)
    error(['Unknown protocol: ' ProtocolName]);
end

% Select the current procotol
gui_brainstorm('SetCurrentProtocol', iProtocol);

for idx = 1:length(ID)
    
    % Load sFileEp
    load([pathData,ID{idx},filesep,ID{idx},'_bs_settings.mat']);
    
    % Manually align the fiducials
    view_mri([pathBSanat,ID{idx},filesep,'subjectimage_T1.mat'], 'EditMri');
    uiwait(msgbox('This message will pause execution until you click OK'));
    
    
    % Load electrode positions 
    % Set condition to manually alter electrodes
    manCond = condition{1};
    sFiles = sFileEp.(manCond);
    
    % Use individual electrode positions
    RawFiles = {[pathElec,ID{idx},'/',ID{idx},'_electrodes.txt']};
    
    % Process: Add EEG positions
    sFiles = bst_process('CallProcess', 'process_import_channel', sFiles, [], ...
        'channelfile', {RawFiles{1}, 'ASCII_NXYZ'}, ...
        'usedefault',  60, ...  % ICBM152: BrainProducts EasyCap 128
        'fixunits',    1, ...
        'copycond',    1, ...
        'vox2ras',     1);
    
    % Process: Remove head points
    sFiles = bst_process('CallProcess', 'process_headpoints_remove', sFiles, [], 'zlimit', []);
    
    % Process: Project electrodes on scalp
    sFiles = bst_process('CallProcess', 'process_channel_project', sFiles, []);
    
    happy = 0;
    
    while happy == 0
        
        % Edit good/bad channel for current file
        channel_align_manual(sFileEp.(manCond)(1).ChannelFile, 'EEG', 1, 'scalp' );
        uiwait(msgbox('This message will pause execution until you click OK'));
        
        % Check sensor positions
        sSubject = bst_get('Subject', ID{idx});
        HeadFile = sSubject.Surface(sSubject.iScalp).FileName;
        hFig = view_surface(HeadFile);
        hFig = view_channels(sFiles(1).ChannelFile, 'EEG', 1 , 1 , hFig , 1);
        
        uiwait(msgbox('This message will pause execution until you click OK'));
        
        if ishandle(hFig)
            close(hFig);
        end
        
        % Construct a questdlg with two options
        choice = questdlg('Are you happy with alignment?', ...
            'Electrode alignment', ...
            'Yes','No','Yes');
        
        % Handle response
        switch choice
            case 'Yes'
                happy = 1;
            case 'No'
                happy = 0;
        end
        
    end
    
    % Update all other conditions
    save([pathBSdata,ID{idx},'/',ID{idx},'_',condition{1},'_avref_FINAL/channel.mat']) 
    
    % Alter other conditions electrodes
    for conds = 2:length(condition)
        
        manCond = condition{conds};
        sufData2 = strrep(sufData,'.set','');
        OutputFile = [pathBSdata,ID{idx},filesep,ID{idx,1},'_',condition{1},sufData2,filesep,'channel.mat'];
        RawFiles = {OutputFile};
        sFiles = sFileEp.(manCond);
        sFiles = bst_process('CallProcess', 'process_channel_addloc', sFiles, [], ...
            'channelfile', {RawFiles{1}, 'BST'}, ...
            'usedefault',  1); 
        
        % Process: Remove head points
        sFiles = bst_process('CallProcess', 'process_headpoints_remove', sFiles, [], 'zlimit', []);
        
        % Update channel.mat files
        delete([pathBSdata,ID{idx},'/',ID{idx},'_',condition{conds},'_avref_FINAL/channel.mat'])
        load([pathBSdata,ID{idx},'/',ID{idx},'_',condition{1},'_avref_FINAL/channel.mat'])
        save([pathBSdata,ID{idx},'/',ID{idx},'_',condition{conds},'_avref_FINAL/channel.mat'])
        Channel=[];
    end
end
% #### Subjects should be reloaded after this to make sure channels are updated before moving on to the next step!
  