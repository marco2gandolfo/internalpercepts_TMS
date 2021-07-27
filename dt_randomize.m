function dt_randomize(m)									
  % function  dt_randomize(m)
  [R C] = size(m);
  newInd = randperm(R)';
  out = zeros(R, C);
  for i = 1:R
    out(i, :) = m(newInd(i), :);
  end