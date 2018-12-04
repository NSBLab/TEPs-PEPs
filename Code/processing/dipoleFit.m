function dipoleFit (pathOut, ID, indivPeaks, condition, meanTrials, eeglabChans, myWindow, condName, lfPath, filteredData, cleanMethod, leadField)

% Dipole fitting
% Mana Biabani, Monash University 
% Nigel Rogasch, Monash University

TEPCondNum = (find(strcmp(condition, condName)))-1;
peaks = indivPeaks{TEPCondNum};
origWindow = [myWindow.OrigBaseLength + 1 : myWindow.OrigBaseLength + myWindow.widowToStudy];
filteredWindow = [myWindow.filtBaseLength + 1 : myWindow.filtBaseLength + myWindow.widowToStudy];

for idx = 1:length(ID)
    
    mt = find(strcmp(condition, condName));
    origD = meanTrials{mt}{idx};
    origD_window{idx} = origD(:,origWindow);
    filteredD_window{idx} = squeeze(filteredData(:,idx,filteredWindow));
    
    % Load field matrix L from idividuals head model
    load([lfPath, ID{idx},'_headmodel_surf_openmeeg'],'Gain');
    
    % Re-referencing the new gain matrix
    L = Gain - repmat(mean(Gain,1),[size(Gain,1),1]);
    
    % Sort the leadfield channel order to match EEGLAB channel order
    for i = 1:size(eeglabChans,2)
        [~,chanIndex(i)] = ismember(lower(eeglabChans{i}),lower(leadField.leadfieldChan));
    end
    leadfieldInOrig{idx} = L(chanIndex,:);
    leadfieldInFilt{idx} = leadfieldInOrig{idx};
    
    % Use sspsir-corrected leadfield for sspsir filtered data
    if strcmp(cleanMethod,'SSP-SIR')
        leadfieldInFilt{idx} = [leadField.cleaning_operator{idx}]*leadfieldInOrig{idx} ;
    end
    
    % Apply dipfit 
    for k = 1:size(peaks,2)
        data_vector_orig = origD_window{idx}(:,peaks(idx,k));
        data_vector_filtered = filteredD_window{idx}(:,peaks(idx,k));
        [bestmatch_orig{k}(idx), GOF_of_bestmatch_orig{k}(idx), fit_residuals_orig{k}(:,idx), GOF_scores_orig{k}(:,idx), dipole_amplitudes_orig{k}{idx}, best_match_topography_orig{k}(:,idx)]= dipfit(data_vector_orig, leadfieldInOrig{idx}, 1);
        [bestmatch_filtered{k}(idx), GOF_of_bestmatch_filtered{k}(idx), fit_residuals_filtered{k}(:,idx), GOF_scores_filtered{k}{idx}, dipole_amplitudes_filtered{k}{idx}, best_match_topography_filtered{k}(:,idx)]= dipfit(data_vector_filtered, leadfieldInFilt{idx}, 1);
    end
    
end

% Save
save([pathOut,'bestDipole_',cleanMethod,'_',condName],'bestmatch_orig','bestmatch_filtered','GOF_of_bestmatch_orig','GOF_of_bestmatch_filtered','fit_residuals_orig','fit_residuals_filtered','GOF_scores_orig',...
'GOF_scores_filtered','dipole_amplitudes_orig','dipole_amplitudes_filtered','best_match_topography_orig','best_match_topography_filtered');

end

function [bestmatch, GOF_of_bestmatch, fit_residuals, GOF_scores, dipole_amplitudes, best_match_topography] = dipfit(data_vector, lead_field, is_free_dipoles)

% This function does the simple dipole fitting to the signal vector of
% interest.

% By Tuomas Mutanen, 20th June, 2018
% Tuomas.mutanen@glasgow.ac.uk
% Room 632 Level 6 
% 62 Hillhead Street
% G12 8AD Glasgow, Scotland, UK
% Centre for Cognitive Neuroimaging
% Institute of Neuroscience & Pshychology
% University of Glasgow


% Input:

% data_vector : The input signal vector, e.g. at a certain deflection. 
% The function assumes the data in channels x 1 format.
%
% lead_field : The matrix containing the forward model. The function
% assumes channels x es structure
%
% is_free_dipoles : The parameter that defines whether the dipoles in the
% forward model have a free orientation or not. In the case of free dipoles,
% the function assumes that the the dipoles are stored in the lead_field
% matrix as [q1x,q1y,q1z, ...,  qix,qiy,qiz, ...]

% Output:

% bestmatch = the index of the best dipole match
% GOF_of_bestmatch = The goodness-of-fit of the best macthing dipole
% fit_residuals = the residuals of all the dipoles (the fitting error) in
% uV^2
% GOF_scores = the goodness-of-fit scores of all the dipoles
% dipole_amplitudes = the best fitting dipole amplitudes at each source
% location (useful for different sort of visualizations)
% best_match_topography = the topopgrahy produced by the best matching
% dipole

if is_free_dipoles
    
    dipN = size(lead_field,2)/3;
    
    fit_residuals = zeros(1,dipN);
    GOF_scores = zeros(1,dipN);
    
    
    for i=1:dipN
        dipole_amplitudes(:,i) = pinv(lead_field(:,(3*i-2):(3*i)))*data_vector;
        fit_residuals(i) = sum((data_vector - lead_field(:,(3*i-2):(3*i))*dipole_amplitudes(:,i)).^2);
        GOF_scores(i) = 1 - fit_residuals(i)/sum(data_vector .^2);
    end
    
else
    
    dipN = size(lead_field,2);
    
    fit_residuals = zeros(1,dipN);
    GOF_scores = zeros(1,dipN);
    
    for i=1:dipN
        dipole_amplitudes(i) = pinv(lead_field(:,i))*data_vector;
        fit_residuals(i) = sum((data_vector - lead_field(:,i)*dipole_amplitudes(i)).^2);
        GOF_scores(i) = 1 - fit_residuals(i)/sum(data_vector .^2);
    end
end

[~, bestmatch] = min(fit_residuals);
GOF_of_bestmatch = GOF_scores(bestmatch);

if is_free_dipoles
    best_match_topography = dipole_amplitudes(1,bestmatch)*lead_field(:,3*bestmatch -2) +...
        dipole_amplitudes(2,bestmatch)*lead_field(:,3*bestmatch -1) + ...
        dipole_amplitudes(3,bestmatch)*lead_field(:,3*bestmatch);
else
    best_match_topography = dipole_amplitudes(bestmatch)*lead_field(:,bestmatch);
end
end
