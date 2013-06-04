function K = gaussDensityKern(x,z,hyp)
%GAUSSDENSITYKERN  K = gaussDensityKern(x,z,hyp)
% Computes the Gaussian density kernel parametrised by the characteristic
% lengthscales ell = exp(hyp).
%     k(x,z) = exp(-0.5 * \sum(((x_i - z_i)/ell(i))^2).
%   
% The covariance matrix is diag(ell^2)
% 
%
% INPUT
%   X : N x d 
%   Z : M x d
%   hyp : hyperparameters of the kernel function
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
d = length(hyp);
K = K/prod(ell)/(2*pi)^(d/2);  % normalisation constant of the density kernel det(2piSigma)^(-1/2)

