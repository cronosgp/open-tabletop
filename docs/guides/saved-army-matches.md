# Partidas com listas salvas

## Escopo atual

Novas partidas de treino aceitam listas resolvidas pelo catálogo local consolidado de Space Marines. O preset atual é um espelho de 550 pontos dentro de um limite personalizado de 1000; pontos e perfis vêm do snapshot local Wahapedia 11e. Isso não certifica legalidade completa de exército.

Listas históricas, inclusive os perfis Necron e rosters com preços MFM, continuam salvas e editáveis como drafts legados. Elas podem ser inspecionadas e mantidas na biblioteca, mas não podem entrar em uma nova partida pelo fluxo de construção atual. Essa barreira não apaga nem migra saves antigos.

## Fluxo local

1. Abra **Match setup → LOCAL MATCH • TWO ARMIES**.
2. Escolha uma lista atual em cada seletor. O lançamento novo preseleciona o preset Space Marine para ambos os lados.
3. Revise as opções e inicie a partida. Drafts históricos são identificados pelo relatório e bloqueados na admissão.
4. Use **Save a copy of player …** para criar uma cópia editável no perfil. Alterações na cópia não modificam o preset.

`training_roster.gd` mantém inspeção de dados legados separada da admissão de construção atual. `prepared_training.gd` rematerializa listas aceitas e sela os respectivos perfis no manifesto. A retomada de um save existente segue sua identidade gravada; ela não promove o roster a uma escolha nova do catálogo.

## Rede e limites

O projeto mantém adaptadores de LAN e caminhos antigos de seleção, mas a validação de rede para o escopo Space Marine atual está adiada até a integração final. Não conte exercícios locais ou testes de loopback como validação de rede entre jogadores.

Modelos são visuais e não alteram regras, bases ou elegibilidade. Veja [importação de modelos](../data/forceorg-import.md), [política do catálogo](../construction-catalog-policy.md) e a [matriz de suporte](../project/support-matrix.md).
