# Desperate Escape re-rolls — 16 October 2026

**170/170 processes passed** in `.tools/verification/20261016T203756291474Z`: project import, Python checks, startup, every local suite and all host/client variants. This includes the new escape suite, host-restart pair and saved-army escape-option variant. Existing Intercessor/Immortal abilities, attack decisions, movement, objectives, model workflows, persistence and recovery remain green.

The local suite checks strict options and unchanged disabled identities, saved-list setup reconstruction, original pool timing, blocked gameplay commands, invalid player/squad/revision/stratagem/index/provider, single-die replacement, free acceptance, mandatory worse results, prevention timing, all-heavy hazard consequences, CP/Battle-shock/phase/unit restrictions, placement reset and failed-Fall-Back behavior, UI dispatch, RNG/save restoration, legacy saves, conflicting save/peer flags and journal dice counts. The new network pair restarts the host in a fresh process with an authenticated returning guest, then resolves the original pool once, rejects stale/duplicate commands and preserves final hazards through a placement reset. Exactly two original dice and one replacement are recorded.

Graphical review at 1280 × 800 checked the advanced checkbox, the Play decision with die selector/CP, and continuation to escape-wound allocation. `.tools/qa_escape_rerolls.log` reports `ESCAPE REROLLS VISUAL QA: PASS`; inspected captures: `.tools/escape-rerolls-setup.png`, `.tools/escape-rerolls-decision.png`, `.tools/escape-rerolls-resolved.png`. These are staged fixtures, not a full manual match.

Scope and source are recorded in [Desperate Escape re-rolls](escape-rerolls.md). This closes the planned Command Re-roll windows for the currently implemented training movement and weapons. Other stratagems, transport hazards, complete official armies, Linux, native exports and separate-machine LAN were not added or verified here.

# Implacable Eradication training reference — 16 October 2026

**165/165 processes passed** in `.tools/verification/20261016T201702748833Z`: import, Python checks, startup, every local suite and all host/client variants. This includes the corrected real-shooting fixture, which needs 5+ wounds against the pinned Terminator's Toughness 6.

The new local suite covers canonical identity, strict options, objective eligibility, dead target models, fast/checkpoint parity, one-reroll protection across Twin-linked and Command Re-roll, real shooting/allocation, melee declaration, frozen target eligibility, setup reconstruction and save/resume. The new network pair verifies both unit options together with mixed armies, authoritative guest commands, replicated capability metadata and authenticated rejoin.

Graphical review at 1280 × 800 verified the advanced option fits and the selected Immortal displays its ability. `.tools/qa_implacable.log` reports `IMPLACABLE VISUAL QA: PASS`; captures `.tools/implacable-setup.png` and `.tools/implacable-play.png` were inspected. This is a staged UI fixture, not a full manual playthrough.

[Source and limitations](implacable-eradication.md): the complete effect is an older-index training reference, not verification of the current official datasheet. Automatic rerolls preserve successful rolls. Native exports, Linux and separate-machine LAN were not verified in this increment.

# Verification results — 16 October 2026

## Intercessor Objective Secured — 16 October 2026

**162/162 processes passed** in `.tools/verification/20261016T195548562071Z`: import, Python checks, startup, every local suite and all host/client variants. Existing exercises, mixed armies, attacks, objectives, history, persistence, rejoin and stratagem windows remain green.

The new local suite covers an opt-in identity, strict boolean options, activation after control/Battle-shock, owner/revision guards, zero OC, unit identity, terrain/marker objectives, retained/lost control, pending morale decisions, UI commands, journal publication, mixed setup reconstruction, current/legacy save restoration and conflicting save/peer flags. The new network pair verifies a guest Intercessor's Command request, authoritative securing, replicated state and authenticated reconnect with mixed armies.

Windows graphical review at 1280 × 800 opened Advanced match options and checked the enabled checkbox, selected-unit ability label and secured-objective summary. `.tools/qa_objective_secured.log` reports `OBJECTIVE SECURED VISUAL QA: PASS`; captures: `.tools/objective-secured-setup.png`, `.tools/objective-secured-play.png`. The graphical fixture positions an Intercessor unit at an objective to exercise the phase effect; it is not a separate full-playthrough or separate-machine LAN claim.

The rule source and exact scope are recorded in [Objective Secured](objective-secured.md). Only this unit ability is enabled by its option; other unit/faction abilities, official armies and missions remain incomplete. Native exports, Linux and separate-machine testing were not added in this increment.


## Mixed reference armies — 16 October 2026

**159/159 processes passed** in `.tools/verification/20261016T193918505424Z`: project import, Python checks, startup, all local Godot suites and all host/client variants. This final run includes the earlier corrected UI/history/stratagem expectations, the automatic ForceOrg catalog checks, and the new mixed-army suites. It supersedes the partial broad-run result recorded below.

