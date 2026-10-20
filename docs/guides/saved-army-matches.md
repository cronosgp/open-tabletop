# Partidas de treino com listas salvas

> **Legacy data boundary:** This exercise resolves its fixed training profiles and points from the pinned 40kdc-data starter pack. That pack is not an authoritative current datasheet source and does not certify these lists. Do not use its preparation command as a substitute for the local Wahapedia export required for new e11 profile work; see the [source policy](../data/source-assessment.md).

Implementado em 16/10/2026, protocolo **v23**. Este incremento liga o planejador de listas ao deployment e à missão customizada de cinco rodadas, localmente e por LAN. O modo continua explicitamente parcial: não certifica listas ou regras oficiais.

## Escopo admitido

Cada jogador pode escolher até seis unidades dos perfis admitidos: Intercessors e Terminators de **5 modelos**, Captain isolado, Warriors de **10 modelos**, Immortals de **5 modelos** e Overlord isolado. Além das forças mistas de 480/500 pontos, há o preset **Necrons • Overlord + Warriors + Immortals**, de 245/500 pontos locais. Ative Awakened Dynasty nas opções avançadas para declarar o vínculo do Overlord antes da implantação; [limites e integração pendente com Reanimation](../rules/awakened-dynasty.md). As seleções antigas continuam compatíveis. As armas são as padrão fixas do exercício; as anotações da lista não configuram equipamento. Habilidades e estratagemas ausentes continuam fora desse treino.

Os pontos são resolvidos pelo pacote starter local fixado, independentemente do custo salvo no planejador ou retornado pela API. O orçamento deve comportar esses custos; os dois jogadores precisam escolher a mesma categoria/limite. O cenário permanece customizado, 43 × 43, com primeiro jogador 1 e cinco rodadas; mudar o orçamento não muda as dimensões nem o transforma em missão oficial.

## Criar e usar localmente

1. Prepare o starter com `python tools/prepare_starter.py`.
2. Em **Match setup → LOCAL MATCH • TWO ARMIES**, os dois seletores oferecem quatro padrões pequenos de uma/duas unidades e duas listas mistas de referência, categoria treino de 500 pontos. Os padrões de duas unidades custam 160 e 170 pontos respectivamente; o limite de 500 não significa que sejam listas completas de 500 pontos ou competitivamente equilibradas.
3. Selecione uma lista padrão ou qualquer lista salva compatível para cada jogador e clique **Create local match with these two lists**. O jogo inicia o deployment e permite controlar os dois lados. Não exige marcar aceite de LAN.
4. **Save a copy of player …** grava uma cópia independente no perfil ativo. Edite-a em **Armies**. Os padrões nunca alteram a biblioteca automaticamente.
5. Para listas próprias, em **Armies** escolha edição/facção/categoria e crie uma lista compatível com treino. Salve no perfil e volte aos seletores. O resumo explica custos e incompatibilidades. Os dois lados devem ter categoria/limite iguais.
6. **Download and link ForceOrg models automatically** prepara os visuais em segundo plano. Sem fonte configurada, o catálogo é baixado automaticamente na primeira partida. Também é possível escolher um JSON local em **Models / Import** e usar Retry; veja [modelos automáticos](../data/forceorg-import.md). Falhas de visual não bloqueiam a partida.

Identidades de listas/entradas são verificadas, não seus nomes de exibição. Uma lista com um personagem ou outra unidade não implementada é bloqueada mesmo que seja renomeada para “Intercessor Squad”. Quantidades de modelos inconsistentes também são bloqueadas: o programa não acrescenta sargentos nem corrige a composição da API silenciosamente. As listas bloqueadas permanecem salvas e editáveis no planejador.

## LAN: cada jogador escolhe sua lista

