clear all; 
global wtFlag
global tR0
global rD_Nt
%% %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% EXECUTION OF THE MODEL SCENARIO SIMULATIONS
% Selection of scenario for intervention and values to evaluate.
dynInt = 0;     % By default we are in static interventions mode.
selScn = input(strcat('SELECT ONE from this list of static intervention scenarios: \n', ...
'(0): Do nothing (default parameters used)\n',...
'(1): Imposed social isolation (non age selective)\n',...
'(2): Imposed social isolation (elderly 60+ only)\n',...
'(3): Imposed social isolation (youngest only 0-19)\n',...
'(4): Imposed social isolation (elderly and youngest)\n',...
'(5): Intensive care beds per Million\n',...
'(6): Increase in PPE & measures\n',...
'(7): Implementation of extensive population testing\n',...
'OR from this list of dynamic interventions\n',...
'(8): End isolation once Ro reaches value\n',...
'(9): End isolation (except elderly) once Ro reaches value\n',...
'(10): End isolation once fatality rate reaches value\n',...
'(11): End isolation (except elderly) once fatality rate reaches value\n',...
'Select one of (-1) to run all interventions-> #'));

if selScn==-1,
    for i=1:11,
    runCOVID(1, i);
    runCOVID(0, i);
    end
else
    runCOVID(1, selScn);
    runCOVID(0, selScn);
end
