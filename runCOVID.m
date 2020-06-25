% %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% CONTACT:
% Jorge Rodríguez R. PhD MSc FHEA
% Dep.Chemical Engineering
% Khalifa University
% PO Box 127788 Abu Dhabi
% United Arab Emirates
% jorge.rodriguez@ku.ac.ae
% %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
function [P, vNdTF, Out] = runCOVIDv2(figON, legON, selScn, GenP, EpiP, IntP, iniSt)
global R
global wtFlag
global tRt trDpM
global rD_Nt
clc;    warning off 
tic;

idR = R.idR;
nAG =R(idR).Dim.nAG;

% Print PDF
plotPDF = 1;
paperWidth = 24;
paperHeight = 16;
printPath = strcat(pwd, '\ScenarioResults\');

% General parameters for plots
rfXaxis = 1;
if selScn == 0, rfXaxis = 2;  end
if selScn == 1, rfXaxis = 2;end
if selScn == 2, rfXaxis = 2;  end
if selScn == 3, rfXaxis = 2;  end
if selScn == 4, rfXaxis = 2;  end
if selScn == 5, rfXaxis = 2;  end
if selScn == 6, rfXaxis = 2;  end
if selScn == 7, rfXaxis = 1;  end
if selScn == 8, rfXaxis = 1;  end
if selScn == 9, rfXaxis = 1;  end
if selScn == 10,rfXaxis = 2;  end
if selScn == 11,rfXaxis = 2;  end
if selScn == 12,rfXaxis = 2;  end

%% %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% IMPLEMENTATION OF DYNAMIC INTERVENTIONS
% %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%
% % INITIAL OF MODEL STATES FROM PARAMETERS
% % Initial numbers of population types and per age groups. 
% % All in a single row vector 1x(nAGx2genders)
% nAG = size(EpiP.pNt,2);
% stNini = zeros(1,8*nAG);
% 
% % Adding all state matrix rows into a single one.
% for i=1:8,
%     stNini((i-1)*nAG+1:i*nAG) = iniSt(i,:);
% end

% stNini = R(idR).StV;
% All in a single row vector 1x(nAGx2genders)
stNini = zeros(1,R(idR).Dim.numStG*R(idR).Dim.nAG);
% All states in a vector from the initial matrix.
for i=1:R(idR).Dim.numStG,
    stNini((i-1)*nAG+1:i*nAG) = R(idR).iniStM(i,:);
end

% If no interventions 
if selScn==0, selScn=100;   end

% %%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% TEMP predefined values for the selected scenarios of intervention.
switch selScn
    case 100  % 'Do nothing'
        P = 1;
        strLegInt = 'par_{Int} =';
        labelX = 'No intervention evaluated';
        
        % STATIC INTERVENTIONS
    case 1  % 'Individual isolation (non age selective)'
        P = [0:0.1:2 2.25:0.2:8];
        if legON==1,    P = [0 0.5 0.75 1 2.5 5 10];    end
        strLegInt = 'ni_h =';
        labelX = 'Number of daily contacts';
        
    case 2  % 'Individual isolation (elderly only 60+)'
        P = [0:0.1:2 2.25:0.2:8];
        if legON==1,    P = [0 0.5 0.75 1 2.5 5 10];    end
        strLegInt = 'ni_h =';
        labelX = 'Number of daily contacts (Elderly)';
        
    case 3  % 'Individual isolation (youngest only 0-19)'
        P = [0:0.1:2 2.25:0.2:8];
        if legON==1,    P = [0 0.5 0.75 1 2.5 5 10];    end
        strLegInt = 'ni_h =';
        labelX = 'Number of daily contacts (Youngsters)';
        
    case 4  % 'Individual isolation (elderly and youngest)'
        P = [0:0.1:2 2.25:0.2:8];
        if legON==1,    P = [0 0.5 0.75 1 2.5 5 10];    end
        strLegInt = 'ni_h =';
        labelX = 'Number of daily contacts (Elderly & Young)';
        
    case 5  % 'Intensive Care Beds per Million'
        P = [0:100:300, 500:500:2500];
        if legON==1,    P = [0 250 500:1000: 2500];    end
        strLegInt = 'ICU_p_M =';
        labelX = 'Intensive Care Units per million';
        
    case 6  % 'Increase in PPE and measures'
        P = 0:0.05:1;
        if legON==1,    P = [0 0.25 0.5:0.1:1];    end
        % Record to apply the factor to the original values.
        org_lpa_h  = IntP.lpa_h;
        org_lpa_ps = IntP.lpa_ps;
        org_lpa_s  = IntP.lpa_s;
        Pmax = max([IntP.lpa_h IntP.lpa_ps]);
        strLegInt = 'f_{PPE} =';
        labelX = 'Increase in PPE use';
        
    case 7  % 'Implementation of extensive testing for pre-symptomatic'
        P = 0:0.02:1;
        if legON==1,    P = [0:0.05:0.25 0.5 1];    end
        org_rfi_ps = IntP.rfi_ps;
        org_rfi_s  = IntP.rfi_s;
        pInf = min(1,(1-P));
        strLegInt = 'pInf =';
        labelX = '% of Infections Detected (p_{Test} * t_{sns})';
        
    case 8  % 'Implementation of extensive testing for symptomatic'
        P = 0:0.02:1;
        if legON==1,    P = [0:0.05:0.25 0.5 1];    end
        org_rfi_ps = IntP.rfi_ps;
        org_rfi_s  = IntP.rfi_s;
        pInf = min(1,(1-P));
        strLegInt = 'pInf =';
        labelX = '% of Infections Detected (p_{Test} * t_{sns})';
        
    case 9  % 'Implementation of extensive testing for symptomatic and pre-symptomatic'
        P = [0:0.02:1];
        if legON==1,    P = [0:0.05:0.25 0.5 1];    end
        org_rfi_ps = IntP.rfi_ps;
        org_rfi_s  = IntP.rfi_s;
        %         rfi_sV = bsxfun(@times, IntP.rfi_s, P');
        pInf = min(1,(1-P));
        strLegInt = 'pInf =';
        labelX = '% of Infections Detected (p_{Test} * t_{sns})';
        
        % DYNAMIC INTERVENTIONS
    case 10  % 'End isolation once R reaches value'
        % Default intervention to be withdrawn ni_h value.
        IntP.ni_h(1,:) = 1;
        P = [0:0.05:1.5 1.75:0.25:3];
        if legON==1,    P = [0 0.5 0.8:0.05:1.1];    end
        labelX = 'Ro value from which isolation ends';
        strLegInt = 'R_{0,end,I} =';
        
    case 11  % 'End isolation (except elderly) once R reaches value'
        % Default intervetion to be withdrawn ni_h value.
        IntP.ni_h(1,:) = 1;
        P = [0:0.05:1.5 1.75:0.25:4];
        if legON==1,    P = [0:0.5:4];    end
        labelX = 'Ro value from which isolation ends';
        strLegInt = 'R_{0,end,I} =';
        
    case 12  % 'End isolation once daily fatality rate per million reaches value'
        % Default intervetion to be withdrawn ni_h value.
        IntP.ni_h(1,:) = 1;
        P = [0.01:0.01:0.3];
        if legON==1,    P = [0.01 0.1:0.05:0.3];   end
        labelX = 'Daily fatality rate per M from which isolation ends';
        strLegInt = 'Frate_{pM} =';
        
    case 13  % 'End isolation (except elderly) once daily fatality rate per million reaches value'
        % Default intervetion to be withdrawn ni_h value.
        IntP.ni_h(1,:) = 1;
        P = [0.01:0.01:0.3];
        if legON==1,    P = [0.01 0.1:0.05:0.3];   end
        labelX = 'Daily fatality rate per M from which isolation ends';
        strLegInt = 'Frate_{pM} =';
end
% %%%%%%%%%%%%%%%%%%%%%%%%%%%%%1
% reset all figures
if (legON==1)&&(selScn~=0)
    figure(selScn);  clf;
end

% Prepare Legend
strLeg = cell(1, length(P));
for n = 1:length(strLeg)
    if n == 1
        strLeg{n} = sprintf('%s %s', strLegInt, num2str(P(n),0));
    else
        strLeg{n} = sprintf('%s', num2str(P(n),2));
    end
end

% Runs the scenario as per type and parameter values selected 
for i=1:length(P)
    % Applies the parameters for the selected scenario of intervention.
    switch selScn
        case 100  % 'Do nothing'
            dynInt = 0;
            
        case 1      % 'Individual isolation (non age selective)'
            dynInt = 0;
            IntP.ni_h(1,:) = P(i);
            
        case 2      % 'Individual isolation (elderly only 60+)'
            dynInt = 0;
            IntP.ni_h(1,7:9) = P(i);
            
        case 3      % 'Level of individual isolation (youngest only 0-19)'
            dynInt = 0;
            IntP.ni_h(1,1:2) = P(i);
            
        case 4      % 'Level of individual isolation (elderly and youngest)'
            dynInt = 0;
            IntP.ni_h(1,1:2) = P(i);
            IntP.ni_h(1,7:9) = P(i);
            
        case 5      % 'Intensive Care beds per Million'
            dynInt = 0;
            IntP.capICpM = P(i);
            
            
        case 6      % 'Increase in personal protection measures'
            dynInt = 0;
            IntP.lpa_h  = (P(i)/Pmax)*org_lpa_h;  if max(IntP.lpa_h)>1,   IntP.lpa_h  = IntP.lpa_h /max(IntP.lpa_h);   end
            IntP.lpa_ps = (P(i)/Pmax)*org_lpa_ps; if max(IntP.lpa_ps)>1,  IntP.lpa_ps = IntP.lpa_ps/max(IntP.lpa_ps);  end
            IntP.lpa_s  = (P(i)/Pmax)*org_lpa_s;  if max(IntP.lpa_s)>1,   IntP.lpa_s  = IntP.lpa_s /max(IntP.lpa_s);   end
            
            
        case 7      % 'Implementation of rapid testing to pre-symptomatic'
            dynInt = 0;
            IntP.rfi_ps = P(i)*org_rfi_ps; if max(IntP.rfi_ps)>1,   IntP.rfi_ps = IntP.rfi_ps /max(IntP.rfi_ps); end
            IntP.rfi_s  = org_rfi_s;
            %         IntP.rfi_s  = P(i)*org_rfi_s; if max(IntP.rfi_s)>1,   IntP.rfi_s = IntP.rfi_s /max(IntP.rfi_s); end
            
            
        case 8      % 'Implementation of rapid testing to symptomatic'
            dynInt = 0;
            IntP.rfi_ps = org_rfi_ps;
            IntP.rfi_s  = P(i)*org_rfi_s ; if max(IntP.rfi_s)>1,    IntP.rfi_s  = IntP.rfi_s  /max(IntP.rfi_s);  end
            
            
        case 9     % 'Implementation of rapid testing to symptomatic and non-symptomatic'
            dynInt = 0;
            IntP.rfi_ps = P(i)*org_rfi_ps; if max(IntP.rfi_ps)>1,   IntP.rfi_ps = IntP.rfi_ps /max(IntP.rfi_ps); end
            IntP.rfi_s  = P(i)*org_rfi_s ; if max(IntP.rfi_s)>1,    IntP.rfi_s  = IntP.rfi_s  /max(IntP.rfi_s);  end
            
            
            % DYNAMIC INTERVENTIONS
        case 10  % 'End isolation once R reaches value'
            dynInt = 1;
            Rthr = P(i);
            rd_thr = -1;
            spC = 0;    % No set point control below the threshold, one off withdraw.
            
            
        case 11  % 'Social isolation to under remain under R value'
            dynInt = 1;
            Rthr = P(i);
            rd_thr = -1;
            spC = 0;    % Set point control below the threshold, one off withdraw.
            
            
        case 12  % 'End isolation once fatality rate reaches value'
            dynInt = 1;
            Rthr = -1;
            rd_thr = P(i)*1e-6;
            spC = 0;    % Set point control below the threshold, one off withdraw.
            
            
        case 13  % End isolation (except elderly) once fatality rate reaches value'
            dynInt = 1;
            Rthr = -1;
            rd_thr = P(i)*1e-6;
            spC = 0;    % Set point control below the threshold, one off withdraw.
            
    end
    
% Reset global variables used in the solvers.
tRt=[]; trDpM=[];
wtFlag = 0; rD_Nt = 0;

if dynInt==0
    % Defining variables if no dynInt to feed to function call.
    if dynInt ==0,  Rthr = 0;   rd_thr = 0; end
end

    
% Keeping global variables in sync.    
R(idR).GenP = GenP;
R(idR).IntP = IntP;
R(idR).EpiP = EpiP;
R(idR).Rthr = Rthr;
R(idR).rd_thr = rd_thr;
R(idR).selScn = selScn;
    
% Calls the model simulation solver for the current parameter values.
[tsim,stNt] = ode23('mdlSimulator', [0:1:GenP.tFinal], stNini,[], idR, 0);

% Naming states and vectors management.
St.Nh  = stNt(:,0*nAG+1:nAG);        St.Nni = stNt(:,1*nAG+1:2*nAG);  
St.Nps = stNt(:,2*nAG+1:3*nAG);      St.Ns  = stNt(:,3*nAG+1:4*nAG);
St.Nsh = stNt(:,4*nAG+1:5*nAG);      St.Nsc = stNt(:,5*nAG+1:6*nAG);   
St.Nd  = stNt(:,6*nAG+1:7*nAG);      St.Nr  = stNt(:,7*nAG+1:8*nAG); 
% Totals per state (all age groups added).
StT.NhT  = sum(St.Nh,2);     StT.NniT = sum(St.Nni,2);
StT.NpsT = sum(St.Nps,2);    StT.NsT  = sum(St.Ns,2);
StT.NshT = sum(St.Nsh,2);    StT.NscT = sum(St.Nsc,2);
StT.NdT  = sum(St.Nd,2);     StT.NrT  = sum(St.Nr,2);

% Calculation and storage of Outputs.
Out(i).St = St;
Out(i).StT = StT;
% Number of active cases in either stage of infection over time for simulation i.
Out(i).nCases = StT.NniT + StT.NpsT + StT.NsT + StT.NshT + StT.NscT;
% Reproduction number Ro.
Out(i).tRt = sortrows(tRt);
Out(i).trDpM = sortrows(trDpM);
% Maximum of total critical cases for simulation i.
Out(i).maxSC = max(StT.NscT);
% Total final number of fatalities for simulation i.
Out(i).NdF = St.Nd(size(St.Nd,1),:);
% Value of P and tsim
Out(i).P = P;
Out(i).tsim = tsim;


% %%%%%%%%%%%%%%%%%%%%%%%%%%
% PLOTS INSIDE THE LOOP
if legON==1
    % Active cases over time
    figure(selScn);
    subplot(3,2,3);
    plot(tsim, Out(i).nCases);
    % title('Number of cases over Time');
    xlabel('Time (days)')
    ylabel('Number of cases (%)')
    axis([0 GenP.tFinal/rfXaxis 0 Inf])
    % Building a legend for each intervention parameter value.
    legend(strLeg, 'Location', 'NorthEast');
    grid on
    hold on
    
    % R over time
    figure(selScn);
    subplot(3,2,4);
    %     if dynInt==1,
    plot(Out(i).tRt(:,1), Out(i).tRt(:,2));

    xlabel('Time (days)')
    ylabel('Reproduction number (Rt)')
    axis([0 GenP.tFinal/rfXaxis 0 Inf])
    if dynInt==1,   axis([0 GenP.tFinal/rfXaxis 0 5]);  end
    % Building a legend for each intervention parameter value.
    legend(strLeg, 'Location', 'NorthEast');
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
    legend(strLeg, 'Location', 'NorthEast');
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
    % Building a legend for each intervention parameter value.
    legend(strLeg, 'Location', 'NorthEast');
    grid on
    hold on
    
end
% END OF PLOTS INSIDE THE LOOP
% %%%%%%%%%%%%%%%%%%%%%%%%%%%%

end
% Display time elapsed and name of inputs file used for integrity.
fprintf(strcat('>> #', num2str(length(P)),  '# simulations run in #', num2str(toc), '# seconds\n'));
% fprintf(strcat('\n\n>> Inputs Excel file was "',myModelName, '"\n'));



% Outputs Processing
X=P';
vNdTF = zeros(length(X),1);
NdF  = zeros(length(X),nAG);
for i=1:length(X)
    vNdTF(i)=sum(Out(i).NdF);
    NdF(i,:) = Out(i).NdF;
end

% %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% PLOTTING FINAL FIGURES
if legON==0
    figure(selScn);
    subplot(3,2,1);
    max_X = max(P);
    
    % Change of legend for the ptest based figures
    if selScn >= 7 && selScn <= 9
        X = (1-X);
        X = fliplr(X);
        max_X = 1;
        % elseif selScn == 8
        %     X = (1-X);
        %     X = fliplr(X);
        %     max_X = 1;
    end
    
    plot(X, vNdTF)
    % title('Final fatalities vs. daily interactions');
    xlabel(labelX)
    ylabel('Final total fatalities (%)')
    axis([0 max_X 0 Inf])
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

% Sensitivity analysis plot
    if figON==0
        figure(100+selScn);
        plot(X, vNdTF);
        xlabel(labelX)
        ylabel('Final total fatalities (%)')
        axis([0 max(P) 0 Inf])
        grid on
        hold on
    end

    if selScn==100
        % Population types vs Time
        figure(selScn);
        subplot(3,2,1);
        stNt = [StT.NhT StT.NniT StT.NpsT StT.NsT StT.NshT StT.NscT StT.NdT StT.NrT];
        plot(tsim, (stNt));
        % title('Population types over Time');
        xlabel('Time (days)')
        ylabel('Total population in each stage (%)')
        axis([0 GenP.tFinal/rfXaxis 0 Inf])
        legend({'Susceptible','Non infectious','Presymtomatic','Symptomatic','Hospitalised','Critical','Dead','Recovered'},'Location','northeast')
        grid on
        
        figure(selScn);
        subplot(3,2,2);
        plot(tsim, St.Nsc);
        % title('Final fatalities per age vs. daily interactions');
        xlabel('Time (days)')
        ylabel('Number of critical cases (%)')
        legend({'0s','10s','20s','30s','40s','50s','60s','70s','80+'},'Location','northeast')
        axis([0 GenP.tFinal/rfXaxis 0 Inf])
        grid on
        
    end
end