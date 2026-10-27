Historical A3 increment note (17 October 2026; superseded by [roadmap.md](roadmap.md)): [checked Incursion rosters](../rules/roster-validation.md) use official MFM 1.6 points for ten fixed profiles and include fixed-profile construction checks. At the time of this increment, broader equipment/model counts and remaining detachment/core content were still pending.

Historical A2 increment note (17 October 2026; superseded by [roadmap.md](roadmap.md)): [CA 2026-27 selected mission](../rules/chapter-approved-mission.md) added full-size board, role/first-turn roll-offs, private reserve declarations and fixed primary/secondary scoring. Historical custom-training descriptions below remain valid for their separate modes.

> **Superseded.** The forward-looking plan now lives in [roadmap.md](roadmap.md) — the single consolidated roadmap to the final product. This file is retained only as the historical increment log (original diagnosis, milestones, and chronological implementation notes).

# Roadmap para uma primeira versão funcional

Análise do código e da documentação local em 15/10/2026. Este documento propõe prioridades; não certifica conformidade com regras oficiais nem substitui a verificação das fontes de cada edição.

## Diagnóstico

O projeto é um protótipo avançado de combate e treinamento em Godot, com host autoritativo, decisões por jogador, testes de regras e sincronização. Ainda não oferece o ciclo completo de preparação, partida legal, persistência e distribuição. O objetivo inicial deve ser uma partida completa com um subconjunto declarado de conteúdo, antes de prometer cobertura integral de uma edição.

Já existem movimento individual, coerência, moral, tiro, cargas, corpo a corpo, planejamento de ataques, seleção de armas, alocação pelo defensor, defesa mista/Precision, prevenção de dano, terreno plano, objetivos e vitória em missão customizada. Há importação visual local OBJ/textura e recuperação de convidado enquanto o host permanece aberto.

## Evidências e lacunas

- `scripts/edition_11/combat_scenario.gd`: integração v21, inicialização limitada a uma ou duas unidades por jogador, facções e perfis escolhidos no código. A constante `DISABLED` explicita regras ausentes. Ter perfis sintéticos de veículos/personagens não equivale a suportar integralmente essas unidades.
- `scripts/edition_11/test_battlefield.gd` e `docs/guides/initial-test-scenario.md`: cenário de teste 43 × 43, limite declarado de 1.000 pontos, listas sem validação de pontos e sem preparação/deployment completos.
- `scripts/main.gd`: UI, renderização e RPCs no mesmo arquivo, com 1.624 linhas. Host e cliente precisam selecionar previamente o mesmo exercício. Estado é transmitido em snapshots; não há persistência de partida em disco.
- `scripts/data_pack.gd`: verifica integridade e identidade básica, mas a autorização de jogo completo continua restrita à demonstração. A integração de combate é um caminho separado e limitado; falta um catálogo único de capacidades suportadas.
- `data/imported/` é ignorado pelo Git e o combate depende de `starter-11e-v1`. Um checkout limpo precisa de preparação explícita e reproduzível, com conteúdo de demonstração adequado para distribuição.
- `scripts/local_models.gd`: importação com limites de arquivo e parsing sem executar Lua. Permanecem formatos, materiais, montagem de componentes e variantes por miniatura.
- Sem configuração de CI ou presets de exportação na árvore inspecionada. Documentação registra Windows/loopback; Linux, LAN entre máquinas e builds distribuíveis ainda precisam de validação.
- O README e `docs/project/rules-status.md` acumulam afirmações antigas seguidas de incrementos que as superam. Falta uma matriz atual de suporte.
- O Git local apresenta os arquivos principais como não rastreados. Verificar e estabelecer um primeiro checkpoint versionado antes de mudanças maiores.

## Ordem proposta

### Implementação iniciada em 16/10/2026

Base reproduzível: adicionados executor isolado com timeout/logs/relatório JSON, perfis demo/full, variantes de loopback sequenciais, dados opcionais fixados por revisão e hashes, matriz atual de suporte, definição de CI Windows/Linux, presets e ferramenta de exportação da demonstração. A execução revelou uma fixture de rede com identidade de cenário desatualizada e guias ainda recortados no campo antigo; ambos receberam correções e regressões. Resultados finais desta etapa estão em `docs/verification/verification-results.md`.

