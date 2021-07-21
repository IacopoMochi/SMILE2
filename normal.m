function y=normal(x)

%Y = NORMAL(X)
%Array normlization between 0 and 1


y=(x-min(x(:)))./(max(x(:))-min(x(:)));

