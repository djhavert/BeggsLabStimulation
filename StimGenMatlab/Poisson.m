function X = Poisson(lambda, n)
% Produces random interval times between events for a Poisson distribution
% with mean rate lambda events per interval.

X = zeros(n,1);

for ii = 1:n
  k=1;
  prod = rand;
  while prod >= exp(-1/lambda)
    prod = prod * rand;
    k = k + 1;
  end
  X(ii) = k;
end