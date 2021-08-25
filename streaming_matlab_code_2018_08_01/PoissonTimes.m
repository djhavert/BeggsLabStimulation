function X = PoissonTimes(lambda, T, LL)
% Simulates a Poisson random process by generating event times through a
% time period T governmed by mean 'events per interval' lambda. LL gives a
% lower limit of the time allowed between events.

if nargin < 3
  LL = 0;
end

prob = lambda * exp(-lambda);
X = find(rand(T,1)<prob);

%invalid = find(diff(X) <= LL);

ii = 1;
while ii < length(X)
  if X(ii+1) - X(ii) <= LL
    X(ii+1) = [];
  else
    ii = ii + 1;
  end
end

%invalid_all = find(diff(X) <= LL) + 1;
%invalid_higher_order = diff(invalid_all)>1+1;
%for ii = 1:length(invalid_higher_order)
%  if X(invalid_higher_order(ii)) - X(

%X(setdiff(invalid_all,invalid_higher_order)) = [];