O marco 0 continua parcial: CI remoto, executáveis nativos e Linux ainda precisam de execução; não foi criado commit automaticamente. Os demais marcos seguem abaixo, com o progresso do marco 1 registrado a seguir.

Avanço do marco 1: implementado o modo separado de [partida customizada preparada](../guides/prepared-match.md), com manifesto/configuração validada, listas de treino fixas, zonas, deployment alternado, confirmação por unidade e início da missão de cinco rodadas. Testes cobrem o resultado final e reconexão durante placement. Legalidade/pontos das listas e missões/deployment oficiais continuam pendentes; este incremento não conclui a compatibilidade oficial do marco.

Por solicitação do usuário, avançado o [construtor de listas e perfis](../guides/army-builder.md): catálogo OpenHammer completo por edição, facções/unidades/variantes, categorias e limite de pontos, bases padrão editáveis, salvamento de listas/cópias por perfil local e cache offline. A persistência de listas não conclui o marco de persistência de partidas. A admissão de todas as unidades do catálogo em partidas oficiais depende de regras/validações ainda ausentes.

Integração v23: [listas salvas compatíveis](../guides/saved-army-matches.md) já entram em treino parcial local/LAN, com uma ou duas unidades por jogador, escolha independente de facção implementada, custos canônicos do pacote, verificação de composição/orçamento, congelamento da seleção e reconexão no deployment. Outras unidades e legalidade oficial continuam bloqueadas/pendentes. O próximo marco de continuidade é salvar e retomar a própria partida, preservando escolhas e dados já resolvidos.

| Marco | Entrega | Critério de conclusão |
|---|---|---|
| 0 — Base reproduzível | Consolidar estado de suporte, registrar código no Git, automatizar testes locais e de rede, preparar dados offline reproduzíveis e exportação mínima | Um checkout limpo inicia a demonstração e executa uma suíte documentada; limitações ficam visíveis |
| 1 — Partida completa restrita | Duas listas predefinidas validadas no cenário escolhido; configuração, zonas e sequência de deployment; missão, gatilhos, pontuação e resultado | Dois jogadores começam na configuração e chegam ao resultado sem edição de código ou intervenção técnica |
| 2 — Continuidade | Snapshot versionado, gravação atômica, autosave, registro de eventos/resultados de dados e recuperação de assento com token de sessão | Fechar e reabrir o host restaura a partida e escolhas pendentes sem repetir dados nem perder baixas |
| 3 — Regras das listas iniciais | Infraestrutura de janelas de reação, custos/CP, estratagemas e habilidades das unidades/facções; ampliar movimento e tipos de unidade conforme as listas exigirem | Toda regra necessária às duas listas é implementada e testada; conteúdo incompleto é bloqueado |
| 4 — Multiplayer de produto | Lobby com negociação de cenário/packs/opções, aceite e prontidão; conexão internet, diagnóstico e tratamento de perda/latência | Os dois clientes concordam com a configuração e conseguem concluir/retomar uma partida remota |
| 5 — Release Windows/Linux | Builds, CI, testes entre sistemas, desempenho, revisão da interface, importação portátil, licença e instruções | Usuários sem editor Godot instalam, configuram e concluem uma partida Windows ↔ Linux |
| 6 — Expansão | Construtor de listas, mais unidades/missões, geometria vertical e cobertura adicional da edição; editor de mapas posteriormente | Cada incremento amplia a matriz de suporte sem admitir conteúdo parcialmente implementado como completo |

Os marcos 1–5 compõem a primeira versão funcional dentro do escopo declarado. Cobertura integral de uma edição é um programa posterior. Antecipar reservas, transportes, voo ou geometria vertical quando forem necessários às listas/missão selecionadas; caso contrário, restringir explicitamente o primeiro cenário.

## Arquitetura que deve acompanhar os marcos

