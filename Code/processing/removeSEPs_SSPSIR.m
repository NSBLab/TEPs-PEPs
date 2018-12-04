function removeSEPs_SSPSIR(pathOut, ID, condition, condName, lfPath, leadfieldChan, meanTrials, eeglabChans, myWindow)

% Suppress SEPs using SSP-SIR
% Mana Biabani, Monash University 
% Nigel Rogasch, Monash University

%---------------------------- Extract TEPs from the defined window of time -------------------------

meanTrials_myWindow = cell(length(meanTrials),1);

for i = 1:length(meanTrials)
    for idx = 1:length(ID)
        d(:,idx,:) = cell2mat(meanTrials{i}(idx));
        meanTrials_myWindow{i} = d(:,:,myWindow);
    end
end

%-------------------------------------------- SSP-SIR ----------------------------------------------

tepCond = find(strcmp(condition,condName));
sepCond = find(strcmp(condition,'control'));

for idx = 1:length(ID)
    
    % Estimating the artifact-supression matrix P
    sepData = squeeze(meanTrials_myWindow{sepCond}(:,idx,:));
    [U,singular_spectum,~] = svd(sepData,'econ');
    
    % How many dimensions to remove (get the dimentions which explain more than 90% of variations)
    i = 1;
    d = diag(singular_spectum);
    a = sum(d(1:i)).^2/sum(d(1:end)).^2;
    while a < 0.9
        i = i+1;
        a = sum(d(1:i)).^2/sum(d(1:end)).^2;
    end
    PC(idx) = i;
    
    % Topography of the artefacts
    Artifact_topographies{idx} = U(:,1:PC(idx));
    
    % Projection matrix to remove SEP components
    tepData = squeeze(meanTrials_myWindow{tepCond}(:,idx,:));
    P = eye(size(tepData,1)) - U(:,1:PC(idx))*(U(:,1:PC(idx)))';
    
    % Suppress the SEP components
    data_clean(:,idx,:) = P*tepData;
       
    % Load field matrix L from idividuals head model
    load([lfPath, ID{idx},'_headmodel_surf_openmeeg'],'Gain');
   
    % Re-referencing the new gain matrix
    Lf = Gain - repmat(mean(Gain,1),[size(Gain,1),1]);
    
    % Sort the leadfield channel order to match EEGLAB channel order  
    for i = 1:length(eeglabChans)
        [~,chanIndex(i)] = ismember(lower(eeglabChans{i}),lower(leadfieldChan));
    end
    L = Lf(chanIndex,:);
     
    % Perform SIR for the suppressed data:
    M = rank(tepData) - PC(idx);
    PL = P*L;
    tau_proj= PL*PL';
    [U,S,V] = svd(tau_proj);
    S_inv = zeros(size(S));
    S_inv(1:M,1:M) = diag(1./diag(S(1:M,1:M)));
    tau_inv = V*S_inv*U';
    suppr_data_SIR(:,idx,:) = L*(PL)'*tau_inv*squeeze(data_clean(:,idx,:)); 

   % SSP-SIR correction of leadfield:
   cleaning_operator{idx} = L*(PL)'*tau_inv*P;
     
end

% Average SSP-SIR cleaned data across subjects
meanSubj_suppr_data_SIR = squeeze(mean(suppr_data_SIR,2)); 

% Save
save([pathOut,'SSPSIR-Filtered_',condName,'_TEPs.mat'],'suppr_data_SIR','cleaning_operator','meanSubj_suppr_data_SIR','Artifact_topographies');
end