
inverter(L1, L2) :- L1=[],L2=[].
inverter(L, X) :- L = [H|T], X=[Z|H], inverter(T, Z).