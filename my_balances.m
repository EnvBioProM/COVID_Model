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
function dNi_dt = my_balances(t, St, options, r)

% Population balance equations (Vectorial per age group).
dNh_dt  =-(r.ri_ps + r.ri_s);
dNni_dt = (r.ri_ps + r.ri_s)  - r.rps_ni - r.rr_ni;
dNps_dt = r.rps_ni - r.rs_ps  - r.rr_ps;
dNs_dt  = r.rs_ps  - r.rsh_s  - r.rr_s;
dNsh_dt = r.rsh_s  - r.rsc_sh - r.rr_sh;
dNsc_dt = r.rsc_sh - r.rd_sc  - r.rr_sc;
dNd_dt  = r.rd_sc;
dNr_dt  = r.rr_ni + r.rr_ps + r.rr_s + r.rr_sh + r.rr_sc;

% Returning states derivatives to the solver in one single vector for each state..
dNi_dt = [dNh_dt dNni_dt dNps_dt dNs_dt dNsh_dt dNsc_dt dNd_dt dNr_dt]';
end