1. Cada computador prepara o mesmo starter e salva sua própria lista compatível.
2. O host seleciona sua lista no campo **Jogador 1**; o convidado seleciona a sua em **Jogador 2**. O outro campo pode ficar sem seleção. Cada um aceita o escopo parcial e usa **Ativar LAN com listas salvas; depois Host / Join**.
3. Escolham a mesma opção de alocação de dano. O host usa **Host LAN**; o convidado informa o IP e usa **Join**. Ambos selecionam a mesma categoria e limite nas respectivas listas.
4. Ao conectar, o cliente envia sua seleção mínima. O host valida as duas e só então inicia o deployment. Orçamentos incompatíveis mantêm a sessão na seleção de listas; não há CP, fases ou ações de jogo liberados nesse estágio.
5. Para corrigir uma seleção antes do deployment, edite/salve a lista no planejador, escolha a lista atualizada e use **Enviar minha lista ao treino LAN**. O salvamento atualiza os seletores; existe também **Atualizar listas do perfil**.

O limite, a composição e as seleções ficam congelados ao iniciar o deployment. Pedidos posteriores para trocar a lista não reiniciam a partida. O convidado pode desconectar e retornar usando sua credencial local e uma lista com a mesma seleção canônica, inclusive após o host retomar um salvamento. Nomes e notas podem ser diferentes; identidade de unidade, composição e orçamento precisam corresponder. Para continuar após reinício, o host usa a ação de retomar como host LAN; o convidado usa os mesmos dados locais e Join. Veja [persistência e reserva de assento](../architecture/match-persistence.md).

## Identidade, pontos e privacidade

`training_roster.gd` é a fronteira entre planejamento e execução. Mapeia apenas IDs explicitamente revisados dos dois perfis, resolve composição/custo pelo pacote local, verifica orçamento e produz uma seleção canônica. Não usa consultas online ou correspondência aproximada por nome para admitir unidades.

`prepared_training.gd` reconstrói os exércitos a partir dessa seleção: modelos, bases, estatísticas e armamento vêm dos perfis locais. A factory suporta os lados invertidos, facções iguais e quantidades assimétricas. Seu manifesto e hash incluem a configuração pública dos exércitos, os pontos locais e a identidade do conteúdo. Uma seleção recebida é reconstruída contra o pacote do cliente e comparada ao hash, e o cliente verifica se sua própria seleção pública foi preservada.

Somente facção, ID canônico de unidade, modelos/cópias, categoria e limite são compartilhados. Nomes de perfil/lista, notas, caminhos de arquivos e preços informados pelo usuário não entram no estado público. A biblioteca pessoal não é enviada. Depois da validação inicial, a configuração aceita é reutilizada durante a sincronização sem reler os packs em cada movimento. A autoridade de estado e dados continua sendo o host; isto não acrescenta proteção contra um host malicioso.

## Verificação

- `test_saved_armies.gd`: templates/editor offline, IDs e composições, pontos locais versus preços salvos, orçamento, privacidade, manifesto, listas assimétricas, ciclo de cinco rodadas, consentimento e recusa de alteração da seleção pelo host.
- `test_saved_armies_network.gd`: escolha independente, reconstrução de modelos/facções, mensagens inválidas, congelamento da lista, desconexão/reconexão no deployment e início do turno. A variante `--budget-mismatch-test` confirma bloqueio e correção/reenvio do orçamento.
- Revisão visual Windows, 1280 × 800: resumo/aceitação, deployment assimétrico e primeiro turno, com perfil de QA isolado. Capturas/logs em `.tools/saved-army-*`, ignorados por Git.

Os resultados estão em [verification-results.md](../verification/verification-results.md). Linux e LAN entre máquinas distintas ainda não são comprovados pelos testes de loopback Windows.


A opção de partida preparada **Insane Bravery** também pode ser ativada nos treinos com listas salvas. Ambos os jogadores devem escolhê-la antes de preparar/ativar o modo LAN. É uma capacidade restrita, preservada no manifesto e no save; veja [estratagemas do núcleo](../rules/core-stratagems.md).