New coverage includes equal 480/500-point reference forces, strict schema-v2 admission, canonical costs and verified API aliases, size/faction/extra-field/budget guards, entry-order normalization, real Terminator defenses/sergeant equipment, actual Gauss-blaster and Rapid Fire attacks, all ten squads' coherent deployment, five-round completion, mixed/legacy compatibility, per-unit repricing, actual setup rendering, save/resume and two-process LAN deployment. Existing schema-v1 setup identity and exercises remain covered by the previous suites.

Graphical Windows validation at 1280 × 800 used an isolated profile and the real ForceOrg JSON. The app reused existing Marine/Warrior files, downloaded the Terminator and Gauss Immortal OBJ/diffuse pairs, linked all four definitions, rendered 70 models and completed deployment. `.tools/qa_mixed_armies.log` reports `Models ready: 4/4` and `MIXED GRAPHICAL QA: PASS phase=start_turn units=70 mappings=4`. Captures: `.tools/mixed-armies-setup.png`, `.tools/mixed-armies-deployment.png`.

The forces remain core-profile training: no commander/detachment or complete unit/faction abilities, official legality, native export, Linux or separate-machine LAN validation is claimed. See [reference army scope](reference-armies.md).


## Local two-list matches and automatic ForceOrg models — 16 October 2026

The broad local/LAN regression executed **155 processes** in `.tools/verification/20261016T191004783527Z`: **152 passed**, with three obsolete UI expectations in `test_local_models`, `test_match_journal` and `test_stratagems`. The first assumed the sidebar's old fixed width; the others expected text that had already been changed. These checks were corrected and all passed in follow-up runs. The saved-army LAN fixture now selects a saved list by its stable ID rather than a menu index; all nine host/client variants passed. The corrected LAN fixture was copied into the isolated project before that suite executed.

The final source passed eight targeted processes in `.tools/verification/20261016T191740718611Z`, covering catalog download, two-list setup, profile copies, cache/link persistence, malformed visuals, cancellation, local-model layout, journal corruption and saved-list admission. The stratagem text check passed separately (4/4 processes) in `.tools/verification/20261016T191850821151Z`. Original broad-run failures remain in their report; follow-up reports record the corrections.

Actual Windows visual/network validation began with an empty profile and no configured source or cache: the app downloaded the ForceOrg JSON, two OBJ meshes and two diffuse images, saved both links and rendered Marines/Necrons during deployment. A separate run reused the external cache, and real catalog-transfer cancellation removed its partial file. Logs: `.tools/qa_forceorg_end_to_end.log`, `.tools/qa_local_armies_models.log`, `.tools/qa_catalog_cancel.log`. Captures: `.tools/local-match-setup.png`, `.tools/local-match-models.png`. See [scope and usage](saved-army-matches.md) and [model details](forceorg-import.md). No native binary, Linux or separate-machine LAN validation is claimed.


## Latest increment: saved-list training admission (v23)

**109/109 processes passed** in `.tools/verification/20261016T130918838991Z`: import, nine Python tests in one process, startup, 44 local Godot suites and 31 host/client pairs. New coverage includes canonical list admission, per-peer roster submission, budget disagreement/correction, frozen selections and rejoin with asymmetric army sizes. Existing combat, movement, allocation and deployment suites remain passing.

The final same-faction combat execution and layout checks also passed in `.tools/verification/20261016T131807993606Z` (5/5 processes). The offline demo/loopback profile passed 12/12 in `.tools/verification/20261016T131303340425Z`. Final demo import/export/exported startup passed in `.tools/verification/build-20261016T131315633746Z`; its PCK supersedes earlier artifacts below.

Visual QA at 1280 × 800 on Windows covered saved-list review/acceptance, an asymmetric Necron/Marine deployment and the first turn, using an isolated local profile and no online catalog. `.tools/saved-army-qa.log` reports `SAVED ARMY VISUAL QA: PASS` without script/render errors. Captures are `.tools/saved-army-review.png`, `.tools/saved-army-deployment.png`, `.tools/saved-army-first-turn.png`.

Rejoin testing exposed stale rendered-piece IDs when resetting from a saved roster to the waiting factory. Host/join/offline transitions now rebuild the piece pool when replacing that state. Public setup reconstruction is verified on initial acceptance/rejoin and reused for ordinary snapshots, avoiding repeated pack reads on every model placement. Setup feedback is visible alongside the setup controls; session text wraps within the sidebar.

Scope and instructions: [saved-list matches](saved-army-matches.md). This admits only one/two supported Intercessor/Warrior units per player under explicitly partial training rules. Arbitrary catalog units, official legality, full abilities, saved matches, native binaries, Linux, remote CI and separate-machine LAN remain outside these verification results.

## Earlier increment: army builder and local profiles

