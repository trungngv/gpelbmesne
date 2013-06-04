function [smse,msll,fpred] = gpmlFITC(x,y,xt,yt,xu,hyp,flag)
%GPMLFITC [smse,msll,fpred] = gpmlFITC(x,y,xt,yt,xu,hyp)
%   
%  Prediction with GP using FITC sparse approximation. Hyper-parameters and
%  inducing points are fixed (given). This method uses the GPML library.
%  
%  No data pre-processing for input is performed by this method. The
%  outputs are automatically zero-mean unless flag is set to false.
%
% Trung V. Nguyen
% 25/02/13

% set-up model
covfunc = {@covFITC,{@covSEard},xu};
likfunc = @likGauss;
if nargin == 6 || flag
  y0 = y - mean(y); % zero-mean
  yt0 = yt - mean(y); 
  [~,~,fpred,~,logpred] = gp(hyp,@infFITC,[],covfunc,likfunc,x,y0,xt,yt0);
  fpred = fpred + mean(y);
else
  [~,~,fpred,~,logpred] = gp(hyp,@infFITC,[],covfunc,likfunc,x,y,xt,yt);
end
% prediction
smse = mysmse(yt,fpred,mean(y));
msll = -mean(logpred); % also try mynlpd