Separar gradualmente `main.gd` em sessão/rede, apresentação do tabuleiro e painéis de UI. Extrair a criação de listas e cenário da fábrica de treinamento. Manter o núcleo de regras independente de renderização; introduzir contratos de comandos/eventos e validação de estado sem reescrever os módulos já testados.

Criar um manifesto imutável de partida contendo edição/update, implementação, hashes de conteúdo, cenário, listas e opções aceitas. Persistência e lobby devem usar a mesma identidade. Representar capacidades suportadas em um único lugar, consumido pelo validador, pela interface e pelos testes.

Implementar um executor de testes com timeout por processo, logs por suíte, códigos de saída e diretórios temporários controlados. Cobrir decisões interrompidas, comandos inválidos/duplicados, snapshots incompatíveis e recuperação em cada etapa obrigatória. Testes gráficos e LAN real complementam os headless.

## Primeira sequência prática

1. Consolidar matriz de suporte e checkpoint do repositório; corrigir instruções de instalação e testes.
2. Automatizar a execução e estabelecer uma build mínima Windows/Linux.
3. Definir duas listas predefinidas e uma missão alvo; listar todas as regras que elas exigem e bloquear opções ausentes.
4. Implementar configuração, deployment e encerramento dessa missão, adicionando as regras obrigatórias identificadas.
5. Implementar persistência e recuperação, testando decisões pendentes e reinício do host.
6. Fechar lobby/internet e realizar partidas completas entre máquinas e sistemas antes de ampliar o catálogo.

## Verificação realizada nesta análise

Os sete testes Python passaram. Doze suítes Godot locais concluíram com verificações aprovadas na execução com log direcionado ao workspace: ações, prática de alocação, unidades anexadas, laboratório/plano/sequência de ataques, combate próximo, resultados da UI, cenário de combate, ações/alcance de contato e alocação de dano. A suíte de orientação contextual também reportou zero falhas, com erro ambiental de diretório.

A execução abrangente foi interrompida após não avançar na etapa seguinte, que usa arquivos `user://`; o ambiente apresentou erros de acesso a logs/diretórios. Não atribuir esses erros ao núcleo de regras sem reprodução em ambiente adequado. Não foram reexecutados nesta análise os testes de rede, a validação gráfica ou Linux. Os resultados históricos registrados em outros documentos não equivalem a uma nova execução.

Avanço do marco 2: [persistência de partidas](../architecture/match-persistence.md) com snapshot versionado, checksum, gravação temporária/renomeação, autosave de comandos publicados, salvamento manual de rascunho, retomada local ou como host LAN e restauração do gerador de dados. Journal independente e histórico de slots continuam pendentes; a recuperação de assento por token está descrita no avanço seguinte. O marco permanece parcial.

Recuperação de assento implementada: credencial local do convidado, desafio HMAC-SHA256 por conexão, reserva privada preservada no save e admissão somente após verificação. Reentrada sem credencial ou com prova falsa não recebe estado nem executa comandos. Transporte cifrado, contas online e transferência/redefinição de credenciais não fazem parte deste incremento. O journal independente de eventos/resultados continua necessário para concluir o marco 2.


Histórico independente implementado: [journal de eventos e dados](../architecture/match-history.md), mudanças do estado público por sequência, D6 em ordem, encadeamento de hashes, checkpoint vinculado ao save, validação por reconstrução de dados, recuperação de cauda não confirmada e consulta paginada local/LAN autenticada. Isso entrega o núcleo do marco 2 no treino suportado; replay visual, múltiplos slots e compactação ficam como melhorias posteriores. A próxima prioridade funcional é o marco 3: regras exigidas pelas listas iniciais, começando por janelas de reação e capacidades explicitamente declaradas.

Marco 3 iniciado: [Insane Bravery e janelas de decisão](../rules/core-stratagems.md) nas partidas preparadas/listas salvas, com fonte do núcleo conferida, capacidade opt-in congelada no manifesto, custos e limites de uso, validação por jogador/alvo/revisão, bloqueio dos demais comandos durante a decisão e persistência das escolhas pendentes. Habilidades provisórias do catálogo continuam desativadas. A próxima ampliação pode usar a mesma base para outras janelas, começando por Command Re-roll em movimento/carga, antes de habilitar regras de facção/unidade com fontes e gatilhos completos.

