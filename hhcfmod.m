function y = hhcfmod(beta,x)

y = real(2*beta(1)*(1-exp(-(x./abs(beta(2))).^(2*abs(beta(3)))))+abs(beta(4)));