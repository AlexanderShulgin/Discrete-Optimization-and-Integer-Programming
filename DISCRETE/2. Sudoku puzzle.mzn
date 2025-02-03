%DATA
int: N = 9; %number of rows and columns
int: M = 11; % big constant
%VARIABLES
array [1..N, 1..N] of var 1..9 : tableau;
array [1..N, 1..N, 1..N, 1..N] of var 0..1 : delta; % delta[i,j,k,l]=1 => tableau[i,j] > tableau [k,l]
%OBJECTIVE - fill tableau with numbers and satisfy constraints
solve satisfy;
%CONSTRAINTS
constraint forall(i1,j1,i2,j2 in 1..N)(tableau[i1,j1] - tableau[i2,j2] > M*(delta[i1,j1,i2,j2]-1)); 
%delta does what it supposed to do
%when i=k and j=l delta can be equal to 0, so no worries

constraint forall(i,j1,j2 in 1..N where j1!=j2)(delta[i,j1,i,j2]+delta[i,j2,i,j1] = 1); 
% no repetitions in rows

constraint forall(j,i1,i2 in 1..N where i1!=i2)(delta[i1,j,i2,j]+delta[i2,j,i1,j] = 1); 
% no repetitions in columns

constraint forall(vert_sq_num in 0..2, horiz_sq_num in 0..2)(forall(i1,i2 in 1+vert_sq_num*3..3+vert_sq_num*3, j1,j2 in 1+horiz_sq_num*3..3+horiz_sq_num*3 where (i1!=i2 \/ j1!=j2))(delta[i1,j1,i2,j2]+delta[i2,j2,i1,j1] = 1));
% no repetitons in squares

constraint tableau[1,4] = 8;
constraint tableau[1,6] = 1;
constraint tableau[2,8] = 4;
constraint tableau[2,9] = 3;
constraint tableau[3,1] = 5;
constraint tableau[4,5] = 7;
constraint tableau[4,7] = 8;
constraint tableau[5,7] = 1;
constraint tableau[7,1] = 6;
constraint tableau[7,8] = 7;
constraint tableau[7,9] = 5;
constraint tableau[8,3] = 3;
constraint tableau[8,4] = 4;
constraint tableau[9,4] = 2;
constraint tableau[9,7] = 6;
