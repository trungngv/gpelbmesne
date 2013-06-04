function model=assignClusterLabels(data, model)
%
% Input:
%   data [struct] Training data:
%       .X [dim x num_data] Training input vectors.
%       .y [1 x num_data] Output cluster labels
%   X [dim x num_data] Input data.
%
% Output:
%  model [struct] from svdd.m
%      .cluster_labels [1 x num_data] predicted cluster labels
%                --> ** NOTE: BSVs are classified as outliers (indexed by 0)
%
% References  
% 1. A.Ben-Hur,D.Horn,H.T.Siegelmann and V.Vapnik. Support Vector Clustring.
%    Journal of Machine Learning Research 2, 125-137, 2001
% 2. J. Lee and D. Lee, An Improved Cluster Labeling Method for Support 
%    Vector Clustering. IEEE TPAMI 27-(3), 461- 464, 2005.
% 3. J. Lee and D. Lee, Dynamic Characterization of Cluster Structures for 
%    Robust and Inductive Support Vector Clustering, IEEE TPAMI 28-(11), 
%    1869-1874, 2006.
% 4. J. Yang, V. Estivill-Castro, S.K. Chalup, Support Vector Clustering 
%    Through Proximity Graph Modelling, Proc. 9th Int��l Conf. Neural 
%    Information Processing, 898-903, 2002.
% 5. Stprtool: http://cmp.felk.cvut.cz/cmp/software/stprtool/
%
%==========================================================================
% January 13, 2009
% Implemented by Daewon Lee
% WWW: http://sites.google.com/site/daewonlee/
%==========================================================================

%% Initialization
if isequal(model.options.method,'KNN')&~isfield(model.options,{'k'})
    model.options.k=4;
end

%% Cluster Labeling
[dim,N] = size(data.X);
disp(strcat(['Labeling cluster index by using ',model.options.method,'....']));
switch model.options.method
    case 'RAND' %random algorithm
      clusters = zeros(N, 1);
      N = numel(model.inside_ind);
      nClusters = ceil(2*log2(N)); % random cluster 'centres'
      perm = randperm(N,N);
      centres = model.inside_ind(perm(1:nClusters));
      remainingInd = model.inside_ind(perm(nClusters+1:end));
      numInitialCluster = nClusters;
      R = model.r + 10^(-7)  % Squared radius of the minimal enclosing ball
      for i=1:nClusters
        clusters(centres(i)) = i;
      end
      
      % assign every remaining point to one cluster
      for iiidx=1:numel(remainingInd)
        idx = remainingInd(iiidx);
        for cluster=1:nClusters
          if svcIsAdjacent(model, data.X(:,idx), data.X(:, centres(cluster)), R)
            clusters(idx) = cluster;
            break;
          end
        end
        if clusters(idx) == 0
          nClusters = nClusters + 1;
          clusters(idx) = nClusters;
          centres(nClusters) = idx;
        end
      end
      fprintf('Initial number of clusters: %d\n', numInitialCluster);
      fprintf('Num clusters after first pass: %d\n', nClusters);
      %TODO also try with replacing cluster centre by the real centres
      
      % merge clusters
      adjacent = FindAdjMatrix(data.X(:,centres),model);
      % Finds the cluster assignment of each data point 
      hubs = FindConnectedComponents(adjacent);
      newClusters = zeros(N, 1);
      nTrueClusters = numel(unique(hubs));
      for i=1:nTrueClusters
        centresInHub = find(hubs == i);
        for j=1:numel(centresInHub)
          newClusters(clusters == centresInHub(j)) = i;
        end  
      end
      model.cluster_labels=zeros(1,length(data.X));
      model.cluster_labels = double(newClusters);
    case 'CG'        
        adjacent = FindAdjMatrix(data.X(:,model.inside_ind),model);
        % Finds the cluster assignment of each data point 
        clusters = FindConnectedComponents(adjacent);
        model.cluster_labels=zeros(1,length(data.X));
        model.cluster_labels(model.inside_ind)=double(clusters);        
    case 'DD'
        [result]=plot_dd(data.X(:,model.inside_ind)');        
        adjacent = FindAdjMatrix_proximity(data.X(:,model.inside_ind),result,model);
        % Finds the cluster assignment of each data point 
        clusters = FindConnectedComponents(adjacent);
        model.cluster_labels=zeros(1,length(data.X));
        model.cluster_labels(model.inside_ind)=double(clusters);    
     case 'MST'
        [result]=plot_mst(data.X(:,model.inside_ind)');
        adjacent = FindAdjMatrix_proximity(data.X(:,model.inside_ind),result,model);
        % Finds the cluster assignment of each data point 
        clusters = FindConnectedComponents(adjacent);
        model.cluster_labels=zeros(1,length(data.X));
        model.cluster_labels(model.inside_ind)=double(clusters);    
    case 'KNN'
        [result]=knn_svc(model.options.k,data.X(:,model.inside_ind));
        adjacent = FindAdjMatrix_proximity(data.X(:,model.inside_ind),result,model);
        % Finds the cluster assignment of each data point 
        clusters =  FindConnectedComponents(adjacent);        
        model.cluster_labels=zeros(1,length(data.X));
        model.cluster_labels(model.inside_ind)=double(clusters);  
        
    case 'SEP-CG'
        % find stable equilibrium points
        [rep_locals,locals,local_val,match_local]=FindLocal(data.X',model);
        model.local=locals';    % dim x N_local
        %small_n=size(locals,1);
        % calculates the adjacent matrix
        [adjacent] = FindAdjMatrix(model.local,model);
        % Finds the cluster assignment of each data point 
        local_clusters_assignments = FindConnectedComponents(adjacent);
        model.cluster_labels = local_clusters_assignments(match_local)';
    case 'E-SVC'
        if ~isfield(model.options,{'epsilon'})
            model.options.epsilon=0.05;
        end
        if ~isfield(model.options,{'NofK'})
            model.options.NofK=0;
        end        
       [model] = esvcLabel(data,model);
end
disp('Finished SVC clustering!');

