# Salvar e retomar partidas

Na aba de configuração há três ações: **Salvar partida agora**, **Retomar última partida localmente** e **Retomar última partida como host LAN**. Existe um único slot neste computador, em `user://matches/current.save`, separado dos perfis e listas de exército.

O host e o jogo local salvam automaticamente ao publicar uma atualização de estado aceita. O botão manual também inclui o plano de ataque ainda em edição. A seleção LAN de exércitos precisa estar concluída antes de salvar. O convidado não grava sobre a partida do host. A retomada só é permitida fora de uma conexão LAN ativa.

O snapshot preserva tipos nativos, IDs inteiros, deployment, posições, baixas, pontuação, histórico presente no estado, decisões pendentes e o estado de 64 bits do gerador de dados. Carregar não executa novamente os comandos nem rola novamente os dados. Configuração e identidade dos pacotes locais são verificadas antes da substituição do jogo. Arquivos truncados ou com checksum diferente são rejeitados. O formato é versionado, limitado a 16 MiB, não permite desserialização de objetos e grava primeiro em arquivo temporário antes da renomeação.

Para continuar em LAN após fechar o host, use **Retomar última partida como host LAN**. O convidado seleciona o mesmo exercício ou sua lista compatível e usa Join, recebendo o estado restaurado. Na primeira entrada, o host reserva a vaga ao convidado e ele guarda automaticamente uma credencial em `user://matches/guest-seats.save`. Depois disso, Join prova a posse da credencial com HMAC-SHA256 e um desafio aleatório novo, antes de receber snapshots ou poder enviar comandos aceitos. Ao retomar o host, a reserva vem do save; convidado sem credencial ou com prova falsa é recusado. Use o mesmo computador e os mesmos dados locais Godot do convidado original. Os perfis do construtor de listas não são contas de autenticação e compartilham esse armazenamento local. Não compartilhar saves como arquivos confiáveis de terceiros; checksum detecta corrupção acidental e não autentica autoria.

Limites: um slot, sem histórico de versões ou migração entre implementações diferentes. O autosave cobre comandos publicados; alterações apenas no rascunho de ataque exigem o botão manual. O [histórico independente de eventos e dados](match-history.md) registra mudanças e resultados, validando sua correspondência ao snapshot antes de retomar. Falhas de autosave aparecem na configuração e não desfazem o comando aceito. A retomada LAN entre máquinas ainda requer validação manual.


## Escopo da reserva de assento

A identidade da sessão e o token ficam em uma seção privada do save, fora do estado público enviado aos jogadores. O token inicial é entregue na primeira conexão LAN e só é confirmado após a gravação no convidado e a prova de posse. O host grava a reserva antes de liberar comandos quando já existe uma partida salvável. Seleção de listas ainda não concluída não é retomável após reinício. Cada tentativa expira em dez segundos. Repetir uma prova de um desafio anterior não autoriza outra conexão. Falha na gravação impede a admissão e não muda o estado de jogo.

Isso protege a reserva contra convidados sem a credencial; não adiciona criptografia ao transporte ENet, contas online nem autenticação da identidade do servidor. A primeira entrada deve ocorrer na rede LAN de confiança. Não há transferência de credencial/redefinição de vaga na interface: perder o arquivo do convidado impede a recuperação automática. Saves antigos sem reserva continuam carregáveis e reservam a vaga ao primeiro convidado da nova sessão. Reiniciar um exercício ou clicar Host LAN inicia outra sessão; para continuar a antiga, use a ação de retomar.


O save atual referencia um arquivo independente no diretório journals; mantenha ambos ao copiar uma partida. Consulte [histórico persistente](match-history.md) para recuperação de gravações interrompidas, navegação e limites.

