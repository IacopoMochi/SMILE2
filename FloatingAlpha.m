function y = FloatingAlpha(beta,freq)

A = beta(1);
B = beta(2);
C = beta(3);
D = beta(4);

y = (A*exp(-(freq.^D)*B^D)+C).';