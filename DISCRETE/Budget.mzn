% BUDGETING
% There is a set of projects which can be invested by the firm
% over time period. Each of the projects brings a reward in each period
% once chosen. The objective is to maximizes the total net income which is 
% the difference between the final revenue and the initial investment. 
% The model enables restrictions on selection of projects, such as 
% that one project must be chosen among a set of mutually exclusive projects. 
% The solution to the model indicates the projects that will be selected and when
% to invest in them. Each period has a constraint on the minimum balance.

%DATA 
% Time periods
int: T;
% Number of 
int: NumMustTakeOne;
% Initial balance
float: InitBal;

%List of projects 
enum Projects;
% Set of projects to choose only one from them
set of Projects: MustTakeOne;
% Setup cost of projects 
array[Projects, 1..T] of float: SetupCost; 

% Rewards of projects in each period 
array[Projects, 1..T] of float: Reward;    

% Minimum balance at the end of each period
array[1..T] of float: MinBal;








%TEST DATA 
var int: x; % Это было в изначальном файле. Я не понял, зачем оно. Предположу, что minizinc требовал создания хотя бы
%одной var-переменной, чтобы успокоиться.

%тут начинается написанное мной.
%Предисловие: несколько раз будет использован трюк "мне запретили обращаться к массиву array по индексу==неизвестной переменной, поэтому я как-нибудь создам для array битовую маску, где 1 будет стоять только по этому самому индексу, и буду считать скалярное произведение array с маской".
% я буду использовать сокращение п.в. - "период времени" и м.в. -- "момент времени". Момент времени 1 -- это начальный, он же начало 1-го периода времени. Момент времени k -- начало k-го периода и т.д.
int: M;
M = T+7; % "большая константа", пригодится в констрейнах

array[Projects, 1..T] of var 0..1 : is_active; % is_active[project, time_moment] = 1 <=> project был активен в time_moment(иначе говоря, если в project проинвестировали в time_moment или раньше). 
%Конечно, в правильном решении, если для данного проекта поставлена 1 для некоего м.в., то она стоит и во всех последующих м.в.(так как отказываться от проектов мы не умеем, да и вряд ли хотим -- затрат проинвестированный проект уже не принесёт, только прибыль). 

array[Projects] of var 1..T+1 : invest_time; % для каждого проекта знаем,в какой м.в. в него проинвестировали. T+1 припасено для проектов, в которые решили не инвестировать. Данный массив играет важнейшую роль связующего звена для остальных переменных.

array[Projects, 1..T] of var 0..1 : help_matrix;
%Можно по-другому взглянуть на is_active: is_active[project, time_moment] = 1 <=> invest_time[project]<= time_moment
% Эту связь мы позже закрепим специальным констрейном.
%Понадобится вспомогательная таблица help_matrix: help_matrix[project, time_moment] = 1 <=> invest_time[project]>= time_moment
%Ввожу я её вынужденно, так как на самом деле мне необходима таблица matrix, т.ч.
% matrix[project, time_moment] = 1 <=> invest_time[project] = time_moment
% но умею сделать такое только комбинацией двух неравенств.
% Утверджается, что matrix = is_active + help_matrix -1 (поэлементно). Вообще конъюнкция нужна, конечно, но умножать нельзя. А такая операция совпадает с конъюнкцией на трёх из четырёх возможных бинарных-пар входов, оставшийся тождественно нулевой вход у меня не случится(т.к.не может случиться одновременного time_moment > invest_time[project]< time_moment).

% Итого 2*|Projects|*T бинарных переменных и |Projects| переменных, принимающих значения от 1 до T+1.

% Цель -- максимизировать прибыль!
% Из доходов вычтем расходы на инвестиции и начальный баланс. Поскольку последнее -- константа, то не буду её включать сюда
solve maximize sum(project in Projects, time_moment in 1..T)(Reward[project, time_moment]*is_active[project, time_moment]) - sum(project in Projects, time_moment in 1..T)(SetupCost[project, time_moment]*(is_active[project, time_moment]+help_matrix[project, time_moment]-1));

