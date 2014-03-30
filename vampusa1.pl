:- dynamic ([
	bot_location/1,
        bot_row/1,
        bot_col/1,
        bot_direction/1,
        object_ahead/1,
        object_row/1,
        object_col/1,
        pizzaguy_location/1,
        pit_location/1,
        vampire1_location/1,
        vampire2_location/1,
        vampire3_location/1,
        vampire4_location/1,
        vampire5_location/1,
        vampire6_location/1,
	room/1,
        map_width/1,
	map_height/1,
        action_count/1,
        action_took/1]).

begin :-
	format("Setting up a game of Vamp U.S.A.!~n"),
	initialize,
	format("Setup is complete, game is beginning!~n"),
	bot_location(BL),
	bot_direction(BD),
	format("The slayerbot is in room ~p, facing ~p~n",[BL, BD]),
	action([[1,1]]).

pre_action(VisitedList) :-
	bot_location(BL),
	pizzaguy_location(PL),
	vampire1_location(V1L),
	vampire2_location(V2L),
	vampire3_location(V3L),
	vampire4_location(V4L),
	vampire5_location(V5L),
	vampire6_location(V6L),

	(   BL = PL -> format("Got the pizza guy!~n");% actionHome(VisitedList);
	BL = V1L -> format("Vampire destroyed the bot!~n");
	BL = V2L -> format("Vampire destroyed the bot!~n");
	BL = V3L -> format("Vampire destroyed the bot!~n");
	BL = V4L -> format("Vampire destroyed the bot!~n");
	BL = V5L -> format("Vampire destroyed the bot!~n");
	BL = V6L -> format("Vampire destroyed the bot!~n");
	action(VisitedList)
	).
action(VisitedList) :-

	%figure out what action to take
	get_object_ahead,
	object_ahead(OA),
	format("Object Ahead: ~p~n", [OA]),

	(   OA == p -> format("Pit Ahead!~n"), turn;
	OA == w -> format("Wall Ahead!~n"), turn;
	OA == v -> kill_vampire_and_move;
	OA == o -> move_in_if_unvisited(VisitedList);
	move_but_look_for_adjacent_unvisited_rooms(VisitedList)),

	bot_location(Bloc),
	VL = [Bloc|VisitedList],
	%increase action count
	action_count(AC),
	AC1 is AC+1,
	retractall(action_count(_)),
	assert(action_count(AC1)),
	%output state of game
	output_game,
	pre_action(VL).
%stepHome(VisitedList) :-
	%go back to the beginning [1,1]
	%.
%Outputting the game
output_game :-
	%print current location, direction.
	bot_location(BL),
	bot_direction(BD),
	format("The slayerbot is in room ~p, facing ~p~n",[BL, BD]),
	%print map
	format("~n"),
	%print action
	action_count(AC),
	action_took(AT),
	format("Action ~p: ~p~n", [AC, AT]).
%----Walking and Turning------
turn :-
	bot_direction(BD),
	(   BD == e -> retractall(bot_direction(_)), assert(bot_direction(s));
	BD ==  s -> retractall(bot_direction(_)), assert(bot_direction(w));
	BD == w -> retractall(bot_direction(_)), assert(bot_direction(n));
	BD ==  n -> retractall(bot_direction(_)), assert(bot_direction(e));
	format("Couldn't turn!~n")
	).

kill_vampire_and_move :-
	%remove the vampire from the game and move into the room
        vampire1_location(V1L),
	vampire2_location(V2L),
	vampire3_location(V3L),
	vampire4_location(V4L),
	vampire5_location(V5L),
	vampire6_location(V6L),
	ObjectLocation = [object_row, object_col],
	(   ObjectLocation == V1L -> retractall(vampire1_location(_)), assert(vampire1_location(null));
	ObjectLocation == V2L -> retractall(vampire2_location(_)), assert(vampire2_location(null));
	ObjectLocation == V3L -> retractall(vampire3_location(_)), assert(vampire3_location(null));
	ObjectLocation == V4L -> retractall(vampire4_location(_)), assert(vampire4_location(null));
	ObjectLocation == V5L -> retractall(vampire5_location(_)), assert(vampire5_location(null));
	ObjectLocation == V6L -> retractall(vampire6_location(_)), assert(vampire6_location(null));
	format("Didn't work here~n")),
	retractall(action_took(_)),
	assert(action_took("Killed vampire!")),
	bot_direction(BD),
	walk(BD).

move_in_if_unvisited(VisitedList) :-
	%member may not be built in, need to identify if the object ahead is in a room I've already visited
	format("Got Here"),
	Visited = member([object_row, object_col], VisitedList),
	(   Visited == false -> walk(bot_direction);
	format("Worked")),
	retractall(action_took(_)),
	assert(action_took("Walked into univisted room!")).

