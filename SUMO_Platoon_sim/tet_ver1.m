clc, clear all, close all

L = 2.5;
x = (0:0.001:L)';
y = 0:0.001:L;
k = 0:100;
n = 2*k+1;

V = zeros(length(x),length(y));

for m = 1:length(y)
    for idx = n
        V(:,m) = V(:,m) + (800/(idx*pi*(1-exp(-2*idx*pi)))).*...
            (exp(-idx*pi*y(m)/L)-exp(idx*pi*y(m)/L)*exp(-2*idx*pi)).*...
            sin(idx*pi*x/L);
    end
end

[Ex Ey] = gradient(V);
E = sqrt(Ex.^2 + Ey.^2);
