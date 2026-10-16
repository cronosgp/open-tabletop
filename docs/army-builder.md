# Construtor de exércitos e perfis locais

Implementado em 16/10/2026. A aba **Listas** fica disponível desde a abertura do jogo, sem importar os dados do exercício de combate. É um planejador de listas persistentes; ele não habilita automaticamente novas unidades no motor de partidas. A admissão restrita de listas compatíveis está disponível no protocolo v23, conforme [partidas com listas salvas](saved-army-matches.md).

## Uso

1. Abra **Listas** e pressione **Atualizar catálogo online**. A consulta carrega todas as páginas da edição selecionada. Depois da primeira atualização, o catálogo funciona offline.
2. Escolha edição e exército/facção. Capítulos de Space Marines também exibem as unidades do catálogo comum de Space Marines. Ative **Permitir outras facções** para planejar uma composição personalizada; essa opção não certifica a legalidade dos aliados.
3. Escolha a categoria: Treino 500, Incursion 1.000, Strike Force 2.000, Onslaught 3.000 ou Personalizada. Na categoria personalizada, edite o limite. Estes são presets de orçamento do planejador, não missões nem listas oficiais.
4. Use **Buscar / adicionar unidades** para navegar ao catálogo. Filtre por nome e categoria de unidade, escolha uma variante de modelos/custo e quantas cópias da unidade deseja adicionar. O total é custo da variante × cópias, não custo × modelos.
5. Remova entradas quando necessário e anote equipamento/observações. **Salvar lista** grava alterações na lista aberta; **Salvar cópia** cria outra identidade e preserva a original.
6. Expanda **Perfis e listas salvas** para criar/alternar perfis, carregar listas e excluir uma lista específica mediante confirmação. O perfil é local neste computador; não é uma conta online.

Uma lista acima do orçamento ou com custos ausentes pode ser salva como rascunho, com o estado explicitamente indicado. Edições diferentes não podem ser misturadas. Sem a opção de outras facções, o planejador rejeita entradas de outra facção, exceto o catálogo comum de Marines para capítulos conhecidos. Esses controles não substituem as demais regras oficiais de montagem de exércitos.

## Bases padrão editáveis

**Nova base padrão editável** cria um novo rascunho para a facção/orçamento atuais, procurando até um personagem e duas unidades de linha pelos menores custos disponíveis que caibam no limite. A base pode ser parcial ou vazia se o catálogo/orçamento não oferecer essas opções. É um ponto de partida gerado, não uma lista oficial, lista competitiva ou um exército completo garantido. Os exércitos padrão dos exercícios de combate continuam disponíveis em Match setup.

## O que a API fornece

Integração com a [OpenHammer API](https://openhammer-api-production.up.railway.app/) a partir da sua [especificação OpenAPI](https://openhammer-api-production.up.railway.app/openapi.json). A verificação real pelo Godot retornou **35 facções / 1.348 registros em 11e** e **35 facções / 1.380 registros em 10e**. São contagens do provedor observadas nesta data, não uma certificação de cobertura oficial.

O cliente consulta `/v1/{edition}/stats` e `/v1/{edition}/units?limit=500&offset=...&sort_by=name`. Verifica identidades, paginação sem duplicatas, contagens de unidades/facções, formato e integridade antes de substituir o cache. Requisições têm timeout de 30 segundos, corpo de até 16 MiB, agregado de até 32 MiB e nenhum redirecionamento. A atualização pode ser cancelada; erros ou páginas incompletas não substituem o catálogo anterior. Nenhuma consulta é feita automaticamente durante a abertura de uma partida, edição de uma lista ou resolução de ações.

Somente metadados necessários ao planejador são mantidos: identidades, nomes, facções, palavras-chave, categorias, opções de modelos/custos e digest de origem. Descrições de habilidades não são executadas nem copiadas ao cache do planejador. Os catálogos obtidos não são incluídos nos arquivos distribuídos do projeto.

## Pontuação e composição de referência

O custo-base só é associado a uma quantidade quando os limites de composição retornados são estruturalmente consistentes. Variantes usam quantidades/custos explícitos; não há interpolação ou multiplicação por modelo. Composição inválida, preços conflitantes e custos ausentes são mantidos como pendências. Quantidades exibidas como **modelos (API)** são os valores retornados pelo provedor, sem correções presumidas de sargentos, líderes ou membros adicionais.

A API não fornece nesta integração um conjunto oficial datado de atualização de regras, um validador completo de listas, opções executáveis de destacamento/equipamento ou exércitos padrão prontos. Limites de repetição, personagens únicos, aliados oficiais, destacamentos e equipamento continuam sem validação completa. **Dentro do limite de pontos não significa lista oficial válida ou lista executável no jogo.**

Cada entrada salva inclui a variante, custo e digest da fonte. Atualizar o catálogo não altera listas já salvas. **Recalcular custos pelo catálogo atual** gera uma revisão do rascunho; salvar é uma etapa separada. Se a unidade ou composição não existir mais, a revisão falha preservando a lista anterior.

## Arquivos e persistência

- Perfis/listas: `user://profiles/army-lists.json`, schema 1, gravação por arquivo temporário e substituição atômica, limite de 16 MiB.
- Catálogos: `user://army-catalogs/10e.json` e `11e.json`, schema 1, data UTC e hash do conteúdo, limite de 32 MiB por cache.
- IDs são gerados localmente e não derivados do nome do usuário. Nomes de perfil/lista não são utilizados como caminhos de arquivo.
- Alterações não salvas são mantidas em memória ao alternar perfis na mesma execução; para sobreviver ao fechamento do jogo é necessário salvar a lista.
- Arquivos de perfil corrompidos ou de formato incompatível são preservados; o aplicativo bloqueia sua substituição por uma biblioteca vazia.
- Arquivos de perfil/listas não são enviados para a API ou para o outro jogador. Ao admitir uma lista no treino, compartilha-se somente sua seleção mínima de unidade/composição/orçamento; nomes de perfil/lista e notas permanecem privados. Mapeamentos visuais continuam separados.

## Integração com partidas

Listas pessoais compatíveis já podem entrar em treino parcial por Match setup: uma ou duas unidades de Intercessors de 5 modelos ou Warriors de 10 por jogador, com armamento padrão fixo. Use **Nova lista compatível com treino** e **Verificar compatibilidade de treino** para criar/conferir uma seleção. Os pontos vêm do pacote local fixado, e não dos preços salvos ou da API. O editor permite criar esses templates offline quando o starter está instalado.

Admitir outras unidades e listas oficiais exige resolver um pack compatível e implementar todas as regras, equipamentos, geometrias e restrições exigidas. A seleção de treino requer aceitação explícita do escopo parcial; ela não alega legalidade oficial. A persistência disponível continua sendo de listas/perfis, não de partidas. Veja [o fluxo local/LAN](saved-army-matches.md).

Testes: `test_army_catalog.gd` e `test_army_builder.gd`, incluídos também no perfil offline de verificação. Cobrem paginação, cancelamento/erro, cache offline, variantes de pontos, orçamento, custos desconhecidos, edições/facções, templates, edição/cópias, isolamento e reabertura de perfis, tamanho de arquivos e preservação de dados corrompidos. A atualização real das duas edições, o salvamento/reabertura com dados reais e a interface a 1280 × 800 foram verificados no Windows. Veja [resultados](verification-results.md).
