clc, close all, clear all

NumVehicles = 7;

v  = [20,22,18,19,22.2,0,0];
dx = [-100,-85.84,-150,-25.325,-80,0,0];
dy = [0,0,0,0,0,0,0];

flags = [0,1,0,1,1,0,0];

edx = zeros(NumVehicles,1);
edy = zeros(NumVehicles,1);
ev  = zeros(NumVehicles,1);
ed  = zeros(NumVehicles,1);

y = zeros(2,NumVehicles);

idx = find(flags);
if ~isempty(idx)
    d = sqrt(dx(idx).^2 + dy(idx).^2);
    [dist,sortIdx] = sort(d);
    temp = idx(sortIdx);
    switch length(temp)
        case 1
            edx(temp) = dx(temp);
            edy(temp) = dy(temp);
            ev(temp)  = v(temp);
            ed  = sqrt(edx.^2 + edy.^2);
        otherwise
            edx(temp(1)) = dx(temp(1));
            edy(temp(1)) = dy(temp(1));
            edx([temp(2:end)]) = dx([temp(2:end)]) - dx([temp(1:end-1)]);
            edy([temp(2:end)]) = dy([temp(2:end)]) - dy([temp(1:end-1)]);
            
            ev(temp(1)) = v(temp(1));
            ev([temp(2:end)]) = v([temp(2:end)]) - v([temp(1:end-1)]);

            ed  = sqrt(edx.^2 + edy.^2);
    end
end
y = [ed,ev]';
v0 = v;