% Здесь записана линеаризованная версия следующей эквивалентности:
%для любого проекта project и м.в.time_moment:
%is_active[project, time_momemt] =1 <=> invest_time[project] <= time_moment.
% Она обеспечивает соответствие таблицы is_active с набором времён инвестирования invest_time
% P.S.Естественно, конъюнкцию можно было бы разбить на два констрейна.
constraint forall(project in Projects, time_moment in 1..T)(time_moment*(1-is_active[project, time_moment]) < invest_time[project] /\ invest_time[project] <= time_moment + (M-time_moment)*(1-is_active[project, time_moment]));

% Здесь записана линеаризованная версия следующей эквивалентности:
%для любого проекта project и м.в.time_moment:
%help_matrix[project, time_momemt] = 1 <=> invest_time[project] >= time_moment.
% Она обеспечивает соответствие таблицы help_matrix с набором времён инвестирования invest_time
constraint forall(project in Projects, time_moment in 1..T)(time_moment*help_matrix[project, time_moment] <= invest_time[project] /\ invest_time[project] < time_moment + (M-time_moment)*help_matrix[project, time_moment]);


% Выполним условия на поддержание минимального баланса. Я буду считать, что, например, MinBal[4] играет роль "финансовой подушки" на будущее. То есть в момент конца 4-го п.в. я соберу доход с уже заинвестированных проектов, потрачу сколько-то на новые инвестиции, и ПОСЛЕ ВСЕГО ЭТОГО у меня на счету должно быть хотя бы MinBal[4]. Такая интепретация мне кажется логичной.
%Остаток на счету в м.в. current_time -- это InitBal+сколько успели заработать-сколько успели потратить.

%Отдельно обработаем MinBal на концах всех п.в., кроме последнего.
%max тут на известном, да и можно было его разбить на два неравенства. Просто так нагляднее
constraint forall(current_time in 1..T-1)(InitBal + sum(project in Projects, time_moment in 1..current_time)(Reward[project, time_moment]*is_active[project, time_moment]) - sum(project in Projects, time_moment in 1..current_time+1)((is_active[project, time_moment]+help_matrix[project, time_moment]-1)*SetupCost[project, time_moment]) >= max(0, MinBal[current_time]));

%Теперь самый последний MinBal:
constraint InitBal + sum(project in Projects, time_moment in 1..T)(Reward[project, time_moment]*is_active[project, time_moment]) - sum(project in Projects, time_moment in 1..T)((is_active[project, time_moment]+help_matrix[project, time_moment]-1)*SetupCost[project, time_moment]) >= max(0, MinBal[T]);
%ну и чтобы в первый же м.в. не поступить гениально и не проинвестировать во все проекты, скажем, что в минус не ушли:
constraint InitBal - sum(project in Projects)(is_active[project, 1]*SetupCost[project, 1]) >= 0;

%наконец, реализуем MustTakeOne. Нам повезло -- последний столбец таблицы is_active как раз показывает нам, инвестировали мы в проект или нет.
% Правда, я не понял, что такое NumMustTakeOne. Это число таких множеств, из которых нужно выбрать лишь один элемент? Или множество одно, но хочется, чтобы вместо "только один" можно было легко получить "Только два" и т.д., и для этого дан параметр NumMustTakeOne?
% Пока буду считать, что второе. 
% Так же непонятно, стоит ли трактовать musthaveone как "ровно один проект" или "не больше одного". Буду считать, что второе.
% в любом случае моё решение будто должно быстро дорабатываться.
constraint sum(project in MustTakeOne)(is_active[project, T]) <= NumMustTakeOne;

%Необязательный, но более красивый output.
output["Ваш персональный план инвестиций:\n"]++["В \(project) инвестируем в начале \(invest_time[project]) -ого периода\n"|project in Projects]++["Если в проект сказано инвестировать в начале \(T+1) -ого периода, то не инвестируйте в него. "];


