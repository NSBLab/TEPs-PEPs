function removeSEPs_LinearRegression(ID, condition, tepConds, meanTrials, myWindow, pathOut)

% Uses first order polynomial regression to supress SEPs in TEP data : 
% 1- Finds the best fit line between TEPs and SEPs for each subject (for all electrodes / at each point of time(following TMS ) /in each condition)
% 2- Removes the fit line and keeps the residuals in TEPs for each subject
% 3- Finds the average of the residuals across subjects
% % Mana Biabani, Monash University 

%------------------------- Extract TEPs from the defined window of time ----------------------------

% Preallocate variables
meanTrials_myWindow = cell(1,length(meanTrials));

for i = 1:length(meanTrials)
    for idx = 1:length(ID)
        a(:,idx,:) = cell2mat(meanTrials{i}(idx));
        meanTrials_myWindow{i} = a(:,:,myWindow);
    end
end

%-------------------------- Regress out SEPs from each subject's TEPs ------------------------------

% Preallocate variables
spatial_EachSubj_fitLine = cell(1,length(condition)-1);
spatial_EachSubj_resid = cell(1,length(condition)-1);
n = 1;
for conds = 1:length(tepConds)
    condControl = find(strcmp(condition,'control'));
    condTep = find(strcmp(condition,tepConds(conds)));
    
    for idx = 1:length(ID)
        
        for t = 1: length(myWindow)  
            a = double(squeeze(meanTrials_myWindow{condControl}(:,idx,t)));
            b = double(squeeze(meanTrials_myWindow{condTep}(:,idx,t)));
            spatial_EachSubj_fitLine{n}{idx,t} = fit(a,b,'poly1');
            spatial_EachSubj_resid{n}(:,idx,t) = b - spatial_EachSubj_fitLine{n}{idx,t}(a);
            a =[];
            b = [];
        end
%         reg_eeg = squeeze(spatial_EachSubj_resid{conds-1}(:,idx,:));
%         save([pathOut, ID{idx,1},'/',ID{idx,1},'_',condition{conds},'_LinearReg_cleaned_SEPs.mat'],'reg_eeg');
%         reg_eeg =[];
        
    end
    n = n+1;
end

%------------------------------------ Average across subjects --------------------------------------

% Preallocate variables
meanSubj_residuals = cell(1,length(condition)-1);
SD_meanSubj_residuals = cell(1,length(condition)-1);

for conds = 1:length(condition)-1
    meanSubj_residuals{conds} = squeeze(mean(spatial_EachSubj_resid{conds},2));
    SD_meanSubj_residuals{conds} = squeeze(std(spatial_EachSubj_resid{conds},0,2));
end

%------------------------------------------ save ---------------------------------------------------

 save([pathOut,'RegResiduals']);
 
end