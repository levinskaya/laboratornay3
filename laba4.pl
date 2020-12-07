move(A,B):- move_lr(A,B).
move(A,B):- move_ud(A,B).

move_z([0,X,Y],[X,0,Y]).
move_z([X,0,Y],[0,X,Y]).
move_z([X,0,Y],[X,Y,0]).
move_z([X,Y,0],[X,0,Y]).

move_lr([A,T],[B,T]):- move_z(A,B).
move_lr([A,T],[A,R]):- move_z(T,R).

move_h([0|T],[A|R],[A|T],[0|R]).
move_h([A|T],[0|R],[0|T],[A|R]).
move_h([X|T],[Y|R],[X|T1],[Y|R1]):- move_h(T,R,T1,R1).

move_ud([A,B],[A1,B1]):- move_h(A,B,A1,B1).

path(X,Y,P):- path1([X],Y,P).
prolong([X|T],[Y,X|T]):- move(X,Y), not(member(Y,[X|T])).
path1([X|T],X,[X|T]).
path1(P,Y,R):- prolong(P,P1), path1(P1,Y,R).

path2(X,Y,P):- bdth([[X]],Y,P).
bdth([[X|T]|_],X,[X|T]).
bdth([P|QI],X,R):- findall(Z,prolong(P,Z),T), append(QI,T,QO),!,bdth(QO,X,R).
bdth([_|T],Y,L):- bdth(T,Y,L).

int(1).
int(M):- int(N), M is N+1.

search_id(Start,Finish,Path,DepthLimit):- depth_id([Start],Finish,Path,DepthLimit).
depth_id([Finish|T],Finish,[Finish|T],0).
depth_id(Path,Finish,R,N):- N > 0, prolong(Path,NewPath), N1 is N - 1,
depth_id(NewPath,Finish,R,N1).

search_id1(Start,Finish,Path):- int(Level), search_id(Start,Finish,Path,Level).
