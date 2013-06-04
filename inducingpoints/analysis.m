%%% 01/03/13
% SMSE and MSLL comparison of different inducing points selection methods
% Settings:
% - Train full GP on a random subset of 2000 points
% - Normalise training inputs and zero mean outputs
% - All methods select inducing points given fixed hyper-parameters

clear; clc; %close all;
% rsde, r, kmeans, ivm, optim for myelevators,puma,and kin40k
load('/home/trung/projects/ensemblegp/output/indpoints06-Mar-2013-1362536134861309.mat')
results = logger;
%load('/home/trung/projects/ensemblegp/output/indpoints-meb-07-Mar-2013-1362628315662335.mat');
load('/home/trung/projects/ensemblegp/output/indpoints-meb-08-Mar-2013-1362694431408050.mat')
mebresults = logger;
%load('/home/trung/projects/ensemblegp/output/indpoints-hybrid-08-Mar-2013-1362700268760776.mat');
load('/home/trung/projects/ensemblegp/output/indpoints-hybrid-08-Mar-2013-latest.mat')
hybridresults = logger;
ind_points = [200 350 500 750 1000];

% plotting
datasets={'kin40k','pumadyn32nm','myelevators'};
methods={'rsde','r','kmeans','ivm','optim','fullgp','meb','hybrid'};
colors={'b','y','r','m','g','k','c','k'};
mks = markers(length(methods));
for id=1:length(datasets)
  disp(['plotting for ' datasets{id}]);
  smse = zeros(length(methods)-3,length(ind_points));
  msll = smse;
  for ii=1:length(ind_points)
    fieldname = [datasets{id} 'Inducing' num2str(ind_points(ii))];
    smse(:,ii) = results.(fieldname).smse;
    msll(:,ii) = results.(fieldname).msll;
  end
  figure; hold on;
  for im=1:length(methods)-3
    plot(ind_points,smse(im,:),[mks{im} colors{im} '-']);
  end
  fullgp = load(['datasets/' datasets{id} '/evaluation.mat']);
  plot(ind_points,repmat(fullgp.smse,length(ind_points),1),[mks{im+1} colors{im+1} '-']);
  % meb
  l200 = mebresults.(datasets{id}).num_inducing<ind_points(1);
  mebresults.(datasets{id}).num_inducing(l200) = [];
  mebresults.(datasets{id}).smse(l200) = [];
  mebresults.(datasets{id}).msll(l200) = [];
  [meb_vals,meb_ind] = sort(mebresults.(datasets{id}).num_inducing);
  plot(meb_vals,mebresults.(datasets{id}).smse(meb_ind),[mks{im+2} colors{im+2} '-']);
  %hybrid
  l200 = hybridresults.(datasets{id}).num_inducing<ind_points(1);
  hybridresults.(datasets{id}).num_inducing(l200) = [];
  hybridresults.(datasets{id}).smse(l200) = [];
  hybridresults.(datasets{id}).msll(l200) = [];
  [hybrid_vals,hybrid_ind] = sort(hybridresults.(datasets{id}).num_inducing);
  plot(hybrid_vals,hybridresults.(datasets{id}).smse(hybrid_ind),[mks{im+3} colors{im+3} '-']);
  
  legend(methods,'Location','SouthEastOutside');
  title(['SMSE for the ' datasets{id} ' dataset']);
  %saveas(gca,['ensemblegp/figures/' datasets{id} '-smse4.pdf']);
  
  figure; hold on;
  for im=1:length(methods)-3
    plot(ind_points,msll(im,:),[mks{im} colors{im} '-']);
  end
  plot(ind_points,repmat(fullgp.msll,length(ind_points),1),[mks{im+1} colors{im+1} '-']);
  % meb
  plot(meb_vals,mebresults.(datasets{id}).msll(meb_ind),[mks{im+2} colors{im+2} '-']);
  %hybrid
  plot(hybrid_vals,hybridresults.(datasets{id}).msll(hybrid_ind),[mks{im+3} colors{im+3} '-']);
  legend(methods,'Location','SouthEastOutside');
  title(['MSLL for the ' datasets{id} ' dataset']);
  %saveas(gca,['ensemblegp/figures/' datasets{id} '-msll4.pdf']);
end

%%%rsde,r,kmeans,ivm,optim for my synthetic dataset
%% one off analysis
close all;
load('/home/trung/projects/ensemblegp/output/indpoints01-Mar-2013-1362097232487083.mat')
mysynth = logger;
smse = zeros(5,5);
msll = zeros(5,5);
ind_points = [10 50 100 200 500];
for ii=1:length(ind_points)
  fieldname = ['mysynthInducing' num2str(ind_points(ii))];
  smse(:,ii) = mysynth.(fieldname).smse;
  msll(:,ii) = mysynth.(fieldname).msll;
end

figure; hold on;
for im=1:length(methods)
  plot(ind_points,smse(im,:),[mks{im} colors{im} '-']);
end
legend(methods);
title('SMSE for the synthetic dataset');
  
figure; hold on;
for im=1:length(methods)
  plot(ind_points,msll(im,:),[mks{im} colors{im} '-']);
end
legend(methods);
title('MSLL for the synthetic dataset');
