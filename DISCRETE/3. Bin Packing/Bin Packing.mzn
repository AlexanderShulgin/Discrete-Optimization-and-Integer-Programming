% BIN PACKING PROBLEM
% There are n items with different weights and m bins with equal capacity. These items should be packed into bins such that 
% total weight of items packed into one bin doesn't exceed capacity of this bin. Find minimal number of required bins. 

% DATA
int: num_stuff;                    % number of things to pack
array[1..num_stuff] of int: stuff; % the weight of the things to pack
int: bin_capacity;                 % all bins have the same capacity
int: num_bins;                     % total number of bins (some of them can be empty)
% VARIABLES
array[1..num_stuff, 1..num_bins] of var 0..1 : placing; % placing[i,j]=1 <=> i-th thing is placed into j-th bin
array[1..num_bins] of var 0..1 : used; % used[i] = 1 <=> i-th bin is used (at least one item is placed into it)

solve minimize sum(bin in 1..num_bins)(used[bin]); 

constraint forall(bin in 1..num_bins)(sum(stuff_id in 1..num_stuff)(stuff[stuff_id]*placing[stuff_id, bin]) <= bin_capacity*used[bin]); % bin is not overflowed
constraint forall(stuff_id in 1..num_stuff)(sum(bin in 1..num_bins)(placing[stuff_id, bin]) = 1); % every item is placed in exactly one bin
 