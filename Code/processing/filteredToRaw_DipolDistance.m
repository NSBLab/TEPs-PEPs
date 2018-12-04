function filteredToRaw_DipolDistance (pathOut, ID, anatPath, lfPath, condName, peakName, cleanMethod, hotSpot)

% Distace between the best fit dipole from the original and filtered data
% Mana Biabani, Monash University 
% Nigel Rogasch, Monash University

load([pathOut,'bestDipole_',cleanMethod,'_',condName]);

for idx = 1:length(ID)
    load([anatPath,ID{idx},'_tess_cortex_pial_low.mat']);
    load([lfPath, ID{idx},'_headmodel_surf_openmeeg'],'GridLoc');

    % Name of the selected scouts saved in brainstorm
    a = {Atlas(1).Scouts.Label};
    
    % Find the vertex of the stimulated area
    b = find(strcmp(a,hotSpot));
    
    % The index of the vertex
    c = Atlas(1).Scouts(b).Vertices;
    
    % Coordinate of stimulated site
    fdiVert(idx,:) = GridLoc(c,:)*1000;
    
    % Find the coordinates of the best fit dipoles from raw and filtered data
    for k = 1:length(peakName)
        bFilt= find(strcmp(a,[cleanMethod,'_',condName,'_',peakName{k}]));
        cFilt= Atlas(1).Scouts(bFilt).Vertices;
        filtVert{k}(idx,:) = GridLoc(cFilt,:)*1000;
        bRaw = find(strcmp(a,['Raw_',condName,'_',peakName{k}]));
        cRaw = [Atlas(1).Scouts(bRaw).Vertices];
        if max(cRaw) ~= min(cRaw )
            error('raw data is different across filtering methods')
        end
        
        cRaw = cRaw(1);
        rawVert{k}(idx,:) = GridLoc(cRaw,:)*1000;
        
        % Find the distance between the dipoles and stimulated area
        disToFdi_raw(idx,k) = pdist2(fdiVert(idx,:),rawVert{k}(idx,:));
        disToFdi_filtered(idx,k) = pdist2(fdiVert(idx,:),filtVert{k}(idx,:));
    end
end

% Mean coordinates
meanSubj_fdiVert = mean(fdiVert);
for k = 1:length(peakName)
    meanSubj_rawVert(k,:)= mean(rawVert{k},1);
    meanSubj_filtVert(k,:) = mean(filtVert{k},1);
end

% Mean distances
meanSubj_disToFdi_raw = mean(disToFdi_raw,1);
meanSubj_disToFdi_filtered = mean(disToFdi_filtered,1);

save([pathOut,'distance_bestDipole_',cleanMethod,'_',condName]);
end