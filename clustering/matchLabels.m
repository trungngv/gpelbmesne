function [relabel, assignment] = matchLabels(candLabels, refLabels)
%MATCHLABELS reLabel = matchLabels(cand, ref)
%   Given a list of candidate labels (output of some labelling algorithm)
%   and a list of reference labels (true labels), assign (by matching) the
%   cluster labels of candidates according to the reference clusters.
% 
% Algorithm:
%   cand(i) := {k} s.t candLabels(k) = i
%   ref(j) := {k} s.t refLabels(k) = j
%   compat(i, j) := intersect(cand(i), ref(j))
%      how much candidate cluster i is compatible with reference j
% Now must assign each reference cluster to ONLY one candidate cluster
%   assignment(j) = argmax_i compat(i, j) s.t compat(i,j) > 0
%
% INPUT
%
% OUTPUT
%
% Trung V. Nguyen
% 04/02/13
%
nCand = max(candLabels);
nRef = max(refLabels);
cand = cell(nCand, 1);
ref = cell(nRef, 1);
for i=1:nCand,    cand{i} = find(candLabels == i); end
for j=1:nRef,    ref{j} = find(refLabels == j); end
compat = zeros(nCand, nRef);
for icand = 1:nCand
  for iref = 1:nRef
    compat(icand, iref) = numel(intersect(cand{icand}, ref{iref}));
  end
end
% assignment(i) = true cluster corresponding to the candidate cluster i
assignment = zeros(nCand,1);
if nCand == 1
  [~, ind] = max(compat);
  assignment(1) = ind;
else
  for cnt = 1:min(nRef, nCand)
    [maxCompats, bestRows] = max(compat);
    [~, bestCol] = max(maxCompats);
    bestRow = bestRows(bestCol);
    assignment(bestRow) = bestCol;
    compat(bestRow,:) = -1;
    compat(:,bestCol) = -1;
  end
end
% re-assign the labels
relabel = zeros(size(candLabels));
for i=1:nCand
  relabel(candLabels == i) = assignment(i);
end
end

