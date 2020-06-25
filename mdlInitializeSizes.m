%% %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% MODEL INITIALISATION TASK.
% This section is generic and does not need to be modified.
function [sys,x0,str,ts] = mdlInitializeSizes (idR,dynInt)
global R oP
% If parameter optimisation is being conducted no read of default parameters.
    if (isempty(oP)==1 | oP==0) | oP==2
% The reader of model structure and parameters from Excel is called here.
fprintf('\n>>>> Reading the Model Parameters from Excel...\n');
loadCOVIDxls(idR,dynInt);
fprintf('\n... Model and Simulation Parameters Loaded >>>>>\n');        
    end
    
% Flag for initialisation.
ini = 1;
R(idR).ini = ini;
    
sizes = simsizes;
sizes.NumContStates  = prod(size(R(idR).iniStM)); % Total number of states (rows times columns).
sizes.NumDiscStates  = 0;
nAG = size(R(idR).iniStM,2);
Dim.nAG = nAG;
Dim.numStG = length(R(idR).StNames);          % Number of state groups.
Dim.numSt = prod(size(R(idR).iniStM));          % Number of state variables types.
Dim.numRtT = length(R(idR).RtNames);          % No. of rates totals .
Dim.numRt = size(R(idR).RtNames,2)*nAG;          % No. of rates age distributed.
Dim.numInt = length(R(idR).IntPnames)*Dim.nAG;% The time vector is not included.


sizes.NumInputs = -1;   % Automatic.
% The number of outputs is the number of states plus the number of algebraic variables plus the number
% of rates plus the number of net generation rates plus the number of feeding stream variables.
% % Dim.NOut = Dim.numStG + Dim.numSt + Dim.numRt + Dim.numInt + 1;    % Tha additional output is the Ro.
% 
% sizes.NumOutputs = Dim.NOut;
% sizes.NumSampleTimes = 1;
    
%% %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% SET UP OF STATES NAMES AND VALUES.
% INITIAL OF MODEL STATES
    % %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    % SPECIAL TASK TO SET INITIAL STATES FOR INFECTED AS FUNCTION OF pzM
    % Aplying patient zero numbers are distributed between NI and PS
    % proportional to the time durations in each stage.
    tps_ni = R(idR).EpiP.tps_ni;
    ts_ps  = R(idR).EpiP.ts_ps;
    R(idR).iniStM(2,:) = (tps_ni./(tps_ni + ts_ps)).*(R(idR).GenP.pzM/1e6).* R(idR).iniStM(1,:);
    R(idR).iniStM(3,:) = (ts_ps./(tps_ni + ts_ps)) .*(R(idR).GenP.pzM/1e6).* R(idR).iniStM(1,:);
    % END OF SPECIAL TASK
    % %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    
% Initial numbers of population types and per age groups. 
% All in a single row vector 1x(nAGx2genders)
stNiniV = zeros(1,Dim.numStG*nAG);
% All states in a vector from the initial matrix.
for i=1:Dim.numStG
    stNiniV((i-1)*nAG+1:i*nAG) = R(idR).iniStM(i,:);
end
% Setup of states names and values.
aux = R(idR).StNames;
StV = stNiniV;
for i=1:(Dim.numStG)    
    St.(char(aux(i))) = StV(:,(i-1)*nAG+1:i*nAG);
end

% Totals per state (all age groups added).
for i=1:(Dim.numStG)    
%     eval(strcat('StT.',char(aux(i)),'T',' = sum(StV(:,(i-1)*nAG+1:i*nAG));'));
    StT.(strcat(char(aux(i)),'T')) = sum(StV(:,(i-1)*nAG+1:i*nAG));
end
% Totals of the states for all ages,.
StTV = zeros(1,length(R(idR).StNames));
aux = R(idR).StNames;
for i=1:length(R(idR).StNames)
    StTnames(i) = strcat(R(idR).StNames(i),'T');
    StTV(i) = sum(St.(char(aux(i))));
end
% %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Dimensions into the global R.
R(idR).Dim = Dim;
% Update also in the global struture for use by other functions.
R(idR).St  = St;
R(idR).StV = stNiniV;
R(idR).StT  = StT;
R(idR).StTV = StTV;
R(idR).StTnames = StTnames;
% Called here to generate the names of the algebraic variables.
[AlgSt, AlgStT, AlgStV,  AlgStTV, AlgStNames] = my_algebraics(idR);
R(idR).AlgSt  = AlgSt;
R(idR).AlgStT = AlgStT;
R(idR).AlgStTV = AlgStTV;
R(idR).AlgStV = AlgStV;
R(idR).AlgStNames  = fieldnames(AlgSt);

Dim.numAlgStT = length(fieldnames(AlgStT));
Dim.numAlgStV = length(AlgStV);

Dim.NOut = Dim.numStG + Dim.numAlgStT + Dim.numSt + Dim.numAlgStV + Dim.numRtT + Dim.numRt + Dim.numInt + 1;    % The additional output is the Ro.

% Re-update dimensions into the global R.
R(idR).Dim = Dim;
sizes.NumOutputs = Dim.NOut;
sizes.NumSampleTimes = 1;

sys = simsizes(sizes);
x0  = R(idR).StV';       % Initial values of the state variables.
str = [];
ts  = [0 0];
% %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
end