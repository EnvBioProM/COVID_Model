% %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% CONTACT:
% Jorge Rodríguez R. PhD MSc FHEA
% Dep.Chemical Engineering
% Khalifa University
% PO Box 127788 Abu Dhabi
% United Arab Emirates
% jorge.rodriguez@ku.ac.ae
% %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
function runCOVID(legON, selScn)
global wtFlag
global tR0
global rD_Nt
clc;    warning off 
tic;
% Calls the parameters loader from Excel.
loadPBMcovidParam;

% General parameters for plots
rfXaxis = 1;
if selScn == 0, rfXaxis = 3;    end
if selScn == 1, rfXaxis = 5/3;  end
if selScn == 2, rfXaxis = 3;    end
if selScn == 3, rfXaxis = 3;    end
if selScn == 4, rfXaxis = 2;    end
if selScn == 5, rfXaxis = 3;    end
if selScn == 6, rfXaxis = 3;    end
if selScn == 7, rfXaxis = 2;    end
if selScn == 7, rfXaxis = 2;    end
if selScn == 8, rfXaxis = 3/2;  end
if selScn == 9, rfXaxis = 3/2;  end
if selScn == 10,rfXaxis = 1;    end
if selScn == 11,rfXaxis = 1;    end


%% %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% IMPLEMENTATION OF DYNAMIC INTERVENTIONS
% %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%
% INITIAL OF MODEL STATES FROM PARAMETERS
% POPULATION SIZE AND DISTRIBUTION PER AGE FROM PARAMETERS
Nt_ini  = EpiP.Nt;
Nhn_ini = Nt_ini .* EpiP.fhn_t;
Nh_ini  = Nt_ini - Nhn_ini;
Nps_ini = (EpiP.pzM*1e-6) .* Nt_ini;
% Initial numbers of population types and per age groups. 
% All in a single row vector 1x(8xnAG)
nAG = size(EpiP.Nt,2);
stNini = zeros(1,8*nAG);
stNini(1:nAG)        = Nhn_ini;
stNini(1*nAG+1:2*nAG)= Nh_ini;
stNini(2*nAG+1:3*nAG)= Nps_ini;


% If no intereventions 
if selScn==0, selScn=100;   end


% %%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% TEMP predefined values for the selected scenarios of intervention.
switch selScn
    case 100  % 'Do nothing'
        P = [1];
    % STATIC INTERVENTIONS
    case 1  % 'Individual isolation (non age selective)'
        P = [0:0.1:2 2.25:0.2:8];
        if legON==1,    P = [0:1:6];    end
    case 2  % 'Individual isolation (elderly only 60+)'
        P = [0:0.1:2 2.25:0.2:8];
        if legON==1,    P = [0:1:6];    end
    case 3  % 'Individual isolation (youngest only 0-19)'
        P = [0:0.1:2 2.25:0.2:8];
        if legON==1,    P = [0:1:6];    end
    case 4  % 'Individual isolation (elderly and youngest)'
        P = [0:0.1:2 2.25:0.2:8];
        if legON==1,    P = [0:1:6];    end
    case 5  % 'Intensive Care Beds per Million'
        P = [0:25:1500];
        if legON==1,    P = [0:250:1500];    end
    case 6  % 'Increase in PPE and measures'
        P = [0:0.1:2.5];
        if legON==1,    P = [0:0.5:2.5];    end
        % Record to apply the factor to the original values.
        org_lpa_h  = IntP.lpa_h;
        org_lpa_ps = IntP.lpa_ps;
        org_lpa_s  = IntP.lpa_s;
    case 7  % 'Implementation of extensive testing'
        P = [0:0.02:1];
        if legON==1,    P = [0 0.1 0.2:0.2:1 2];    end
        org_rfi_ps = IntP.rfi_ps;
        org_rfi_s  = IntP.rfi_s;

    % DYNAMIC INTERVENTIONS
    case 8  % 'End isolation once R reaches value'
        % Default intervetion to be withdrawn ni_h value.
        IntP.ni_h(1,:) = 1;
        P = [0:0.05:1.5 1.75:0.25:3];
        if legON==1,    P = [0:0.5:3];    end
    case 9  % 'End isolation (except elderly) once R reaches value'
        % Default intervetion to be withdrawn ni_h value.
        IntP.ni_h(1,:) = 1;
        P = [0:0.05:1.5 1.75:0.25:4];
        if legON==1,    P = [0:0.5:4];    end
        
     case 10  % 'End isolation once daily fatality rate per million reaches value'
        % Default intervetion to be withdrawn ni_h value.
        IntP.ni_h(1,:) = 1;
        P = [0.1:0.2:4.9 5:1:9 9.1:0.1:12];
        if legON==1,    P = [0.1 1:2:12 ];   end
        
     case 11  % 'End isolation (except elderly) once daily fatality rate per million reaches value'
        % Default intervetion to be withdrawn ni_h value.
        IntP.ni_h(1,:) = 1;
        P = [0.1:0.2:4.9 5:1:9 9.1:0.1:12];
        if legON==1,    P = [0.1 1:2:12];   end
