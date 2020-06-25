function [outNames, outFlag] = myOutputNames(R, idR)

nAG =  R(idR).Dim.nAG;
outFields = R(idR).Dim;
outFields = rmfield(outFields, 'nAG');
outFields = rmfield(outFields, 'NOut');

%Preallocate names
outNames = cell(1, R(idR).Dim.NOut);

%% StT Names
StTNames = strcat('StT.',R(idR).StNames,'T')';

%% Algebraic Total States
AlgStTNames = strcat('AlgStT.',fieldnames(R(idR).AlgStT))';


%% StNames
%Preallocate StNames
StNames = strings(R(idR).Dim.numStG, nAG);
%St Names per age
for i = 1:length(R(idR).StNames)
    for j = 1:nAG
        StNames(i,j) = strcat('St.', R(idR).StNames(i), sprintf('_%i' ,j));
    end
end
% Reshape into only one vector
StNames = reshape(StNames', 1, R.Dim.numSt);


%%  Algebraic States per Age
%Preallocate matrix
AlgStNames = strings(length(R(idR).AlgStNames), nAG);
%Rates Names per age
for i = 1:length(R(idR).AlgStNames)
    for j = 1:nAG
        AlgStNames(i,j) = strcat('AlgSt.', R(idR).AlgStNames(i), sprintf('_%i' ,j));
    end
end   
% Reshape into only one vector
AlgStNames = reshape(AlgStNames', 1, R.Dim.numAlgStV);

%% Rates Totals 
rTNames = strcat('rT.',fieldnames(R(idR).rT))';

%% Rates vectors
%Preallocate matrix
rNames = strings(length(R(idR).RtNames), nAG);
%Rates Names per age
for i = 1:length(R(idR).RtNames)
    for j = 1:nAG
        rNames(i,j) = strcat('r.', R(idR).RtNames(i), sprintf('_%i' ,j));
    end
end   
% Reshape into only one vector
rNames = reshape(rNames', 1, R.Dim.numRt);

%% Intervention vectors
%Preallocate matrix
IntPnames = strings(length(R(idR).IntPnames), nAG);
%Rates Names per age
for i = 1:length(R(idR).IntPnames)
    for j = 1:nAG
        IntPnames(i,j) = strcat('IntP.', R(idR).IntPnames(i), sprintf('_%i' ,j));
    end
end   
% Reshape into only one vector
IntPnames = reshape(IntPnames', 1, R.Dim.numInt);

%%
outNames = [StTNames, AlgStTNames, StNames, AlgStNames, rTNames, rNames, IntPnames, 'Rt'];

% Flag to indicate that the script has run and does not need to be run
% anymore
outFlag = 1;
