
% %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% DERIVATIVES CALCULATION TASK
% No code modification is needed for most of the traditional models . 
% It accepts however modifications and additions in the differential equations as indicated.
function [sys] = mdlSimulator(t, x, u, idR, dynInt)
global R;
R(idR).t = t;   % Current time recorded for external access if necesary.
R(idR).ini = 0;
% Shorter names of some global variables used here.
Dim = R(idR).Dim;       St = R(idR).St;
nAG = R(idR).Dim.nAG;

%% Updates the state variables with current solver state (x).
aux = R(idR).StNames;
auxT = strcat(aux, 'T');
StV = x';
StTV = zeros(1,Dim.numStG);

for i=1:(Dim.numStG)    
    St.(char(aux(i))) = StV((i-1)*nAG+1:i*nAG);
%     StT.(strcat(char(aux(i)),'T')) = sum(StV(:,(i-1)*nAG+1:i*nAG));
    StTV(i) = sum(StV((i-1)*nAG+1:i*nAG));    
    StT.(char(auxT(i)))           = StTV(i);   
end

% Totals per state (all age groups added).
% for i=1:(Dim.numStG)
% %     eval(strcat('StT.',char(aux(i)),'T',' = sum(StV((i-1)*nAG+1:i*nAG));'));
%     StT.(strcat(char(aux(i)),'T')) = sum(StV(:,(i-1)*nAG+1:i*nAG));
% end
% Totals of the states for all ages,.
% StTV = zeros(1,Dim.numStG);
% aux = R(idR).StNames;
% for i=1:Dim.numStG
%     StTV(i) = sum(St.(char(aux(i))));
% end

% Update also in the global struture for use by other functions.
R(idR).St  = St;
R(idR).StT = StT;
R(idR).StV = StV;
R(idR).StTV = StTV;

%% Calls all fucntions needed for the differential equations terms.
% Calls for algebraics calculation function.
[AlgSt, AlgStT, AlgStTV AlgStV, AlgStNames] = my_algebraics(idR);

% Updates global R.
R(idR).AlgSt  = AlgSt;
R(idR).AlgStT = AlgStT;
R(idR).AlgStV = AlgStV;
R(idR).AlgStTV = AlgStTV;
R(idR).AlgStNames  = fieldnames(AlgSt);

% Calls for calculation of the interventions as per schedule.
    if dynInt~=0
[IntP, IntPV] = my_interventions(t, u, idR, dynInt);

R(idR).IntP = IntP;
R(idR).IntPV = IntPV;
    end

% Function calculating the reaction and transfer rates from states and algebraics.
[r, rT, rV, rTV] = my_rates(idR);
% Updates global R.
R(idR).r = r;       
R(idR).rT = rT;
R(idR).rV = rV;
R(idR).rTV = rTV;

% This function multiplies the stoichiometry matrix by the rates vector and
% returns the vector of net generation terms Ri for each state variable to
% be used in the mass balances.
% [Rt, RtV] = my_transitions(idR);

%% Differential equations for state transition.
if isfield(R(idR),'idR')==1
GenP = R(idR).GenP;
IntP = R(idR).IntP ;
EpiP= R(idR).EpiP ;
Rthr = R(idR).Rthr;
rd_thr = R(idR).rd_thr;
selScn = R(idR).selScn;
    [dNi_dt] = dynModelCOVID(t,R(idR).StV, [], GenP, IntP, EpiP);
else
    [dNi_dt] = my_balances(t,R(idR).St, [], r);
end

% Derivatives provided for the solver.
sys = dNi_dt;