**104/104 processes passed** in `.tools/verification/20261016T124054739412Z`: import, nine Python tests in one process, startup, 43 local Godot suites and 29 host/client pairs. The two new offline suites cover catalog integrity/pagination/cancellation, list costs and variants, saved price snapshots, profile isolation, copied lists and fresh-load persistence. The final storage-size guard was separately verified with both suites in `.tools/verification/20261016T124224630829Z` (5/5 processes).

The clean offline/demo profile with loopback passed 12/12 processes in `.tools/verification/20261016T123909200708Z`. Demo import/export/exported startup passed in `.tools/verification/build-20261016T124430121612Z`; the generated `open-tabletop-demo.pck` there supersedes previous artifacts below.

Actual OpenHammer refreshes through the Godot HTTP client fetched **1,348 records / 35 factions for 11e** and **1,380 records / 35 factions for 10e**, across all pages. Both completed catalogs reopened offline with matching digests. Logs/caches are retained under ignored `.tools/army-live.log` and `.tools/army-live/catalogs/`; no downloaded dataset is bundled. These are provider counts observed on this date, not official coverage certification.

A generated Marine base was saved and reopened with real catalog data in a separate QA user profile. The builder, search/variant options and profile library were rendered and inspected at 1280 × 800 on Windows: `.tools/army-builder-top.png`, `.tools/army-builder-catalog.png`, `.tools/army-builder-profile.png`. Final `.tools/army-qa.log` reports `REAL ARMY PROFILE: PASS` without script/rendering errors. Catalog update controls were moved to the top so a first-time user can populate the empty catalog; the UI provides navigation to unit selection and back to saving.

Scope: [army builder](army-builder.md). Lists are persistent local planning documents, not new executable army packs. Official legality/points/composition certification and use of arbitrary saved rosters in enforced matches remain pending. Existing training armies are unchanged. Native binaries, Linux, remote CI and separate-machine LAN were not newly verified.

## Earlier increment: prepared custom match (v22)

**102/102 processes passed** on Windows in `.tools/verification/20261016T121727787119Z`: resource import, nine Python tests in one process, startup, 41 local Godot suites and 29 host/client pairs including variants. This includes the new configuration/deployment-to-five-round-result check and disconnect/rejoin during individual deployment placement. Existing combat/training suites remain passing.

The interface was rendered with the compatibility renderer and visually inspected at 1280 × 800 for each deployment owner and the first turn. Captures are `.tools/prepared-deployment.png`, `.tools/prepared-player2.png` and `.tools/prepared-first-turn.png`; the final `.tools/prepared-qa.log` has no script/rendering errors. Deployment controls were moved above selection/history after inspection. Off-board deployment cursor previews now avoid creating empty geometry surfaces.

Demo import/export/headless exported startup also passed in `.tools/verification/build-20261016T121909724828Z`; the artifact there supersedes the earlier demo PCK below. No native binary or separate-machine/Linux validation is implied.

Implementation and scope: [prepared custom match](prepared-match.md). Official army legality/point validation, official missions/deployment, persistent saves and full faction abilities remain pending.

## Earlier reproducible-foundation baseline

Platform: Windows, Godot 4.7.2 stable, headless. Runs used isolated project copies/user profiles. Full combat data matched `data/starter.lock.json`; the demo run contained no imported starter data or player models.

| Run | Result | Evidence directory under `.tools/verification/` |
|---|---|---|
| Full rules/UI/loopback | **99/99 processes passed**: resource import, nine Python unit tests in one process, scene startup, 40 local Godot suites and 28 host/client pairs including variants | `20261016T031701334989Z` |
| Clean demo + loopback | **10/10 processes passed**, without imported data | `20261016T031958451680Z` |
| Demo PCK export | Import, export and exported headless startup passed | `build-20261016T031901357625Z` |
| Starter snapshot | Offline revision/content-hash verification passed | `python tools/prepare_starter.py --check` |

Every runner/build directory contains `results.json`, stdout/stderr logs and Godot logs. The generated demo artifact is `.tools/verification/build-20261016T031901357625Z/open-tabletop-demo.pck`. It needs a compatible Godot engine to run; it is not a standalone executable.

## Regressions found and corrected

- Mixed-defense networking replaced the host state with a fixture lacking the Incursion battlefield identity. The client correctly rejected its compatibility hash. Apply the same battlefield preset to the fixture and assert compatibility before the scenario begins. Disconnect/rejoin during allocation now passes.
- Tactical-guide tests assumed the old board dimensions. Investigation also found a real presentation defect: guide polygons still clipped to 30 × 20 on the 43 × 43 board. Guides now use the same state-derived bounds as movement validation. Tests require guides to extend beyond the legacy dimensions while remaining within the actual board, and separately retain legacy clipping for the original demo.
- Runner tests ensure a Godot script error cannot pass merely because the engine exits with zero, and a hung process is terminated while its diagnostic output is retained.
- The demo profile excludes the local-model board-integration suite because that suite starts the imported-data combat lab; it remains covered by the full profile. Cache/catalog/download-validation suites remain in the offline demo checks.

