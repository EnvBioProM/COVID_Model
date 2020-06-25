% my_stoichiometry.m - MULTIPLIES THE STOICHIOMETRY MATRIX BY THE RATES VECTOR...
% ... AND ALLOWS FOR CHANGES IN THE STOICHIOMETRY MATRRIX IF DESIRED VIA AN EXTERNAL FUNCTION.
% This function does not need any code modification for structural changes
% in the model since it is fully defined by the information in the excel
% file and the rates from 'my_kinetics' .
function [Rt, RtV] = my_stoichiometry(idR);
global R;

% Reading all parameters and variables for this reactor.
stoM = R(idR).stoM;
rV = R(idR).rV;
St = R(idR).St;
vStoM = stoM;

% The stoichiometry matrix can be changed by calling a fully customisable
% external function is desired. Not used in most of the convetional models.
% To call the external function uncomment the next line and write the
% function returning the changed stoM in the variable vStoM.
% [vStoM] = my_stoichange(idR, stoM);


% Multiplication of the current stoichiometry matrix by 
% the reaction rates to calculate the net generation term.
RtV = vStoM * rV;

% Structure with the net formation of each state species.
numSt = length(St.StNames);
for i=1:(numSt)
    Rt.(char(St.StNames(i))) = RtV(i);
end
% Output to global R.
R(idR).Rt = Rt;
R(idR).RtV = RtV;
R(idR).vStoM = vStoM;