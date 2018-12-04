function markBestDipole(anatPath,ID , peakName, condName, filtName, hotSpotName, filtData)

% Mark best fit dipole on cortex
% Mana Biabani, Monash University 
% Nigel Rogasch, Monash University

for idx = 1:length(ID)
    load([anatPath,ID{idx},'_tess_cortex_pial_low.mat']);
    labels = {Atlas(1).Scouts.Label};
    a = find(strcmp(labels,hotSpotName));
    Atlas(1).Scouts = Atlas(1).Scouts(a); % Remove all of the marked scouts except for the stimulated site
    presentScouts = 1;
    
    for f = 1:length(filtName)
        
        for k = 1:length(peakName)
            cellInd = k+presentScouts; % Starts from the second scout. The stimulation site is the first scout already marked on the cortex.
            Atlas(1).Scouts(cellInd).Vertices = filtData{f}{k}(idx);
            Atlas(1).Scouts(cellInd).Seed = filtData{f}{k}(idx);
            
            if strcmp(filtName{f},'Raw')
                Atlas(1).Scouts(cellInd).Color = [1,1,0];
            elseif strcmp(filtName{f},'SSP-SIR')
                Atlas(1).Scouts(cellInd).Color = [0,0,1];
            elseif strcmp(filtName{f},'ICA')
                Atlas(1).Scouts(cellInd).Color = [1,0,0];
            elseif strcmp(filtName{f},'Regression')
                Atlas(1).Scouts(cellInd).Color = [0,1,1];
            else Atlas(1).Scouts(cellInd).Color = [1,1,0];
            end
            Atlas(1).Scouts(cellInd).Label = [filtName{f},'_',condName,'_',peakName{k}];
            Atlas(1).Scouts(cellInd).Function = 'Mean';
            Atlas(1).Scouts(cellInd).Region = 'LC';
            
        end
        
        presentScouts = cellInd;
    end
    
    % Replace the existing anatomy files
    save([anatPath,ID{idx},'_tess_cortex_pial_low.mat'],'Atlas','-append');
end

end