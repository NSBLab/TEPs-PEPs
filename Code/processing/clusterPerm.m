function clusterPerm (pathIn,pathOut,ID , allData, condition, condA, condB)

% TEP-SEP Voltage difference (clusterbased permutation tests in Fieldtrip)

% Mana Biabani, Monash University 

    neighbour = load([pathIn,'neighbour_template.mat']);    % Load neighbour template
    ft_defaults;
    cfg = [];
    cfg.channel = {'EEG'};
    cfg.latency = [0 0.3];
    cfg.method = 'montecarlo';
    cfg.statistic = 'depsamplesT';
    cfg.correctm = 'cluster';
    cfg.clusteralpha = 0.05;
    cfg.clusterstatistic = 'maxsum';
    cfg.minnbchan = 2;
    cfg.neighbours = neighbour.neighbours;  % same as defined for the between-trials experiment
    cfg.tail = 0;
    cfg.clustertail = 0;
    cfg.alpha = 0.025;
    cfg.numrandomization = 5000;
    subj = length(ID);
    design = zeros(1,2*subj);

    for i = 1:subj
        design(1,i) = i;
    end
    for i = 1:subj
        design(1,subj+i) = i;
    end
    design(2,1:subj)        = 1;
    design(2,subj+1:2*subj) = 2;
    cfg.design = design;
    cfg.uvar  = 1;
    cfg.ivar  = 2;

    % Clusterbased permutation test for the selected conditions
    [stat] = ft_timelockstatistics(cfg,allData.(condA){:}, allData.(condB){:});

    % Calculate grand avrege for each condition and store
    for conds = 1:length(condition)
        cfg = [];
        cfg.channel   = 'all';
        cfg.latency   = 'all';
        cfg.parameter = 'avg';
        grandAverage.(condition{conds}) = ft_timelockgrandaverage(cfg,allData.(condition{conds}){:});
    end

    save([pathOut,condA,'_',condB,'_clusterPerm'],'grandAverage', 'stat');
    
end