Marco 3 ampliado: Command Re-roll em avanço/carga, com opção adicional preservando saves anteriores, decisão antes de mover/escolher alvos, substituição de um/dois D6, resultado novo obrigatório, CP e limites por fase/unidade, bloqueio de repetição tardia, journal e retomada do host em processo novo. A próxima extensão é validar as janelas dentro das sequências de ataques (sem oferecer re-roll após conhecer resultados posteriores), seguida de habilidades verificadas das unidades/facções iniciais.

Marco 3 ampliado novamente: Command Re-roll em acertos e ferimentos, com checkpoints antes dos dados posteriores, seleção de um D6 elegível, preservação de Twin-linked e efeitos críticos, opção/manifesto próprios, save e retomada autenticada em processo novo. Defesas, dano, Hazardous e número de ataques continuam pendentes, assim como habilidades verificadas das unidades/facções iniciais.

Marco 3: Command Re-roll de defesa implementado como capacidade separada, com decisão do defensor antes de ordenar os D6 e resolver dano, custo e limites compartilhados por jogador/fase, grupos mistos/invulneráveis, persistência e retomada em processo novo. As próximas janelas são dano, Hazardous e número de ataques; habilidades verificadas de unidade/facção continuam pendentes.

Marco 3: Command Re-roll de dano aleatório implementado antes da prevenção/baixas, com destinatário fixo, seleção de um dado de D3/D6 ou expressão múltipla, bônus preservado, CP/limites, save/journal e retomada LAN. A interface habilita a prática no laboratório sintético com seu rifle D3 e 2 CP iniciais por jogador; listas iniciais mantêm dano fixo. Próximas janelas: Hazardous e número de ataques.

Marco 3: Command Re-roll para Hazardous de armas implementado, com escolha de um D6 antes de alocação/prevenção, sucesso ou falha originais, recalculação das consequências, limites, save/journal e retomada em processo novo. O equipamento variado preparado permite experimentar o plasma supercharge existente. Próximas janelas: número de ataques e hazards de Desperate Escape.

Marco 3: Command Re-roll de número de ataques implementado antes dos acertos, com mapeamento de dado para fonte, fontes fixas/aleatórias combinadas, bônus intrínsecos/Rapid Fire/Blast preservados, checkpoints, CP/limites, save/journal e retomada LAN. O laboratório oferece um perfil de rifle A D3+1 com a opção ativa, mantendo as listas iniciais de A fixo. Próxima lacuna de Command Re-roll: hazards de Desperate Escape.


## Avanço em 16/10: partida local pronta e modelos automáticos

O setup agora oferece duas seleções com listas padrão e do perfil, preseleciona Space Marines contra Necrons e cria uma partida local diretamente com deployment e cinco rodadas. Quatro padrões offline cobrem uma/duas unidades por facção, categoria treino de 500 pontos; cópias editáveis podem ser salvas no perfil sem alterar os padrões.

O início local pode preparar os modelos automaticamente: catálogo ForceOrg obtido automaticamente na ausência de fonte local, variante compatível por perfil, cache antes de HTTP, validação e vínculo persistente aos bonecos. Links manuais são preservados; há progresso, cancelamento, erro por perfil e retry. Validação real partiu de perfil vazio e baixou catálogo, dois OBJ e duas texturas, vinculando os dois tipos na mesa. Também foram testados cache e JSON local com 32.256 entradas. Permanecem fora do escopo montagem genérica de compostos/AssetBundles e suporte jogável a todos os exércitos da API.


## Avanço em 16/10: listas mistas de referência

Primeira etapa da ampliação dos exércitos: [duas forças mistas de referência](../guides/reference-armies.md), ambas de 480/500 pontos. Space Marines inclui Intercessors e Terminators; Necrons inclui Warriors e Immortals. Um registro explícito valida identidades, aliases, tamanhos, custos e armas padrão; o novo formato público permite até seis unidades por jogador e preserva o formato anterior. A fábrica usa os atributos e equipamentos de cada perfil, incluindo sargento Terminator e defesa invulnerável, com formações adequadas a bases diferentes. Seleção local/LAN, deployment, missão, save/retomada e visuais dos quatro tipos foram integrados.

