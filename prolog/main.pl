:- [wumpus].

% Establece variables del interprete de prolog.
% verbose = silent establece la supresión de los mensajes informacionales.
:- set_prolog_flag(verbose, silent).

% Indica que al cargar el código se debe evaluar la regla main.
:- initialization main.


main :- inicial(Inicial), jugar(Inicial, _) .

