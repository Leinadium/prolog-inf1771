% a arvore possui ramos e folhas
% folha_sim(Ramo, Animal)
% folha_nao(Ramo, Animal)
% ramo_sim(Ramo, Ramo)
% ramo_nao(Ramo, Ramo)

 
% ramo_inicial("Eh um mamifero?").

:- dynamic ramo_sim/2.
% ramo_sim("Eh um mamifero?", "Tem listras?").
% ramo_sim("Eh uma ave?", "Ele voa?").

:- dynamic ramo_nao/2.
% ramo_nao("Eh um mamifero?", "Eh uma ave?").

:- dynamic folha_sim/2.
% folha_sim("Tem listras?", "zebra").
% folha_sim("Ele voa?", "aguia").

:- dynamic folha_nao/2.
% folha_nao("Tem listras?", "leao").
% folha_nao("Ele voa?", "pinguin").
% folha_nao("Eh um passaro?", "lagarto").


achar_folha(Ramo, Folha) :-
    write("Pergunta: "), write(Ramo), write(" (s./ n.)"), nl,
    read(Input), nl,
    (
        (Input=s, ramo_sim(Ramo, NovoRamo), achar_folha(NovoRamo, Folha), !);
        (Input=s, not(ramo_sim(Ramo, _)), folha_sim(Ramo, Folha), !);
        (Input=n, ramo_nao(Ramo, NovoRamo), achar_folha(NovoRamo, Folha), !);
        (Input=n, not(ramo_nao(Ramo, _)), folha_nao(Ramo, Folha), !)
    ).

verificar_resposta(Folha, Input) :-
    write("Seu animal eh "), write(Folha), write("? (s./n.)"), nl,
    read(Input), nl,
    (
        (Input=s, write("Adivinhei!"), nl);
        (Input=n, write("Errei!"), nl)
    ).

atualizar_arvore(Folha) :-
    % achando ramo da folha
    % (
    %     folha_sim(RamoAntigo, Folha); 
    %     folha_nao(RamoAntigo, Folha)
    % ),

    % perguntando o novo animal
    write("Qual era o seu animal? (Digite o nome entre aspas)"), nl,
    read(NovoAnimal),

    % perguntando a nova pergunta
    write("Como diferenciar '"), write(Folha), 
    write("' de '"), write(NovoAnimal), write("'? (Digite uma pergunta entre aspas)"), nl,
    read(NovaPergunta),
    
    % perguntando qual a resposta para o novo animal para a nova pergunta
    write("Qual a resposta de '"), write(NovaPergunta), 
    write("' para '"), write(NovoAnimal), write("'? (s./n.)"), nl,
    read(NovaResposta),

    % removendo a folha, e colocando a nova pergunta
    (
        % se antes a folha era sim
        (
            folha_sim(RamoAntigo, Folha), 
            retract(folha_sim(RamoAntigo, Folha)),
            assertz(ramo_sim(RamoAntigo, NovaPergunta))
        );
        % se antes a folha era nao
        (
            folha_nao(RamoAntigo, Folha),
            retract(folha_nao(RamoAntigo, Folha)),
            assertz(ramo_nao(RamoAntigo, NovaPergunta))
        )
    ),

    % colocando as novas folhas
    (
        % se a resposta para o novo animal for sim
        (
            NovaResposta=s,
            assertz(folha_sim(NovaPergunta, NovoAnimal)),
            assertz(folha_nao(NovaPergunta, Folha))
        );
        (
            NovaResposta=n,
            assertz(folha_nao(NovaPergunta, NovoAnimal)),
            assertz(folha_sim(NovaPergunta, Folha))
        )
    ).

salvar :-
    tell('memoria.txt'),
    listing(ramo_inicial),
    listing(ramo_sim),
    listing(ramo_nao),
    listing(folha_sim),
    listing(folha_nao),
    told.

carregar :- consult('memoria.txt').

rodar :-
    carregar,
    write("Bem vindo ao jogo dos animais!"), nl, nl,
    ramo_inicial(RamoInicial),
    achar_folha(RamoInicial, RespostaPossivel),
    verificar_resposta(RespostaPossivel, Acertei),
    (
        (Acertei=s, write("Obrigado por jogar!"), nl);
        (Acertei=n, atualizar_arvore(RespostaPossivel), write("Obrigado por me ensinar algo novo!"), nl)
    ),
    salvar,
    write("Deseja jogar novamente? (s./n.): "), nl,
    read(JogarNovamente),
    (   
        (JogarNovamente=s, nl, rodar, !, fail);
        (JogarNovamente=n, write("Tchau!"), nl, !, fail)
    ).