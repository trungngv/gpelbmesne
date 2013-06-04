function model = CCMEBSolver(model)
%CCMEBSOLVER  model = CCMEBSolver(model)
%   MEB solver to find the minimum enclosing ball of the coresets S, which
%   correspond to finding the reduced/condense set of density estimator.
%
%   The dual QP form of an MEB:
%      max \alpha' p - 0.5*\alpha' K \alpha
%      s.t. \alpha' \vec{1} = 1, 0 <= \alpha <= 1
%   Transformation into Matlab quadprog form (i.e. minimisation problem) 
%      min 0.5* \alpha' (2*K) \alpha  + (-2*p)'\alpha
%      s.t. \alpha' \vec{1} = 1, 0 <= \alpha <= 1
% 
%   Trung V. Nguyen
%   21/02/13
S = model.X(model.in_coreset,:);
N = size(S, 1);
K = feval(model.kern_func,S,S,model.kern_hyp);
% the density kernel_hyp = 0.5*kernel_hyp 
model.parzen_estimate = parzenEstimator(S,model.X,...
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
model.kern_matrix = K;
model.radius = sqrt(model.eta-fval); % (\alpha' diag(K) - \alpha' K \alpha)^0.5
end

