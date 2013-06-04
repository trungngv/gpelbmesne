function out = dummy(x)
%DUMMY Summary of this function goes here
%   Detailed explanation goes here
k=1;
while k<20 %use while to prevent internal matlab parallelization of for loop
  pinv(x);
  k = k+1;
end
out = x;
% disp('dummy')

