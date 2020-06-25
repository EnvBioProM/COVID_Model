function [IntP, IntPV] = my_interventions(t, u, idR, dynInt);
global R;

% Parameters.
dynIntP   = R(idR).dynIntP;
tDynInt   = R(idR).tdynInt;
IntPnames = R(idR).IntPnames;
% Intervention values are given in a matrix as well as the time vector.
% To avoid errors the first element of the vector of times is set to zero independently of the given value.
TM = tDynInt;

if t>21
    t;
end

% Depending on the current time value appropriate feed composition is assigned.
for i=2:length(TM),
    if t >= TM(i-1) && t < TM(i) || t > TM(i)
        for j=1:length(IntPnames),
            IntP.(char(IntPnames(j))) = dynIntP.(char(IntPnames(j)))(i,:);
        end
    end
end

% All current intervention values in a vector for outputs.
nAG = R(idR).Dim.nAG;
IntPV = zeros(1,length(IntPnames)*nAG);
aux = IntPnames;
    for i=1:length(IntPnames),
IntPV((i-1)*nAG+1:i*nAG) = IntP.(char(aux(i)));
    end

end

