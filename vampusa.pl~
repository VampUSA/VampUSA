:- dynamic ([
	robot_row/1,
	robot_col/1,
	direction/1,
	visited_rooms/1,
	room/1,
	room_width/1,
	room_height/1
	]).

go :-
	format("Setting up a game of Vamp U.S.A.!"),
	assert(robot_row(1)),
	assert(robot_col(1)),
	assert(direction(e)),
	assert(room([E,_,v,v], [v,p,d,_], [_,_,_,v])),
	assert(room_width(4),
	assert(room_heigh(3),
	
	format("Setup is complete, game is beginning!"),
	step(1,1).
	
step(RoomRow, RoomCol) :-
	visited_rooms(prev_visited),
	retractall(visited_rooms(_)),
	assert(visited_rooms([prev_visited | [RoomRow, RoomCol])).
	
	%figure out what action to take
	
	
	%change the map
	
	
	%do some recursive stuff to continue process
	
%---------------------------------------------------------------
%Moves -- Make all necessary checks before executing this function
walk(e) :-
	room(G),
	robot_row(R),
	robot_col(C),
	C1 is C+1,
	putel(G, R, C1, b, newG),	%Store new grind in newG
	
	retractall(rooms(X)),
	assert(room(newG)).
	
walk(s) :-
	room(G),
	robot_row(R),
	robot_col(C),
	R1 is R+1,
	putel(G, R1, C, b, newG),	%Store new grind in newG
	
	retractall(rooms(X)),
	assert(room(newG)).
	
walk(w) :-
	room(G),
	robot_row(R),
	robot_col(C),
	C1 is C-1,
	putel(G, R, C1, b, newG),	%Store new grind in newG
	
	retractall(rooms(X)),
	assert(room(newG)).
	
walk(n) :-
	room(G),
	robot_row(R),
	robot_col(C),
	R1 is R-1,
	putel(G, R1, C, b, newG),	%Store new grind in newG
	
	retractall(rooms(X)),
	assert(room(newG)).
	
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
	

%---------------------------------------------------------------
%Grid Handling

% getel(M,R,C,E): Get an element from matrix M: E = M(R,C).
getel(Row, Column, Result) :-
	nthl(Row, Row1),
	nthl(Column, Row, Result),
	!.
	
% replace(I,L,E,L2): Replace the Ith element of list L with E,
% resulting in L2.  L2=L; L2[I]=E.
replace(I,L1,E,L2) :- replace(I,L1,E,L2,1).
replace(I,[_|L],E,[E|L],I) :- !.
replace(I,[E0|L1],E,[E0|L2],J) :- J < I,
	J1 is J+1,
	replace(I,L1,E,L2,J1).
	
% putel(Grid,R,C,E,Grid2): Given a matrix Grid, modify it: Grid1=Grid; Grid2(R,C)=E.
putel(Grid,R,C,E,Grid2) :-
	nth1(R,Grid,R1),
	replace(C,R1,E,R2),
	replace(R,Grid,R2,Grid2).