move_but_look_for_adjacent_unvisited_rooms(VisitedList) :-
        %get all objects around bot, see if they are in rooms that have already been visited
	room(G),
	bot_row(BR),
	bot_col(BC),
	bot_row1 is BR+1,
	getel(G, bot_row1, BC, RoomNorth),
	bot_row1 is BR-1,
	getel(G,bot_row1, BC, RoomSouth),
	bot_col1 is BC+1,
	getel(G,BR, bot_col1, RoomEast),
	bot_col1 is BC-1,
	getel(G,BR, bot_col1, RoomWest),
	(  RoomNorth == v -> kill_vampire_and_move;
	RoomNorth == o -> move_in_if_unvisited(VisitedList);
	RoomSouth == v -> kill_vampire_and_move;
	RoomSouth == o -> move_in_if_unvisited(VisitedList);
	RoomWest == v -> kill_vampire_and_move;
	RoomWest == o -> move_in_if_unvisited(VisitedList);
	RoomEast == v -> kill_vampire_and_move;
	RoomEast == o -> move_in_if_unvisited(VisitedList);
	bot_direction(BD), walk(BD)).

walk(e) :-
	room(G),
	bot_row(R),
	bot_col(C),
	C1 is C+1,
	putel(G, R, C1, b, newG),	%Store new grind in newG
	retractall(bot_location(_)),
	assert(bot_location([R, C1])),
	retractall(room(X)),
	assert(room(newG)).

walk(s) :-
	room(G),
	bot_row(R),
	bot_col(C),
	R1 is R+1,
	putel(G, R1, C, b, newG),	%Store new grind in newG
	retractall(bot_location(_)),
	assert(bot_location([R1, C])),
	retractall(room(X)),
	assert(room(newG)).

walk(w) :-
	room(G),
	bot_row(R),
	bot_col(C),
	C1 is C-1,
	putel(G, R, C1, b, newG),	%Store new grind in newG
	retractall(bot_location(_)),
	assert(bot_location([R, C1])),
	retractall(room(X)),
	assert(room(newG)).
walk(n) :-
	room(G),
	bot_row(R),
	bot_col(C),
	R1 is R-1,
	putel(G, R1, C, b, newG),	%Store new grind in newG
	retractall(bot_location(_)),
	assert(bot_location([R1, C])),
	retractall(room(X)),
	assert(room(newG)).

%-----Looking Ahead-----
get_object_ahead :-
	%given bot location and direction facing, store object in the
	%next room in object_ahead
	bot_direction(D),
	room(G),
	map_height(MH),
	map_width(MW),
	bot_row(BR),
	bot_col(BC),
	Bot_row1 is BR+1,
	Bot_row2 is BR-1,
	Bot_col1 is BC+1,
	Bot_col2 is BC-1,
	(
	D == e -> (   (Bot_row1) > MH -> retractall(object_ahead(_)), assert(object_ahead(w));
getel(G, Bot_row1, BC, OA), retractall(object_row(_)), assert(object_row(Bot_row1)), retractall(object_col(_)), assert(object_col(BC)), retractall(object_ahead(_)),assert(object_ahead(OA)));
	D == w -> (   (Bot_row2) < 1 -> retractall(object_ahead(_)), assert(object_ahead(w)); getel(G, Bot_row2, BC, OA),  retractall(object_row(_)), assert(object_row(Bot_row2)), retractall(object_col(_)), assert(object_col(BC)), retractall(object_ahead(_)),assert(object_ahead(OA)));
	D == n ->  (   (Bot_col1) > MW -> retractall(object_ahead(_)), assert(object_ahead(w));getel(G, BR, Bot_col1, OA),  retractall(object_row(_)), assert(object_row(BR)), retractall(object_col(_)), assert(object_col(Bot_col1)), retractall(object_ahead(_)),assert(object_ahead(OA)));
        D == s -> (   (Bot_col2) < 1 -> retractall(object_ahead(_)), assert(object_ahead(w));getel(G, BR, Bot_col2, OA),  retractall(object_row(_)), assert(object_row(BR)), retractall(object_col(_)), assert(object_col(Bot_col2)), retractall(object_ahead(_)),assert(object_ahead(OA)));
	format("Invalid Direction")).


%---------------INITIALIZE GAME--------------------
initialize :-
	initializeGame,
	initializeBot.
initializeGame :-
	retractall(action_count(_)),
	assert(action_count(0)),

	retractall(map_height(_)),
	assert(map_height(4)),
	retractall(map_width(_)),
	assert(map_width(3)),

	retractall(pizzaguy_location(_)),
	assert(pizzaguy_location([3,2])),

	retractall(pit_location(_)),
	assert(pit_location([3,3])),

	retractall(vampire1_location(_)),
	assert(vampire1_location([1,3])),

	retractall(vampire2_location(_)),
	assert(vampire2_location([1,4])),

	retractall(vampire3_location(_)),
	assert(vampire3_location([2,2])),

	retractall(vampire4_location(_)),
	assert(vampire4_location([4,2])),

	retractall(vampire5_location(_)),
	assert(vampire5_location([2,3])),

	retractall(vampire6_location(_)),
	assert(vampire6_location([4,4])),

	retractall(room(_)),
	assert(room([[o,o,o],[o,v,v],[v,d,p],[v,v,v]])).
initializeBot :-
	retractall(bot_location(_)),
	assert(bot_location([1,1])),
	retractall(bot_direction(_)),
	assert(bot_direction(e)),
	retractall(bot_row(_)),
	assert(bot_row(1)),
	retractall(bot_col(_)),
	assert(bot_col(1)).

%-----Grid Handling-------
getel(G, Row, Column, Result) :-
	nth1(Row, G, Row1),
	nth1(Column, Row1, Result),
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














