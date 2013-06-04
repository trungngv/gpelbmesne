function gpcluster()
%GPCLUSTER Clustering based on GP
%
rng(1110, 'twister');

load ring.mat;
data.X = train_input;
data.Y = train_output;
data.Y = data.Y + 0.12*randn(size(data.Y),1);

load('motorcycle.mat');
data.X = x_times;
data.Y = accelaration;

load('jain.mat');
data.X = X;
data.Y = Y;
data.Y = data.Y + 0.5*randn(size(data.Y),1);

gpmodel = standardGP(data.X, data.Y);
disp('Computing adjacency matrix')
adjacent = computeAdjMatrix(data.X, gpmodel, false);

% complete graph-based search
disp('Finding connected components')
clustersLabel = FindConnectedComponents(adjacent);
nClusters = numel(unique(clustersLabel));
fprintf('Number of clusters: %d\n', nClusters);
clustersInd = cell(nClusters + 1, 1);
for i=1:nClusters
  clustersInd{i} = find(clustersLabel == i);
  if numel(clustersInd{i}) < 3
    clustersInd{nClusters + 1} = [clustersInd{nClusters + 1}; clustersInd{i}];
    clustersInd{i} = [];
  end
end

% quick plot
figure;
%hold all;
hold on;
cc=hsv(nClusters + 1);
marks = markers(nClusters + 1);
for i=1:nClusters+1
  if (size(data.X,2) == 2)
    %plot(data.X(clustersInd{i},1), data.X(clustersInd{i},2), 'x');
    if ~isempty(clustersInd{i})
      plot(data.X(clustersInd{i},1), data.X(clustersInd{i},2), marks{i}, 'color', cc(i,:));
    end  
  elseif size(data.X,2) == 1 && ~isempty(clustersInd{i})
    plot(data.X(clustersInd{i}), data.Y(clustersInd{i}), marks{i}, 'color', cc(i,:));
  end
end
fprintf('outliers: %s\n', marks{nClusters + 1});
end

