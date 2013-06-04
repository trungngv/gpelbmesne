rng(100,'twister');

N = 500;
x = rand(N,2);
y = sin(x(:,1)*0.5) + x(:,2).^2 + 0.5*(x(:,1)+x(:,2)) + 0.05*randn(N,1);
xt = x(401:end,:); yt = y(401:end,:);
x = x(1:400,:); y = y(1:400,:);

% gpstuff library
% pn = prior_sinvchi2('s2',0.2^2,'nu',1);
% pl = prior_t('s2', 1);               % a prior structure
% pm = prior_sqrtt('s2', 1);           % a prior structure
% gpcf = gpcf_sexp('lengthScale', [1 1], 'magnSigma2', 0.2^2, ...
%                   'lengthScale_prior', pl, 'magnSigma2_prior', pm);
lik = lik_gaussian('sigma2',0.1^2);
gpcf = gpcf_sexp('lengthScale',[1 1],'magnSigma2',1);

gp = gp_set('lik', lik, 'cf', gpcf, 'jitterSigma2', 1e-8)
opt=optimset('TolFun',1e-3,'TolX',1e-3);
gp=gp_optim(gp,x,y,'opt',opt);
[gpstuff_fpred,~,gpstuff_nlpd] = gp_pred(gp,x,y,xt,'yt',yt);

% gpml library
gpml = standardGP([],x,y,xt,yt);

figure(1);
scatter(gpstuff_fpred,yt);
title('prediction by gpstuff');
axis([min(yt),max(yt),min(yt),max(yt)]);
figure(2);
scatter(gpml.ymean,yt);
title('prediction by gpml');
axis([min(yt),max(yt),min(yt),max(yt)]);

disp('GPstuff')
fprintf('smse = %.5f\n', mysmse(gpstuff_fpred,yt,mean(y)));
fprintf('nlpd = %.5f\n', -mean(gpstuff_nlpd));

disp('GPML')
fprintf('smse = %.5f\n', mysmse(gpml.ymean,yt,mean(y)));
fprintf('nlpd = %.5f\n', -mean(gpml.lp));