Este avanço não conclui o marco de duas listas oficiais completas. Permanecem necessários comandantes/attachments, destacamentos e habilidades verificadas das unidades e facções, além de construção legal integral. As habilidades ausentes aparecem no resumo e continuam desabilitadas; importação numérica não equivale a implementação de regras.


## Avanço em 16/10: primeira habilidade das listas de referência

[Objective Secured dos Intercessors](../rules/objective-secured.md) implementada como opção explícita para partidas preparadas e listas salvas. Fonte do datasheet conferida; efeito ao fim de Command, depois de Battle-shock e controle, exigindo unidade canônica viva em alcance com OC positivo. O objetivo mantém controle ao sair da área e perde o estado assegurado quando o adversário supera seu OC no fechamento de fase. Manifesto, configuração, save antigo/novo, journal, feedback e reconexão LAN integram a capacidade. Outras habilidades e regras de facção permanecem desabilitadas; o próximo incremento deve continuar verificando e implementando as capacidades necessárias às duas forças, incluindo comandantes/attachments antes de certificar listas completas.

## Avanço em 16/10: habilidade dos Immortals como referência de treino

[Implacable Eradication](../rules/implacable-eradication.md) integrada a tiro e combate corpo a corpo, por opção explícita. Repete resultados de ferimento iguais a 1, ou falhas contra unidades em alcance de objetivos; a política automática preserva sucessos. Elegibilidade fica congelada na declaração por alvo, e dados já repetidos não podem receber Twin-linked ou Command Re-roll novamente. Listas mistas, manifesto, save/retomada e reconexão LAN carregam a opção. A fonte oficial disponível para o efeito completo é de uma edição anterior, e o catálogo local é provisório: falta confirmar o datasheet atual antes de tratar essa capacidade como regra oficial da edição. Comandantes, destacamentos, habilidades restantes e construção integral de listas oficiais seguem pendentes.

## Avanço em 16/10: última janela de Command Re-roll prevista para o treino

[Desperate Escape](../rules/escape-rerolls.md) agora oferece decisão após os hazards e antes de feridas mortais, prevenção ou movimento. O dono escolhe um D6 por 1 CP ou aceita gratuitamente; o resultado novo é obrigatório. A opção compartilha limites com avanço/carga e demais usos, recusa unidades em Battle-shock e preserva resultado/CP ao resetar posições. Manifesto, listas salvas, UI, journal, save antigo/novo e reinício autenticado do host carregam a capacidade. Isso fecha as janelas de Command Re-roll previstas para os movimentos e armas implementados; não habilita transporte, demais estratagemas ou todas as regras oficiais. As próximas prioridades do marco 3 continuam sendo habilidades verificadas, comandantes/attachments, destacamentos e legalidade das forças de referência.

## Track A: Hail of Bolts e primeiro perfil de facção

[Hail of Bolts](../rules/hail-of-bolts.md) substitui o slot provisório Target Elimination dos Intercessors por um efeito verificado no card oficial de junho: escolha explícita de inimigo visível no plano e +2 ataques para os bolt rifles direcionados a ele. Divisão de alvos, equipamentos, bônus existentes, draft, checkpoints e LAN preservam a escolha sem alterar os perfis base.

[Oath of Moment](../rules/oath-of-moment.md) entra como perfil identificado de **junho/2026**, com escolha no início da Command, duração até a próxima Command própria, repetição automática de falhas de acerto e bônus condicional de ferimento no contexto Codex. Dados já repetidos não recebem Command Re-roll novamente. O catálogo oficial foi consultado e agora remete aos suplementos do Codex de outubro; por isso este perfil não certifica esse livro posterior.

