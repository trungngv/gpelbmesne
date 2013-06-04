function model = approxMEB(model)
%APPROXMEB model = approxMEB(model)
%   Solve the (1+\eps)-approximation MEB problem.
%
% INPUT
%   - model : struct containing configuration of the model
%       .X  : data (required)
%       .kern_hyp : hyper-parameters of the kernel (required)
%       .solver : must be one of 'MEB','RSDE-CCMEB' (required) or 'CCMEB'
%       (not implemented for other cases except RSDE)
%       .eps : (1+\eps)-approximation (default = 1e-4)
%       .eta : for CCMEB (default = 20)
%
% OUTPUT
%   - the learned model. empty is size of coreset is greater than
%   model.maxSize
%
% Trung V. Nguyen
% 06/03/13
N = size(model.X,1);
if ~(isfield(model,'X') && isfield(model,'kern_hyp') && isfield(model,'solver'))
  error('Not enough arguments. See help approxMEB.');
end

switch model.solver
  case 'MEB'
    model.kern_func = 'gaussArdKern';
    model.dist_func = 'computeKernDist';
    model.meb_solver = 'myMEBSolver';
  case 'RSDE-CCMEB'
    model.kern_func = 'gaussDensityKern';
    model.dist_func = 'computeAugmentedDist';
    model.meb_solver = 'CCMEBSolver';
  case 'CCMEB'
    model.kern_func = 'gaussArdKern';
    model.dist_func = 'computeAugmentedDist';
    model.meb_solver = 'CCMEBSolver';
end

if ~isfield(model,'eps')
  model.eps = 1e-6;
end  
if ~isfield(model,'eta')
  model.eta = 20;
end  

% Step 1: Initialise S0, C0, and R0 using random points
model.in_coreset = false(N,1);
% some random points
incoreset = randsample(1:N,5);
model.in_coreset(incoreset) = true;
model = feval(model.meb_solver,model);
fprintf('initial radius: %.4f\n', model.radius);

% TODO initialise S0, C0, and R0 using described techniques

iters = 1; nsamples = 69;
while true
% Step 2: Termination check
distances = zeros(N,1);
outside_ind = find(~model.in_coreset);
if (numel(outside_ind) > nsamples*2)
  sample_ind = randsample(outside_ind,nsamples,false);
else
  sample_ind = outside_ind;
end
Xout = model.X(sample_ind,:);
if isempty(Xout),     break;  end
distances(sample_ind) = feval(model.dist_func,Xout,model);
% Xout = model.X(~model.in_coreset,:);
% if isempty(Xout),     break;  end
% distances(~model.in_coreset) = feval(model.dist_func,Xout,model);
if all(distances <= ((1+model.eps)*model.radius)^2)
  break;
end

% Step 3: Find corevector x* s.t \phi(x*) is furthest away from the centre,
% x* = argmax kdist(x, model.centre), x \in model.X \ model.coreset_ind
[~,xstar_ind] = max(distances);
model.in_coreset(xstar_ind) = true;

% Step 4: Solve the new MEB for new coreset
model = feval(model.meb_solver,model);
if (sum(model.in_coreset) > model.max_coreset)
  model = [];
  return;
end
% fprintf('radius after iters %d: %.4f\n', iters, model.radius);
% fprintf('alpha > 0: %d; min = %.4f; max = %.4f:\n', sum(model.alpha>0),min(model.alpha),max(model.alpha));
iters = iters + 1;
end

