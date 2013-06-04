function [X,Mu,Sigma] = randGMM(N,K,pi,Mu,Sigma,showPlot)
%RANDGMM X = randGMM(N,K,pi,Mu,Sigma,showPlot)
%   Draw samples from a gaussian mixture model (2-D).
% 
% INPUT
%   - N : number of samples to draw
%   - K : number of mixture components
%   - pi : mixture weights (prior probability of class) (K x 1)
%   - Mu : mean vectors (K x 2, optional)
%   - Sigma : covariance matrices (K x 1 cell, optional)
%
% OUTPUT
%   - X : the samples (N x 2)
%   - Mu : the mean vectors used
%   - Sigma : the covariance matrices used
% 
% 20/02/13
% Trung V. Nguyen

if isempty(Mu),   Mu = repmat([2,2],K,1) - randi(4,K,2); end
if isempty(Sigma)
  R = cell(K,1); Sigma = R;
  for k=1:K
    R{k} = triu(1 + 1.5*randn(2,2));
    Sigma{k} = R{k}'*R{k};
  end
else % user provided Sigma
  R = cell(K,1);
  for k=1:K
    R{k} = jit_chol(Sigma);
  end
end

% random samples from gaussian mixture
zs = randsample(1:K,N,true,pi); % sample classes
X = [];
for k=1:K
  Nk = sum(zs == k);
  X = [X; repmat(Mu(k,:),Nk,1) + randn(Nk,2)*R{k}];
end

if showPlot
  xrange = linspace(min(X(:,1)),max(X(:,1)),200);
  yrange = linspace(min(X(:,2)),max(X(:,2)),200);
  % compute values for all (x,y) in xrange, yrange
  [xx, yy] = meshgrid(xrange, yrange);
  zz = zeros(length(xx(:)),1);
  for k=1:K
    zz = zz + pi(k)*mvnpdf([xx(:),yy(:)],Mu(k,:),Sigma{k});
  end
  zz = reshape(zz,length(xrange),length(yrange));
  surfc(xrange,yrange,zz);
  axis([min(X(:,1)),max(X(:,1)),min(X(:,2)),max(X(:,2))]);
  title('true density');
end

