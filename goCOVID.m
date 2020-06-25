clear all; 
global R oP
global wtFlag
global tRt
global rD_Nt

% Calls the parameters loader from Excel.
% loadPBMcovidParam;
idR = 1; 
tFinal = 365;
oP=2;
mdlInitializeSizes(idR,0);
R(idR).idR=1;
R(idR).GenP.tFinal = tFinal;

origEpiP = R(idR).EpiP;
origIntP = R(idR).IntP;
origGenP = R(idR).GenP;

% Save Results
printDateName = datestr(now,'yymmdd');
saveFileName = strcat(printDateName, '_goCOVIDResults.mat');


%Print Results Properties
printToFile = 0;
printPath = strcat(pwd, '\ScenarioResults\');

% Print all figures
paperWidth   = 24;
paperHeight = 16;
outputFileName = 'Scenario';


%% %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% EXECUTION OF THE MODEL SCENARIO SIMULATIONS
% Selection of scenario for intervention and values to evaluate.
dynInt = 0;     % By default we are in static interventions mode.
selScn = input(strcat(...
'SELECT ONE from this list of static intervention scenarios: \n',...
'(0): Do nothing (default parameters used)\n',...
'(1): Imposed social isolation (non age selective)\n',...
'(2): Imposed social isolation (elderly 60+ only)\n',...
'(3): Imposed social isolation (youngest only 0-19)\n',...
'(4): Imposed social isolation (elderly and youngest)\n',...
'(5): Intensive care beds per Million\n',...
'(6): Increase in PPE & measures\n',...
'(7): Implementation of extensive testing for pre-symptomatic people\n',...
'(8): Implementation of extensive testing for symptomatic people\n',...
'(9): Implementation of rapid testing to symptomatic and non-symptomatic people\n',...
'Select one of (-1) to run all interventions-> #'));

%Building all interventions scenario
if selScn==-1
    selScn = 0:9;
end 
    
% Evaluate each intervention per scenario
for i=1:length(selScn)
    
    R(idR).EpiP = origEpiP;
    R(idR).IntP = origIntP;
    R(idR).GenP = origGenP;
    
    runCOVID(1,1,selScn(i),R(idR).GenP, R(idR).EpiP, R(idR).IntP, R(idR).iniStM);
    [P, vNdTF, Out] = runCOVID(1,0,selScn(i),R(idR).GenP, R(idR).EpiP, R(idR).IntP, R(idR).iniStM);
    
    %Store outputs for total results
    numScn = strcat('Scn', num2str(selScn(i)));
    Output.(char(numScn))  = Out;
    Output.(char(numScn))(1).vNdTF = vNdTF;
    numInt.(char(numScn))  = P;
    numTotF.(char(numScn)) = vNdTF;
  
end

    