Initial runs exposed sandbox restrictions on atomic file writes; successful runs above executed with the required local filesystem permissions. One diagnostic retry overlapped another runner and collided on the shared UDP game port; network runner invocations now reserve a separate TCP guard port to reject concurrent runs. No unresolved failure remains in the final selected checks.

## Not verified by these results

Separate-machine LAN, internet sessions, native Windows/Linux binaries, Linux execution and remote GitHub Actions have not been validated by these runs. The workflow and export presets are supplied, but their presence does not establish those results. The latest increment adds limited graphical inspection and custom deployment as recorded above; full official rules compliance, legal 1,000-point rosters, official deployment and persistence remain roadmap work.

## Persistência de partidas — 16/10/2026

- Suíte full + loopback: **110 processos aprovados**, relatório `.tools/verification/20261016T132529654481Z/results.json`.
- Regressão final de persistência/importação/startup/Python: **4 processos aprovados**, `.tools/verification/20261016T132820263441Z/results.json`.
- Retomada como host LAN: `test_match_save.gd --resume-host`, **PASS**, `.tools/match-resume-host.log`.
- Cobertos: snapshot com deployment em andamento, substituição de save existente, identidade incompatível sem substituir o jogo atual, checksum/truncamento, IDs e geometria nativos, estado RNG de 64 bits, plano de ataque real, estado após ataque e abertura de servidor restaurado.
- Uma execução intermediária de teste isolado concorreu com a suíte LAN pela porta 24560 e falhou. A verificação final do host foi feita sequencialmente, sem conflito, e passou. Não há validação nova entre máquinas/Linux ou autenticação de assento.

## Reserva de assento e recuperação — 16/10/2026

- Validação final: **8 processos aprovados**, incluindo importação, Python, startup, layout, persistência, credenciais e par host/convidado de recuperação. Relatório `.tools/verification/20261016T134709217962Z/results.json`.
- O teste de recuperação encerra a sessão original, elimina a cena do host e abre um **novo processo Godot**, com o mesmo armazenamento local, para retomar o save. O convidado também usa novas instâncias da cena. A reserva privada, o deployment e o estado RNG são conferidos antes da continuação.
- Tentativas sem credencial, com token falso e com comando antes da autenticação são recusadas; o convidado correto reconecta e executa o próximo comando. Provas de um desafio anterior são rejeitadas no teste do módulo. Credenciais locais corrompidas não são sobrescritas.
- Duas execuções direcionadas anteriores aprovaram **11 processos cada**, incluindo rede de demonstração e listas salvas/reenvio de orçamento: `.tools/verification/20261016T134117729873Z/results.json` e `.tools/verification/20261016T134221685940Z/results.json`.
- A execução abrangente aprovou **112 de 113 processos** em `.tools/verification/20261016T134316260986Z/results.json`. O teste de recuperação do host falhou por comparar o snapshot anterior depois que o convidado já havia enviado seu comando seguinte. O teste foi corrigido para aceitar essa ordem válida, ganhou reinício em processo separado e passou na validação final acima. A suíte abrangente não foi repetida após essa correção.
- Verificação gráfica em 1280 × 800: instrução de recuperação e botões de salvar/retomar legíveis. Captura `.tools/session-recovery-ui.png`; log `.tools/session-recovery-qa.log`.
- Escopo: loopback Windows. Não certifica LAN entre máquinas, Linux ou transporte criptografado. Não há contas online nem transferência/redefinição de credenciais na interface.

## Histórico independente de eventos e dados — 16/10/2026

- Suíte completa full + loopback: **114 processos aprovados**, `.tools/verification/20261016T135521745414Z/results.json`.
- Verificação final após ajustes de apresentação/avisos: **6 processos aprovados**, `.tools/verification/20261016T135840931922Z/results.json` (importação, Python, startup, layout, journal e persistência).
- Integração direcionada anterior: **12 processos aprovados**, `.tools/verification/20261016T135421456585Z/results.json`, incluindo treino com listas salvas e recuperação do host em processo novo com consulta autenticada do histórico.
- Journal: mais de 30 eventos preservados, páginas de 20, continuidade de sequência e hashes, reconstrução do estado sem execução das regras, ordem dos D6 preservada, consulta sem consumo RNG, comandos obsoletos sem novos registros, snapshots repetidos sem duplicação.
- Recuperação: snapshot incompatível rejeitado, checksum inválido e histórico corrompido bloqueiam carga sem substituir o jogo atual; cauda posterior ao checkpoint/incompleta continua em arquivo separado, mantendo o original intacto.
- Rede: convidado autorizado consulta páginas sem patches internos ou credenciais; tentativa anterior à autenticação não recebe histórico. O checkpoint e as decisões sobrevivem ao reinício real do processo do host.
- QA gráfica Windows 1280 × 800: `.tools/match-history-ui.png`, `.tools/match-history-qa.log` (**MATCH HISTORY UI: PASS**). Aba, paginação, lista e detalhe dos dados inspecionados.
- Não foram realizados novos testes LAN entre máquinas, Linux, exportação nativa ou replay visual. O laboratório de ataques em cena separada mantém seu próprio RNG e não integra o journal da partida principal.

