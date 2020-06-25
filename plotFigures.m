function []=plotFigures(selScn, tsim, Out)

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
    % Building a legend for each intervention parameter.
    if legON==1,
        if selScn >= 7 && selScn <= 9
            legend(pInfLeg, 'Location', 'NorthEast');
        else
            str='';
            for j=1:length(P)-1,
                str = strcat(str,'''', num2str(P(j)),'''',',');
            end
            str = strcat(str,'''', num2str(P(length(P))),'''');
            str = strip(str,'left', '''');
            legStr =strcat(strLegInt, str);
            eval(strcat('legend({','''',legStr,'},', '''','Location','''',',','''','northeast', '''',')'));
        end
    end
grid on
hold on

% R over time
figure(selScn);
subplot(3,2,4);
%     if dynInt==1,
plot(Out(i).tRt(:,1), Out(i).tRt(:,2));
%     else
% plot(tsim, Out(i).Rt);
%     end
% title('Reproduction number profiles');
xlabel('Time (days)') 
ylabel('Reproduction number (Rt)') 
axis([0 GenP.tFinal/rfXaxis 0 Inf])
if dynInt==1,   axis([0 GenP.tFinal/rfXaxis 0 5]);  end
% Building a legend for each intervention parameter.
if legON==1,
    if selScn >= 7 && selScn <= 9
        legend(pInfLeg, 'Location', 'NorthEast');
    else
        str='';
        for j=1:length(P)-1,
            str = strcat(str,'''', num2str(P(j)),'''',',');
        end
        str = strcat(str,'''', num2str(P(length(P))),'''');
        str = strip(str,'left', '''');
        legStr =strcat(strLegInt, str);
        eval(strcat('legend({','''',legStr,'},', '''','Location','''',',','''','northeast', '''',')'));
    end
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
    if selScn >= 7 && selScn <= 9
        legend(pInfLeg, 'Location', 'NorthEast');
    else
        str='';
        for j=1:length(P)-1
            str = strcat(str,'''', num2str(P(j)),'''',',');
        end
        str = strcat(str,'''', num2str(P(length(P))),'''');
        str = strip(str,'left', '''');
        legStr =strcat(strLegInt, str);
        eval(strcat('legend({','''',legStr,'},', '''','Location','''',',','''','northeast', '''',')'));
    end
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
    % Building a legend for each intervention parameter value.
    if legON==1,
        if selScn >= 7 && selScn <= 9
            legend(pInfLeg, 'Location', 'NorthEast');
        else
            str='';
            for j=1:length(P)-1,
                str = strcat(str,'''', num2str(P(j)),'''',',');
            end
            str = strcat(str,'''', num2str(P(length(P))),'''');
            str = strip(str,'left', '''');
            legStr =strcat(strLegInt, str);
            eval(strcat('legend({','''',legStr,'},', '''','Location','''',',','''','northeast', '''',')'));
        end
    end
grid on
hold on

% 
% Y = Out(i).tRt(:,2);
% X = trDpM(:,1);
% figure(15);
% % subplot(3,2,2);
% plot(log10(X), log10(Y), '.');
% % title('Final fatalities per age vs. daily interactions');
% xlabel(' log10 Daily fatality rate per million rfDpM')
% ylabel('log10 Rt') 
% % legend({'0s','10s','20s','30s','40s','50s','60s','70s','80+'},'Location','northeast')
% % axis([0 max(P) 0 Inf])
% grid on
% hold on
% 

end
% END OF PLOTS INSIDE THE LOOP
% %%%%%%%%%%%%%%%%%%%%%%%%%%%%

end
% Display time elapsed and name of inputs file used for integrity.
fprintf(strcat('>> #', num2str(length(P)),  '# simulations run in #', num2str(toc), '# seconds\n'));
% fprintf(strcat('\n\n>> Inputs Excel file was "',myModelName, '"\n'));
filename=strcat('resIntScenario(', num2str(selScn), ').mat');
save(filename,'Out','P','GenP','IntP','EpiP')


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

% Prepare print of the figures as PDF and JPG
if plotPDF==1
    set(gcf, 'units','normalized','outerposition',[0 0 1 1])
    set(gcf, 'PaperUnits', 'centimeters');
    set(gcf, 'PaperPosition', [0 0 24 20]);
    set(gcf, 'PaperSize', [24 20]); % dimension on x axis and y axis resp.
    savefig(gcf, sprintf('%s.fig', 'Isolation Measures'))
    print(gcf,'-dpdf', sprintf('%sScenario%i.pdf',printPath, selScn))
    print(gcf,sprintf('%sScenario%i.png',printPath,selScn),'-dpng','-r600')
end

end


% END OF PLOTTING FINAL FIGURES
% %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

% Sensitivity analysis plot
    if figON==0,
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