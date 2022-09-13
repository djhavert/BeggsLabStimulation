% For each value in 'data', checks if value is in the ranges specified by
% lower and upper.
% data: column vector of values to be checked if in range
% lower: row vector of all of the lower limit in each range
% upper: row vector of all of the corresponding upper limits in range
% If any inputted arrays are in wrong format, will automatically convert

function b = isInRange(data, lower, upper)
  if isrow(data)
    data = data';
  end
  if iscolumn(lower)
    lower = lower';
  end
  if iscolumn(upper)
    upper = upper';
  end
  b = any((data>=lower) & (data<=upper), 2);
end