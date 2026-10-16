# Histórico persistente de partidas

A aba **Histórico** permite consultar eventos, fases, mudanças de posição/ferimentos, resultados de ataques e a ordem dos D6. **Anteriores**, **Próximos** e **Mais recentes** navegam por páginas de até 20 registros. Selecionar um registro mostra seus detalhes. Consultar nunca executa comandos, muda o estado de jogo ou consome o gerador de dados.

O recurso cobre a cena principal de partida, incluindo o treino de alocação. O laboratório de ataques em cena separada não participa desse histórico. O painel resumido de combate continua disponível em Play. O histórico independente preserva os registros que saem das últimas 30 mensagens desse resumo. A sequência dos D6 informa a fase e o jogador ativo; esse jogador não é necessariamente quem tomou a decisão defensiva. Quando o estado possui resultado de ataque consolidado, também aparecem os grupos de acertos, ferimentos, defesas, dano e prevenção disponíveis nesse resultado.

## Gravação e retomada

O host/jogo local grava em `user://matches/journals/<id>.journal`. O save contém a referência ao arquivo e ao trecho confirmado: quantidade de registros, posição final e hash. Cada registro contém sequência, UTC, hash anterior, mudanças do estado público e hash do estado resultante. Os registros são binários com tamanho e checksum; não permitem desserialização de objetos.

O histórico é gravado antes da substituição do save. Na retomada, a aplicação verifica o trecho confirmado e reconstrói seus dados para compará-los ao snapshot, sem chamar o núcleo de regras nem rolar dados. O estado RNG continua vindo do save. Snapshots repetidos e reconexões sem mudança não geram eventos duplicados.

Se houver registros posteriores ao trecho confirmado (por exemplo, queda antes de substituir o save), a retomada copia apenas o trecho confirmado para outro arquivo e continua nele. O arquivo original permanece preservado, inclusive sua cauda incompleta. Esses registros posteriores não são aplicados à partida retomada. Corrupção ou ausência dentro do trecho confirmado bloqueia o carregamento sem substituir a partida atual.

Para transferir um salvamento, preserve também o arquivo de histórico referenciado, no diretório `journals`. Saves antigos sem referência continuam carregáveis; seu histórico começa no estado disponível ao retomar, sem inventar dados anteriores. O arquivo de credenciais do convidado continua separado.

## LAN e limites

O convidado consulta páginas fornecidas pelo host após a autenticação do assento. Essas páginas contêm informações públicas para leitura; não incluem as credenciais, o RNG ou os patches internos completos. O convidado não grava o journal do host. Reabra a aba ou use **Mais recentes** para atualizar a consulta.

Limites atuais: 64 MiB por arquivo, 2 MiB por registro; ao atingir o limite, a falha aparece na configuração e no histórico, o estado em memória continua disponível e o último save confirmado permanece intacto. Arquivos de partidas anteriores não são apagados automaticamente. Não há compactação, gerenciador de arquivos antigos, replay visual do tabuleiro nem comandos de desfazer. Hashes detectam inconsistência/corrupção e não certificam a honestidade do host.

A verificação cobre Windows/loopback; testes entre máquinas e sistemas continuam parte do marco de distribuição.

