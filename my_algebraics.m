% my_algebraics.m - CALCULATES THE ALGEBRAIC VARIABLES FROM THE STATE VARIABLES.
% This function is almost fully customizable by the user, but very easy to use 
% since the names from the structre variables can be used to write the equations 
% and the algebraic variables are created inside a structre called AlgSt.
function [AlgSt, AlgStT, AlgStV, AlgStTV, AlgStNames] = my_algebraics(idR)
global R;
% Reading the global variables to make then available with shorter names.
St   = R(idR).St;       StT  = R(idR).StT;      Dim.nAG = R(idR).Dim.nAG;
GenP = R(idR).GenP;     EpiP = R(idR).EpiP;     IntP = R(idR).IntP;
nAG =  R(idR).Dim.nAG;
NtT = sum(R(idR).StTV);


% Calls the ICU allocation function based on medical and capacity criteria.
[Nsc_ic, Nsc_ncm, Nsc_ncc] = ICU_allocation(EpiP, IntP, NtT, StT, St, Dim);
% Critical individuals are either in ICU or without due to either medical or capacity reasons.
AlgSt.Nsc_ic = Nsc_ic;
AlgSt.Nsc_nc = Nsc_ncm + Nsc_ncc;
AlgSt.Nsc_ncm = Nsc_ncm;
AlgSt.Nsc_ncc = Nsc_ncc;

% ALGEBRAICS required for rates computations.
% Fraction of interactions with PS and S among the total interactions 
AlgSt.f_ips = IntP.rfi_ps.*StT.NpsT / sum(StT.NhT + StT.NniT + sum(IntP.rfi_ps.* StT.NpsT) + sum(IntP.rfi_s.* StT.NsT) + StT.NrT);
AlgSt.f_is  = IntP.rfi_s.* StT.NsT  / sum(StT.NhT + StT.NniT + sum(IntP.rfi_ps.* StT.NpsT) + sum(IntP.rfi_s.* StT.NsT) + StT.NrT);

% Weighted averages of lpa over age groups.
AlgSt.lpa_ps_av = sum(St.Nps.* IntP.lpa_ps)/ StT.NpsT;       if StT.NpsT==0, AlgSt.lpa_ps_av= 0; end
AlgSt.lpa_s_av  = sum(St.Ns .* IntP.lpa_s) / StT.NsT;        if StT.NsT==0,  AlgSt.lpa_s_av = 0; end

% Probability of infection per interaction is function of personal protection and awarenes.
AlgSt.pi_ps = (1-IntP.lpa_h).*(1-AlgSt.lpa_ps_av);
AlgSt.pi_s  = (1-IntP.lpa_h).*(1-AlgSt.lpa_s_av);    

    % %%%%%%% END OF ALGEBRAICS CUSTOMISABLE AREA %%%%%%%%%%%
    
AlgStNames = fieldnames(AlgSt);
AlgStM = zeros(length(AlgStNames),nAG);
for i=1:length(AlgStNames),      AlgStM(i,:) = AlgSt.(char(AlgStNames(i)));   end

% All algebraics in a vector for future outputs.
AlgStV = zeros(1,length(AlgStNames)*nAG);
for i=1:length(AlgStNames)
    AlgStV((i-1)*nAG+1:i*nAG) = AlgStM(i,:);
end

AlgStTV = zeros(1, length(AlgStNames));
% Totals per algebraic state (all age groups added).
for i=1:length(AlgStNames)    
%     eval(strcat('AlgStT.',char(AlgStNames(i)),'T',' = sum(AlgSt.', char(AlgStNames(i)),');'));
    if R(idR).ini == 1  || R(idR).sensAna == 0  
        AlgStT.(strcat(char(AlgStNames(i)),'T')) = sum(AlgSt.(char(AlgStNames(i))));
    else
        AlgStT = R(idR).AlgStT;
    end
    AlgStTV(i) = sum(AlgSt.(char(AlgStNames(i)))); 
end

end