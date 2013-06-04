N = 10;
M = 10;
A = 2*rand(M,N);
D = (1:N)';
tic
expected = A*diag(1./D)*A';
toc
tic
AL = A.*repmat(1./sqrt(D'),size(A,1),1);
result = AL*AL';
toc
disp('total diff')
sum(sum(expected-result))

% % disp(expected)
% disp(result)