function y = hhcfmod(beta,x)

y = 2*beta(1)*(1-exp(-(x./beta(2)).^(2*beta(3))))+abs(beta(4));