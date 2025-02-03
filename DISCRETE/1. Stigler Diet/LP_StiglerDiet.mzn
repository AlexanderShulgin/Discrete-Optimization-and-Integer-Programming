%DATA
% planning horizon
int: T = 365;
% food ids: 1 to F
int: F = 77;
% nutrient ids: 1 to N
int: N = 9;
% allowed violation of nutrition target
float: delta = 0.1;
% nutrition target per day
array[1..N] of float: k;
% food nutrition per 1$ (1939)
array[1..F, 1..N] of float: s;
% VARIABLES
array [1..F] of var float: x; % consumption of every type of food per day in $
% OBJECTIVE - MINIMIZE TOTAL COST
solve minimize T*sum(i in 1..F)(x[i]);
% CONSTRAINTS
constraint forall (prod_type in 1..F)(x[prod_type]>=0); % negative consumption not allowed
constraint forall (nutr_type in 1..N)((1+delta)*k[nutr_type] >= sum(prod_type in 1..F)(s[prod_type,nutr_type]*x[prod_type]));
constraint forall (nutr_type in 1..N)((1-delta)*k[nutr_type] <= sum(prod_type in 1..F)(s[prod_type,nutr_type]*x[prod_type]));
%nutrition within boundaries


