# Janelas de decisão e estratagemas do núcleo

Atualização de 16/10: [Command Re-roll em Desperate Escape](escape-rerolls.md) também está disponível, por opção separada. As referências abaixo a essa janela como pendente descrevem o escopo dos incrementos anteriores.

A primeira regra habilitada é **Insane Bravery**, opcional nas partidas preparadas e nos treinos com listas salvas. Na aba Match setup, marque **Próxima partida preparada: Insane Bravery** antes de preparar o cenário ou ativar o modo LAN de listas. Na LAN, ambos precisam escolher a mesma opção. Os exercícios anteriores continuam com seu fluxo padrão; marcar a opção durante uma partida não altera a configuração já aceita.

Ao avançar a fase Command com unidades que precisam testar Battle-shock, o jogo abre uma decisão antes de rolar dados. Escolha a próxima unidade e use **Rolar Battle-shock normalmente** ou **Insane Bravery**. A segunda ação custa 1 CP e aprova automaticamente aquele teste, sem consumir o RNG. A opção se desabilita quando CP, alvo ou limites não permitem o uso. Quando todos os testes pendentes forem resolvidos, o jogo continua para Movement e resolve o controle dos objetivos no encerramento da Command.

## Regras e referência

A implementação foi conferida no [PDF oficial de Core Rules da 11ª edição](https://assets.warhammer-community.com/eng_01-06_warhammer40k_new40k_core_rules-was6fbu1ix-hfewhmxyiy.pdf), §§01.07, 08.03, 15.01, 15.02 e 15.04, incluindo a página impressa 56. Referência de publicação: [Warhammer Community, 1 de junho de 2026](https://www.warhammer-community.com/en-gb/articles/nhqt9wx3/new40k-rules-download-the-free-core-rules-now/). SHA-256 do PDF local consultado: `f6a2443a44627ac5f0ef08407d29aa5ec7e97339998f05bc35f3ae37bf276833`. O PDF não é necessário em runtime.

O estratagema só pode ser usado imediatamente antes do teste da unidade, na Battle-shock step da própria Command; custa 1 CP e cada jogador pode usá-lo uma vez na batalha. Uma unidade já em Battle-shock não pode ser alvo de um estratagema próprio; ela continua podendo fazer o teste normal e recuperar-se se tiver sucesso. Não é possível esperar uma falha e usar Insane Bravery retroativamente.

As restrições gerais por jogador/fase e por unidade alvo constam do registro de usos: o mesmo estratagema não pode ser repetido na mesma fase, e uma unidade não pode receber outro estratagema naquela fase, salvo exceção implementada. Insane Bravery mantém seu limite mais restritivo por batalha. Command Re-roll está disponível para avanço/carga, acertos/ferimentos, defesas, dano aleatório, Hazardous de armas e número aleatório de ataques, mediante opções adicionais. Não há reduções de custo, exceções de facção ou demais estratagemas habilitados.

## Command Re-roll: avanço e carga

Marque **Próxima partida: Command Re-roll avanço/carga** antes de preparar a partida ou ativar o treino LAN com listas. Isso também marca Insane Bravery, pois usa a infraestrutura de estratagemas do núcleo. Ambos os jogadores devem escolher as mesmas opções; elas ficam congeladas no manifesto. A nova opção inicia desativada, preservando o comportamento dos saves anteriores, inclusive os que já habilitavam somente Insane Bravery.

Depois da rolagem original de avanço ou carga, se o jogador puder usar Command Re-roll, o jogo pausa antes de liberar o movimento ou a escolha de alvos. Escolha **Aceitar resultado e continuar** (sem CP nem novos dados) ou **Command Re-roll** (1 CP). No avanço, substitui-se o D6; na carga, substituem-se obrigatoriamente os dois D6. O novo resultado vale mesmo se for pior. Uma carga inicialmente sem alcance ainda oferece a decisão quando o uso do estratagema é permitido.

Cada jogador pode usar Command Re-roll uma vez por fase. A mesma unidade não pode receber outro estratagema próprio naquela fase, salvo exceções implementadas; atualmente não há exceções. Sem CP, em Battle-shock ou sem permissão pelos limites de uso, o jogo aplica o resultado original diretamente. A escolha deixa de existir assim que o resultado é aceito/re-rolado: não é possível esperar a movimentação, seleção de alvo ou cancelamento de posicionamento para pedir uma nova tentativa. Resetar posições conserva o resultado final e o CP gasto.

O host valida jogador, unidade, fase, revisão e custo; o cliente não fornece valores de dados nem escolhe qual dado da carga substituir. Decisões rejeitadas não gastam CP. Um provedor inválido não confirma CP, resultado ou registro de uso. Enquanto a decisão estiver aberta, os demais comandos e as guias de destinos/alvos ficam bloqueados.

O save guarda os dados originais, a decisão e o RNG. Após aceitar/re-rolar, guarda também o resultado final e o limite já consumido. O histórico mantém somente os D6 realmente rolados. Retomar o host ou reconectar o convidado não repete a rolagem original, devolve CP ou oferece outro re-roll. Hazardous de armas usa uma opção separada; Número de ataques usa uma opção separada; Desperate Escape continua sem re-roll.

## Command Re-roll: acertos e ferimentos

Marque **Próxima partida: re-roll acerto/ferimento** antes de iniciar a partida preparada ou o treino com listas salvas. A opção ativa a infraestrutura de estratagemas; avanço/carga permanece uma escolha independente. As duas opções compartilham o limite de Command Re-roll por jogador/fase. A capacidade `command-reroll-hit-wound-v1` integra o manifesto/hash; saves antigos assumem desativada.

O ataque pausa depois do lote de acertos e antes de rolar ferimentos. Escolha um D6 no seletor e use Command Re-roll por 1 CP, ou aceite o lote gratuitamente. Se aceitar, a possibilidade de gastar CP continua disponível no lote de ferimentos, antes das defesas. O dado escolhido recebe o resultado novo obrigatoriamente, mesmo quando pior; Lethal Hits, Sustained Hits e Devastating Wounds são recalculados a partir dos resultados finais. Torrent não cria uma escolha de acertos. Dados já re-rolados por Twin-linked não aparecem entre as opções elegíveis para outro re-roll.

Não são rolados dados da etapa seguinte enquanto a decisão estiver aberta. A escolha antecede Precision, ordem dos grupos defensores e alocação do lote. Tiro e corpo a corpo usam o mesmo fluxo, inclusive quando o jogador que está atacando não é o dono do turno. Sem CP, sob Battle-shock ou com o limite consumido, o ataque segue automaticamente até a próxima decisão obrigatória. O modo de alocação manual continua respeitado.

Os checkpoints guardam perfis/contexto, dados originais e substituições, etapa e revisão. Save, journal e reconexão preservam a decisão e o RNG. O cliente envia somente a escolha do índice do dado; o host valida janela, jogador, unidade, revisão, índice, CP e limites antes de confirmar. Outros comandos permanecem bloqueados. Defesas, dano aleatório e Hazardous de armas usam opções separadas; Número de ataques usa uma opção separada; Desperate Escape continua pendente.

## Command Re-roll: defesas

Marque **Próxima partida: re-roll de defesa** antes de preparar a partida ou ativar o treino com listas salvas. A opção ativa a infraestrutura do núcleo e permanece independente das opções de avanço/carga e acertos/ferimentos. Os dois jogadores precisam escolher as mesmas capacidades. A capacidade `command-reroll-save-v1` integra o manifesto/hash e a configuração persistida; saves antigos continuam com o valor desativado.

Conforme a sequência da 11ª edição (§§05.03–05.04), os grupos de defesa e sua ordem são definidos antes do lote de defesas. Depois de rolar os D6, o jogo abre uma decisão para o dono da unidade alvo, mesmo durante o turno adversário: aceitar gratuitamente ou escolher um D6 e gastar 1 CP para substituí-lo. Somente depois da decisão o lote é ordenado do menor para o maior resultado, e a resolução de dano/alocação continua. O resultado novo é obrigatório, mesmo se pior. Isso também preserva o comportamento de grupos mistos e salvamentos invulneráveis; o novo valor não representa uma aprovação automática.

Nenhum dano aleatório, prevenção ou baixa desse lote é resolvido antes da decisão. O modo de alocação manual continua permitindo a escolha de modelo após as defesas. Devastating Wounds não cria dados de defesa; um lote sem defesas não abre esta janela. Battle-shock, CP insuficiente ou limite já consumido fazem o lote seguir diretamente. O atacante e o defensor têm limites independentes; cada um pode usar Command Re-roll uma vez na mesma fase. Para um mesmo jogador, as opções compartilham esse limite.

O cliente envia somente o índice escolhido. Janela, jogador, alvo, revisão, índice, custo e limites são validados no host; pedidos inválidos/duplicados não alteram CP ou estado. O journal preserva os D6 originais e o novo D6, e o resultado final registra a substituição antes da ordenação. Save e reconexão autenticada preservam o lote pendente e o RNG, sem repetir defesas ou devolver CP. Hazardous de armas usa uma opção separada; Número de ataques usa uma opção separada; Desperate Escape continua pendente.

## Command Re-roll: dano aleatório

Marque **Próxima partida: re-roll de dano** antes de iniciar a partida. A capacidade `command-reroll-damage-v1` é independente das demais opções, exige a infraestrutura do núcleo e compartilha o limite de Command Re-roll por jogador/fase. Fica congelada no manifesto/hash das partidas preparadas e listas salvas. Saves sem essa opção continuam desativados.

As listas iniciais suportadas têm dano fixo: a opção não modifica seus perfis nem cria dados onde não existem. Para experimentar o fluxo sem editar código, marque a opção e abra o **laboratório sintético de alocação**. Seu rifle de prática já usa D3; nesse modo explicitamente sintético, a opção concede **2 CP iniciais a cada jogador**. O laboratório anterior, sem a opção, preserva seus valores/hash. A arma e esses CP de prática não certificam um datasheet ou exército oficial.

Depois que o defensor escolhe o destinatário de um ataque que causa dano, o host rola sua característica D e pausa antes de Feel No Pain, redução de feridas e baixas. O dono da unidade atacante aceita gratuitamente ou escolhe um dado por 1 CP. O destinatário fica fixo, inclusive no modo de alocação automática. Aceitar não repete a rolagem de dano. O novo resultado é obrigatório mesmo se pior, e somente depois dele a prevenção é rolada para aquele modelo. Devastating Wounds usa a mesma pausa antes de aplicar seu pacote mortal.

D3 é representado pelo D6 bruto convertido para 1–3 (1/2 → 1, 3/4 → 2, 5/6 → 3). A interface mostra a expressão, o total e os D6. Em expressões com vários dados, apenas o índice escolhido é substituído; os outros dados e o bônus fixo permanecem. Por exemplo, 2D3+2 com D6 [6,4] vale 7; substituir o primeiro por 1 resulta em 5. Dano fixo não abre janela. Battle-shock, CP insuficiente e limite consumido também fazem a sequência prosseguir normalmente.

Comandos durante a decisão, alvo/jogador/índice incorretos, revisão antiga e repetição são recusados. O cliente nunca envia o valor novo. A operação confirma CP, resultado e aplicação somente se a retomada for válida; falha na prevenção posterior não confirma alterações. Save e reconexão preservam destinatário, dados originais, expressão, resultado pendente e RNG. O journal contém os dados efetivamente consumidos, sem repetir os originais ao retomar. Hazardous de armas usa uma opção separada; Número de ataques usa uma opção separada; Desperate Escape continua pendente.

## Command Re-roll: Hazardous de armas

Marque **Próxima partida: re-roll Hazardous** antes de preparar a partida. Para experimentar pela interface, marque também **varied training equipment** e escolha o plasma **supercharge** do modelo 100 no plano de ataques. O armamento padrão das listas salvas continua inalterado. A capacidade `command-reroll-weapon-hazard-v1` exige a infraestrutura do núcleo, integra manifesto/hash, persiste nas opções de listas salvas e compartilha o limite de Command Re-roll por jogador/fase. Saves antigos assumem desativada. **Desperate Escape não está incluído neste incremento.**

Depois de resolver todos os ataques, o jogo rola o lote de Hazardous das armas selecionadas (§24.15) e pausa para seu dono antes de alocar consequências. Aceite gratuitamente ou escolha um D6 e gaste 1 CP. Os outros dados não mudam. Um novo resultado é obrigatório, inclusive trocar um sucesso por uma falha: 1–2 falha e 3–6 passa. A quantidade de feridas mortais é recalculada, incluindo o multiplicador do grupo MONSTER/VEHICLE suportado. Mesmo um lote originalmente sem falhas oferece a decisão se elegível.

Durante a janela, não há destinatário escolhido, prevenção ou baixa de Hazardous. A alocação manual preserva suas prioridades quando a decisão termina. Se não restar consequência, a ativação é concluída uma única vez; caso contrário, o dono aloca as feridas pendentes. Não há uso retroativo depois da alocação. Sem CP, sob Battle-shock ou com limite consumido, o lote segue sem a escolha opcional. A resolução dos ataques inimigos anteriores não é repetida.

Host valida jogador, unidade, fase/revisão, índice, custo e limites; o cliente não envia dados novos. O save preserva o lote e a ativação pendente, e o journal mantém os dados originais e substituição. Reabrir o host e reconectar não rola novamente os ataques/Hazardous nem devolve CP. O resultado registra a substituição e as alocações posteriores. O re-roll de número de ataques usa uma opção separada; Desperate Escape continua pendente.

## Command Re-roll: número de ataques

Marque **Próxima partida: re-roll de nº ataques** antes de iniciar a partida. A capacidade `command-reroll-attack-count-v1` é separada das demais, exige a infraestrutura do núcleo e compartilha o limite por jogador/fase. Fica congelada no manifesto/hash e nas opções de listas salvas. Saves anteriores assumem desativada, mantendo sua identidade.

A geração de ataques agora pode pausar depois de rolar A e antes de qualquer acerto, ferimento ou defesa daquele lote. Escolha um D6 por 1 CP ou aceite gratuitamente. O novo resultado é obrigatório, inclusive quando produz menos ataques. Só o dado selecionado muda: os demais dados, parcelas fixas, bônus por fonte, Rapid Fire e Blast permanecem. As condições de alcance/tamanho do alvo são as congeladas no plano; não há nova seleção de alvos. D3 usa D6 bruto convertido para 1–3. Armas com A fixo não criam essa janela.

O seletor identifica modelo, expressão e posição do dado. Um lote de ataques idênticos pode combinar fontes com expressões distintas; o índice é mapeado para a fonte correta, sem usar o máximo do lote como se fosse uma expressão aleatória. O total é recalculado e só depois os acertos são rolados. Torrent continua sem dados de acerto. Aceitar A não gasta CP: se a opção de acertos estiver habilitada e o jogador ainda for elegível, ele poderá usar o estratagema naquela etapa posterior.

As listas iniciais continuam com A fixo. Para experimentar pela interface, marque a opção e abra o laboratório sintético: selecione o perfil **Synthetic random-A practice rifle** (A D3+1) no plano de ataques. Esse perfil existe somente no laboratório com a opção ativa. A lâmina de prática com A aleatório também continua disponível no corpo a corpo. Como nas decisões de dano, o laboratório habilitado começa com 2 CP por jogador; isso não certifica perfis ou listas oficiais. Sem a opção, o laboratório e os saves antigos preservam seus perfis e hashes.

Pedidos de outro jogador/unidade, revisão obsoleta, índice indevido, dado já re-rolado e provedor inválido não confirmam CP ou estado. Battle-shock, CP insuficiente e limite consumido fazem a sequência seguir automaticamente. Checkpoint, fontes, dados originais/substituição e RNG sobrevivem ao save e ao reinício autenticado do host; o journal mantém a ordem dos dados. Desperate Escape permanece pendente.

## Implementação e continuidade

`stratagems.gd` declara a capacidade `core-stratagem-windows-v1`, o registro de regras suportadas, as condições da janela, custo e limites. A capacidade adicional `command-reroll-movement-v1` identifica o re-roll de avanço/carga e integra o manifesto/hash quando habilitada. O cenário de combate é responsável pela resolução transacional: nenhuma validação rejeitada muda CP ou estado; um provedor de dados inválido não confirma o resultado. Pedidos de outro jogador, alvo indevido, revisão obsoleta, estratagema desconhecido e repetição são recusados. Outros comandos ficam bloqueados enquanto a janela está pendente.

A opção integra o hash e o manifesto da partida. Nos treinos com listas salvas, a seleção pública preserva essa configuração e o convidado recusa uma mudança na opção que escolheu. O save preserva testes restantes, resultados parciais, CP e limites de uso; o journal registra as escolhas e os D6 efetivamente consumidos. A reconexão não repete testes nem devolve CP. Saves anteriores à opção recebem o valor padrão desativado, preservando seu estado e hash.

As decisões aparecem no topo de Play, com o motivo de indisponibilidade e o CP disponível. Após uma decisão, o aviso mostra o resultado e o CP restante. O histórico continua disponível para consulta.

O marco 3 já cobre Insane Bravery e Command Re-roll em avanço/carga, acertos/ferimentos, defesas, dano aleatório, Hazardous de armas e número de ataques, com infraestrutura de decisão antes de testes e após rolagens. As habilidades de unidade/facção provisórias presentes no catálogo não foram ativadas. Legalidade integral das listas, demais janelas/regras, missões oficiais e interações de habilidades ainda exigem implementação e validação próprias.

