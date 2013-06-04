rng(1000,'twister');

clear; clc; close all;

% first gaussian
mu1 = [-1 0];
Sigma1 = [1 .5; .5 2];
R1 = chol(Sigma1);

% second gaussian
mu2 = [2 2];
Sigma2 = [1.5 -1; -1 1];
R2 = chol(Sigma2);

% mixture weight (prior probability of a mixture)
mixtures = [0.6 0.4];

% gaussian mixture density contour plot
xrange = (-5:0.1:5)';
yrange = (-5:0.1:5)';
% compute values for all (x,y) in xrange, yrange
[xx, yy] = meshgrid(xrange, yrange);
zz = mixtures(1)*mvnpdf([xx(:),yy(:)],mu1,Sigma1) + mixtures(2)*mvnpdf([xx(:),yy(:)],mu2,Sigma2);
zz = reshape(zz,length(xrange),length(yrange));
figure;
contour(xrange,yrange,zz); % x corresponds to column of z
axis([-4,5,-4,5]);

% random samples from gaussian mixture
N = 200;
zs = randsample([1,2],N,true,mixtures); % sample classes
N1 = sum(zs == 1);
N2 = sum(zs == 2);
x1 = repmat(mu1,N1,1) + randn(N1,2)*R1;
x2 = repmat(mu2,N2,1) + randn(N2,2)*R2;
x = [x1;x2];
figure;
plot(x(:,1),x(:,2), 'x');
axis([-4,5,-4,5]);