end
% %%%%%%%%%%%%%%%%%%%%%%%%%%%%%1

% reset all figures
if (legON==1)&&(selScn~=0)
    figure(selScn);  clf;
end

% Runs the scenario as per type and parameter values selected 
for i=1:length(P),
    % Applies the parameters for the selected scenario of intervention.
    switch selScn
        case 100  % 'Do nothing'
        dynInt = 0;
        labelX = 'No intervention evaluated';
        strLegInt = 'par_Int =';
        
        case 1      % 'Individual isolation (non age selective)'
        dynInt = 0;
        IntP.ni_h(1,:) = P(i);
        labelX = 'Daily Social Interactions';
        strLegInt = 'ni_h =';
        
        case 2      % 'Individual isolation (elderly only 60+)'
        dynInt = 0;
        IntP.ni_h(1,7:9) = P(i);
        labelX = 'Daily Social Interactions (Elderly)';
        strLegInt = 'ni_h =';
        
        case 3      % 'Level of individual isolation (youngest only 0-19)'
        dynInt = 0;
        IntP.ni_h(1,1:2) = P(i);
        labelX = 'Daily Social Interactions (Youngsters)';
        strLegInt = 'ni_h =';
        
        case 4      % 'Level of individual isolation (elderly and youngest)'
        dynInt = 0;
        IntP.ni_h(1,1:2) = P(i);
        IntP.ni_h(1,7:9) = P(i);
        labelX = 'Daily Social Interactions (Elderly & Young)';
        strLegInt = 'ni_h =';
        
        case 5      % 'Intensive Care beds per Million'
        dynInt = 0;
        GenP.capICpM = P(i);
        labelX = 'Intensive Care Beds per million';
        strLegInt = 'ICbed_p_M =';
        
        case 6      % 'Increase in personal protection measures'
        dynInt = 0;
        IntP.lpa_h  = P(i)*org_lpa_h;  if max(IntP.lpa_h)>1,   IntP.lpa_h  = IntP.lpa_h /max(IntP.lpa_h);   end
        IntP.lpa_ps = P(i)*org_lpa_ps; if max(IntP.lpa_ps)>1,  IntP.lpa_ps = IntP.lpa_ps/max(IntP.lpa_ps);  end
        IntP.lpa_s  = P(i)*org_lpa_s;  if max(IntP.lpa_s)>1,   IntP.lpa_s  = IntP.lpa_s /max(IntP.lpa_s);   end
        labelX = 'Increase in PPE use';
        strLegInt = 'fPPE =';
        
        case 7      % 'Implementation of rapid testing to all'
        dynInt = 0;
        IntP.rfi_ps = P(i)*org_rfi_ps; if max(IntP.rfi_ps)>1,   IntP.rfi_ps = IntP.rfi_ps /max(IntP.rfi_ps); end
        IntP.rfi_s  = P(i)*org_rfi_s ; if max(IntP.rfi_s)>1,    IntP.rfi_s  = IntP.rfi_s  /max(IntP.rfi_s);  end
        labelX = 'Isolation factor by infection awareness';
        strLegInt = 'iFinfA =';

        % DYNAMIC INTERVENTIONS
        case 8  % 'End isolation once R reaches value'
        dynInt = 1;
        Rthr = P(i);
        rd_thr = -1;
        spC = 0;    % No set point control below the threshold, one off withdraw.
        labelX = 'Ro value from which isolation ends';
        strLegInt = 'R_0_e_n_d_I =';
              
        case 9  % 'Social isolation to under remain under R value'
        dynInt = 1;
        Rthr = P(i);
        rd_thr = -1;
        spC = 0;    % Set point control below the threshold, one off withdraw.
        labelX = 'Ro value from which isolation ends';
        strLegInt = 'R_0_e_n_d_I =';

        case 10  % 'End isolation once fatality rate reaches value'
        dynInt = 1;
        Rthr = -1;
        rd_thr = P(i)*1e-6;
        spC = 0;    % Set point control below the threshold, one off withdraw.
        labelX = 'Daily fatality rate per M from which isolation ends';
        strLegInt = 'Frate_pM =';
        
        case 11  % End isolation (except elderly) once fatality rate reaches value'
        dynInt = 1;
        Rthr = -1;
        rd_thr = P(i)*1e-6;
        spC = 0;    % Set point control below the threshold, one off withdraw.
        labelX = 'Daily fatality rate per M from which isolation ends';
        strLegInt = 'Frate_pM =';

    end
    
