% %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% CONTACT:
% Jorge Rodríguez R. PhD MSc FHEA
% Dep.Chemical Engineering
% Khalifa University
% PO Box 127788 Abu Dhabi
% United Arab Emirates
% jorge.rodriguez@ku.ac.ae
% %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

function [] = loadCOVIDxls(idR, dynInt)
global R oP
warning off;
% idR is the identifier of the node when more than one is simulated.
% The node no. 1 used (idR=1) requires no number in the xls sheets names.
% The second and following nodes, require the sheets names in the excel followed,...
% ... by the idR number at the end to indicate to which node they refer. e.g. StateVar2
if idR==1,  id = '';    else    id = strcat(' (', num2str(idR),')');   end

% Name of the Excel file to be used, it must contain the sheets with the parameters in specific format.
myModelName = 'modelCOVIDparameters.xlsx';

% %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% DEFAULT MODEL PARAMETERS from Excel Model File.
% %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
fileinfoXls = dir(myModelName);
fileinfoMat = dir('model_loaded.mat');
    if isempty([fileinfoMat.date])==0 && (datenum(fileinfoMat.date)>=datenum(fileinfoXls.date)),
fprintf('\n>> NO PARAMETER CHANGES DETECTED -> USING SAVED PARAMETERS >');
load('model_loaded.mat');
    else  % If the Excel file has changed we reload from it.
%% VARIABLES AND PARAMETERS NAMES AND VALUES ARE READ FROM THE EXCEL FILE.
    fprintf(strcat('\n>> RETRIEVING PARAMETERS FOR CLUSTER No. #', num2str(idR)));
    fprintf('\n>> DEFAULT GENERAL PARAMETERS ->         Loading from Excel...');
[GenParam, GenPnames]  = xlsread(myModelName, strcat('GenP'), '', 'basic');
    NidR = size(GenParam,2);
    fprintf('-> LOADED >>');
    fprintf('\n>> DEFAULT EPIDEMIOLOGICAL PARAMETERS -> Loading from Excel...');
[EpiParam, EpiPnames] = xlsread(myModelName, strcat('EpiP', id), '');%, 'basic');
    fprintf('-> LOADED >>');
    fprintf('\n>> STATE TRANSITIONS MATRIX ->           Loading from Excel...');
[trnsM, trnsNames]  = xlsread(myModelName, strcat('transM'), '', 'basic');
    fprintf('-> LOADED >>');
    fprintf('\n>> DEFAULT INTERVENTIONS PARAMETERS ->   Loading from Excel...');
[IntParam, IntPnames]  = xlsread(myModelName, strcat('IntP', id), '');%, 'basic');
    fprintf('-> LOADED >>');
    if dynInt~=0
    fprintf('\n>> SCHEDULE OF INTERVENTIONS ->          Loading from Excel...');
[dynIntParam, dynIntPnames]  = xlsread(myModelName, strcat('dynIntP', id), '', 'basic');
    fprintf('-> LOADED >>');
    end
    fprintf('\n>> INITIAL STATES VALUES ->              Loading from Excel...');
[iniStM, StNames] = xlsread(myModelName, strcat('iniSt', id), '');%, 'basic');
    fprintf('-> LOADED >>');

% For debugging purposes to try an easier alternative
loadParams = 1;

% To define that a sensitivity analysis is done or not
% If 0, the major structures are not written for performance purposes
% If 1, "Rt." or "AlgSt." structures are updated every timestep
R(idR).sensAna = 1;   

switch loadParams
    case 1
%% Alternative way to load parameters
% General parameters
for i=1:length(GenPnames)
    GenP.(char(GenPnames(i))) = GenParam(i);
end
GenP.NtT = sum(sum(iniStM));

% Epidemiological parameters
for i=1:length(EpiPnames)
    EpiP.(char(EpiPnames(i))) = EpiParam(i,:);
end

