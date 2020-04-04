function r = ratesCOVID(stN, GenP, IntP, EpiP)
% Number of age groups.
nAG = length(EpiP.fhn_t);
% Naming states and vectors management.
Nhn = stN(1:nAG)';          Nh  = stN(1*nAG+1:2*nAG)';  
Nps = stN(2*nAG+1:3*nAG)';  Ns	= stN(3*nAG+1:4*nAG)';  Nsh	= stN(4*nAG+1:5*nAG)';  
Nsc = stN(5*nAG+1:6*nAG)';  Nd	= stN(6*nAG+1:7*nAG)';  Nr	= stN(7*nAG+1:8*nAG)';
Nsc_nc = zeros(1,nAG);      Nsc_ic = zeros(1,nAG);

% Totals per stage independent of age group.
NhnT  = sum(Nhn);   NhT  = sum(Nh);     NpsT = sum(Nps);    NsT  = sum(Ns); 
NshT = sum(Nsh);    NscT = sum(Nsc);    NdT  = sum(Nd);     NrT  = sum(Nr);
% Total population.
Nt = sum(sum(stN));

% ALGEBRAICS required for rates computations.
% Fraction of interactions with PS and S among the total interactions 
f_ips = IntP.rfi_ps.*NpsT / sum(NhnT + NhT + sum(IntP.rfi_ps.* NpsT) + sum(IntP.rfi_s.* NsT) + NrT);
f_is  = IntP.rfi_s.* NsT  / sum(NhnT + NhT + sum(IntP.rfi_ps.* NpsT) + sum(IntP.rfi_s.* NsT) + NrT);

% Weighted averages of lpa over age groups.
lpa_ps_av = sum(Nps.* IntP.lpa_ps)/ NpsT;       if NpsT==0, lpa_ps_av= 0; end
lpa_s_av  = sum(Ns .* IntP.lpa_s) / NsT;        if NsT==0,  lpa_s_av = 0; end

% Probability of infection per interaction is function of personal protection and awarenes.
pi_ps = (1-IntP.lpa_h).*(1-lpa_ps_av);
pi_s  = (1-IntP.lpa_h).*(1-lpa_s_av);

% INFECTION AND TRANSITION RATES
% Infection rates (all vectorial per age group).
r.ri_ps = pi_ps .* f_ips .* IntP.ni_h .* Nh;      % Rate of infection of H by PS for each age range.
r.ri_s  = pi_s  .* f_is  .* IntP.ni_h .* Nh;      % Rate of infection of H by S  for each age range.

% Transition rates (all vectorial per age group).
r.rs_ps  = EpiP.fs_ps  .* Nps ./ EpiP.ts_ps;      % Rate of transition from PS to S  for each age range.
r.rsh_s  = EpiP.fsh_s  .* Ns  ./ EpiP.tsh_s;      % Rate of transition from S  to SH for each age range.
r.rsc_sh = EpiP.fsc_sh .* Nsh ./ EpiP.tsc_sh;     % Rate of transition from SH to SC for each age range.

    % Function for critical care units allocation.
    % Total number of critical care units available.
    capICt = GenP.capICpM * 1e-6 * Nt; 
    % Total shortage of IC units to take away from Nsc_ic.
    Nsc_ncT = subplus(NscT - capICt);
    % Counter of shortage of IC units pending to take away from Nsc_ic.
    left = Nsc_ncT;
    % Loop of transfer of Nsc_ic to Nsc_nc starting from older to younger.
    for i=1:nAG,
        if left>0
        Nsc_nc(nAG+1-i) = min(Nsc(nAG+1-i), left);
        left = subplus(left - Nsc(nAG+1-i));
        end
    end
% Number of individuals in IC per age group is the Nsc minus those with no IC available.
Nsc_ic = Nsc - Nsc_nc;

% Death rate is that of critical in care plus that of critical with no care.
rd_scic = EpiP.fd_sc.*Nsc_ic./ EpiP.td_sc;
rd_scnc = Nsc_nc ./ EpiP.td_nc;
r.rd_sc = rd_scic + rd_scnc;

