# Отчет по лабораторной работе №3
## 
##  по курсу "Логическое программирование"
#### студент: Лебеденко А.В.
# Результат проверки
| Преподователь | Дата | Оцека |
| ------------- | ---- | ----- | 
| Сошников Д.В. |      |       |
| Левинская М.А.|      |       |
# Введение
Метод поиска в пространсве состояний используется в основном для решения задач искусственного интелекта.Этими методами удобно работь с графами. Поиск в графе, где вершинами являются состояния, а дугами способы перехода от одного состояния к другому.Prolog оказывается удобным языком для решения задач, которые решаются методом  поиска, потому, что он работает с деревьями решений.
# Задание 
На писать и отладить Пролог-программу решения задачи искусственного интелекта, используя технологию поиска в пространистве состояний.
 Задча "Растановка мебели"
Площадь разделена на шесть квадратов, пять из них заняты мебелью, шестой - свободен. Переставить мебель так, чтобы шкаф и кресло поменялись местами, при этом никакие два предмета не могут стоять на одном квадрате. 
# Принцип решения
 Сначала напишем правила движения медели.
 Двигать мебель мы можем только на пустое место. Это движение может быть в рамках одной строки, в право и влево, и в рамках 2х соседних сторок вверх/вниз. Так и напишем.
 
    move(A,B):- move_lr(A,B).
    move(A,B):- move_ud(A,B).
  
  Напишем предикат который двигает мебель на пустое место. Прорсто перебираем все возможные вариамты.

    move_z([0,X,Y],[X,0,Y]).
    move_z([X,0,Y],[0,X,Y]).
    move_z([X,0,Y],[X,Y,0]).
    move_z([X,Y,0],[X,0,Y]).
  
  Предикат move_lr [A,T] - начальное состояние списка списков(A и T - строки) [B,T] - конечное состояние.

    move_lr([A,T],[B,T]):- move_z(A,B).
    move_lr([A,T],[A,R]):- move_z(T,R).
  
  Предикат перемешения вверх вниз. move_h([0|T],[A|R],[A|T],[0|R]). - если в первой строке 0 (т.е пустое место[0|T]),а во второй какое-то значение A([A|T]), то в результате движения A на пустое место получиться - [A|T] [0|R]. Если на первом месте нет 0, то берем хвост строк.   

    move_h([0|T],[A|R],[A|T],[0|R]).
    move_h([A|T],[0|R],[0|T],[A|R]).
    move_h([X|T],[Y|R],[X|T1],[Y|R1]):- move_h(T,R,T1,R1).
  
  Принимает список списков [A,B] - начальное состояние, [A1,B1] - конечное состояние.

    move_ud([A,B],[A1,B1]):- move_h(A,B,A1,B1).
  
Поиск в глубину
  
 path(X,Y,P) - X - начальное состояние Y - конечное состояние P - путь.
 path1([X],Y,P) - [X] - список продлений с начальное вершиной X, Y - конечное состояние, P - путь. path1([X|T],X,[X|T]). - условие прикотором мы понимам что путь найден если в списке продлений голова совпадает с конечным состоянием, копируем список продлений в результируюший список.  path1(P,Y,R):- prolong(P,P1), path1(P1,Y,R). - продляем путь P при помощи предиката prolong, результат помещаем path1(P1,Y,R)(рекурсия).  prolong([X|T],[Y,X|T]):- move(X,Y), not(member(Y,[X|T])). - при помощи предиката move продляем список и проверяем не было ли этого состояния (вершины) в списке раньше, чтобы избежать зацикливаний.
 
    path(X,Y,P):- path1([X],Y,P).
    prolong([X|T],[Y,X|T]):- move(X,Y), not(member(Y,[X|T])).
    path1([X|T],X,[X|T]).
    path1(P,Y,R):- prolong(P,P1), path1(P1,Y,R).
 
