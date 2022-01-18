% For each value in 'data', checks if value is in the ranges specified by
% lower and upper.
% data: column vector
% lower: column vector of all of the lower limit in each range
% upper: column vector of all of the corresponding upper limits in range

function b = isInRange(data, lower, upper)
  b = any((data>=lower') & (data<=upper'), 2);
end