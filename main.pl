% ESTRUTURA DA ARVORE:

% Uma pergunta eh um ramo, um animal eh uma folha.
% ou seja, um ramo eh descendente de um outro ramo, e pode gerar dois ramos ou duas folhas

% ramo_sim(X, Y) significa que X possui um filho ramo, Y, pela ligacao SIM (reposta da pergunta)
% ramo_nao(X, y) significa que X possui um filho ramo, Y, pela ligacao NAO
% folha_sim(X, Y) significa que X possui um filho folha, Y, pela ligacao SIM
% folha_nao(X, Y) significa que X possui um filho folha, Y, pela ligacao SIM

% RAMOS E FOLHAS DAS CONDICOES INICIAIS:

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


% PESQUISA NA ARVORE :
%    Começando em *Ramo*, desce ate chegar numa folha, pergunta para o usuario as perguntas
%    *Folha* sera a folha final (ou seja, o animal encontrado)
achar_folha(Ramo, Folha) :-
    write("Pergunta: "), write(Ramo), write(" (s./ n.)"), nl,
    read(Input), nl,
    (
        (Input=s, ramo_sim(Ramo, NovoRamo), achar_folha(NovoRamo, Folha), !);
        (Input=s, not(ramo_sim(Ramo, _)), folha_sim(Ramo, Folha), !);
        (Input=n, ramo_nao(Ramo, NovoRamo), achar_folha(NovoRamo, Folha), !);
        (Input=n, not(ramo_nao(Ramo, _)), folha_nao(Ramo, Folha), !)
    ).

% VERIFICAR RESPOSTA :
%    Pergunta se aquele animal (Folha) eh o animal desejado
%    *Input* eh a resposta (s ou n)
verificar_resposta(Folha, Input) :-
    write("Seu animal eh "), write(Folha), write("? (s./n.)"), nl,
    read(Input), nl,
    (
        (Input=s, write("Adivinhei!"), nl);
        (Input=n, write("Errei!"), nl)
    ).

% EDICAO DA ARVORE :
%    Caso o animal esteja errado, eh necessario editar a arvore
%    A partir da folha da regra, a folha é retirada,
%    eh acrescentada um novo ramo (uma nova pergunta),
%    e as duas folhas (a folha antiga e a nova folha, ou seja o novo animal)
%    sao acrescentados como filhos do novo ramo
atualizar_arvore(Folha) :-

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
            folha_sim(RamoAntigo, Folha),                   % "if era folha_sim"
            retract(folha_sim(RamoAntigo, Folha)),          % remove a folha
            assertz(ramo_sim(RamoAntigo, NovaPergunta))     % cria o novo ramo
        );                                                  % OU
        % se antes a folha era nao
        (
            folha_nao(RamoAntigo, Folha),                   % "if era folha_nao"
            retract(folha_nao(RamoAntigo, Folha)),          % remove a folha
            assertz(ramo_nao(RamoAntigo, NovaPergunta))     % cria o novo ramo
        )
    ),

    % colocando as novas folhas
    (
        (
            NovaResposta=s,                                 % "if a resposta para o novo animal for sim"
            assertz(folha_sim(NovaPergunta, NovoAnimal)),   % coloca a nova folha como filho do novo ramo
            assertz(folha_nao(NovaPergunta, Folha))         % coloca a folha antiga como filho do novo ramo
        );                                                  % OU
        (
            NovaResposta=n,                                 % "if a resposta para o novo animal for nao"
            assertz(folha_nao(NovaPergunta, NovoAnimal)),   % coloca a nova folha como filho do novo ramo
            assertz(folha_sim(NovaPergunta, Folha))         % coloca a folha antiga como filho do novo ramo
        )
    ).

% SALVAMENTO DA ARVORE
%    salva os ramos e folhas no arquivo memoria.txt
salvar :-
    tell('memoria.txt'),
    listing(ramo_inicial),
    listing(ramo_sim),
    listing(ramo_nao),
    listing(folha_sim),
    listing(folha_nao),
    told.

% LOADING DA ARVORE
%    consulta os fatos (os ramos e folhas) do arquivo memoria.txt
carregar :- consult('memoria.txt').

% MAIN LOOP
%    roda o jogo dos animais!
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