clear; clc; close all;

% experiments with regression tree
N = 1000;
Ntest = 100;
X = rand(N, 3);
truef = @(X) X(:,1).^2 + sin(X(:,2)) + 0.5*X(:,3); 
Y = truef(X) + 0.1*randn(N,1);
Xtest = rand(Ntest, 3);
Ytest = truef(Xtest);

% some configuration for tree

% TODO config for shallow trees
tree = RegressionTree.fit(X, Y, 'MinLeaf', 100);
view(tree, 'mode', 'graph');
[XPartitions, YPartitions] = getPartitions(tree);
models = trainMultipleGPs(XPartitions, YPartitions);
[ymu, yvar] = predictMultipleGPs(models, XPartitions, YPartitions, Xtest);

singlegp = standardGP(X,Y,Xtest);
fprintf('single gp smse = %.4f\n', mysmse(Ytest, singlegp.ymean));
fprintf('our smse = %.4f\n', mysmse(Ytest, ymu));
fprintf('treed smse = %.4f\n', mysmse(Ytest, predict(tree, Xtest)));

scatter(Ytest, ymu);