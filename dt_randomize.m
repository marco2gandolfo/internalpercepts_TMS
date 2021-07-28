function out = dt_randomize(m)
% function out = dt_randomize(m)
% randomizes the rows of m, keeping them intact

%% rand('state',sum(100*clock));
[R C] = size(m);
newInd = randperm(R)';

out = zeros(R, C);
for i = 1:R
  out(i, :) = m(newInd(i), :);
end

