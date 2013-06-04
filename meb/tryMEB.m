%clear; clc; close all;
rng(110,'twister');

% generate gmm data
N = 200; K = 2; pi = ones(K,1)/K; Mu = [0 1; 3 4];
%Mu = [0 2; 2 1; 3 2]; pi = [0.3 0.4 0.3];
figure;

[x,Mu,Sigma] = randGMM(N,K,pi,Mu,[],true);
disp(Mu);

% set up MEB data
model.X = x;
%use kern_hyp = average distance
model.kern_hyp = 0.5*ones(2,1)/sqrt(mean(mean(sq_dist(x',x'))));
%model.kern_hyp = log([1 1]);
model.eps = 1e-6;
model.solver = 'MEB';
model.eta = 100;

% CCMEB and plot
model = approxMEB(model);
coreset = model.X(model.in_coreset,:);
disp('MEB solution')
fprintf('coreset size: %d\n',length(model.alpha));
fprintf('radius: %.4f\n',model.radius); 
figure; hold on; plot(x(:,1),x(:,2),'x');
plot(coreset(:,1),coreset(:,2),'or','MarkerSize',10);
title('condense set by RSDE (CCMEB)');
