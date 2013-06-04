rng(1110, 'twister');

%% first synthetic : from gp
N = 1000; D = 5;
params.lengthScale = [1 1.5 0.4 2.5 0.1];
params.magnSigma2 = 1;
params.noiseSigma2 = 0.01^2;
X = randn(N,D);
K = feval('covSEard',log([2*params.lengthScale,params.magnSigma2]),X);
fx = mvnrnd(zeros(1,N),K)';
y = fx + sqrt(params.noiseSigma2)*randn(N,1);

Ntest = 200;
Xtest = X(1:Ntest,:); ytest = y(1:Ntest,:);
X = X(Ntest+1:end,:); y = y(Ntest+1:end,:);
save_data(X,y,Xtest,ytest,'/home/trung/projects/datasets/mysynth','synth1');

%% second synthetic : from true function
% must learn hyper using a full gp first
