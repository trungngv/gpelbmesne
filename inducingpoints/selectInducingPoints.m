function xu = selectInducingPoints(method,x,M,hyp,logsn,y)
%SELECTINDUCINGPOINTS [ind,xu] = selectInducingPoints(method,x,M,hyp)
%   
% Select the inducing points for a set of input x.
%
% INPUT
%   - method : the inducing point selection methdo
%       'r'       : random
%       'kmeans'  : the k-centres in k-means clustering
%       'rsde'    : the exact reduce density estimator (threshold for alpha
%                   must be set)
%       'meb'     : the standard meb 
%       'ccmeb'   : the approximate rsde (solved using ccmeb)
%       'ivm'     : the informative vector machine approach
%       'optim'   : optimize the inducing points
%       'hybrid'  : 'rsde' and 'meb' combine
%   - x : N x d
%   - M : number of inducing points
%   - hyp : hyperparameters of kernel (for rsde, meb, ccmeb) and covariance
%           function (ivm and optim) (empty for 'r' and 'kmeans')
%   - logsn : log sigma_noise (for ivm and optim)
%   - y : for optimisation (optim) only
%
% OUTPUT
%   - xu : M x d
D = size(x,2); xu = [];
switch method
  case 'r'
    ind = randsample(size(x,1),M,false);
    xu = x(ind,:);
  case 'kmeans'
    [~,xu] = kmeans(x,M);
  case {'rsde','meb','ccmeb'}
    model.X = x;     model.kern_hyp = hyp;    model.eps = 1e-6;
    model.max_coreset = 2000;
    if strcmp(method,'rsde')
      model.eta = 10;
      model = RSDESolver(model);
      [~,sorted_ind] = sort(model.alpha,'descend');
      xu = x(sorted_ind(1:M),:);
    else
      model.solver = upper(method);
      model = approxMEB(model);
      if ~isempty(model)
        xu = x(model.in_coreset,:);
      end;
      model = []; % free memory
    end
  case 'ivm'
    if ~isempty(logsn),      sigma2_noise = exp(2*logsn);
    else      sigma2_noise = 1e-6;    end
    %ind = selectIVM(x,M,hyp,sigma2_noise);
    loghyper.cov = hyp;
    xu = x(indPoints(x,M,'e',{@covSEard},loghyper),:);
  case 'optim'
    % hyperparameters must be converted to spgp representation
    [dum,randind] = sort(rand(size(x,1),1)); clear dum;
    randind = randind(1:M);
    xu_init = x(randind,:);
    w_init = [reshape(xu_init,M*D,1);-2*hyp(1:D);2*hyp(D+1);2*logsn];
    w = minimize(w_init,'spgp_lik_nohyp',-200,y-mean(y),x,M);
    xu = reshape(w(1:M*D,1),M,D);
  case 'hybrid'
    model.X = x;     model.kern_hyp = hyp;    model.eps = 1e-6;
    model.max_coreset = 1000;
    % solve meb first
    model.solver = 'MEB';
    model = approxMEB(model);
    if ~isempty(model)
      meb_ind = find(model.in_coreset);
      % solve rsde by ccmeb
      model.solver = 'RSDE-CCMEB';
      model = approxMEB(model);
      if ~isempty(model)
        ccmeb_ind = find(model.in_coreset);
      end;
      ind = union(meb_ind,ccmeb_ind);
      xu = x(ind,:);
      model = []; % free memory
    end
end


function ind = selectIVM(x,M,hyp,sigma2_noise)
  if size(x,1) > 2000,     ind=[]; return; end
  S = feval('covSEard',hyp,x);
  ind = zeros(M,1);
  for i=1:M
     % corresponds to max Delta_in = max v_in diag(S)_n,n = max x/(x+a)
    diagS = diag(S);
    [~,next_idx] = max(diagS);
    vin = 1/(diagS(next_idx)+sigma2_noise);
    S = S - vin*S(:,next_idx)*S(:,next_idx)';
    ind(i) = next_idx;
  end
  
  