function [Nsc_ic, Nsc_ncm, Nsc_ncc] = ICU_allocation(EpiP, IntP, NtT, StT, St, Dim)
nAG =  Dim.nAG;

% Recovery rate of those in their 60s is used as min for ICU entry.
fr_sc_60s = EpiP.fr_sc(7);
% Ratio of survival fractions over the one of 60s.
pfr_sc = EpiP.fr_sc / fr_sc_60s;
% Makes one those over one and keeps those under.
% pfr_sc = (pfr_sc>=1)+mod(pfr_sc,1).*(pfr_sc<1);
pfr_sc = min(1, pfr_sc); 

% People to ICU on medical grounds.
% Nsc_icm = pfr_sc .* St.Nsc;

% Temporarily we do not use medical non ICU admissions.
Nsc_icm = St.Nsc;

% Number with no ICU due under medical criteria.
Nsc_ncm = St.Nsc - Nsc_icm;

% Total number that should get ICU on medical grounds.
Nsc_icmT = sum(Nsc_icm);
% Total number of critical care units available.
capICt = IntP.capICpM(1) * 1e-6 * NtT; 
% Total shortage of IC units to take away from Nsc_icm.
% Nsc_nccT = subplus(Nsc_icmT - capICt);
Nsc_nccT = max(0, Nsc_icmT - capICt);

% Counter of shortage of IC units still pending to take away from Nsc_icm.
left = Nsc_nccT;
% Loop of transfer of Nsc_ic to starting from older to younger.
Nsc_ncc = zeros(1,nAG);
for i=1:nAG
    if left>0
        Nsc_ncc(nAG+1-i) = min(Nsc_icm(nAG+1-i), left);
%         left = subplus(left - St.Nsc(nAG+1-i));
        left = max(0,  left - St.Nsc(nAG+1-i));
    end
end

Nsc_ic = Nsc_icm - Nsc_ncc;