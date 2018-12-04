clear; clc;

% Subject ID
ID = {'001';'002';'003';'004';'005';'006';'007';'008';'009';'010';'011';'012';'013';'014';'015';'016';'017';'019';'020';'021'};

% Conditions
condition = {'control';'low';'high'};

% Data file suffix
sufData = '_avref_FINAL.set';
sufHeadFile = '_avref_FINAL';

% Brainstorm data path
pathBSdata = '/Volumes/RAW_DATA/Mana/brainstorm_db/StudyI_spPP/data/';

% Brainstorm anatomy path
pathBSanat = '/Volumes/RAW_DATA/Mana/brainstorm_db/StudyI_spPP/anat/';

% Analyzed data path
pathData = '/Volumes/BACKUP_HD/MANA_TMS_EEG/Analyzed/';

% Initiate Brainstorm GUI
if ~brainstorm('status')
    brainstorm nogui
end

ProtocolName = 'StudyI_spPP';

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
    
    % Process: Generate BEM surfaces
    sFiles = bst_process('CallProcess', 'process_generate_bem', sFileEp.(condition{1}), [], ...
        'subjectname', ID{idx}, ...
        'nscalp',      1922, ...
        'nouter',      1922, ...
        'ninner',      1922, ...
        'thickness',   4);
    
    % Process: Compute head model
    sFiles = bst_process('CallProcess', 'process_headmodel', sFileEp.(condition{1}), [], ...
        'Comment',     '', ...
        'sourcespace', 1, ...  % Cortex surface
        'eeg',         3, ...  % OpenMEEG BEM
        'openmeeg',    struct(...
        'BemFiles',     {{}}, ...
        'BemNames',     {{'Scalp', 'Skull', 'Brain'}}, ...
        'BemCond',      [1, 0.0125, 1], ...
        'BemSelect',    [1, 1, 1], ... %Maybe different from GUI...
        'isAdjoint',    0, ...
        'isAdaptative', 1, ...
        'isSplit',      0, ...
        'SplitLength',  4000));
    
    
    % Copy the forward model file to the other runs
    DataFile = sFileEp.(condition{1})(1).FileName;
    [sStudy, iStudy, iData] = bst_get('DataFile', DataFile);
    sHeadmodel = bst_get('HeadModelForStudy', iStudy);
    
    for i = 2:length(condition)
        DataFile1 = sFileEp.(condition{i})(1).FileName;
        [sStudy, iStudy, iData] = bst_get('DataFile', DataFile1);
        db_add(iStudy, sHeadmodel.FileName);
    end
    
end