% Reset global variables used in the solvers.
tR0=[];
wtFlag = 0; rD_Nt = 0;

    if dynInt==0,
% Defining variables if no dynInt to feed to function call.
if dynInt ==0,  Rthr = 0;   rd_thr = 0; end
    end
   
% Calls the model simulation solver for the current parameter values.
[tsim,stNt] = ode23('modelCOVID', [0:1:GenP.tFinal], stNini,[], GenP, IntP, EpiP, Rthr, rd_thr, selScn);

% Naming states and vectors management.
St.Nhn = stNt(:,0*nAG+1:nAG);        St.Nh  = stNt(:,1*nAG+1:2*nAG);  
St.Nps = stNt(:,2*nAG+1:3*nAG);      St.Ns  = stNt(:,3*nAG+1:4*nAG);
St.Nsh = stNt(:,4*nAG+1:5*nAG);      St.Nsc = stNt(:,5*nAG+1:6*nAG);   
St.Nd  = stNt(:,6*nAG+1:7*nAG);      St.Nr  = stNt(:,7*nAG+1:8*nAG); 
% Totals per state (all age groups added).
StT.NhnT = sum(St.Nhn,2);    StT.NhT  = sum(St.Nh,2);
StT.NpsT = sum(St.Nps,2);    StT.NsT  = sum(St.Ns,2);
StT.NshT = sum(St.Nsh,2);    StT.NscT = sum(St.Nsc,2);
StT.NdT  = sum(St.Nd,2);     StT.NrT  = sum(St.Nr,2);

% Calculation and storage of Outputs.
Out(i).St = St;
Out(i).StT = StT;
% Number of active cases in either stage of infection over time for simulation i.
Out(i).nCases = StT.NpsT + StT.NsT + StT.NshT + StT.NscT;
% Reproduction number Ro.
Out(i).tR0 = sortrows(tR0);
% Maximum of total critical cases for simulation i.
Out(i).maxSC = max(StT.NscT);
% Total final number of fatalities for simulation i.
Out(i).NdF = St.Nd(size(St.Nd,1),:);


