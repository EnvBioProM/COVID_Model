% %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% CONTACT:
% Jorge Rodríguez R. PhD MSc FHEA
% Dep.Chemical Engineering
% Khalifa University
% PO Box 127788 Abu Dhabi
% United Arab Emirates
% jorge.rodriguez@ku.ac.ae
% %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
global tR0
% Name of the Excel file to be used, it must contain the sheets with the parameters in specific format.
myModelName = 'pbmCOVID_v2.3.xlsx';
% %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% DEFAULT MODEL PARAMETERS from Excel Model File.
% %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
rdXLS = 0;
fileinfoXls = dir(myModelName);
fileinfoMat = dir('model_loaded.mat');
    if isempty([fileinfoMat.date])==0 && (datenum(fileinfoMat.date)>=datenum(fileinfoXls.date)),
fprintf('\n>> NO PARAMETER CHANGES DETECTED -> USING SAVED PARAMETERS >\n');
load('model_loaded.mat', 'GenP', 'EpiP', 'IntP');
    else
        rdXLS=1;
    end
% If the Excel file has changed we reload from it.
    if rdXLS == 1;
%% %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% GENERAL DEFAULT MODEL PARAMETERS
% Loading names and values of parameters from Excel into a Matlab Structure.
fprintf('\n>> DEFAULT GENERAL PARAMETERS ->         Loading from Excel...');
[GenParam, GenPnames] = xlsread(myModelName, strcat('GenP'), '', 'basic');
aux = '';
GenPnames = GenPnames(:,1);
for i=1:size(GenParam,1)
    % Building the string command for the structure, last without ', '.
    if i<size(GenParam,1)  
        aux = strcat(aux, char(39), GenPnames(i), char(39), ', 0, ');
    else
        aux = strcat(aux, char(39), GenPnames(i), char(39), ', 0');
    end 
end
aux = char(aux);
% Creates an structure with every variable name with its own value.
eval(strcat('GenP = struct(', aux, ');'));

% Allocating values for each paramater. 
for i=1:length(GenPnames)
    eval(strcat('GenP.', char(GenPnames(i)), ' = [', char(num2str(GenParam(i,:))), '];'));
end
fprintf('-> LOADED >>\n');

%% %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% EPIDEMIOLOGICAL AND CLINICAL DEFAULT PARAMETERS
% Loading names and values of parameters from Excel into a Matlab Structure.
fprintf('>> DEFAULT EPIDEMIOLOGICAL PARAMETERS -> Loading from Excel...');
[EpiParam, EpiPnames] = xlsread(myModelName, strcat('EpiP'), '', 'basic');
aux = '';
EpiPnames = EpiPnames(:,1);
for i=1:size(EpiParam,1)
    % Building the string command for the structure, last without ', '.
    if i<size(EpiParam,1)  
        aux = strcat(aux, char(39), EpiPnames(i), char(39), ', 0, ');
    else
        aux = strcat(aux, char(39), EpiPnames(i), char(39), ', 0');
    end 
end
aux = char(aux);
% Creates an structure with every variable name with its own value.
eval(strcat('EpiP = struct(', aux, ');'));

% Allocating values for each paramater. 
for i=1:length(EpiPnames)
    eval(strcat('EpiP.', char(EpiPnames(i)), ' = [', char(num2str(EpiParam(i,:))), '];'));
end
fprintf('-> LOADED >>\n');

%% %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% INTERVENTION PARAMETERS
%% Loading names and values of parameters from Excel into a Matlab Structure.
fprintf('>> DEFAULT INTERVENTIONS PARAMETERS ->   Loading from Excel...');
[IntParam, IntPnames] = xlsread(myModelName, strcat('IntP'), '', 'basic');
aux = '';
IntPnames = IntPnames(:,1);
for i=1:size(IntParam,1)
    % Building the string command for the structure, last without ', '.
    if i<size(IntParam,1)  
        aux = strcat(aux, char(39), IntPnames(i), char(39), ', 0, ');
    else
        aux = strcat(aux, char(39), IntPnames(i), char(39), ', 0');
    end 
end
aux = char(aux);
% Creates an structure with every variable name with its own value.
eval(strcat('IntP = struct(', aux, ');'));

% Allocating values for each paramater. 
for i=1:length(IntPnames)
    eval(strcat('IntP.', char(IntPnames(i)), ' = [', char(num2str(IntParam(i,:))), '];'));
end
fprintf('-> LOADED >>\n');
    end
save('model_loaded.mat');
load('model_loaded.mat');
