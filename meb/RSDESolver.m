function model = RSDESolver(model)
%RSDESOLVER  model = RSDESolver(model)
%   RSDE solver for the RSDE problem.
%
%   The dual QP form of an RSDE:
%      max \alpha' p - 0.5*\alpha' K \alpha
%      s.t. \alpha' \vec{1} = 1, 0 <= \alpha <= 1
%   Transformation into Matlab quadprog form (i.e. minimisation problem) 
%      min 0.5* \alpha' (2*K) \alpha  + (-2*p)'\alpha
%      s.t. \alpha' \vec{1} = 1, 0 <= \alpha <= 1
% 
%   Trung V. Nguyen
%   27/02/13
model.kern_func = 'gaussDensityKern';
model.dist_func = 'computeAugmentedDist';
N = size(model.X, 1);
K = feval(model.kern_func,model.X,model.X,model.kern_hyp);
% the density kernel_hyp = 0.5*kernel_hyp 
model.parzen_estimate = parzenEstimator(model.X,model.X,...
  log(0.5*exp(model.kern_hyp).^2));
c = -2*model.parzen_estimate; % linear term
Aeq = ones(1, N); beq = 1; % Aeq \alpha = beq <-> \vec{1}' \alpha = 1
lb = zeros(N, 1); ub = ones(N, 1); % 0 <= \alpha <= 1
% select algorithm (see help quadprog) for more options
options = optimset('Algorithm','interior-point-convex','Display','off');
%fprintf('sovling MEB problem of size %d\n', N);
tic;
[alpha,fval] = quadprog(2*K,c,[],[],Aeq,beq,lb,ub,[],options);
%fprintf('running time %.2f(s)\n', toc);

model.alpha = alpha;
model.fval = fval;
end
