:- use_module(library(csv)).

:- 
  csv_read_file('data/test02.csv', Rows, [functor(cell), arity(3)]),
	maplist(assert, Rows).

world(I, J) :- cell(world, I, J), !.
wumpus(I, J) :- cell(wumpus, I, J), !.
gold(I, J) :- cell(gold, I, J), !.
door(I, J) :- cell(hero, I, J), !.
pit(I, J) :- cell(pit, I, J), !.

cell(I,J) :- I >= 0, J >= 0, world(Ti, Tj), I < Ti , J < Tj.

vecina(I, J, I, VJ) :- cell(I,J), VJ is J + 1, cell(I, VJ). %%derecha
vecina(I, J, I, VJ) :- cell(I,J), VJ is J - 1, cell(I, VJ). %%izquierda
vecina(I, J, VI, J) :- cell(I,J), VI is I + 1, cell(VI, J). %%abajo
vecina(I, J, VI, J) :- cell(I,J), VI is I - 1, cell(VI, J). %%arriba

percibir(I, J, glitter) :- gold(I,J).

percibir(I, J, strench) :- vecina(I, J, VI, VJ), wumpus(VI,VJ).
percibir(I, J, breeze) :- vecina(I, J, VI, VJ), pit(VI,VJ), !.

hit([cell(I,J)|_]) :- wumpus(I,J) .
hit([_|Cells]) :- hit(Cells) .

shot(0, _, norte, []) .
shot(I, J, norte, [cell(VI, J)|_]) :- I >= 0, VI is I - 1, shot(VI, J, norte, _) .

shot(filas, _, sur, []) :- world(filas, _) .
shot(I, J, sur, [cell(VI, J)|_]) :- world(filas, _), I < filas, VI is I + 1, shot(VI, J, sur, _) .

shot(_, columnas, este, []) :- world(_, columnas) .
shot(I, J, este, [cell(I, VJ)|_]) :- world(_, columnas), J < columnas, VJ is J + 1, shot(I, VJ, este, _) .

shot(_, 0, oeste, []) .
shot(I, J, oeste, [cell(I, VJ)|_]) :- J >= 0, VJ is J - 1, shot(I, VJ, oeste, _) .


girar('l', norte, oeste).
girar('l', oeste, sur).
girar('l', sur, este).
girar('l', este, norte).

girar('r', norte, este).
girar('r', este, sur).
girar('r', sur, oeste).
girar('r', oeste, norte).

accion(Accion, estado(I, J, D, C, O, W), estado(I, J, ND, C, O, W) ) :- girar(Accion, D, ND), write([I, J, ND, C, O, W]), nl .
accion('f', estado(I, J, sur, C, O, W), estado(VI, J, sur, C, O, W) ) :- VI is I + 1, cell(VI, J), write([VI, J, sur, C, O, W]), nl .
accion('f', estado(I, J, norte, C, O, W), estado(VI, J, norte, C, O, W) ) :- VI is I - 1, cell(VI, J), write([VI, J, norte, C, O, W]), nl .
accion('f', estado(I, J, este, C, O, W), estado(I, VJ, este, C, O, W) ) :- VJ is J + 1, cell(I, VJ), write([I, VJ, este, C, O, W]), nl .
accion('f', estado(I, J, oeste, C, O, W), estado(I, VJ, oeste, C, O, W) ) :- VJ is J - 1, cell(I, VJ), write([I, VJ, oeste, C, O, W]), nl .
accion('f', estado(I, J, D, C, O, W), estado(I, J, D, C, O, W) ) :- write([I, J, D, C, O, W]), nl .

accion('p', estado(I, J, D, C, O, W), estado(I, J, D, C, O, W) ) :- findall(X, percibir(I, J, X), Y), writeln(Y) .

accion('g', estado(I, J, D, C, false, W), estado(I, J, D, C, true, W) ) :- gold(I, J), writeln('Agarraste el oro!') .
accion('g', estado(I, J, D, C, true, W), estado(I, J, D, C, true, W) ) :- writeln('Ya agarraste el oro, es una falsa percepción...') .

accion('s', estado(I, J, D, 1, O, true), estado(I, J, D, 1, O, false) ) :- shot(I, J, D, X), hit(X), write('Disparaste hacia el '), write(D), writeln(' y mataste al wumpus!!') .
accion('s', estado(I, J, D, 1, O, W), estado(I, J, D, 1, O, W) ) :- write('Disparaste hacia el '), write(D), writeln(', pero el wumpus no estaba en esa dirección...') .
accion('s', estado(I, J, D, 0, O, W), estado(I, J, D, 0, O, W) ) :- writeln('Se acabaron las flechas') .


accion('q', E, E) :- write('¡Adios!'), nl, halt.
accion(A, E, E) :- char_type(A, space). % Ignora
accion(A, E, E) :- write('Accion desconocida. ['), write(A), write(']'), nl.

jugar(estado(I, J, _, _, _, _), perdiste) :- pit(I, J), writeln('Caiste en un pozo'), halt.
jugar(estado(I, J, _, _, _, true), perdiste) :- wumpus(I, J), writeln('Te comió el Wumpus'), halt.

jugar(estado(I, J, _, _, true, _), ganaste) :- door(I, J), writeln('Ganaste!!'), halt.
jugar(EActual, X) :- get_char(Accion), accion(Accion, EActual, ESiguiente), jugar(ESiguiente, X) .


inicial(estado(I, J, sur, 1, false, true)) :- door(I, J) .
