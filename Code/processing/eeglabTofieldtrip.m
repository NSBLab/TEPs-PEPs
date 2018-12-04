function eeglabTofieldtrip(pathIn,pathOut,ID,condition)
eeglab;
ft_defaults;

% Convert data from eeglab to fieldtrip
for idx = 1:length(ID)
    
    for conds = 1:length(condition) 
        %load EEGLAB data
        EEG = pop_loadset([pathIn, condition{conds},'/',ID{idx,1},'_',condition{conds}, '_avref_FINAL.set']);
        EEG.icachansind = [];
        %convert to fieldtrip
        ftData = eeglab2fieldtrip(EEG, 'timelockanalysis');
        ftData.dimord = 'chan_time';
        %store data
        allData.(condition{conds,1}){idx} = ftData;
        fprintf('%s''s data converted from eeglab to fieldtrip\n', ID{idx,1});
    end
    
end

% Create grand average for each condition and store
for conds = 1:length(condition)
    %Perform grand average
    cfg = [];
    cfg.channel   = 'all';
    cfg.latency   = 'all';
    cfg.parameter = 'avg';
    grandAverage.(condition{conds}) = ft_timelockgrandaverage(cfg,allData.(condition{conds,1}){:});
end

save([pathOut,'FieldtripTEPs.mat'],'allData');
end