:- dynamic ([
	robot_loc,
	visited_rooms,
	room
	]).

go :-
	format("Setting up a game of Vamp U.S.A.!"),
	assert(robot_loc([1,1])),
	assert(room([E,_,v,v], [v,p,d,_], [_,_,_,v]))
	
	format("Setup is complete, game is beginning!"),
	walk([1,1]).
	
walk(room_to_visit) :-
	visited_rooms(prev_visited),
	retractall(visited_rooms(_)),
	assert(visited_rooms([prev_visited | room_to_visit])).