## Janelas de reação e Insane Bravery — 16/10/2026

- Suíte full + loopback: **119 processos aprovados**, `.tools/verification/20261016T140916046403Z/results.json`, incluindo novo teste local, novo par host/convidado e variante de listas salvas com estratagemas ativados.
- Verificação final após ajustes de hierarquia/feedback e preservação de configuração: **7 processos aprovados**, `.tools/verification/20261016T141223088863Z/results.json` (importação, Python, startup, layout, persistência, partida preparada e estratagemas).
- Cobertos: decisão antes da rolagem; escolha da ordem das unidades; aprovação automática sem RNG; custo de 1 CP; insuficiência de CP; limite por jogador/batalha; unidade em Battle-shock; alvo/jogador incorreto; pedido obsoleto, desconhecido e duplicado; provedor inválido sem confirmação; comandos comuns bloqueados; testes normais restantes; avanço único para Movement e preservação dos CP.
- Save/UI: restauração de janela pendente, limites e CP já gastos; defaults de saves anteriores à opção; configuração fracassada sem substituir a partida em curso; recusa de opção recebida divergente; manifesto/hash e configuração pública das listas preservam a capacidade.
- Rede: convidado reconecta após descarregar/recriar a cena do host e retomar o save ainda na decisão, resolve Insane Bravery e depois o teste normal. O journal registra somente os dois D6 do teste normal, sem cobrança ou dados duplicados. Reinício em novo processo continua coberto pelo teste geral de recuperação de sessão.
- QA gráfica Windows 1280 × 800: `.tools/stratagem-window-ui.png` e `.tools/stratagem-resolved-ui.png`; `.tools/stratagem-qa.log` reporta **STRATAGEM UI: PASS**. Os controles da decisão ficam no topo de Play; o resultado informa CP restantes.
- Fonte lida e inspecionada visualmente: Core Rules 11e, §§01.07, 08.03, 15.01, 15.04, página impressa 56; referência e hash em `docs/core-stratagems.md`. Não foram ativadas habilidades comunitárias provisórias ou outros estratagemas.
- Escopo de plataforma: Windows/loopback. Sem nova validação LAN entre máquinas, Linux ou builds nativos.

## Command Re-roll em avanço/carga — 16/10/2026

- Suíte full + loopback: **126 processos aprovados**, `.tools/verification/20261016T144540141422Z/results.json`.
- Verificação final das guias/interface, opções e compatibilidade: **7 processos aprovados**, `.tools/verification/20261016T144905639660Z/results.json`.
- Integração direcionada anterior: **16 processos aprovados**, `.tools/verification/20261016T144352496199Z/results.json`, incluindo dois pares de recuperação (carga e avanço) e variantes de listas salvas.
- Regras: avanço substitui um D6; carga substitui ambos. Aceitar não consome novos dados nem CP. Resultado pior é obrigatório, uma carga originalmente falhada ainda pode receber re-roll elegível, e nova falha não permite redeclarar a carga da mesma unidade. Limites por jogador/fase e alvo, CP insuficiente, Battle-shock e provedor inválido são tratados. Reset de posições mantém o resultado final e o CP gasto.
- Decisões: jogador/unidade/revisão indevidos, estratagema incompatível com a janela, pedidos duplicados e re-roll tardio são rejeitados. Não há escolha de um único dado da carga pelo cliente. Movimento, alvos e progressão ficam bloqueados durante a decisão. As guias de alcance/hover também aguardam a confirmação.
- Persistência: nova opção possui capability/hash próprios e fica congelada nas listas/manifesto. Configurações antigas sem a opção assumem desativado, inclusive saves com Insane Bravery já ativo; seus hashes continuam válidos. Cliente recusa uma opção recebida divergente.
- Rede: testes de avanço e carga encerram a sessão original, abrem um **novo processo Godot** e retomam o save com a decisão pendente. Após reconectar, somente os dados adicionais esperados são consumidos (2 D6 totais no avanço e 4 D6 totais na carga com re-roll), o CP é debitado uma vez e o estado RNG final corresponde à sequência de referência.
- QA gráfica Windows 1280 × 800: `.tools/advance-reroll-ui.png`, `.tools/advance-rerolled-ui.png`, `.tools/charge-reroll-ui.png`, `.tools/charge-rerolled-ui.png`; log `.tools/movement-reroll-qa.log` (**MOVEMENT REROLL UI: PASS**). Conferidos resultados obrigatórios de 6 → 1 no avanço e [6,6] → [1,1] na carga, com aviso explícito de falha e CP restante.
- Referência: mesmo Core Rules 11e fixado/documentado em `docs/core-stratagems.md`, §15.02. O recurso não habilita re-roll de acertos, ferimentos, defesas, dano, Hazard ou número de ataques. Sem nova validação LAN entre máquinas, Linux ou executáveis nativos.