Поиск в ширину 
    При поиске в ширину используем как основу алгоритм Форда-Фалкерсона. bdth([[X]],Y,P). - [[X]] - очередь путей. Находим все продления и помещаем их в очередь, если findall проваливается то удаляем путь из очереди.
    
    path2(X,Y,P):- bdth([[X]],Y,P).
    bdth([[X|T]|_],X,[X|T]).
    bdth([P|QI],X,R):- findall(Z,prolong(P,Z),T), append(QI,T,QO),!,bdth(QO,X,R).
    bdth([_|T],Y,L):- bdth(T,Y,L).
    
Поиск с итерационным заглублением
Поиск в глабину с ограничением глубины погружения. Ограничение глубины задает предикат int( генерирует по очереди все натуральные числа), чтобы находить минимальный путь первым. 

    int(1).
    int(M):- int(N), M is N+1.

    search_id(Start,Finish,Path,DepthLimit):- depth_id([Start],Finish,Path,DepthLimit).
    depth_id([Finish|T],Finish,[Finish|T],0).
    depth_id(Path,Finish,R,N):- N > 0, prolong(Path,NewPath), N1 is N - 1,
    depth_id(NewPath,Finish,R,N1).

    search_id1(Start,Finish,Path):- int(Level), search_id(Start,Finish,Path,Level).
     
# Результаты

