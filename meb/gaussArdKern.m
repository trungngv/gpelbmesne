function K = gaussArdKern(x,z,hyp)
%GAUSSARDKERN  K = gaussArdKern(x,z,hyp)
%   Computes the Gaussian ARD kernel parametrised by 'hyp'.
%     k(x,z) = exp(-0.5 * \sum((x_i - z_i)/ exp(hyp(i)))^2).
%   Similar to the squared exponential covariance function with Automatic
%   Relevance Determination in GPML.
%
% INPUT
%   X : N x d 
%   Z : M x d
%   ells : lengthscale parameters of the kernel function
%
% OUTPUT
%   K : N x M matrix where K_ij = k(x_i, z_j)
%
if nargin<2, K = '(D+1)'; return; end              % report number of parameters
if nargin<3, z = []; end                                   % make sure, z exists
xeqz = numel(z)==0;                                 % determine mode
ell = exp(hyp);                               % characteristic length scale

% precompute squared distances
if xeqz                                                 % symmetric matrix Kxx
  K = sq_dist(diag(1./ell)*x');
else                                                   % cross covariances Kxz
  K = sq_dist(diag(1./ell)*x',diag(1./ell)*z');
end
K = exp(-K/2);                                                  % covariance
