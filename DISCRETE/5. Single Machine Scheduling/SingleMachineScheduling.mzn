% SINGLE MACHINE SCHEDULING
% There are n tasks which should be processed by a single machine for the time interval [0,..,T]. We consider only discrete time moments.
% Each task has release time, processing time and deadline. Only one task can be processed by the machine at each time moment. 
% Makespan of given schedule is the completion time of the latest task. Find a minimal makespan schedule.
%так как иного не указано, я считаю, что задание i выполняется на отрезке времени [s_i, s_i+p_i).
% DATA
int: T;                  % time horizon
int: n;                  % num tasks
array[1..n] of int: r;   % release times
array[1..n] of int: p;   % processing times
array[1..n] of int: d;   % deadlines
int : M1 = sum(i in 1..n)(p[i]);
int : M2 = max(d);
% VARIABLES
array[1..n] of var int: s; % s_j -- момент начала выполнения j-го задания
array[1..n, 1..n] of var 0..1 : x; % x_ij = 1 <=> i-ое задание начато прежде j-го
array[1..n] of var 0..1 : max_index; % max_index[i] = 1 => s[i]+p[i] -- это максимум среди всех s[j]+p[j]
var int : max_time;
%OBJECTIVE
solve minimize max_time;
%CONSTRAINS
constraint forall(i in 1..n)(s[i]>=r[i]); %задание нельзя начать раньше его релиза
constraint forall(i in 1..n)(s[i]<=d[i]-p[i]); %задание нужно начать так, чтобы успеть до дедлайна
constraint forall(i,j in 1..n where i!=j)(x[i,j]+x[j,i] = 1); %либо первое задание начато раньше второго, либо наоборот
constraint forall(i,j in 1..n where i!=j)(s[j]-s[i] >= 2*M1*(x[i,j]-1)+p[i]); % чтобы задания не накладывались
constraint sum(i in 1..n)(max_index[i]) = 1; % чтобы массив Max_index был ненулевым, а действительно выбрал максимум
constraint forall(i,j in 1..n where i!=j)(M2*(1-max_index[i]) + s[i]+p[i] >= s[j]+p[j]); %чтобы max_index принял правильный вид
constraint forall(i in 1..n)(max_time >= s[i]+p[i]); %конечно, максимум чисел больше или равен им всем
constraint forall(i in 1..n)(max_time <= s[i]+p[i] + M2*(1-max_index[i])); %а это даст на него оценку сверху

