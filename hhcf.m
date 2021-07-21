function [G,r] = hhcf(x,ps)

N = size(x,1);
G = zeros(round(N/4),1);

for m = 1:round(N/4)
    for n = 1+m:N-m
        G(m) = G(m) + (x(n-m)-x(n+m))^2;
    end
    G(m) = G(m)/(N-2*m);
end
r = ps*(2*(1:round(N/4))+1);    