## Command Re-roll em acertos/ferimentos — 16/10/2026

- Suíte full + loopback: **134 processos executados, 133 aprovados e uma regressão de layout identificada**, `.tools/verification/20261016T150123629433Z/results.json`. O rótulo novo alargava o painel no teste de modelos locais. Foi encurtado sem mudar a regra.
- Verificação posterior à correção: **10 processos aprovados**, `.tools/verification/20261016T150326633450Z/results.json`: importação, Python, startup, checkpoints/integração de re-rolls, layout, modelos locais, save, avanço/carga e estratagemas. A suíte completa não foi repetida após essa correção; o teste que falhou passou nessa bateria final.
- Integração LAN direcionada anterior: **19 processos aprovados**, `.tools/verification/20261016T150002764477Z/results.json`, incluindo checkpoints de acerto e ferimento retomados em novos processos Godot, regressões de movimento/carga e listas salvas. A suíte abrangente também aprovou a nova variante de listas salvas com re-roll de ataques habilitado.
- Motor: 360 comparações com seeds/traits variados confirmam os mesmos resultados e estado RNG do lote original quando não há intervenção. Cobertos Torrent, Heavy, cobertura, Rapid Fire, Blast, Lethal/Sustained Hits, Twin-linked, Devastating Wounds, ataques aleatórios e defesas adiadas. Não são consumidos dados de ferimento/defesa antes de avançar o checkpoint correspondente.
- Integração: escolha de um índice elegível, resultado pior obrigatório, recálculo de efeitos críticos, recusa de dado já re-rolado, custo/limite compartilhado, comandos obsoletos/duplicados/alvo incorreto/índice inválido, provedor inválido sem confirmação, bloqueio da alocação durante a escolha, aceitação gratuita seguida de decisão de ferimento, alocação manual e combate do jogador fora do turno. Sem CP/Battle-shock, o ataque segue sem a janela opcional.
- Save/UI: checkpoints, opções/hash, RNG, journal e limite de uso preservados; opção anterior ausente assume desativada. Configuração pública divergente é recusada. Os testes LAN comparam o estado completo e o RNG após a retomada com uma referência determinística.
- QA gráfica Windows 1280 × 800: `.tools/hit-reroll-ui.png`, `.tools/wound-reroll-ui.png`, `.tools/attack-rerolled-ui.png`; `.tools/attack-reroll-qa.log` reporta **ATTACK REROLL UI: PASS**. Seletor de D6, aviso antes dos dados posteriores, CP e resultado inspecionados.
- Referência: Core Rules 11e fixado em `docs/core-stratagems.md`, §§05 e 15.02. Re-rolls de defesa, dano, Hazardous e número de ataques continuam pendentes. Sem nova validação LAN entre máquinas, Linux ou executáveis nativos.

## Command Re-roll de defesa — 16/10/2026

- Suíte abrangente: **139 processos executados, 138 aprovados e uma falha no cliente do teste antigo da demonstração**, `.tools/verification/20261016T152945864629Z/results.json`. O host atingiu o estado correto; a checagem do cliente usava esperas fixas de 300 ms. O teste passou a aguardar os estados de movimento/fim de turno com prazo limitado, mantendo as mesmas condições de aprovação; o host também aguarda a conclusão e dá tempo para entregar o snapshot final.
- Verificação final após corrigir essa sincronização do teste: **11 processos aprovados**, `.tools/verification/20261016T153533272141Z/results.json`, incluindo o par host/cliente que falhou, defesas, acertos/ferimentos, layout, modelos locais, save e avanço/carga. A suíte inteira não foi repetida depois da alteração exclusiva no teste de rede.
- Integração direcionada: **22 processos aprovados**, `.tools/verification/20261016T152758549599Z/results.json`. Inclui três pares de checkpoints (acerto, ferimento e defesa), recuperação em processo Godot novo, configuração LAN de listas salvas e a nova suíte local de defesas.
- Regressões iniciais: **8 processos aprovados**, `.tools/verification/20261016T152544082956Z/results.json`, cobrindo acertos/ferimentos, alocação, layout/modelos, movimento/carga e estratagemas. O teste de migração de saves anteriores também remove a chave nova para validar o valor padrão desativado.
- A janela pertence ao defensor antes da ordenação dos resultados e de qualquer dano desse lote. Testes confirmam resultado pior obrigatório, preservação das feridas durante a decisão, dano aleatório apenas após selecionar destinatário, aceitação gratuita, somente um uso por jogador/fase e recusa de alvo/jogador/revisão/índice incorretos, duplicatas e provedor inválido sem confirmação de estado/CP.
- Regras: grupos mistos recebem as defesas reordenadas depois da substituição; invulneráveis continuam aplicáveis com AP alto. Devastating Wounds não cria uma janela de save sem dados de defesa. Battle-shock, CP insuficiente e uso anterior pelo defensor suprimem a janela opcional. Os dois jogadores podem gastar Command Re-roll na mesma fase com limites independentes.
- Persistência: capability/hash e opções congeladas, snapshot/RNG exatos após carga local, reserva de assento autenticada e decisão de defesa preservada depois de encerrar o host e abri-lo em **outro processo**. A rede compara o estado completo e o RNG final com uma resolução de referência.
- QA gráfica Windows 1280 × 800: `.tools/save-reroll-ui.png` e `.tools/save-rerolled-ui.png`; `.tools/save-reroll-qa.log` reporta **SAVE REROLL UI: PASS**. Conferidos jogador 2 como decisor no turno do jogador 1, seletor de D6, resultado 6 → 1, CP debitado do defensor e alocação manual com dano D3 ainda não rolado.
- Fonte consultada: Core Rules 11e fixado em `docs/core-stratagems.md`, §§05.03–05.04 e 15.02. Dano, Hazardous e número de ataques ainda não têm Command Re-roll. Escopo da execução: Windows/loopback; sem nova validação entre máquinas, Linux ou executáveis nativos.

