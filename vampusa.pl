
%---------------------------------------------------------------
%Sensors
is_vampire(e) :-
	robot_col(Column),
	Column1 is Column+1,
	getel(Row,Column1,v).

is_vampire(w) :-
	robot_col(Column),
	Column1 is Column-1,
	getel(Row,Column1,v).

is_vampire(n) :-
	robot_row(Row),
	Row1 is Row-1,
	getel(Row1,Column,v).

is_vampire(s) :-
	robot_row(Row),
	Row1 is Row+1,
	getel(Row1,Column,v).

is_pit(e) :-
	robot_col(Column),
	Column1 is Column+1,
	getel(Row,Column1,p).

is_pit(w) :-
	robot_col(Column),
	Column1 is Column-1,
	getel(Row,Column1,p).

is_pit(n) :-
	robot_row(Row),
	Row1 is Row-1,
	getel(Row1,Column,p).

is_pit(s) :-
	robot_row(Row),
	Row1 is Row+1,
	getel(Row1,Column,p).

is_pizza(e) :-
	robot_col(Column),
	Column1 is Column+1,
	getel(Row,Column1,d).

is_pizza(w) :-
	robot_col(Column),
	Column1 is Column-1,
	getel(Row,Column1,d).

is_pizza(n) :-
	robot_row(Row),
	Row1 is Row-1,
	getel(Row1,Column,d).

is_pizza(s) :-
	robot_row(Row),
	Row1 is Row+1,
	getel(Row1,Column,d).

is_wall(e) :-



