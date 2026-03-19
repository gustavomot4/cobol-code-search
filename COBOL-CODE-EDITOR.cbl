      *================================================================*
      * PROGRAMA  : COBOL-CODE-EDITOR                                  *
      * DESCRICAO : LE, EXIBE, EDITA E REGRAVA 3 LINHAS DE UM ARQUIVO  *
      *================================================================*

       IDENTIFICATION DIVISION.
       PROGRAM-ID.   COBOL-CODE-EDITOR.
       AUTHOR.       Gustavo Mota.
       DATE-WRITTEN. 2026-03-17.

      *----------------------------------------------------------------*
      * ENVIRONMENT DIVISION                                            *
      * Dois arquivos declarados:                                       *
      *   ARQ-ORIGINAL : arquivo de entrada (somente leitura)           *
      *   ARQ-TEMP     : arquivo de saida temporario (escrita)          *
      * Ambos usam LINE SEQUENTIAL para preservar quebras de linha.     *
      *----------------------------------------------------------------*
       ENVIRONMENT DIVISION.
       INPUT-OUTPUT SECTION.
       FILE-CONTROL.

           SELECT ARQ-ORIGINAL ASSIGN TO WS-NOME-ORIGINAL
               ORGANIZATION  IS LINE SEQUENTIAL
               FILE STATUS   IS WS-STATUS-ORIGINAL.

           SELECT ARQ-TEMP     ASSIGN TO WS-NOME-TEMP
               ORGANIZATION  IS LINE SEQUENTIAL
               FILE STATUS   IS WS-STATUS-TEMP.

      *----------------------------------------------------------------*
      * DATA DIVISION                                                   *
      *----------------------------------------------------------------*
       DATA DIVISION.

       FILE SECTION.

       FD  ARQ-ORIGINAL.
       01  REG-LINHA-ORIGINAL     PIC X(80).

       FD  ARQ-TEMP.
       01  REG-LINHA-TEMP         PIC X(80).

       WORKING-STORAGE SECTION.

      * --- NOMES DOS ARQUIVOS ---
       01  WS-NOMES-ARQUIVOS.
           05  WS-NOME-ORIGINAL   PIC X(50)
               VALUE 'examples/IMC-EXAMPLES.cbl'.
           05  WS-NOME-TEMP       PIC X(50)
               VALUE 'TEMP-EDICAO.cbl'.

      * --- STATUS DOS DOIS ARQUIVOS ---
      *     Codigos: '00' OK | '10' FIM DE ARQ | '35' NAO ENCONTRADO
       01  WS-STATUS-ARQUIVOS.
           05  WS-STATUS-ORIGINAL PIC X(02) VALUE SPACES.
               88  ORIG-OK             VALUE '00'.
               88  ORIG-FIM            VALUE '10'.
               88  ORIG-NAO-EXISTE     VALUE '35'.
           05  WS-STATUS-TEMP     PIC X(02) VALUE SPACES.
               88  TEMP-OK             VALUE '00'.

      * --- CONTROLE DE LINHA ---
       01  WS-CONTROLE.
           05  WS-CONTADOR-LINHA  PIC 9(04) VALUE ZEROS.
           05  WS-FIM-LEITURA     PIC X(01) VALUE 'N'.
               88  CONTINUAR-LENDO     VALUE 'N'.
               88  PARAR-LEITURA       VALUE 'S'.

      * --- DEFINICAO DAS LINHAS-ALVO ---
       01  WS-ALVOS.
           05  WS-ALVO-1          PIC 9(04).
           05  WS-ALVO-2          PIC 9(04).
           05  WS-ALVO-3          PIC 9(04).

      * --- BUFFER DAS LINHAS ORIGINAIS CAPTURADAS ---
       01  WS-LINHAS-ORIGINAIS.
           05  WS-ORIG-1          PIC X(80) VALUE SPACES.               
           05  WS-ORIG-2          PIC X(80) VALUE SPACES.
           05  WS-ORIG-3          PIC X(80) VALUE SPACES.

      * --- BUFFER DAS LINHAS NOVAS INFORMADAS PELO USUARIO ---
       01  WS-LINHAS-NOVAS.
           05  WS-NOVA-1          PIC X(80) VALUE SPACES.
           05  WS-NOVA-2          PIC X(80) VALUE SPACES.
           05  WS-NOVA-3          PIC X(80) VALUE SPACES.

      * --- AUXILIAR PARA REESCRITA ---
       01  WS-LINHA-A-GRAVAR      PIC X(80) VALUE SPACES.

      * --- SEPARADORES VISUAIS ---
       01  WS-VISUAIS.
           05  WS-SEP             PIC X(55) VALUE
            '======================================================='.
           05  WS-SEP2            PIC X(55) VALUE
            '-------------------------------------------------------'.

      *----------------------------------------------------------------*
      * PROCEDURE DIVISION                                              *
      *                                                                 *
      * Fluxo principal:                                                *
      *   1000 -> Abrir e ler o arquivo original                        *
      *   2000 -> Coletar novas linhas do usuario                       *
      *   3000 -> Regravar o arquivo com as substituicoes               *
      *   4000 -> Confirmar resultado ao usuario                        *
      *   9000 -> Encerrar                                              *
      *----------------------------------------------------------------*
       PROCEDURE DIVISION.

           DISPLAY 'INFORME A LINHA QUE DESEJA EDITAR'.
           ACCEPT WS-ALVO-1.
           DISPLAY 'INFORME A LINHA QUE DESEJA EDITAR'.
           ACCEPT WS-ALVO-2.
           DISPLAY 'INFORME A LINHA QUE DESEJA EDITAR'.
           ACCEPT WS-ALVO-3.

       0000-PRINCIPAL.
           PERFORM 1000-FASE-LEITURA
           IF CONTINUAR-LENDO OR PARAR-LEITURA
               CONTINUE
           END-IF
           PERFORM 2000-FASE-COLETA
           PERFORM 3000-FASE-REESCRITA
           PERFORM 4000-CONFIRMAR-RESULTADO
           PERFORM 9000-ENCERRAR
           STOP RUN.

      *================================================================*
      *  FASE 1 — LEITURA: abre o original e exibe as 3 linhas-alvo    *
      *================================================================*
       1000-FASE-LEITURA.
           DISPLAY WS-SEP
           DISPLAY ' FASE 1: LENDO O ARQUIVO ORIGINAL'
           DISPLAY WS-SEP

           OPEN INPUT ARQ-ORIGINAL

           EVALUATE TRUE
               WHEN ORIG-NAO-EXISTE
                   DISPLAY 'ERRO: ARQUIVO NAO ENCONTRADO: '
                       WS-NOME-ORIGINAL
                   STOP RUN
               WHEN NOT ORIG-OK
                   DISPLAY 'ERRO AO ABRIR ORIGINAL. STATUS: '
                       WS-STATUS-ORIGINAL
                   STOP RUN
           END-EVALUATE

           MOVE 'N' TO WS-FIM-LEITURA
           MOVE  0  TO WS-CONTADOR-LINHA

           PERFORM 1100-LER-LINHA

           PERFORM 1200-CAPTURAR-ALVOS
               UNTIL PARAR-LEITURA

           CLOSE ARQ-ORIGINAL

           DISPLAY ' '
           DISPLAY ' LINHAS SELECIONADAS DO ARQUIVO:'
           DISPLAY WS-SEP2
           DISPLAY ' LINHA ' WS-ALVO-1 ': ' WS-ORIG-1
           DISPLAY ' LINHA ' WS-ALVO-2 ': ' WS-ORIG-2
           DISPLAY ' LINHA ' WS-ALVO-3 ': ' WS-ORIG-3
           DISPLAY WS-SEP.

      *----------------------------------------------------------------*
      * 1100-LER-LINHA: leitura de um unico registro com limpeza previa*
      *----------------------------------------------------------------*
       1100-LER-LINHA.
           MOVE SPACES TO REG-LINHA-ORIGINAL
           READ ARQ-ORIGINAL INTO REG-LINHA-ORIGINAL
               AT END
                   MOVE 'S' TO WS-FIM-LEITURA
               NOT AT END
                   ADD 1 TO WS-CONTADOR-LINHA
           END-READ.

      *----------------------------------------------------------------*
      * 1200-CAPTURAR-ALVOS: identifica e armazena as 3 linhas-alvo    *
      *----------------------------------------------------------------*
       1200-CAPTURAR-ALVOS.
           EVALUATE WS-CONTADOR-LINHA
               WHEN WS-ALVO-1
                   MOVE REG-LINHA-ORIGINAL TO WS-ORIG-1
               WHEN WS-ALVO-2
                   MOVE REG-LINHA-ORIGINAL TO WS-ORIG-2
               WHEN WS-ALVO-3
                   MOVE REG-LINHA-ORIGINAL TO WS-ORIG-3
           END-EVALUATE

           IF WS-CONTADOR-LINHA >= WS-ALVO-3
               MOVE 'S' TO WS-FIM-LEITURA
           END-IF

           IF CONTINUAR-LENDO
               PERFORM 1100-LER-LINHA
           END-IF.

      *================================================================*
      *  FASE 2 — COLETA: recebe do usuario o novo conteudo de cada    *
      *  linha. O usuario pode pressionar ENTER para manter o original. *
      *================================================================*
       2000-FASE-COLETA.
           DISPLAY WS-SEP
           DISPLAY ' FASE 2: INFORME O NOVO CONTEUDO DAS LINHAS'
           DISPLAY ' (PRESSIONE ENTER EM BRANCO PARA MANTER ORIGINAL)'
           DISPLAY WS-SEP

           PERFORM 2100-COLETAR-LINHA-1
           PERFORM 2200-COLETAR-LINHA-2
           PERFORM 2300-COLETAR-LINHA-3

           DISPLAY WS-SEP
           DISPLAY ' CONFIRMACAO DAS NOVAS LINHAS:'
           DISPLAY WS-SEP2
           DISPLAY ' LINHA ' WS-ALVO-1 ': ' WS-NOVA-1
           DISPLAY ' LINHA ' WS-ALVO-2 ': ' WS-NOVA-2
           DISPLAY ' LINHA ' WS-ALVO-3 ': ' WS-NOVA-3
           DISPLAY WS-SEP.

       2100-COLETAR-LINHA-1.
           DISPLAY ' '
           DISPLAY ' LINHA ' WS-ALVO-1 ' ATUAL    : [' WS-ORIG-1 ']'
           DISPLAY ' NOVO CONTEUDO LINHA ' WS-ALVO-1 ': '
           ACCEPT WS-NOVA-1
           IF WS-NOVA-1 = SPACES
               MOVE WS-ORIG-1 TO WS-NOVA-1
               DISPLAY ' (MANTIDO CONTEUDO ORIGINAL)'
           END-IF.

       2200-COLETAR-LINHA-2.
           DISPLAY ' '
           DISPLAY ' LINHA ' WS-ALVO-2 ' ATUAL    : [' WS-ORIG-2 ']'
           DISPLAY ' NOVO CONTEUDO LINHA ' WS-ALVO-2 ': '
           ACCEPT WS-NOVA-2
           IF WS-NOVA-2 = SPACES
               MOVE WS-ORIG-2 TO WS-NOVA-2
               DISPLAY ' (MANTIDO CONTEUDO ORIGINAL)'
           END-IF.

       2300-COLETAR-LINHA-3.
           DISPLAY ' '
           DISPLAY ' LINHA ' WS-ALVO-3 ' ATUAL    : [' WS-ORIG-3 ']'
           DISPLAY ' NOVO CONTEUDO LINHA ' WS-ALVO-3 ': '
           ACCEPT WS-NOVA-3
           IF WS-NOVA-3 = SPACES
               MOVE WS-ORIG-3 TO WS-NOVA-3
               DISPLAY ' (MANTIDO CONTEUDO ORIGINAL)'
           END-IF.

      *================================================================*
      *  FASE 3 — REESCRITA: percorre o arquivo original do inicio,    *
      *  grava cada linha no temporario. Ao encontrar uma linha-alvo,   *
      *  substitui pelo novo conteudo informado pelo usuario.           *
      *================================================================*
       3000-FASE-REESCRITA.
           DISPLAY WS-SEP
           DISPLAY ' FASE 3: REESCREVENDO O ARQUIVO...'
           DISPLAY WS-SEP

           MOVE 'N' TO WS-FIM-LEITURA
           MOVE  0  TO WS-CONTADOR-LINHA

           OPEN INPUT  ARQ-ORIGINAL
           OPEN OUTPUT ARQ-TEMP

           IF NOT ORIG-OK
               DISPLAY 'ERRO AO REABRIR ORIGINAL: ' WS-STATUS-ORIGINAL
               STOP RUN
           END-IF
           IF NOT TEMP-OK
               DISPLAY 'ERRO AO ABRIR TEMPORARIO: ' WS-STATUS-TEMP
               STOP RUN
           END-IF

           PERFORM 1100-LER-LINHA

           PERFORM 3100-COPIAR-COM-SUBSTITUICAO
               UNTIL PARAR-LEITURA

           CLOSE ARQ-ORIGINAL
           CLOSE ARQ-TEMP

           DISPLAY ' REESCRITA CONCLUIDA. ARQUIVO GERADO: '
               WS-NOME-TEMP.

      *----------------------------------------------------------------*
      * 3100-COPIAR-COM-SUBSTITUICAO                                    *
      *   Para cada linha lida:                                         *
      *     - Se for linha-alvo  -> grava o NOVO conteudo               *
      *     - Se nao for alvo    -> grava a linha original sem alteracao *
      *----------------------------------------------------------------*
       3100-COPIAR-COM-SUBSTITUICAO.
           EVALUATE WS-CONTADOR-LINHA
               WHEN WS-ALVO-1
                   MOVE WS-NOVA-1 TO WS-LINHA-A-GRAVAR
               WHEN WS-ALVO-2
                   MOVE WS-NOVA-2 TO WS-LINHA-A-GRAVAR
               WHEN WS-ALVO-3
                   MOVE WS-NOVA-3 TO WS-LINHA-A-GRAVAR
               WHEN OTHER
                   MOVE REG-LINHA-ORIGINAL TO WS-LINHA-A-GRAVAR
           END-EVALUATE

           WRITE REG-LINHA-TEMP FROM WS-LINHA-A-GRAVAR

           IF NOT TEMP-OK
               DISPLAY 'ERRO AO GRAVAR LINHA ' WS-CONTADOR-LINHA
                   '. STATUS: ' WS-STATUS-TEMP
               STOP RUN
           END-IF

           PERFORM 1100-LER-LINHA.

      *================================================================*
      *  FASE 4 — CONFIRMACAO: rele o arquivo gerado e exibe as 3      *
      *  linhas para o usuario confirmar que a edicao foi correta.      *
      *================================================================*
       4000-CONFIRMAR-RESULTADO.
           DISPLAY WS-SEP
           DISPLAY ' FASE 4: VERIFICANDO ARQUIVO GERADO'
           DISPLAY WS-SEP

           MOVE WS-NOME-TEMP TO WS-NOME-ORIGINAL

           MOVE 'N' TO WS-FIM-LEITURA
           MOVE  0  TO WS-CONTADOR-LINHA
           MOVE SPACES TO WS-ORIG-1
           MOVE SPACES TO WS-ORIG-2
           MOVE SPACES TO WS-ORIG-3

           OPEN INPUT ARQ-ORIGINAL

           PERFORM 1100-LER-LINHA

           PERFORM 1200-CAPTURAR-ALVOS
               UNTIL PARAR-LEITURA

           CLOSE ARQ-ORIGINAL

           DISPLAY ' '
           DISPLAY ' CONTEUDO FINAL DAS LINHAS NO ARQUIVO GERADO:'
           DISPLAY WS-SEP2
           DISPLAY ' LINHA ' WS-ALVO-1 ': ' WS-ORIG-1
           DISPLAY ' LINHA ' WS-ALVO-2 ': ' WS-ORIG-2
           DISPLAY ' LINHA ' WS-ALVO-3 ': ' WS-ORIG-3
           DISPLAY WS-SEP
           DISPLAY ' EDICAO CONCLUIDA COM SUCESSO!'
           DISPLAY ' ARQUIVO DE SAIDA: ' WS-NOME-TEMP
           DISPLAY WS-SEP.

      *================================================================*
      *  9000 — ENCERRAR                                                *
      *================================================================*
       9000-ENCERRAR.
           DISPLAY ' PROGRAMA ENCERRADO NORMALMENTE.'.
           STOP RUN.
       END PROGRAM COBOL-CODE-EDITOR.