## Command Re-roll de dano aleatório — 16/10/2026

- Suíte full + loopback: **144 processos aprovados**, `.tools/verification/20261016T173453794979Z/results.json`.
- Após o ajuste final de identificação visual do laboratório: **7 processos aprovados**, `.tools/verification/20261016T173900703616Z/results.json`; o rótulo permanece visível durante a decisão e o QA gráfico também passou nessa versão.
- Integração direcionada local/LAN: **27 processos aprovados**, `.tools/verification/20261016T173319688725Z/results.json`, com variante de dano 2D3+1 retomada em processo novo do host, regressões de acerto/ferimento/defesa, laboratório e opções das listas salvas.
- Verificação local anterior ao rótulo final: **7 processos aprovados**, `.tools/verification/20261016T173544538992Z/results.json`, incluindo a suíte de dano, layout, modelos locais e save. Verificação local anterior: **6 processos aprovados**, `.tools/verification/20261016T173239908173Z/results.json`, cobrindo também laboratório e migração de opções antigas.
- O destinatário é escolhido antes da rolagem de dano e permanece fixo durante a decisão do atacante. Nenhuma prevenção, redução de feridas ou baixa ocorre antes da escolha. Aceitar não repete os dados nem gasta CP; o resultado novo é obrigatório, inclusive quando pior. Dano fixo, Battle-shock, CP insuficiente e limite consumido seguem sem a janela opcional.
- Cobertos D3 com conversão do D6 bruto, dano com bônus, seleção de um dado em 2D3+2 mantendo os demais/bônus, rejeição de repetição, índices/jogador/alvo/revisão inválidos, resultado inválido e falha posterior de Feel No Pain sem confirmar estado ou CP. A ordem do histórico contém originais, substituição e somente depois prevenção. Devastating Wounds também pausa antes da prevenção mortal.
- O laboratório sintético existente, com rifle D3, aceita a opção na UI e inicia com 2 CP por jogador nesse modo de prática. O laboratório sem a opção preserva sua identidade anterior. Testes reais de UI salvam e retomam a janela, verificando estado e RNG exatos. Não foram introduzidos perfis aleatórios nos exércitos iniciais de dano fixo.
- Rede: o convidado atacante reconecta ao host aberto em outro processo, encontra o mesmo dano/destinatário pendente e usa Command Re-roll uma única vez. Estado completo e RNG final coincidem com uma resolução de referência. A configuração de listas salvas também preserva a nova capacidade.
- QA gráfica Windows 1280 × 800: `.tools/damage-reroll-ui.png` e `.tools/damage-rerolled-ui.png`; `.tools/damage-reroll-qa.log` reporta **DAMAGE REROLL UI: PASS**. Conferidos expressão/total, D6 bruto, destinatário fixo, save/retomada e CP após a decisão.
- Referência: Core Rules 11e fixado em `docs/core-stratagems.md`, §15.02, com resolução de dano/prevenção nos módulos existentes. Hazardous e número de ataques continuam pendentes. Sem nova validação LAN entre máquinas, Linux ou executáveis nativos.

## Command Re-roll de Hazardous de armas — 16/10/2026

