function assignments = chineseRestaurantProcess(numCustomers, alpha)
%CHINESERESTAURANTPROCESS assignments = chineseRestaurantProcess(numCustomers, alpha)
%   
%  Generate table assignments for 'numCustomers' customers, according to a
%  Chinese Restaurant Process with dispersion parameter 'alpha'.
%
%  NOTE: this method does not return the group parameters (i.e. food
%  ordered at a table) as in a standard CRP.
%
%  Returns the table assignments for each customers.
%
% Trung V. Nguyen
% 31/01/13
assignments = zeros(numCustomers, 1);

% first customer always sit at a new table!
assignments(1) = 1;
nextTableIdx = 2;

for n=2:numCustomers
  newTable = rand < (alpha / (n + alpha));
  if newTable
    % sits at a new table
    assignments(n) = nextTableIdx;
    nextTableIdx = nextTableIdx + 1;
  else
    % sits at a current table
    % here's how this code works
    %                        n-th customer waiting to be seated
    %                        ^
    % [1 2 3 1 2 1 ... 4 2 1 0 0 0 0 0 0]
    %                      ^
    %                      (n-1)-th customer
    % p(n-th sits at table k) \propto n_k 
    assignments(n) = assignments(randi(n-1, 1, 1));
  end
end
end