Вывод программы:
Поиск в глубину (привыден первый найденный путь):
?- path([[table,chair,cupdoard],[chair,0,armchair]],[[_,_,armchair],[_,_,cupdoard]],X).
X = [ [ [ table, chair, armchair ], [ chair, 0, cupdoard ] ], [ [ table, chair, armchair ], [ chair, cupdoard, 0 ] ], [ [ table, chair, 0 ], [ chair, cupdoard, armchair ] ], [ [ table, 0, chair ], [ chair, cupdoard, armchair ] ], [ [ 0, table, chair ], [ chair, cupdoard, armchair ] ], [ [ chair, table, chair ], [ 0, cupdoard, armchair ] ], [ [ chair, table, chair ], [ cupdoard, 0, armchair ] ], [ [ chair, table, chair ], [ cupdoard, armchair, 0 ] ], [ [ chair, table, 0 ], [ cupdoard, armchair, chair ] ], [ [ chair, 0, table ], [ cupdoard, armchair, chair ] ], [ [ 0, chair, table ], [ cupdoard, armchair, chair ] ], [ [ cupdoard, chair, table ], [ 0, armchair, chair ] ], [ [ cupdoard, chair, table ], [ armchair, 0, chair ] ], [ [ cupdoard, chair, table ], [ armchair, chair, 0 ] ], [ [ cupdoard, chair, 0 ], [ armchair, chair, table ] ], [ [ cupdoard, 0, chair ], [ armchair, chair, table ] ], [ [ 0, cupdoard, chair ], [ armchair, chair, table ] ], [ [ armchair, cupdoard, chair ], [ 0, chair, table ] ], [ [ armchair, cupdoard, chair ], [ chair, 0, table ] ], [ [ armchair, 0, chair ], [ chair, cupdoard, table ] ], [ [ 0, armchair, chair ], [ chair, cupdoard, table ] ], [ [ chair, armchair, chair ], [ 0, cupdoard, table ] ], [ [ chair, armchair, chair ], [ cupdoard, 0, table ] ], [ [ chair, armchair, chair ], [ cupdoard, table, 0 ] ], [ [ chair, armchair, 0 ], [ cupdoard, table, chair ] ], [ [ chair, 0, armchair ], [ cupdoard, table, chair ] ], [ [ 0, chair, armchair ], [ cupdoard, table, chair ] ], [ [ cupdoard, chair, armchair ], [ 0, table, chair ] ], [ [ cupdoard, chair, armchair ], [ table, 0, chair ] ], [ [ cupdoard, chair, armchair ], [ table, chair, 0 ] ], [ [ cupdoard, chair, 0 ], [ table, chair, armchair ] ], [ [ cupdoard, 0, chair ], [ table, chair, armchair ] ], [ [ 0, cupdoard, chair ], [ table, chair, armchair ] ], [ [ table, cupdoard, chair ], [ 0, chair, armchair ] ], [ [ table, cupdoard, chair ], [ chair, 0, armchair ] ], [ [ table, cupdoard, chair ], [ chair, armchair, 0 ] ], [ [ table, cupdoard, 0 ], [ chair, armchair, chair ] ], [ [ table, 0, cupdoard ], [ chair, armchair, chair ] ], [ [ 0, table, cupdoard ], [ chair, armchair, chair ] ], [ [ chair, table, cupdoard ], [ 0, armchair, chair ] ], [ [ chair, table, cupdoard ], [ armchair, 0, chair ] ], [ [ chair, table, cupdoard ], [ armchair, chair, 0 ] ], [ [ chair, table, 0 ], [ armchair, chair, cupdoard ] ], [ [ chair, 0, table ], [ armchair, chair, cupdoard ] ], [ [ 0, chair, table ], [ armchair, chair, cupdoard ] ], [ [ armchair, chair, table ], [ 0, chair, cupdoard ] ], [ [ armchair, chair, table ], [ chair, 0, cupdoard ] ], [ [ armchair, 0, table ], [ chair, chair, cupdoard ] ], [ [ armchair, table, 0 ], [ chair, chair, cupdoard ] ], [ [ armchair, table, cupdoard ], [ chair, chair, 0 ] ], [ [ armchair, table, cupdoard ], [ chair, 0, chair ] ], [ [ armchair, table, cupdoard ], [ 0, chair, chair ] ], [ [ 0, table, cupdoard ], [ armchair, chair, chair ] ], [ [ table, 0, cupdoard ], [ armchair, chair, chair ] ], [ [ table, cupdoard, 0 ], [ armchair, chair, chair ] ], [ [ table, cupdoard, chair ], [ armchair, chair, 0 ] ], [ [ table, cupdoard, chair ], [ armchair, 0, chair ] ], [ [ table, cupdoard, chair ], [ 0, armchair, chair ] ], [ [ 0, cupdoard, chair ], [ table, armchair, chair ] ], [ [ cupdoard, 0, chair ], [ table, armchair, chair ] ], [ [ cupdoard, chair, 0 ], [ table, armchair, chair ] ], [ [ cupdoard, chair, chair ], [ table, armchair, 0 ] ], [ [ cupdoard, chair, chair ], [ table, 0, armchair ] ], [ [ cupdoard, chair, chair ], [ 0, table, armchair ] ], [ [ 0, chair, chair ], [ cupdoard, table, armchair ] ], [ [ chair, 0, chair ], [ cupdoard, table, armchair ] ], [ [ chair, chair, 0 ], [ cupdoard, table, armchair ] ], [ [ chair, chair, armchair ], [ cupdoard, table, 0 ] ], [ [ chair, chair, armchair ], [ cupdoard, 0, table ] ], [ [ chair, chair, armchair ], [ 0, cupdoard, table ] ], [ [ 0, chair, armchair ], [ chair, cupdoard, table ] ], [ [ chair, 0, armchair ], [ chair, cupdoard, table ] ], [ [ chair, cupdoard, armchair ], [ chair, 0, table ] ], [ [ chair, cupdoard, armchair ], [ 0, chair, table ] ], [ [ 0, cupdoard, armchair ], [ chair, chair, table ] ], [ [ cupdoard, 0, armchair ], [ chair, chair, table ] ], [ [ cupdoard, armchair, 0 ], [ chair, chair, table ] ], [ [ cupdoard, armchair, table ], [ chair, chair, 0 ] ], [ [ cupdoard, armchair, table ], [ chair, 0, chair ] ], [ [ cupdoard, armchair, table ], [ 0, chair, chair ] ], [ [ 0, armchair, table ], [ cupdoard, chair, chair ] ], [ [ armchair, 0, table ], [ cupdoard, chair, chair ] ], [ [ armchair, table, 0 ], [ cupdoard, chair, chair ] ], [ [ armchair, table, chair ], [ cupdoard, chair, 0 ] ], [ [ armchair, table, chair ], [ cupdoard, 0, chair ] ], [ [ armchair, table, chair ], [ 0, cupdoard, chair ] ], [ [ 0, table, chair ], [ armchair, cupdoard, chair ] ], [ [ table, 0, chair ], [ armchair, cupdoard, chair ] ], [ [ table, chair, 0 ], [ armchair, cupdoard, chair ] ], [ [ table, chair, chair ], [ armchair, cupdoard, 0 ] ], [ [ table, chair, chair ], [ armchair, 0, cupdoard ] ], [ [ table, chair, chair ], [ 0, armchair, cupdoard ] ], [ [ 0, chair, chair ], [ table, armchair, cupdoard ] ], [ [ chair, 0, chair ], [ table, armchair, cupdoard ] ], [ [ chair, chair, 0 ], [ table, armchair, cupdoard ] ], [ [ chair, chair, cupdoard ], [ table, armchair, 0 ] ], [ [ chair, chair, cupdoard ], [ table, 0, armchair ] ], [ [ chair, chair, cupdoard ], [ 0, table, armchair ] ], [ [ 0, chair, cupdoard ], [ chair, table, armchair ] ], [ [ chair, 0, cupdoard ], [ chair, table, armchair ] ], [ [ chair, table, cupdoard ], [ chair, 0, armchair ] ], [ [ chair, table, cupdoard ], [ chair, armchair, 0 ] ], [ [ chair, table, 0 ], [ chair, armchair, cupdoard ] ], [ [ chair, 0, table ], [ chair, armchair, cupdoard ] ], [ [ 0, chair, table ], [ chair, armchair, cupdoard ] ], [ [ chair, chair, table ], [ 0, armchair, cupdoard ] ], [ [ chair, chair, table ], [ armchair, 0, cupdoard ] ], [ [ chair, chair, table ], [ armchair, cupdoard, 0 ] ], [ [ chair, chair, 0 ], [ armchair, cupdoard, table ] ], [ [ chair, 0, chair ], [ armchair, cupdoard, table ] ], [ [ 0, chair, chair ], [ armchair, cupdoard, table ] ], [ [ armchair, chair, chair ], [ 0, cupdoard, table ] ], [ [ armchair, chair, chair ], [ cupdoard, 0, table ] ], [ [ armchair, chair, chair ], [ cupdoard, table, 0 ] ], [ [ armchair, chair, 0 ], [ cupdoard, table, chair ] ], [ [ armchair, 0, chair ], [ cupdoard, table, chair ] ], [ [ 0, armchair, chair ], [ cupdoard, table, chair ] ], [ [ cupdoard, armchair, chair ], [ 0, table, chair ] ], [ [ cupdoard, armchair, chair ], [ table, 0, chair ] ], [ [ cupdoard, armchair, chair ], [ table, chair, 0 ] ], [ [ cupdoard, armchair, 0 ], [ table, chair, chair ] ], [ [ cupdoard, 0, armchair ], [ table, chair, chair ] ], [ [ 0, cupdoard, armchair ], [ table, chair, chair ] ], [ [ table, cupdoard, armchair ], [ 0, chair, chair ] ], [ [ table, cupdoard, armchair ], [ chair, 0, chair ] ], [ [ table, 0, armchair ], [ chair, cupdoard, chair ] ], [ [ 0, table, armchair ], [ chair, cupdoard, chair ] ], [ [ chair, table, armchair ], [ 0, cupdoard, chair ] ], [ [ chair, table, armchair ], [ cupdoard, 0, chair ] ], [ [ chair, table, armchair ], [ cupdoard, chair, 0 ] ], [ [ chair, table, 0 ], [ cupdoard, chair, armchair ] ], [ [ chair, 0, table ], [ cupdoard, chair, armchair ] ], [ [ 0, chair, table ], [ cupdoard, chair, armchair ] ], [ [ cupdoard, chair, table ], [ 0, chair, armchair ] ], [ [ cupdoard, chair, table ], [ chair, 0, armchair ] ], [ [ cupdoard, chair, table ], [ chair, armchair, 0 ] ], [ [ cupdoard, chair, 0 ], [ chair, armchair, table ] ], [ [ cupdoard, 0, chair ], [ chair, armchair, table ] ], [ [ 0, cupdoard, chair ], [ chair, armchair, table ] ], [ [ chair, cupdoard, chair ], [ 0, armchair, table ] ], [ [ chair, cupdoard, chair ], [ armchair, 0, table ] ], [ [ chair, cupdoard, chair ], [ armchair, table, 0 ] ], [ [ chair, cupdoard, 0 ], [ armchair, table, chair ] ], [ [ chair, 0, cupdoard ], [ armchair, table, chair ] ], [ [ 0, chair, cupdoard ], [ armchair, table, chair ] ], [ [ armchair, chair, cupdoard ], [ 0, table, chair ] ], [ [ armchair, chair, cupdoard ], [ table, 0, chair ] ], [ [ armchair, chair, cupdoard ], [ table, chair, 0 ] ], [ [ armchair, chair, 0 ], [ table, chair, cupdoard ] ], [ [ armchair, 0, chair ], [ table, chair, cupdoard ] ], [ [ 0, armchair, chair ], [ table, chair, cupdoard ] ], [ [ table, armchair, chair ], [ 0, chair, cupdoard ] ], [ [ table, armchair, chair ], [ chair, 0, cupdoard ] ], [ [ table, 0, chair ], [ chair, armchair, cupdoard ] ], [ [ 0, table, chair ], [ chair, armchair, cupdoard ] ], [ [ chair, table, chair ], [ 0, armchair, cupdoard ] ], [ [ chair, table, chair ], [ armchair, 0, cupdoard ] ], [ [ chair, table, chair ], [ armchair, cupdoard, 0 ] ], [ [ chair, table, 0 ], [ armchair, cupdoard, chair ] ], [ [ chair, 0, table ], [ armchair, cupdoard, chair ] ], [ [ 0, chair, table ], [ armchair, cupdoard, chair ] ], [ [ armchair, chair, table ], [ 0, cupdoard, chair ] ], [ [ armchair, chair, table ], [ cupdoard, 0, chair ] ], [ [ armchair, chair, table ], [ cupdoard, chair, 0 ] ], [ [ armchair, chair, 0 ], [ cupdoard, chair, table ] ], [ [ armchair, 0, chair ], [ cupdoard, chair, table ] ], [ [ 0, armchair, chair ], [ cupdoard, chair, table ] ], [ [ cupdoard, armchair, chair ], [ 0, chair, table ] ], [ [ cupdoard, armchair, chair ], [ chair, 0, table ] ], [ [ cupdoard, armchair, chair ], [ chair, table, 0 ] ], [ [ cupdoard, armchair, 0 ], [ chair, table, chair ] ], [ [ cupdoard, 0, armchair ], [ chair, table, chair ] ], [ [ 0, cupdoard, armchair ], [ chair, table, chair ] ], [ [ chair, cupdoard, armchair ], [ 0, table, chair ] ], [ [ chair, cupdoard, armchair ], [ table, 0, chair ] ], [ [ chair, cupdoard, armchair ], [ table, chair, 0 ] ], [ [ chair, cupdoard, 0 ], [ table, chair, armchair ] ], [ [ chair, 0, cupdoard ], [ table, chair, armchair ] ], [ [ 0, chair, cupdoard ], [ table, chair, armchair ] ], [ [ table, chair, cupdoard ], [ 0, chair, armchair ] ], [ [ table, chair, cupdoard ], [ chair, 0, armchair ] ] ] 