[Reanimation Protocols](../rules/reanimation-protocols.md) usa a atualização de facção de **setembro/2026**: no fim da própria Command, o host rola D3 por unidade viva; Warriors/Immortals puros permitem escolher os modelos destruídos e pré-visualizar posições válidas antes da confirmação. Overlords isolados vivos recuperam feridas até o máximo. Save e reconexão autenticada preservam rolagem, orçamento e posições. Anexos de um Overlord com Warriors/Immortals agora compartilham esse fluxo; personagens mortos, outras composições, Resurrection Orb e Their Number is Legion permanecem pendentes. A [Track A](track-a.md) mantém os limites de fonte e escopo; o próximo bloco são os destacamentos, seguido das habilidades restantes, missão e certificação de pontos/legalidade.

## Baseline obrigatório: edição 11 e regras atuais

A referência solicitada pelo usuário é [Wahapedia e11](https://wahapedia.ru/wh40k11ed/the-rules/core-rules/), com conferência nas publicações oficiais vigentes. Perfis históricos não substituem regras atuais. A exigência está registrada em [AGENTS.md](../../AGENTS.md) e na [política de fontes](../data/source-assessment.md#required-rules-baseline).

[Combat Doctrines + Codex Discipline do Gladius](../rules/combat-doctrines.md) agora seguem a estrutura atual: doutrinas são regra de exército; o destacamento oferece uma utilização adicional compartilhada de uma doutrina por batalha. A seleção ocorre no início da Command, antes do CP básico. Devastator concede Assault aos perfis de ataque à distância; Tactical libera tiro/carga após Fall Back; Assault libera carga após Advance. Os limites de ação, engajamento, alcance e movimento permanecem. Save/LAN preservam escolha e usos. Essa opção rejeita combinação com o Oath histórico. Próximos passos: Awakened Dynasty vigente, migração de datasheets/habilidades antigas, demais regras necessárias, missão oficial e certificação de pontos/DP/legalidade.

## Awakened Dynasty e vínculo do Overlord

[Command Protocols](../rules/awakened-dynasty.md) foi integrado conforme a referência e11 vigente: +1 para acertar enquanto um personagem Necron lidera a unidade. Há um novo preset offline com Overlord, Warriors e Immortals, de 245/500 pontos locais. Antes da implantação, o controlador declara o Overlord isolado ou vinculado a uma unidade permitida; o vínculo preserva os modelos/equipamentos e todos ainda precisam cumprir a validação de implantação. Tiro e combate recebem o modificador no contexto calculado pelo host, incluindo o limite final de ±1 e recuperação LAN de ataques pendentes.

Overlord anexado a Warriors/Immortals agora combina com Reanimation. A unidade mantém sua identidade e força inicial combinada; o líder sobrevivente conserva a habilidade mesmo sem guarda-costas, conforme e11 19.04. O orçamento D3 cura sobreviventes antes de retornar tropas. A suposição anterior de separação automática foi corrigida. A próxima prioridade são as habilidades restantes das unidades; este escopo não certifica uma partida Necron oficial completa.

### Habilidades atuais das dez unidades da Track A

Implementadas no perfil [current-unit-abilities](../rules/current-unit-abilities.md), incluindo Assault/Heavy Intercessors, Lieutenant e Royal Warden. O perfil atual substitui habilidades historicas por suas equivalentes verificadas na e11, oferece preparacao de Leader/Support/Warlord, reservas/Teleport Homer, habilidades de fase e escolhas gratuitas de rerrolagem. A etapa cobre os equipamentos fixos admitidos; nao certifica todas as variantes ou listas oficiais. As proximas etapas sao missao oficial (A2) e pontos/legalidade (A3).


## A2 - Cenario selecionado de Chapter Approved 2026-27

Implementado [Battlefield Dominance / Hammer and Anvil](../rules/chapter-approved-mission.md), com Take and Hold nos dois lados, secundarias fixas Engage on All Fronts e Assassination, mesa de 60 x 44 polegadas e terreno personalizado sobre os pontos oficiais. Inclui sorteios de papeis/primeiro turno, deployment iniciado pelo defensor, sigilo das reservas ate ambos confirmarem, limites e momentos atuais de pontuacao, e cinco rodadas mesmo sem tropas restantes. Proxima prioridade: A3, certificacao de pontos/DP/equipamentos/composicao; ainda faltam outras regras necessarias dos destacamentos para declarar Track A completamente legal.
