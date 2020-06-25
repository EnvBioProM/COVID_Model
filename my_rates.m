% my_kinetics.m - CALCULATES THE REACTION AND TRANSFER FROM THE STATE AND ALGEBRAIC VARIABLES.
% This function is very easily customizable by the user using the names from the structure
% variables to write the equations. The rates must be created inside a structre called r.
function [r, rT, rV, rTV] = my_rates(idR)
global R oP;
% Reading all parameters and variables for this reactor.
St = R(idR).St;         StT = R(idR).StT;         AlgSt = R(idR).AlgSt; 
GenP = R(idR).GenP;     EpiP = R(idR).EpiP;     IntP = R(idR).IntP;

    % %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    % CUSTOMISABLE AREA FOR THE MODEL IMPLEMENTED
% INFECTION, TRANSITION DEATH AND RECOVERY RATES (all vectors per age group)
% Infection rates (all vectorial per age group).
r.ri_ps = AlgSt.pi_ps .* AlgSt.f_ips .* IntP.ni_h .* St.Nh;      % Rate of infection of H by PS for each age range.
r.ri_s  = AlgSt.pi_s  .* AlgSt.f_is  .* IntP.ni_h .* St.Nh;      % Rate of infection of H by S  for each age range.
% Transition rates between stages.
r.rps_ni = EpiP.fps_ni.* St.Nni ./ EpiP.tps_ni;     % Rate of transition from NI to PS for each age range.
r.rs_ps  = EpiP.fs_ps .* St.Nps ./ EpiP.ts_ps;      % Rate of transition from PS to S  for each age range.
r.rsh_s  = EpiP.fsh_s .* St.Ns  ./ EpiP.tsh_s;      % Rate of transition from S  to SH for each age range.
r.rsc_sh = EpiP.fsc_sh.* St.Nsh ./ EpiP.tsc_sh;     % Rate of transition from SH to SC for each age range.
% Death rate for critical. (Mortality for those in care plus all for those without care).
r.rd_sc  = EpiP.fd_sc .* AlgSt.Nsc_ic ./ EpiP.td_sc +  AlgSt.Nsc_nc ./ EpiP.td_nc;
% Recovery rates.
r.rr_ni  = EpiP.fr_ni .* St.Nni ./ EpiP.tr_ni;      % Rate of recovery from NI for each age range.
r.rr_ps  = EpiP.fr_ps .* St.Nps ./ EpiP.tr_ps;      % Rate of recovery from PS for each age range.
r.rr_s   = EpiP.fr_s  .* St.Ns  ./ EpiP.tr_s;       % Rate of recovery from S  for each age range.
r.rr_sh  = EpiP.fr_sh .* St.Nsh ./ EpiP.tr_sh;      % Rate of recovery from SH for each age range.
r.rr_sc  = EpiP.fr_sc .* AlgSt.Nsc_ic ./ EpiP.tr_sc;% Rate of recovery from SC in care for each age range.



        % %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
        % COMPUTATION OF THE Ro as additional output.
        if oP==2
        % Age group weighted average rates of infection by PS and S 
        ri_psT = sum(r.ri_ps .* St.Nps) / StT.NpsT;
        ri_sT  = sum(r.ri_s  .* St.Ns)  / StT.NsT;
        % Computation of the reproduction number (R0).
        Rt = sum( (ri_psT/ StT.NpsT)*(EpiP.tr_ps.* EpiP.fr_ps             +  EpiP.ts_ps .* EpiP.fs_ps            ) + ... 
                    (ri_sT / StT.NsT) *(EpiP.tr_s .* EpiP.fs_ps.* EpiP.fr_s +  EpiP.tsh_s .* EpiP.fs_ps.*EpiP.fsh_s) );
        if isnan(Rt)    Rt=0;   end
             r.Rt=Rt;
        end
        % %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

    % END OF THE CUSTOMISABLE AREA
    % %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

% All rates in a vector for future outputs.
nAG = R(idR).Dim.nAG;
RtNames = R(idR).RtNames;

if R(idR).sensAna
    % A faster alternative
    rV = [r.ri_ps,  r.ri_s,   r.rps_ni,  r.rs_ps,  r.rsh_s,  r.rsc_sh,...
          r.rd_sc,  r.rr_ni,  r.rr_ps,   r.rr_s,   r.rr_sh,  r.rr_sc];
    rTV = sum(reshape(rV,  nAG, length(RtNames)));
else
    rV = zeros(1,length(RtNames)*nAG);
    rTV = zeros(1, length(RtNames));
    for i=1:length(RtNames)
        rV((i-1)*nAG+1:i*nAG) = r.(char(RtNames(i)));
        rTV(i) = sum(rV((i-1)*nAG+1:i*nAG));
    end
end



% Totals per algebraic state (all age groups added).

if R(idR).t > 0 &&  R(idR).sensAna == 1 
    rT =  R(idR).rT;
else
    for i=1:length(RtNames)    
        rT.(strcat(char(RtNames(i)),'T')) = sum(r.(char(RtNames(i))));
    end     
end

% for i=1:length(RtNames)    
% %     eval(strcat('rT.',char(RtNames(i)),'T',' = sum(r.', char(RtNames(i)),');'));
% %     rT.(strcat(char(RtNames(i)),'T')) = sum(r.(char(RtNames(i))));
%     rTV2(i) = sum(r.(char(RtNames(i))));
% end    
    
end