Поиск в ширину:
?- path2([[table,chair,cupdoard],[chair,0,armchair]],[[_,_,armchair],[_,_,cupdoard]],X).
X = [ [ [ chair, 0, armchair ], [ chair, table, cupdoard ] ], [ [ chair, armchair, 0 ], [ chair, table, cupdoard ] ], [ [ chair, armchair, cupdoard ], [ chair, table, 0 ] ], [ [ chair, armchair, cupdoard ], [ chair, 0, table ] ], [ [ chair, 0, cupdoard ], [ chair, armchair, table ] ], [ [ 0, chair, cupdoard ], [ chair, armchair, table ] ], [ [ chair, chair, cupdoard ], [ 0, armchair, table ] ], [ [ chair, chair, cupdoard ], [ armchair, 0, table ] ], [ [ chair, chair, cupdoard ], [ armchair, table, 0 ] ], [ [ chair, chair, 0 ], [ armchair, table, cupdoard ] ], [ [ chair, 0, chair ], [ armchair, table, cupdoard ] ], [ [ chair, table, chair ], [ armchair, 0, cupdoard ] ], [ [ chair, table, chair ], [ 0, armchair, cupdoard ] ], [ [ 0, table, chair ], [ chair, armchair, cupdoard ] ], [ [ table, 0, chair ], [ chair, armchair, cupdoard ] ], [ [ table, chair, 0 ], [ chair, armchair, cupdoard ] ], [ [ table, chair, cupdoard ], [ chair, armchair, 0 ] ], [ [ table, chair, cupdoard ], [ chair, 0, armchair ] ] ] 