% %%%%%%%%%%%%%%%%%%%%%%%%%%
% PLOTS INSIDE THE LOOP
if legON==1;
% Active cases over time
figure(selScn);
subplot(3,2,3);
plot(tsim, Out(i).nCases);
% title('Number of cases over Time');
xlabel('Time (days)') 
ylabel('Number of cases (%)') 
axis([0 GenP.tFinal/rfXaxis 0 Inf])
    % Building a legend for each intervention parameter.
    if legON==1,
    str='';
        for j=1:length(P)-1,
    str = strcat(str,'''', num2str(P(j)),'''',',');
        end
    str = strcat(str,'''', num2str(P(length(P))),'''');
    str = strip(str,'left', '''');
    legStr =strcat(strLegInt, str);
    eval(strcat('legend({','''',legStr,'},', '''','Location','''',',','''','northeast', '''',')'));
    end
grid on
hold on

% R over time
figure(selScn);
subplot(3,2,4);
%     if dynInt==1,
plot(Out(i).tR0(:,1), Out(i).tR0(:,2));
%     else
% plot(tsim, Out(i).R0);
%     end
% title('Reproduction number profiles');
xlabel('Time (days)') 
ylabel('Reproduction number (R0)') 
axis([0 GenP.tFinal/rfXaxis 0 Inf])
if dynInt==1,   axis([0 GenP.tFinal/rfXaxis 0 5]);  end
    % Building a legend for each intervention parameter.
    if legON==1,
    str='';
        for j=1:length(P)-1,
    str = strcat(str,'''', num2str(P(j)),'''',',');
        end
    str = strcat(str,'''', num2str(P(length(P))),'''');
    str = strip(str,'left', '''');
    legStr =strcat(strLegInt, str);
    eval(strcat('legend({','''',legStr,'},', '''','Location','''',',','''','northeast', '''',')'));
    end
grid on
hold on

% Critical cases over time
figure(selScn);
subplot(3,2,5);
plot(tsim, StT.NscT);
% title('Number of critical cases ');
xlabel('Time (days)') 
ylabel('Number of critical cases (%)') 
axis([0 GenP.tFinal/rfXaxis 0 Inf])
    % Building a legend for each intervention parameter.
    if legON==1,
    str='';
        for j=1:length(P)-1,
    str = strcat(str,'''', num2str(P(j)),'''',',');
        end
    str = strcat(str,'''', num2str(P(length(P))),'''');
    str = strip(str,'left', '''');
    legStr =strcat(strLegInt, str);
    eval(strcat('legend({','''',legStr,'},', '''','Location','''',',','''','northeast', '''',')'));
    end
grid on
hold on

% Total fatalities over time
figure(selScn);
subplot(3,2,6);
plot(tsim, StT.NdT);
% title('Total fatalities over Time');
xlabel('Time (days)') 
ylabel('Number of fatalities (%)') 
axis([0 GenP.tFinal/rfXaxis 0 Inf])
    % Building a legend for each intervention parameter.
    if legON==1,
    str='';
        for j=1:length(P)-1,
    str = strcat(str,'''', num2str(P(j)),'''',',');
        end
    str = strcat(str,'''', num2str(P(length(P))),'''');
    str = strip(str,'left', '''');
    legStr =strcat(strLegInt, str);
    eval(strcat('legend({','''',legStr,'},', '''','Location','''',',','''','northeast', '''',')'));
    end
grid on
hold on
end
% END OF PLOTS INSIDE THE LOOP
% %%%%%%%%%%%%%%%%%%%%%%%%%%%%

end
% Display time elapsed and name of inputs file used for integrity.
fprintf(strcat('>> #', num2str(length(P)),  '# simulations run in #', num2str(toc), '# seconds\n'));
fprintf(strcat('\n\n>> Inputs Excel file was "',myModelName, '"\n'));
filename=strcat('resIntScenario(', num2str(selScn), ').mat');
save(filename,'Out','P','GenP','IntP','EpiP')


% Outputs Processing
X=P';
vNdTF = zeros(length(X),1);
NdF  = zeros(length(X),nAG);
    for i=1:length(X),
vNdTF(i)=sum(Out(i).NdF);
NdF(i,:) = Out(i).NdF;
    end

% %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% PLOTTING FINAL FIGURES
if legON==0,
figure(selScn);
subplot(3,2,1);
plot(X, vNdTF);
% title('Final fatalities vs. daily interactions');
xlabel(labelX) 
ylabel('Final total fatalities (%)')
axis([0 max(P) 0 Inf])
grid on

figure(selScn);
subplot(3,2,2);
plot(X, NdF);
% title('Final fatalities per age vs. daily interactions');
xlabel(labelX) 
ylabel('Final total fatalities per age (%)')
legend({'0s','10s','20s','30s','40s','50s','60s','70s','80+'},'Location','northeast')
axis([0 max(P) 0 Inf])
grid on
end

% END OF PLOTTING FINAL FIGURES
% %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%


if selScn==100
% Population types vs Time
figure(selScn);
subplot(3,2,1);
stNt = [StT.NhnT StT.NhT StT.NpsT StT.NsT StT.NshT StT.NscT StT.NdT StT.NrT];
plot(tsim, (stNt));
% title('Population types over Time');
xlabel('Time (days)') 
ylabel('Total population in each stage (%)') 
axis([0 GenP.tFinal/rfXaxis 0 Inf])
legend({'NhnT','NhT','NpsT','NsT','NshT','NscT','NdT','NrT'},'Location','northeast')
grid on
% % SH and SC vs Time
% figure(selScn);
% subplot(3,2,1);
% stNt = [StT.NshT StT.NscT];
% plot(tsim, (stNt));
% % title('Population types over Time');
% xlabel('Time (days)') 
% ylabel('Total population in danger stages (%)') 
% axis([0 GenP.tFinal/rfXaxis 0 Inf])
% legend({'NshT','NscT'},'Location','northeast')
% grid on

end








end