- Suíte full + loopback: **149 processos aprovados**, `.tools/verification/20261016T181350194697Z/results.json`. Inclui seleção do segundo dado em lote de duas armas, preservação do primeiro, e abertura da janela somente após a alocação manual dos ataques anteriores.
- Integração direcionada: **31 processos aprovados**, `.tools/verification/20261016T181055293551Z/results.json`, incluindo retomada de Hazardous em outro processo do host, regressões das quatro janelas de ataque anteriores, alocação Hazardous e configuração das listas salvas.
- Verificação local inicial: **7 processos aprovados**, `.tools/verification/20261016T180904617111Z/results.json`, para Hazardous existente, dano, layout/modelos e migração de saves. Nova suíte local inicial: **4 processos aprovados**, `.tools/verification/20261016T181008615544Z/results.json`.
- Janela depois dos ataques e antes de alocação, prevenção e baixas de Hazardous. Escolha de um D6, preservação dos demais, aceitação gratuita sem novos dados, resultado pior obrigatório, recalculação de falhas/consequências e multiplicador de unidades MONSTER/VEHICLE. Um lote sem falhas ainda oferece a decisão quando elegível.
- Bloqueados alocação durante a decisão, jogador/unidade/revisão/índice incorretos, provedor inválido, uso duplicado/tardio e estratagema sem elegibilidade. CP insuficiente, Battle-shock e uso anterior na fase suprimem a janela opcional. A ativação fica pendente até a escolha e suas consequências terminarem.
- Persistência: opção e capability próprias, defaults de saves antigos, dados originais e resultado registrado, RNG/estado exatos ao retomar pela UI e após reiniciar o host em processo novo na LAN. O cliente envia somente o índice, sem valores de dados.
- QA gráfica Windows 1280 × 800: `.tools/hazard-reroll-ui.png` e `.tools/hazard-rerolled-ui.png`; `.tools/hazard-reroll-qa.log` reporta **HAZARDOUS REROLL UI: PASS**. Conferidos plasma supercharge existente no equipamento variado, resultado 6 → 1 obrigatório, CP debitado uma vez e ferida mortal ainda não aplicada.
- Referência local fixada em `docs/core-stratagems.md`: Core Rules 11e §§06.03, 15.02 e 24.15. Escopo: Hazardous de armas. Re-roll de Desperate Escape e de número de ataques continua pendente; sem nova validação entre máquinas, Linux ou executáveis nativos.

## Command Re-roll de número de ataques — 16/10/2026

- Suíte full + loopback: **154 processos aprovados**, `.tools/verification/20261016T183102934430Z/results.json`, incluindo fontes fixas/aleatórias combinadas, bônus de Rapid Fire/Blast, rótulos por fonte e retomada da geração antes dos acertos.
- Integração direcionada: **35 processos aprovados**, `.tools/verification/20261016T182859855977Z/results.json`, incluindo número de ataques 2D3+1 retomado em processo novo do host, regressões de todas as janelas anteriores, opções de listas salvas e testes locais de geração.
- Verificações locais iniciais: **8 processos aprovados**, `.tools/verification/20261016T182652432199Z/results.json`, e **4 processos aprovados**, `.tools/verification/20261016T182754021590Z/results.json`. A suíte de checkpoints agora também compara a geração adiada com os resultados e estado RNG do motor em lote em 360 combinações de seeds/traits, além da comparação anterior sem essa pausa.
- O checkpoint de geração não consome nem revela dados de acerto/ferimento/defesa antes da escolha. A substituição pior (D3+1 de 4 → 2 ataques) é obrigatória. Aceitar é gratuito e preserva a possibilidade de usar Command Re-roll nos acertos se a opção estiver habilitada; os limites por jogador/fase permanecem compartilhados.
- Mapeamento de índice achatado para fonte/posição, expressões com vários dados e bônus fixos preservados, fontes fixas e aleatórias combinadas, Rapid Fire/Blast e Torrent. O seletor identifica modelo e expressão reais da fonte; não usa a contagem máxima do lote como expressão. A fixo não cria a janela. CP insuficiente, Battle-shock e uso anterior suprimem a escolha; revisões/índices/jogador/unidade e provedor inválidos são recusados sem confirmar CP/estado.
- UI/save: o laboratório oferece o perfil sintético random-A de A D3+1 somente com a opção ativa e começa com 2 CP por jogador. O laboratório anterior e as listas iniciais de A fixo ficam preservados. Snapshot e RNG são restaurados exatamente na janela. Rede: convidado reconecta ao host reiniciado, escolhe um dado e termina com estado completo/RNG iguais à referência determinística, sem cobrança ou rolagens repetidas.
- QA gráfica Windows 1280 × 800: `.tools/count-reroll-ui.png` e `.tools/count-rerolled-ui.png`; `.tools/count-reroll-qa.log` reporta **ATTACK COUNT REROLL UI: PASS**. Conferidos A D3+1, total, dado identificado por fonte, acertos ainda não rolados, save/retomada e resultado pior obrigatório.
- Referência: Core Rules 11e §15.02 fixado em `docs/core-stratagems.md`. Desperate Escape continua pendente. Escopo de plataforma: Windows/loopback, sem nova validação entre máquinas, Linux ou executáveis nativos.


