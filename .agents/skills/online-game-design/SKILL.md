---
name: online-game-design
description: Apoia design de jogos online e de seus sistemas, fluxos, interfaces e experiências de uso. Use ao conceber ou revisar gameplay, onboarding, HUD, menus, progressão, recursos sociais ou UX multiplayer; não use para dúvidas gerais de programação sem uma necessidade de design de jogo.
---

# Game design e UI/UX para jogos online

Ajude a transformar a intenção do jogo em decisões de design claras e utilizáveis. Considere juntos o loop de jogo, as necessidades dos jogadores e as condições reais de uma experiência conectada. Adapte recomendações ao gênero, público, plataforma, modelo de negócio e estágio do projeto; não imponha uma fórmula universal.

## Como trabalhar

1. Identifique o que precisa ser resolvido: conceito ou sistema de jogo, fluxo de experiência, interface, revisão de UX ou documentação para implementação. Aproveite o contexto já fornecido. Pergunte apenas quando uma lacuna mudar materialmente a recomendação; enquanto isso, declare suposições razoáveis.
2. Para decisões de gameplay, descreva o jogador-alvo, a fantasia ou necessidade atendida, o loop principal e como a proposta cria escolhas, consequências e domínio ao longo do tempo.
3. Para UI/UX, percorra a jornada pertinente (por exemplo: primeira sessão, entrar em grupo, encontrar partida, jogar, recuperar-se de uma desconexão e voltar). Para cada tela ou estado, esclareça objetivo do jogador, informação prioritária, ação principal, feedback e próximo passo.
4. Considere o contexto online: latência, perda de conexão, matchmaking, diferenças de habilidade, grupos e convites, presença de outros jogadores, sincronização, moderação, privacidade e estados de servidor. Inclua apenas o que for relevante ao pedido.
5. Entregue uma proposta concreta no formato adequado: princípios, fluxo, especificação de tela, tabela de estados, wireframe textual, crítica priorizada, perguntas de playtest ou brief para implementação. Separe observações, recomendações e suposições.
6. Ao revisar uma solução, ligue cada problema observado a um impacto no jogador e a uma correção viável. Priorize por gravidade, frequência e custo de recuperação; não trate gosto pessoal como evidência.

## Critérios de design

- **Clareza em ação:** mostre o estado atual, o que o jogador pode fazer e o resultado provável. Use feedback visual, textual, sonoro ou háptico apropriado, sem depender de um único canal.
- **Hierarquia e ritmo:** mantenha a atenção no jogo durante momentos de ação. Revele complexidade progressivamente e evite interromper decisões urgentes com fluxos secundários.
- **Consistência com propósito:** use padrões familiares e termos coerentes, mas preserve as convenções específicas do gênero quando elas ajudarem o jogador.
- **Acessibilidade e contexto:** considere legibilidade, contraste, daltonismo, remapeamento de controles, opções de movimento e alternativas a sinais apenas sonoros. Inclua celular, controle, teclado ou toque conforme a plataforma real.
- **Experiência multiplayer justa:** deixe claras as regras, os estados de grupo e de partida e os motivos de espera ou falha. Não esconda desvantagens competitivas nem dê vantagem de gameplay por compra quando a proposta exigir integridade competitiva.
- **Falhas recuperáveis:** planeje carregamento, timeout, manutenção, reconexão, abandono, convite expirado e ações indisponíveis. Explique o que aconteceu, preserve o progresso possível e ofereça uma próxima ação segura.
- **Economia respeitosa:** se houver monetização, descreva preço, conteúdo e limitações com transparência. Não recomende pressão enganosa, escassez falsa, ocultação de custos ou mecânicas coercitivas; leve em conta idade e contexto do público.
- **Validação com jogadores:** proponha testes observáveis ligados à hipótese (por exemplo, sucesso sem ajuda, tempo até concluir, erros, desistências e compreensão relatada). Não invente métricas, resultados ou evidências.

## Formato útil para especificações de interface

Quando o pedido exigir detalhamento de uma tela ou fluxo, documente de forma compacta:

- objetivo do jogador e contexto de entrada;
- conteúdo e hierarquia de informação;
- ações, controles e feedback;
- estados normal, carregando, vazio, erro, indisponível e sucesso que realmente se aplicam;
- comportamento em conexão degradada ou interrompida, quando relevante;
- acessibilidade e variações por plataforma;
- questões em aberto e como validá-las.

Não preencha itens irrelevantes só para completar uma lista. Se o usuário pedir código ou assets, passe do design à implementação apenas dentro do escopo solicitado e mantenha a solução compatível com as convenções existentes do projeto.
