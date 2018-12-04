% EEGLAB, TESA and FieldTrip should be added to the path

% Each section has two parts : 1) Define options and 2) Run the function

% 1)Define options : the chosen options here are specific to the current study taking the data from the Input folder and saving the results to the Output folder.
% The options with stars indicate that more than one choices are available for this study (choices are also provided).

% 2) Run the functions : simply runs the function to do the nalysis for each section using the specified options.
% The functions can be used for other similar studies using the study-specific variables as options.  

% Mana Biabani, Monash University , 2018-12-04
% Nigel Rogasch, Monash University , 2018-12-04

clear; close all; clc;
AddPaths;

%% 
% --------------------------------------------------------------------------------------------------
% TEP-SEP Voltage difference (clusterbased permutation tests in Fieldtrip)
% --------------------------------------------------------------------------------------------------
clear; close all; clc;

% Define the options
condA = 'low'; % options : control; low; high ***
condB = 'control'; % options : control; low; high ****
pathOut = ([pwd,'/Outputs/']);
pathIn = ([pwd,'/Inputs/']);
load(['/Inputs/TEPs'],'ID','condition');
load([pathIn,'FieldtripTEPs.mat']);

% Run the function
clusterPerm (pathIn,pathOut,ID , allData, condition, condA, condB)

