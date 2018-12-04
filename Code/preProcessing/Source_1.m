clear; close all; clc;

% Subject ID
ID = {'001';'002';'003';'004';'005';'006';'007';'008';'009';'010';'011';'012';'013';'014';'015';'016';'017';'019';'020';'021'};

% Original electrode positions import from
pathInElec = '/Volumes/BACKUP_HD/MANA_TMS_EEG/Raw/';

% Repositioned electrodes export to
pathOutElec = '/Volumes/BACKUP_HD/MANA_TMS_EEG/Analyzed/';

for idx = 1:length(ID)
    a = {};
    elecData = importdata([pathInElec, ID{idx},'/',ID{idx},'_neuronav/',ID{idx},'_eeg_elec_pos.txt']);
    d = length(elecData.textdata)-length(elecData.data);
    n = 1;
    for i = d+1:length(elecData.textdata)
        a{n,1} = elecData.textdata{i};
        n= n+1;
    end
    
    % Rename fiducial points (apply exceptions for the one which is aready renamed)
    if ~ strcmp(ID{idx},'004')
        a{1} = 'nasion';
        a{2} = 'LPA';
        a{3} = 'RPA';
    end
    
    % Apply exceptions for the subjects for whom right and left ears were defined inversely in the experiment
        if strcmp(ID{idx},'021')
            a{2} = 'RPA';
            a{3} = 'LPA';
        end
    
    % Read electrode positions and flip the dimentions
    electrodPosition{idx} = table(a , elecData.data(:,1)*0.1, elecData.data(:,2)*0.1, elecData.data(:,3)*0.1);
    
    % Correct the wrong names saved in the neuronavigation system
    for i = 1:length(electrodPosition{idx}.a)
        if strcmp(electrodPosition{idx}.a(i) , '01')
            electrodPosition{idx}.a(i) = {'O1'} ;
        elseif strcmp(electrodPosition{idx}.a(i) , '02')
            electrodPosition{idx}.a(i) = {'O2'} ;
        elseif strcmp(electrodPosition{idx}.a(i) , '0Z')
            electrodPosition{idx}.a(i) = {'OZ'} ;
        elseif strcmp(electrodPosition{idx}.a(i) , 'P0Z')
            electrodPosition{idx}.a(i) = {'POZ'} ;
        elseif strcmp(electrodPosition{idx}.a(i) , 'P03')
            electrodPosition{idx}.a(i) = {'PO3'} ;
        elseif strcmp(electrodPosition{idx}.a(i) , 'P04')
            electrodPosition{idx}.a(i) = {'PO4'} ;
        elseif strcmp(electrodPosition{idx}.a(i) , 'P07')
            electrodPosition{idx}.a(i) = {'PO7'} ;
        elseif strcmp(electrodPosition{idx}.a(i) , 'P08')
            electrodPosition{idx}.a(i) = {'PO8'} ;
        end
    end
    
    % Remove ground and reference electrodes
    gr = find (strcmp(a,'GROUND'));
    ref = find (strcmp(a,'REF'));
    electrodPosition{idx}([gr,ref],:) = [];
    
    % Save
    writetable(electrodPosition{idx},[pathOutElec,ID{idx},'/',ID{idx},'_electrodes.txt'],'Delimiter','\t','WriteVariableNames',false);
end