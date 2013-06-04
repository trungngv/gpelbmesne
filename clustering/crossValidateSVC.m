function [bestModel, bestScale, bestC] = crossValidateSVC(X, scales, regularisers)
%CROSSVALIDATESVC [model, bestScale, bestC] = crossValidateSVC(X)
%   Cross validate a dataset to get the best scale and regularisation
%   parameter.
% 
% INPUT
%   - X : d x N training data
%   - scales : values of scales to used in cross-validation
%   - regularisers : values of regularisers to used in cross-validation
%
% OUTPUT
%   - bestModel, bestScale, bestC: best model, scale, and regulariser
%   learned with cross-validation
%
% Trung V. Nguyen
% 04/02/13
options = struct('ker','rbf');
bestObjVal = 1e10;
disp('running cross validation')
%fprintf('scale\t regulariser\t objVal\n');
for scale = scales
  for C = regularisers
    options.arg = scale;
    options.C = C;
    model = svdd(X, options);
    if bestObjVal > model.fval
      bestModel = model;
      bestObjVal = model.fval;
      bestScale = scale;
      bestC = C;
    end
 %   fprintf('%.2f\t %.2f\t %.5f\n', scale, C, model.fval);
  end
end

end

