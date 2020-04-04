% %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% CONTACT:
% Jorge Rodríguez R. PhD MSc FHEA
% Dep.Chemical Engineering
% Khalifa University
% PO Box 127788 Abu Dhabi
% United Arab Emirates
% jorge.rodriguez@ku.ac.ae
% %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

%% SEE DEFINITIONS AND NOMENCLATURE AT THE BOTTOM
function dNi_dt = modelCOVID(t,stN, options, GenP, IntP, EpiP, Rthr, rd_thr, selScn)
global wtFlag
global tR0
global rD_Nt
% Calls rate calculator to compute R.
r = ratesCOVID(stN, GenP, IntP, EpiP);
mIntP = IntP;
rd_scT = [];
NtT = sum(EpiP.Nt);
switch selScn
    case 8      % 'End isolation once R reaches value'
    % If we are below Rthr or were before isolation ends.
    if (r.R0 < Rthr) | wtFlag==1,    
    wtFlag = 1;
    mIntP.ni_h(1,:) = 10;
    end
    
    case 9      % 'End isolation except elderly once R reaches value'
    % If we are below Rthr or were before isolation ends.
    if (r.R0 < Rthr) | wtFlag==1,    
    wtFlag = 1;
    mIntP.ni_h = IntP.ni_h;
    mIntP.ni_h(1,1:6) = 10;
    end
    
    case 10      % 'End isolation once fatality rate reaches value'
    % If we are below number or were before isolation ends.
    rd_scT = sum(r.rd_sc);
    if ((rd_scT/NtT < rd_thr) & (rd_scT/NtT<rD_Nt)) | wtFlag==1,    
    wtFlag = 1;
    mIntP.ni_h(1,:) = 10;
    end
    
    case 11      % 'End isolation (except elderly) once fatality rate reaches value'
    % If we are below number or were before isolation ends.
    rd_scT = sum(r.rd_sc);
    if ((rd_scT/NtT < rd_thr) & (rd_scT/NtT<rD_Nt)) | wtFlag==1,    
    wtFlag = 1;
    mIntP.ni_h = IntP.ni_h;
    mIntP.ni_h(1,1:6) = 10;
    end
    
    otherwise
end
      
% fprintf(strcat('> t = ', num2str(t), '> rD/NtT = ', num2str(rd_scT/GenP.NtT), '> ni_h = ', num2str(mIntP.ni_h(1)), '\n'));

% Calls rate calculator with the modified mIntP
r = ratesCOVID(stN, GenP, mIntP, EpiP);
tR0 = [tR0; t r.R0];
rD_Nt = rd_scT/NtT;
% Population balance equations (Vectorial per age group).
dNhn_dt = zeros(1,length(EpiP.fhn_t));
dNh_dt  =-(r.ri_ps + r.ri_s);
dNps_dt = (r.ri_ps + r.ri_s) - r.rs_ps  - r.rr_ps;
dNs_dt  = r.rs_ps  - r.rsh_s  - r.rr_s;
dNsh_dt = r.rsh_s  - r.rsc_sh - r.rr_sh;
dNsc_dt = r.rsc_sh - r.rd_sc  - r.rr_sc;
dNd_dt  = r.rd_sc;
dNr_dt  = r.rr_ps + r.rr_s + r.rr_sh + r.rr_sc;

% Funtion returning states derivatives to the solver.
dNi_dt = [dNhn_dt dNh_dt dNps_dt dNs_dt dNsh_dt dNsc_dt dNd_dt dNr_dt]';
end