% Rates
rateNames= trnsNames(1,2:size(trnsNames,2));
for i=1:length(rateNames)
    r.(char(rateNames(i))) = 0;
end

% Intervention parameters
for i=1:length(IntPnames)
    IntP.(char(IntPnames(i))) = IntParam(i,:);
end

%Possible alternative ???

if dynInt ~= 0
    dynIntPnames = dynIntPnames(strcmp(dynIntPnames, '')== 0);
    dynIntPnames = dynIntPnames(2:end);    %Ignore the time
    tDynInt = dynIntParam(:,1);
    dynIntParam = dynIntParam(:,2:size(dynIntParam,2));
    nAG = length(IntParam(1,:));
    for i=1:length(dynIntPnames)
        dynIntP.(char(dynIntPnames(i))) = dynIntParam(:,(i-1)*nAG+1:i*nAG);
    end
end

    case 2    
%% %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% GENERAL DEFAULT MODEL PARAMETERS
% Loading names and values of parameters from Excel into a Matlab Structure.
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
    eval(strcat('GenP.', char(GenPnames(i)), ' = [', char(num2str(GenParam(i,idR))), '];'));
end
GenP.NtT = sum(sum(iniStM));


%% %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% EPIDEMIOLOGICAL AND CLINICAL DEFAULT PARAMETERS
% Loading names and values of parameters from Excel into a Matlab Structure.
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


%% %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% TRANSITION MATRIX AND NAMES
% Loading names and values of parameters from Excel into a Matlab Structure.
aux = '';
rateNames= trnsNames(1,2:size(trnsNames,2));
for i=1:size(rateNames,2)
    % Building the string command for the structure, last without ', '.
    if i<size(rateNames,2)  
        aux = strcat(aux, char(39), rateNames(i), char(39), ', 0, ');
    else
        aux = strcat(aux, char(39), rateNames(i), char(39), ', 0');
    end 
end
aux = char(aux);

% Creates an structure with every variable name with its own value.
eval(strcat('r = struct(', aux, ');'));

%% %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% INTERVENTION PARAMETERS
% Loading names and values of parameters from Excel into a Matlab Structure.
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


%% %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% DYNAMIC INTERVENTION PLAN
% Loading names and values of parameters from Excel into a Matlab Structure.
aux = '';
for i=1:size(IntParam,1)
    % Building the string command for the structure, last without ', '.
    if i<size(IntParam,1)  
        aux = strcat(aux, char(39), IntPnames(i), char(39), ', 0, ');
    else
        aux = strcat(aux, char(39), IntPnames(i), char(39), ', 0');
    end 
end

if dynInt~=0
    aux = char(aux);
    % Creates an structure with every variable name with its own value.
    eval(strcat('dynIntP = struct(', aux, ');'));
    tDynInt = dynIntParam(:,1);
    dynIntParam = dynIntParam(:,2:size(dynIntParam,2));
    % Allocating values for each paramater. 
    for i=1:length(IntPnames)
        nAG = size(dynIntParam,2)/length(IntPnames);
        eval(strcat('dynIntP.', char(IntPnames(i)), ' = dynIntParam(:,(i-1)*nAG+1:i*nAG);'));
    end


end

end
%% %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Assigns everything to the global R.
R(idR).GenP = GenP;
R(idR).EpiP = EpiP;
R(idR).IntP = IntP;
   if dynInt~=0
R(idR).dynIntP = dynIntP;
R(idR).tdynInt = tDynInt;
   end
R(idR).StNames = StNames(:,1);
R(idR).RtNames = rateNames;
R(idR).GenPnames = GenPnames;
R(idR).EpiPnames = EpiPnames;
R(idR).IntPnames = IntPnames;
R(idR).trnsM = trnsM;
R(idR).iniStM= iniStM;
    end

    if idR==NidR
    save('model_loaded.mat');
    load('model_loaded.mat');
    end
end