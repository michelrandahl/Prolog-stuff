% I created this becasue I wanted a readable syntax when juggling with self created functions in prolog.
% you aren't allowed to mess with this is/2 predicate and therefore I create my own operater <-, which in the end evaluates stuff with the is/2.
% this allows me to use my own functions in the same syntactical way as with the is/2 predicate. And thus I can write stuff like:
% ?- X <- log2(42)-3*log(7).

:- op(900, xfy, <-).

% examples of self defined 'functions'
R <- log2(X) :- R <- log(X) / log(2), !.
R <- len(L) :- length(L, R), !.
Sum <- sum_list([], _) :- Sum <- 0.
Sum <- sum_list([H|T], Func) :- New_sum <- sum_list(T, Func), !, Apply_func =..[Func,H], Sum <- New_sum + Apply_func.

% folowing two predicates solves the problem of using self defined functions in combination with mathematical operators
% note that they should always be last of type <-
R <- X :- compound(X), X =..[OP,X2,X3], R2 <- X2, R3 <- X3, Expr =..[OP,R2,R3], R is Expr, !.
R <- X :- R is X, !.