% Recovery rates (Vectorial per age group)
r.rr_ps = EpiP.fr_ps .* Nps ./ EpiP.tr_ps;        % Rate of recovery from PS for each age range.
r.rr_s  = EpiP.fr_s  .* Ns  ./ EpiP.tr_s;         % Rate of recovery from S  for each age range.
r.rr_sh = EpiP.fr_sh .* Nsh ./ EpiP.tr_sh;        % Rate of recovery from SH for each age range.
r.rr_sc = EpiP.fr_sc.*Nsc_ic./ EpiP.tr_sc;        % Rate of recovery from SC for each age range.

% Age group weighted average rates of infection by PS and S 
ri_psT = sum(r.ri_ps .* Nps) / NpsT;
ri_sT  = sum(r.ri_s  .* Ns)  / NsT;
% Computation of the reproduction number (R0).
r.R0 = sum( (ri_psT/ NpsT)*(EpiP.tr_ps.* EpiP.fr_ps             +  EpiP.ts_ps .* EpiP.fs_ps            ) + ... 
            (ri_sT / NsT) *(EpiP.tr_s .* EpiP.fs_ps.* EpiP.fr_s +  EpiP.tsh_s .* EpiP.fs_ps.*EpiP.fsh_s) );


%  NOMENCLATURE AND DEFINITIONS 
% Name	Definitions		Units	
% tFinal	Length of simulation	(	days	)
% Nhn	Number of healthy non susceptible to infection	(		)
% Nh	Number of healthy	(	#	)
% Nps	Number of preymptomatic	(	#	)
% Ns	Number of symptomatic	(	#	)
% Nsh	Number of symptomatic hospitalised	(	#	)
% Nsc	Number of symptomatic critical	(	#	)
% Nd	Number of dead	(	#	)
% Nr	Number of recovered & immune	(	#	)
% 				
% Nt	Size of total population	(	persons	)
% pzM	Size of patient zero per million	(	infected per million	)
% capIC	Number of critical care beds per million people 	(	IC bed/ million	)
% maxSC	Peak number of critical cases	(	# SC max	)
% maxSH	Peak number of hospitalised cases	(	# SH max	)
% NdF	Total final number of deceased	(	persons	)
% 				
% ni_h	Number of daily interindividual interactions of H	(	# int /# H.d	)
% lpa_h	Level of personal protection and awareness of H	(	[]	)
% rfi_ps	Reduction factor of daily interactions by PS	(	[]	)
% rfi_s	Reduction factor of daily interactions by S	(	[]	)
% lpa_ps	Level of personal protection and awareness of PS	(	[]	)
% lpa_s	Level of personal protection and awareness of S	(	[]	)
% pi_ps	Prob of infection per int with PS	(	# inf / # int-PS	)
% pi_s	Prob of infection per int with S	(	# inf / # int-S	)
% CFR	Case fatality ratio with available care	(	#D/#PS	)
% CFRnc	Case fatality ratio with and without available care	(	#D/#PS	)
% 				
% fhn_t	Fraction of population non susceptible to infection	(	#HS/#H	)
% fs_ps	Fraction of PS that will become S	(	#S/#PS	)
% fsh_s	Fraction of S that will become SH	(	#SH/#S	)
% fsc_sh	Fraction of SH that will become SC	(	#SC/#SH	)
% fd_sc	Fraction of SC that will die D	(	#D/#SC	)
% fr_ps	Fraction of PS that will recover R	(	#R/#PS	)
% fr_s	Fraction of S that will recover R	(	#R/#S	)
% fr_sh	Fraction of SH that will recover R	(	#R/#SH	)
% fr_sc	Fraction of SC that will recover R	(	#R/#SC	)
% 				
% ts_ps	Time to develop symptoms	(	days	)
% tsh_s	Time to become hospitalised	(	days	)
% tsc_sh	Time to become critical	(	days	)
% td_sc	Time to die from critical	(	days	)
% td_nc	Time to die from critical with no IC available	(	days	)
% tr_ps	Time to recover without symptoms	(	days	)
% tr_s	Time to recover from mild symptoms	(	days	)
% tr_sh	Time to recover from hospitalisation	(	days	)
% tr_sc	Time to recover critical	(	days	)
