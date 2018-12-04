clear; clc;

% Subject ID
ID = {'001';'002';'003';'004';'005';'006';'007';'008';'009';'010';'011';'012';'013';'014';'015';'016';'017';'019';'020';'021'};

% Conditions
condition = {'control';'low';'high'};

% Data path
pathData = '/Volumes/BACKUP_HD/MANA_TMS_EEG/Analyzed/';

% Data file suffix
sufData = '_avref_FINAL.set';

% Anatomy path
pathAnat = '/Volumes/RAW_DATA/Mana/Freesurfer/';

% Brainstorm data path
pathBSdata = '/Volumes/RAW_DATA/Mana/brainstorm_db/StudyI_spPP/data/';

% Initiate Brainstorm GUI
if ~brainstorm('status')
    brainstorm nogui
end

% The protocol name
ProtocolName = 'StudyI_spPP';

% Delete the protocol?
deleteProt = 'no'; % 'yes' | 'no'

% If starting from the first subject: delete the protocol
if strcmp(deleteProt,'yes')
    % Delete existing protocol
    gui_brainstorm('DeleteProtocol', ProtocolName);
    % Create new protocol
    gui_brainstorm('CreateProtocol', ProtocolName, 0, 0);
else
    % Get the protocol index
    iProtocol = bst_get('Protocol', ProtocolName);
    if isempty(iProtocol)
        error(['Unknown protocol: ' ProtocolName]);
    end
    % Select the current procotol
    gui_brainstorm('SetCurrentProtocol', iProtocol);
end

for idx = 1:length(ID)
    
    % Start a new report (one report per subject)
    bst_report('Start');
    
    % If subject already exists: delete it
    [sSubject, iSubject] = bst_get('Subject', ID{idx});
    if ~isempty(sSubject)
        db_delete_subjects(iSubject);
    end
    
    % Import anatomy
    AnatDir = [pathAnat,ProtocolName,'/',ID{idx}];
    
    % Import anatomy folder
    bst_process('CallProcess', 'process_import_anatomy', [], [], ...
        'subjectname', ID{idx}, ...
        'mrifile',     {AnatDir, 'FreeSurfer'}, ...
        'nvertices',   15000);
    
    % Get subject definition
    sSubject = bst_get('Subject', ID{idx});
    
    % Get MRI file and surface files
    MriFile = sSubject.Anatomy(sSubject.iAnatomy).FileName;
    CortexFile = sSubject.Surface(sSubject.iCortex).FileName;
    HeadFile   = sSubject.Surface(sSubject.iScalp).FileName;
    
    % Display scalp and cortex
    hFigSurf = view_surface(HeadFile);
    hFigSurf = view_surface(CortexFile, [], [], hFigSurf);
    hFigMriSurf = view_mri(MriFile, CortexFile);
    
    % Close figures
    close([ hFigSurf hFigMriSurf]);
    
    % Compute MNI transformation 
    sFilesMNI = [];
    sFilesMNI = bst_process('CallProcess', 'process_mni_affine', sFilesMNI, [], ...
    'subjectname', ID{idx});
    
    % Import EEGLAB file
    for conds = 1:length(condition)
        DataFile = [pathData,ID{idx},'/',ID{idx},'_',condition{conds},sufData];
        
        % Import file
        sFileEp.(condition{conds}) = bst_process('CallProcess', 'process_import_data_epoch', [], [], ...
            'subjectname',    ID{idx}, ...
            'datafile',       {DataFile, 'EEG-EEGLAB'}, ...
            'baseline', []);
        
        % Average trials
        sFilesAvTrial.(condition{conds}) = bst_process('CallProcess', 'process_average', sFileEp.(condition{conds}), [], ...
            'avgtype',    6, ...  % By trial group (subject average)
            'avg_func',   1, ...  % Arithmetic average:  mean(x)
            'weighted',   0, ...
            'keepevents', 0);
    end
    
    % Save
    save([pathData,ID{idx},'/',ID{idx},'_bs_settings.mat'],'sFileEp','sFilesAvTrial');
    fprintf('%s complete\n',ID{idx})
end