%%
% --------------------------------------------------------------------------------------------------
% SEPs-TEPs spatial correlation and confidence interval calculations (using Fisher's transformation)
% --------------------------------------------------------------------------------------------------
clear; close all; clc;

% Define the options
pathOut = ([pwd,'/Outputs/']);
load(['/Inputs/TEPs'],'ID','condition','meanTrials');

% Run the function
tepSep_spatialCorr (pathOut,ID ,condition, meanTrials)

%%
% --------------------------------------------------------------------------------------------------
% Confidence intervals of SEPs-TEPs spatial correlation (using Fisher's transformation)
% --------------------------------------------------------------------------------------------------
clear; close all; clc;

% Define the options
pathOut = ([pwd,'/Outputs/']);
load(['/Inputs/TEPs'],'ID','condition','meanTrials','eeglabChans');
load('/Inputs/indivPeaks.mat')
preTr = 999;% Length of window before the trigger
postInterpol = 16; % First timepoint after interpolation 
winds = [4 6 7]; % The peaks number(nth peak) at the end of the individualized time windows (early, mid, late)

% Run the function
tepSep_TemporalCorr (pathOut,ID ,condition, meanTrials, eeglabChans, indivPeaks,preTr,postInterpol,winds)

%%
% --------------------------------------------------------------------------------------------------
% Suppress SEPS using Linear Regression
% --------------------------------------------------------------------------------------------------
clear; close all; clc;

% Define the options
tepConds = {'low';'high'};
pathOut = ([pwd,'/Outputs/']);
load(['/Inputs/TEPs']);
myWindow = [901:1400];

% Run the function
removeSEPs_LinearRegression(ID, condition, tepConds, meanTrials, myWindow, pathOut)

%%
% --------------------------------------------------------------------------------------------------
% Suppress SEPs using ICA
% --------------------------------------------------------------------------------------------------
clear; close all; clc;

% Define the options
pathOut = ([pwd,'/Outputs/']);
load(['/Inputs/TEPs'],'ID','condition');
pathIn = ([pwd,'/Inputs/eegSetFiles']);%## where the preprocessed .set data is stored (should be changed to our public repository)%########
fileName = 'all_blocks_ds_reject_ICA1_clean_ICA2_clean.set';

% Run the function
removeSEPs_ICA(pathIn, fileName, pathOut, ID, condition)

%%
% --------------------------------------------------------------------------------------------------
% Suppress SEPS using SSP-SIR
% --------------------------------------------------------------------------------------------------
clear; close all; clc;

% Define the options
condName ='high'; % options: low,high ****
myWindow = [901:1400]; % Window of time to filter the data. Epoch length is 2000 (-1000:1000) ****
pathOut = ([pwd,'/Outputs/']);
load(['/Inputs/TEPs'],'ID','condition','eeglabChans','meanTrials');
load('/Inputs/leadfieldChan')
lfPath = ([pwd,'/Inputs/Leadfields/']);

% Run the function
removeSEPs_SSPSIR(pathOut, ID, condition, condName, lfPath, leadfieldChan, meanTrials, eeglabChans, myWindow)

%%
% --------------------------------------------------------------------------------------------------
% Dipole fitting
% --------------------------------------------------------------------------------------------------
clear; close all; clc;

% Define the options
pathOut = ([pwd,'/Outputs/']);
cleanMethod = 'SSP-SIR';% options : ICA, Regression, SSP-SIR ****
condName = 'high'; % options : high, low ****
load(['/Inputs/TEPs'],'ID','condition','eeglabChans','meanTrials');
load('/Inputs/indivPeaks.mat')
load('/Inputs/leadfieldChan')
lfPath = ([pwd,'/Inputs/Leadfields/']);
leadField.leadfieldChan = leadfieldChan;
myWindow.OrigBaseLength = 1000; % original epoch length is 2000
myWindow.filtBaseLength = 100; % data from -100 to 400ms poststim were selected to be filtered
myWindow.widowToStudy = 300; % ms post stimulus window to examin

if (strcmp(cleanMethod,'SSP-SIR'))
    load([pathOut, 'SSPSIR-Filtered_',condName,'_TEPs.mat'],'suppr_data_SIR','cleaning_operator');
    filteredData = suppr_data_SIR;
    leadField.cleaning_operator = cleaning_operator;
elseif (strcmp(cleanMethod,'ICA'))
    load([pathOut, 'ICA_cleaned_SEPs.mat'],'meanIcaTrials');
    condNum = find(strcmp(condition, condName));
    filteredData =  meanIcaTrials{condNum};
    
elseif (strcmp(cleanMethod,'Regression'))
    load([pathOut,'RegResiduals'],'spatial_EachSubj_resid');
    condNum = (find(strcmp(condition, condName)))-1;
    filteredData = spatial_EachSubj_resid{condNum};
end

% Run the function
dipoleFit (pathOut, ID, indivPeaks, condition, meanTrials, eeglabChans, myWindow, condName, lfPath, filteredData, cleanMethod, leadField)

%%
% --------------------------------------------------------------------------------------------------
% Mark best fit dipole on cortex
% --------------------------------------------------------------------------------------------------
close all;clear all; clc

% Define the options
condName = 'high';% high or  low ****
pathOut = ([pwd,'/Outputs/']);
anatPath = ([pwd,'/Inputs/Anatomy/']);
load(['/Inputs/TEPs'],'ID');
peakName = {'N20';'P30';'N45';'P60';'N100';'P180';'N280'};
filtName = {'Raw';'SSP-SIR';'ICA';'Regression'};
hotSpotName = 'FDI';

% Call filtered and original data

% Load original and SSPSIR-corrected TEPs
bestmatch_filtered=[];
cleanMethod = [];
cleanMethod = 'SSP-SIR';
load([pathOut,'bestDipole_',cleanMethod,'_',condName],'bestmatch_orig','bestmatch_filtered');
dipole_orig = bestmatch_orig;
dipole_SSP_SIR = bestmatch_filtered;

% Load ICA-corrected TEPs
bestmatch_filtered =[];
cleanMethod = [];
cleanMethod = 'ICA';
load([pathOut,'bestDipole_',cleanMethod,'_',condName],'bestmatch_filtered');
dipole_ICA = bestmatch_filtered;

% Load Regression-corrected TEPs
bestmatch_filtered=[];
cleanMethod = [];
cleanMethod = 'Regression';
load([pathOut,'bestDipole_',cleanMethod,'_',condName],'bestmatch_filtered');
dipole_Regression= bestmatch_filtered;

% The order should be the same as filtName
filtData = [{dipole_orig}, {dipole_SSP_SIR}, {dipole_ICA}, {dipole_Regression}];

% Run the function
markBestDipole(anatPath,ID , peakName, condName, filtName, hotSpotName, filtData)
%%
% --------------------------------------------------------------------------------------------------
% Distace between the best fit dipole from the original and filtered data
% --------------------------------------------------------------------------------------------------
close all;clear all; clc

% Define the options
condName = 'high'; % high, low ****
cleanMethod = 'SSP-SIR'; % ICA, Regression, SSP-SIR  ****
peakName = {'N20';'P30';'N45';'P60';'N100';'P180';'N280'};
hotSpot = 'FDI'; % Name of the stimulated area's scout marked in brainstorm
pathOut = ([pwd,'/Outputs/']);
anatPath = ([pwd,'/Inputs/Anatomy/']);
lfPath = ([pwd,'/Inputs/Leadfields/']);
load(['/Inputs/TEPs'],'ID');

% Run the function
filteredToRaw_DipolDistance (pathOut, ID, anatPath, lfPath, condName, peakName, cleanMethod, hotSpot)

%%
% --------------------------------------------------------------------------------------------------
% Correlation between clean and original TEPs at the selected timewindows (sensor level)
% --------------------------------------------------------------------------------------------------
clear; close all; clc;

% Define the options
tepConds = 'high'; 
correctedCondsNames= {'Lreg';'ICA';'SSPSIR'};
peakWindNames = {'early';'middle';'late'};
winds = [4 6 7]; % The peaks number (nth) at the end of the individualized time windows
meanTrialsWind = [1000:1299];
filterWind = [100:399];
pathOut = ([pwd,'/Outputs/']);
load(['/Inputs/TEPs'],'ID','condition','meanTrials','eeglabChans');
load('/Inputs/indivPeaks.mat')

conds = find(strcmp(condition,tepConds));
timePoints = ones( length(ID),length(winds)+1);
timePoints(:,1) = 16; % The first point of time after interpolation period
timePoints(:,2:end) = indivPeaks{conds-1}(:,winds); % individual peaks are taken from TEP conditions : low, high

% Load original TEPs (before correction) 
for idx = 1:length(ID)
    Orig_meanTrials(:,idx,:) = meanTrials{conds}{idx}(:,meanTrialsWind);
end

% Load Linear regression-corrected TEPs
load([pathOut, 'RegResiduals'],'spatial_EachSubj_resid')
LReg_meanTrials = spatial_EachSubj_resid{conds-1}(:,:,filterWind); % SEP was excluded

% Load ICA-corrected TEPs
load([pathOut, 'ICA_cleaned_SEPs.mat'],'meanIcaTrials');
ICA_meanTrials = meanIcaTrials{conds}(:,:,meanTrialsWind);
 
% Load SSPSIR-corrected TEPs
load([pathOut,'SSPSIR-Filtered_',tepConds,'_TEPs.mat'],'suppr_data_SIR');
SSPSIR_meanTrials = suppr_data_SIR(:,:,filterWind);

% Corrected data matrix
correctedConds = {LReg_meanTrials;ICA_meanTrials;SSPSIR_meanTrials};

% Run the function
cleanUncleanCorrSensors(pathOut,ID ,eeglabChans, timePoints, Orig_meanTrials, correctedConds, correctedCondsNames, tepConds, peakWindNames)

%%
% --------------------------------------------------------------------------------------------------
% Correlation between clean and original TEPs at the selected timewindows (Source level)
% --------------------------------------------------------------------------------------------------
clear; close all; clc;

% Define the options
pathOut = ([pwd,'/Outputs/']);
tepCond = 'high';
correctedCondsNames = {'Lreg';'ICA';'SSPSIR'};
peakWindNames = {'early';'middle';'late'};
winds = [4 6 7]; % The peaks number (nth) at the end of the individualized time windows
vertNum = 15002;
load(['/Inputs/TEPs'],'ID','condition','meanTrials','eeglabChans');
load('/Inputs/indivPeaks.mat')
conds = find(strcmp(condition,tepCond));

timePoints = ones(length(ID),length(winds)+1); 
timePoints(:,2:end) = indivPeaks{conds-1}(:,winds); % peaks are from real TEOP conditions{'low';'high'}
timePoints(:,1) = 16; % The first point of time after interpolation period

% Load source time series estimated from TEPs before (orig) and after filterings (Lreg, ICA, SSPSIR)
load(['/Inputs/Individuals_SourceTimeseries_Original_',tepCond]);
load(['/Inputs/Individuals_SourceTimeseries_LReg_',tepCond]);
load(['/Inputs/Individuals_SourceTimeseries_ICA_',tepCond]);
load(['/Inputs/Individuals_SourceTimeseries_SSPSIR_',tepCond]);

% Save the TEPs (from the specified condition (high))
correctedConds = {LReg_meanSourceTrials; ICA_meanSourceTrials; SSPSIR_meanSourceTrials};

% Run the function
cleanUncleanCorrSource(pathOut,ID ,vertNum, timePoints, Orig_meanSourceTrials, correctedConds, correctedCondsNames, tepCond, peakWindNames)