Поиск с итерационным заглублением:
?- search_id1([[table,chair,cupdoard],[chair,0,armchair]],[[_,_,armchair],[_,_,cupdoard]],X).
X = [ [ [ chair, 0, armchair ], [ chair, table, cupdoard ] ], [ [ chair, armchair, 0 ], [ chair, table, cupdoard ] ], [ [ chair, armchair, cupdoard ], [ chair, table, 0 ] ], [ [ chair, armchair, cupdoard ], [ chair, 0, table ] ], [ [ chair, 0, cupdoard ], [ chair, armchair, table ] ], [ [ 0, chair, cupdoard ], [ chair, armchair, table ] ], [ [ chair, chair, cupdoard ], [ 0, armchair, table ] ], [ [ chair, chair, cupdoard ], [ armchair, 0, table ] ], [ [ chair, chair, cupdoard ], [ armchair, table, 0 ] ], [ [ chair, chair, 0 ], [ armchair, table, cupdoard ] ], [ [ chair, 0, chair ], [ armchair, table, cupdoard ] ], [ [ chair, table, chair ], [ armchair, 0, cupdoard ] ], [ [ chair, table, chair ], [ 0, armchair, cupdoard ] ], [ [ 0, table, chair ], [ chair, armchair, cupdoard ] ], [ [ table, 0, chair ], [ chair, armchair, cupdoard ] ], [ [ table, chair, 0 ], [ chair, armchair, cupdoard ] ], [ [ table, chair, cupdoard ], [ chair, armchair, 0 ] ], [ [ table, chair, cupdoard ], [ chair, 0, armchair ] ] ] 

|Алгоритм поиска|Длина первого найдениго пути|
|---------------|----------------------------|
|В глубину      |186                         |
|В ширину       |18                          |
|с итерационным заглублением|18              |
# Выводы 
В этой лабораторной работе я изучила методы поиска в пространсве состояний, научилать применять их, узнала где они могут пригодиться.
Какие алгоритмы поиска в каких случаях удобно использовать?
Если нам не важно будет ли первым кратчайший путь но но важна используемая память и простота написания предиката поиска,то удобно использовать поиск в глубину.
Если важно, чтобы кратчайший путь выдавалсь первым, можно было бы использовать для нахождения путей с циклом, то удобно использовать поиск в ширину.
Если надо чтобы поиск совмещал в себе плюсы поска в глубину и поиска в ширину, то удобно сипользовать поиск с итерационным заглублением.
Какие оказались оптимальными в вашем конкретном случае?
В моем случае опимальным оказалсь поиск с итерационным заглублением, так как он первым выводит кратчайший путь и не так взыскателен к памяти как поиск в ширину.
