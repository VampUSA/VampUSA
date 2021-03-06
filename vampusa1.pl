:- dynamic ([
	bot_location/1,
        bot_row/1,
        bot_col/1,
        bot_direction/1,
        object_ahead/1,
        object_location/1,
        object_row/1,
        object_col/1,
        object_in_list/1,
        pizzaguy_location/1,
        ladder_location/1,
        pit_location/1,
        %room is a list of lists, storing the map's room objects (vampire, open room, pit, pizza dude)
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
	room(G),
	bot_row(R),
	bot_col(C),
	putel(G, R, C, b, NewG),	%Store new grind in newG
	retractall(room(X)),
	assert(room(NewG)),
	format("The slayerbot is in room ~p, facing ~p~n~n",[BL, BD]),
	pre_action.

pre_action :-
	bot_location(BL),
	pizzaguy_location(PL),
	(   BL == PL -> format("Found the pizza dude!~nGo climb the ladder!~n"), retractall(action_took(_)),assert(action_took("Picked up Pizza Dude!")), action_count(AC),AC1 is AC+1,retractall(action_count(_)),assert(action_count(AC1)),output_game, pre_actionHome;% actionHome(VisitedList);
	action
	).
action :-

	get_object_ahead,
	object_ahead(OA),
	format("Object Ahead: ~p~n", [OA]),
	%take action based on what the object ahead of the bot is.
	(   OA == p -> format("Detected smoke! Pit Ahead!~n"), turn;
	OA == w -> format("Wall Ahead!~n"), turn;
	OA == v ->  bot_direction(BD), walk(BD),retractall(action_took(_)),assert(action_took("Vampire ahead, attack!")) ;%kill_vampire_and_move;
	OA == o -> bot_direction(BD), walk(BD),retractall(action_took(_)),assert(action_took("Walked into univisted room!")) ;
	OA == d -> bot_direction(BD), walk(BD),retractall(action_took(_)),assert(action_took("Walked into univisted room!")) ;
	move_but_look_for_adjacent_unvisited_rooms),

	%increase action count
	action_count(AC),
	AC1 is AC+1,
	retractall(action_count(_)),
	assert(action_count(AC1)),
	%output state of game
	output_game,
	pre_action.
% pre_actionHome and actionHome are used after the pizza guy has been
% picked up.
pre_actionHome :-
	bot_location(BL),
	ladder_location(LL),

	(   BL == LL ->  action_count(AC),AC1 is AC+1,retractall(action_count(_)),assert(action_count(AC1)), format("Action ~p: Climbed ladder with the pizza dude!~n Slayerbot saved the day!~n Free pizza for life!~n ---GAME OVER---", [AC1]);
	actionHome
	).
actionHome :-
	%go back to the beginning [1,1]
	get_object_ahead,
	object_ahead(OA),
	format("Object Ahead: ~p~n", [OA]),
	%figure out what action to take based on what is ahead of me
	(   OA == p -> format("Detected smoke! Pit Ahead!~n"), turn;
	OA == w -> format("Wall Ahead!~n"), turn;
	OA == v ->  bot_direction(BD), walkHome(BD),retractall(action_took(_)),assert(action_took("Detected vampire ahead, attack!")) ;
	OA == o -> bot_direction(BD), walkHome(BD),retractall(action_took(_)),assert(action_took("Walked into totally univisted room!"));
	OA == x -> bot_direction(BD), walkHome(BD), retractall(action_took(_)), assert(action_took("Walked into room I haven't visited since finding the pizza guy!"));
	move_but_look_for_adjacent_unvisited_rooms_Home),

	%increase action count
	action_count(AC),
	AC1 is AC+1,
	retractall(action_count(_)),
	assert(action_count(AC1)),
	%output state of game
	output_game,
	pre_actionHome
	.
%Outputting the game
output_game :-
	%print current location, direction.
	action_count(AC),
	action_took(AT),
	format("Action ~p: ~p~n", [AC, AT]),
	bot_location(BL),
	bot_direction(BD),
	format("Now the slayerbot is in room ~p, facing ~p~n",[BL, BD]),
	%print map
	room(R),
	map_height(MP),
	print(MP, R),
	format(" ~n")
	.
%use to print contents of "room"
print(0, _) :- !.
print(_, []).
print(N, [H|T]) :-
	write(H), nl, N1 is N-1, print(N1, T).
%----Walking and Turning------
turn :-
	bot_direction(BD),
	(   BD == e -> retractall(bot_direction(_)), assert(bot_direction(s));
	BD ==  s -> retractall(bot_direction(_)), assert(bot_direction(w));
	BD == w -> retractall(bot_direction(_)), assert(bot_direction(n));
	BD ==  n -> retractall(bot_direction(_)), assert(bot_direction(e));
	format("Couldn't turn!~n")
	),
	retractall(action_took(_)),
	assert(action_took("Turned Right!")).
turnToNorth :-
	bot_direction(BD),
	(   BD == e -> retractall(bot_direction(_)), assert(bot_direction(n)), retractall(action_took(_)), assert(action_took("Turned Left!")), action_count(AC),	AC1 is AC+1,retractall(action_count(_)),assert(action_count(AC1)),output_game;
	BD == w -> retractall(bot_direction(_)), assert(bot_direction(n)), retractall(action_took(_)), assert(action_took("Turned Right!")), action_count(AC),	AC1 is AC+1,retractall(action_count(_)),assert(action_count(AC1)),output_game;
	BD == s -> retractall(bot_direction(_)), assert(bot_direction(e)), retractall(action_took(_)), assert(action_took("Turned Left!")), action_count(AC),	AC1 is AC+1,retractall(action_count(_)),assert(action_count(AC1)),output_game, retractall(bot_direction(_)), assert(bot_direction(n)), retractall(action_took(_)), assert(action_took("Turned Left!")), action_count(AC),	AC1 is AC+1,retractall(action_count(_)),assert(action_count(AC1)),output_game;
	format("Already facing north"))
	.
turnToEast :-
	bot_direction(BD),
	(   BD == n -> retractall(bot_direction(_)), assert(bot_direction(e)), retractall(action_took(_)), assert(action_took("Turned Right!")), action_count(AC),	AC1 is AC+1,retractall(action_count(_)),assert(action_count(AC1)),output_game;
	BD == s -> retractall(bot_direction(_)), assert(bot_direction(e)), retractall(action_took(_)), assert(action_took("Turned Left!")), action_count(AC),	AC1 is AC+1,retractall(action_count(_)),assert(action_count(AC1)),output_game;
	BD == w -> retractall(bot_direction(_)), assert(bot_direction(n)), retractall(action_took(_)), assert(action_took("Turned Right!")), action_count(AC),	AC1 is AC+1,retractall(action_count(_)),assert(action_count(AC1)),output_game, retractall(bot_direction(_)), assert(bot_direction(e)), retractall(action_took(_)), assert(action_took("TurnedRight!")), action_count(AC),	AC1 is AC+1,retractall(action_count(_)),assert(action_count(AC1)),output_game;
	format("Already facing east"))
	.
turnToWest :-
	bot_direction(BD),
	(   BD == n -> retractall(bot_direction(_)), assert(bot_direction(w)), retractall(action_took(_)), assert(action_took("Turned Left!")), action_count(AC),	AC1 is AC+1,retractall(action_count(_)),assert(action_count(AC1)),output_game;
	BD == s -> retractall(bot_direction(_)), assert(bot_direction(w)), retractall(action_took(_)), assert(action_took("Turned Right!")), action_count(AC),	AC1 is AC+1,retractall(action_count(_)),assert(action_count(AC1)),output_game;
	BD == e -> retractall(bot_direction(_)), assert(bot_direction(n)), retractall(action_took(_)), assert(action_took("Turned Left!")), action_count(AC),	AC1 is AC+1,retractall(action_count(_)),assert(action_count(AC1)),output_game, retractall(bot_direction(_)), assert(bot_direction(w)), retractall(action_took(_)), assert(action_took("Turned Left!")), action_count(AC),	AC1 is AC+1,retractall(action_count(_)),assert(action_count(AC1)),output_game;
	format("Already facing west"))
	.
turnToSouth :-
	format("Here in turntosouth"),
	bot_direction(BD),
	(   BD == e -> retractall(bot_direction(_)), assert(bot_direction(s)), retractall(action_took(_)), assert(action_took("Turned Right!")), action_count(AC),	AC1 is AC+1,retractall(action_count(_)),assert(action_count(AC1)),output_game;
	BD == w -> retractall(bot_direction(_)), assert(bot_direction(s)), retractall(action_took(_)), assert(action_took("Turned Left!")), action_count(AC),	AC1 is AC+1,retractall(action_count(_)),assert(action_count(AC1)),output_game;
	BD == n -> retractall(bot_direction(_)), assert(bot_direction(e)), retractall(action_took(_)), assert(action_took("Turned Right!")), action_count(AC), AC1 is AC+1,retractall(action_count(_)),assert(action_count(AC1)),output_game, retractall(bot_direction(_)), assert(bot_direction(s)), retractall(action_took(_)), assert(action_took("Turned Right!")), action_count(Ac),Ac1 is Ac+1,retractall(action_count(_)),assert(action_count(Ac1)), output_game;
	format("Already facing south"))
	.

move_but_look_for_adjacent_unvisited_rooms :-
        %get all objects around bot, see if they are in rooms that have already been visited

	room(G),
	bot_row(BR),
	bot_col(BC),
	map_height(MH),
	map_width(MW),
	Bot_row1 is BR-1,
	(   Bot_row1  < 1 -> getel(G,BR,BC,RoomNorth);
	getel(G, Bot_row1, BC, RoomNorth)),
	Bot_row2 is BR+1,
	(   Bot_row2 > MH ->  getel(G,BR,BC,RoomSouth);
	getel(G,Bot_row2, BC, RoomSouth)),
	Bot_col1 is BC+1,
	(   Bot_col1 > MW ->  getel(G,BR,BC,RoomEast);
	getel(G,BR, Bot_col1, RoomEast)),
	Bot_col2 is BC-1,
	(   Bot_col2 < 1 ->  getel(G,BR,BC,RoomWest);
	getel(G,BR, Bot_col2, RoomWest)),
	(RoomNorth == v -> turnToNorth, walk(n), retractall(action_took(_)),assert(action_took("Detected vampire ahead, attack!"));
	RoomNorth == o -> turnToNorth, walk(n), retractall(action_took(_)),assert(action_took("Walked in unvisited room!"));
	RoomNorth == d -> turnToNorth, walk(n), retractall(action_took(_)),assert(action_took("Walked in unvisited room!"));
	RoomSouth == v -> turnToSouth, walk(s),retractall(action_took(_)),assert(action_took("Detected vampire ahead, attack!"));
	RoomSouth == o -> turnToSouth, walk(s),  retractall(action_took(_)),assert(action_took("Walked in unvisited room!"));
	RoomSouth == d ->  turnToSouth, walk(s),  retractall(action_took(_)),assert(action_took("Walked in unvisited room!"));
	RoomWest == v ->  turnToWest, walk(w),retractall(action_took(_)),assert(action_took("Detected vampire ahead, attack!"));
	RoomWest == o -> turnToWest, walk(w), retractall(action_took(_)),assert(action_took("Walked in unvisited room!"));
	RoomWest == d -> turnToWest, walk(w), retractall(action_took(_)),assert(action_took("Walked in unvisited room!"));
	RoomEast == v ->  turnToEast, walk(e),retractall(action_took(_)),assert(action_took("Detected vampire ahead, attack!"));
	RoomEast == o -> turnToEast, walk(e), retractall(action_took(_)),assert(action_took("Walked in unvisited room!"));
	RoomEast == d ->  turnToEast, walk(e), retractall(action_took(_)),assert(action_took("Walked in unvisited room!"));
	bot_direction(BD), walk(BD), retractall(action_took(_)),assert(action_took("Walked straight ahead. Room already visited!"))).

move_but_look_for_adjacent_unvisited_rooms_Home :-
        %get all objects around bot, see if they are in rooms that have already been visited
	room(G),
	bot_row(BR),
	bot_col(BC),
	map_height(MH),
	map_width(MW),
	Bot_row1 is BR-1,
	(   Bot_row1  < 1 -> getel(G,BR,BC,RoomNorth);
	getel(G, Bot_row1, BC, RoomNorth)),
	Bot_row2 is BR+1,
	(   Bot_row2 > MH ->  getel(G,BR,BC,RoomSouth);
	getel(G,Bot_row2, BC, RoomSouth)),
	Bot_col1 is BC+1,
	(   Bot_col1 > MW ->  getel(G,BR,BC,RoomEast);
	getel(G,BR, Bot_col1, RoomEast)),
	Bot_col2 is BC-1,
	(   Bot_col2 < 1 ->  getel(G,BR,BC,RoomWest);
	getel(G,BR, Bot_col2, RoomWest)),
	(RoomNorth == v -> turnToNorth, walkHome(n), retractall(action_took(_)),assert(action_took("Detected vampire ahead, attack!"));
	RoomNorth == x -> turnToNorth, walkHome(n), retractall(action_took(_)),assert(action_took("Walked in room I haven't visited with Pizza Dude!"));
	RoomNorth == o -> turnToNorth, walkHome(n), retractall(action_took(_)),assert(action_took("Walked in unvisited room!"));
	RoomSouth == v -> turnToSouth, walkHome(s),retractall(action_took(_)),assert(action_took("Detected vampire ahead, attack!"));
	RoomSouth == x -> turnToSouth, walkHome(s), retractall(action_took(_)),assert(action_took("Walked in room I haven't visited with Pizza Dude!"));
	RoomSouth == o -> turnToSouth, walkHome(s),  retractall(action_took(_)),assert(action_took("Walked in unvisited room!"));
	RoomWest == v ->  turnToWest, walkHome(w),retractall(action_took(_)),assert(action_took("Detected vampire ahead, attack!"));
	RoomWest == x -> turnToWest, walkHome(w), retractall(action_took(_)),assert(action_took("Walked in room I haven't visited with Pizza Dude!"));
	RoomWest == o -> turnToWest, walkHome(w), retractall(action_took(_)),assert(action_took("Walked in unvisited room!"));
	RoomEast == v ->  turnToEast, walkHome(e),retractall(action_took(_)),assert(action_took("Detected vampire ahead, attack!"));
        RoomEast == x -> turnToEast, walkHome(e), retractall(action_took(_)),assert(action_took("Walked in room I haven't visited with Pizza Dude!"));
	RoomEast == o -> turnToEast, walkHome(e), retractall(action_took(_)),assert(action_took("Walked in unvisited room!"));
	bot_direction(BD), walkHome(BD), retractall(action_took(_)),assert(action_took("Walked straight ahead. Room already visited since finding the Pizza dude!"))).

walk(e) :-
	room(G),
	bot_row(R),
	bot_col(C),
	C1 is C+1,
	putel(G, R, C, x, NewG1),
	putel(NewG1, R, C1, b, NewG2),	%Store new grid in newG2
	retractall(bot_location(_)),
	assert(bot_location([R, C1])),
	retractall(bot_col(_)),
	assert(bot_col(C1)),
	retractall(room(X)),
	assert(room(NewG2)).

walk(s) :-
	room(G),
	bot_row(R),
	bot_col(C),
	R1 is R+1,
	putel(G, R, C, x, NewG1),
	putel(NewG1, R1, C, b, NewG2),	%Store new grind in newG
	retractall(bot_location(_)),
	assert(bot_location([R1, C])),
	retractall(bot_row(_)),
	assert(bot_row(R1)),
	retractall(room(X)),
	assert(room(NewG2)).

walk(w) :-
	room(G),
	bot_row(R),
	bot_col(C),
	C1 is C-1,
	putel(G, R, C, x, NewG1),
	putel(NewG1, R, C1, b, NewG2),	%Store new grind in newG
	retractall(bot_location(_)),
	assert(bot_location([R, C1])),
	retractall(bot_col(_)),
	assert(bot_col(C1)),
	retractall(room(X)),
	assert(room(NewG2)).
walk(n) :-
	room(G),
	bot_row(R),
	bot_col(C),
	R1 is R-1,
	putel(G, R, C, x, NewG1),
	putel(NewG1, R1, C, b, NewG2),	%Store new grind in newG
	retractall(bot_location(_)),
	assert(bot_location([R1, C])),
	retractall(bot_row(_)),
	assert(bot_row(R1)),
	retractall(room(X)),
	assert(room(NewG2)).
walkHome(e) :-
	room(G),
	bot_row(R),
	bot_col(C),
	C1 is C+1,
	putel(G, R, C, k, NewG1),
	putel(NewG1, R, C1, b, NewG2),	%Store new grid in newG2
	retractall(bot_location(_)),
	assert(bot_location([R, C1])),
	retractall(bot_col(_)),
	assert(bot_col(C1)),
	retractall(room(X)),
	assert(room(NewG2)).

walkHome(s) :-
	room(G),
	bot_row(R),
	bot_col(C),
	R1 is R+1,
	putel(G, R, C, k, NewG1),
	putel(NewG1, R1, C, b, NewG2),	%Store new grind in newG
	retractall(bot_location(_)),
	assert(bot_location([R1, C])),
	retractall(bot_row(_)),
	assert(bot_row(R1)),
	retractall(room(X)),
	assert(room(NewG2)).

walkHome(w) :-
	room(G),
	bot_row(R),
	bot_col(C),
	C1 is C-1,
	putel(G, R, C, k, NewG1),
	putel(NewG1, R, C1, b, NewG2),	%Store new grind in newG
	retractall(bot_location(_)),
	assert(bot_location([R, C1])),
	retractall(bot_col(_)),
	assert(bot_col(C1)),
	retractall(room(X)),
	assert(room(NewG2)).
walkHome(n) :-
	room(G),
	bot_row(R),
	bot_col(C),
	R1 is R-1,
	putel(G, R, C, k, NewG1),
	putel(NewG1, R1, C, b, NewG2),	%Store new grind in newG
	retractall(bot_location(_)),
	assert(bot_location([R1, C])),
	retractall(bot_row(_)),
	assert(bot_row(R1)),
	retractall(room(X)),
	assert(room(NewG2)).
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
	D == e -> (   (Bot_col1) > MW -> retractall(object_ahead(_)), assert(object_ahead(w));
getel(G, BR, Bot_col1, OA), retractall(object_row(_)), assert(object_row(BR)), retractall(object_col(_)), assert(object_col(Bot_col1)), retractall(object_location(_)), assert(object_location([BR, Bot_col1])), retractall(object_ahead(_)),assert(object_ahead(OA)));
	D == w -> (   (Bot_col2) < 1 -> retractall(object_ahead(_)), assert(object_ahead(w)); getel(G, BR, Bot_col2, OA),  retractall(object_row(_)), assert(object_row(BR)), retractall(object_col(_)), assert(object_col(Bot_col2)),  retractall(object_location(_)), assert(object_location([BR, Bot_col2])),retractall(object_ahead(_)),assert(object_ahead(OA)));
	D == s ->  (   (Bot_row1) > MH -> retractall(object_ahead(_)), assert(object_ahead(w));getel(G, Bot_row1, BC, OA),  retractall(object_row(_)), assert(object_row(Bot_row1)), retractall(object_col(_)), assert(object_col(BC)),  retractall(object_location(_)), assert(object_location([Bot_row1, BC])), retractall(object_ahead(_)),assert(object_ahead(OA)));
        D == n -> (   (Bot_row2) < 1 -> retractall(object_ahead(_)), assert(object_ahead(w));getel(G, Bot_row2, BC, OA),  retractall(object_row(_)), assert(object_row(Bot_row2)), retractall(object_col(_)), assert(object_col(BC)),  retractall(object_location(_)), assert(object_location([Bot_row2, BC])),retractall(object_ahead(_)),assert(object_ahead(OA)));
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
	assert(vampire1_location([3,1])),

	retractall(vampire2_location(_)),
	assert(vampire2_location([4,1])),

	retractall(vampire3_location(_)),
	assert(vampire3_location([2,2])),

	retractall(vampire4_location(_)),
	assert(vampire4_location([4,2])),

	retractall(vampire5_location(_)),
	assert(vampire5_location([2,3])),

	retractall(vampire6_location(_)),
	assert(vampire6_location([4,3])),

	retractall(ladder_location(_)),
	assert(ladder_location([1,1])),

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














