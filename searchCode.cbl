      *================================================================*
      * PROGRAMA  : LE-FONTE-COBOL                                     *
      * DESCRICAO : LE UM ARQUIVO FONTE COBOL E EXIBE 3 LINHAS         *
      * VERSAO    : 2.0 - CORRECAO DA LEITURA DE ARQUIVO TEXTO         *
      *                                                                 *
      * CAUSA DO BUG ANTERIOR:                                         *
      *   RECORDING MODE IS F + PIC X(80) lia blocos fixos de 80       *
      *   bytes do arquivo, ignorando completamente os caracteres de    *
      *   quebra de linha (\n). Resultado: o conteudo de varias         *
      *   linhas era misturado em um unico registro.                    *
      *                                                                 *
      * CORRECAO APLICADA:                                              *
      *   ORGANIZATION IS LINE SEQUENTIAL faz com que cada READ        *
      *   leia exatamente ate o proximo \n, preservando as linhas.      *
      *================================================================*
       IDENTIFICATION DIVISION.
       PROGRAM-ID.   LE-FONTE-COBOL.
       AUTHOR.       DESENVOLVEDOR.
       DATE-WRITTEN. 2026-03-17.

      *----------------------------------------------------------------*
      * ENVIRONMENT DIVISION                                            *
      *                                                                 *
      * MUDANCA CRITICA: ORGANIZATION IS LINE SEQUENTIAL               *
      *   - Instrui o runtime COBOL a usar o caractere de nova linha    *
      *     (\n no Linux, \r\n no Windows) como delimitador de cada     *
      *     registro.                                                   *
      *   - Cada READ avanca ate o proximo \n, lendo uma linha inteira. *
      *   - Esta e a organizacao correta para arquivos texto (.cbl,     *
      *     .txt, .csv, etc).                                           *
      *                                                                 *
      * POR QUE NAO USAR SEQUENTIAL AQUI?                              *
      *   SEQUENTIAL (padrao) e para arquivos binarios ou de tamanho   *
      *   fixo onde o comprimento do registro e determinado pela        *
      *   clausula PIC no FD, nao por um delimitador.                   *
      *----------------------------------------------------------------*
       ENVIRONMENT DIVISION.
       INPUT-OUTPUT SECTION.
       FILE-CONTROL.
           SELECT ARQ-ENTRADA ASSIGN TO 'IMC.cbl'
               ORGANIZATION  IS LINE SEQUENTIAL
               FILE STATUS   IS WS-STATUS-ARQ.

      *----------------------------------------------------------------*
      * DATA DIVISION                                                   *
      *                                                                 *
      * MUDANCAS NO FILE DESCRIPTOR (FD):                              *
      *                                                                 *
      * 1. REMOVIDO: RECORDING MODE IS F                               *
      *    - MODE F (Fixed) define registros de tamanho fixo e e       *
      *      incompativel com LINE SEQUENTIAL. Ao usar MODE F,         *
      *      o COBOL lia exatamente 80 bytes do disco, sem se          *
      *      importar com \n. Isso causava o problema relatado.        *
      *    - Com LINE SEQUENTIAL, o tamanho do registro e variavel e   *
      *      determinado pela posicao do proximo \n no arquivo.        *
      *                                                                 *
      * 2. REMOVIDO: BLOCK CONTAINS 0 RECORDS                         *
      *    - Esta clausula e para arquivos em fita magnetica ou com     *
      *      bloqueio fisico de registros. Nao se aplica a arquivos    *
      *      texto modernos.                                            *
      *                                                                 *
      * 3. MANTIDO: PIC X(80)                                          *
      *    - Define o tamanho MAXIMO do buffer de recepcao.            *
      *    - Se a linha do arquivo tiver menos de 80 chars, o restante *
      *      do buffer e preenchido com espacos automaticamente.       *
      *    - 80 colunas e o padrao historico do formato COBOL.         *
      *----------------------------------------------------------------*
       DATA DIVISION.

       FILE SECTION.
       FD  ARQ-ENTRADA.
       01  REG-LINHA-FONTE        PIC X(80).

       WORKING-STORAGE SECTION.

      * --- CONTROLE DE STATUS DO ARQUIVO ---
      *
      *     BOAS PRATICAS: Sempre declarar FILE STATUS e verificar
      *     apos OPEN, READ e CLOSE. Codigos importantes:
      *       '00' = operacao bem-sucedida
      *       '10' = fim de arquivo (AT END)
      *       '35' = arquivo nao encontrado
      *       '41' = arquivo ja estava aberto
      *       '42' = arquivo nao estava aberto
       01  WS-CONTROLE-ARQUIVO.
           05  WS-STATUS-ARQ      PIC X(02) VALUE SPACES.
               88  ARQ-OK              VALUE '00'.
               88  ARQ-FIM-DE-ARQUIVO  VALUE '10'.
               88  ARQ-NAO-ENCONTRADO  VALUE '35'.
           05  WS-CONTADOR-LINHA  PIC 9(04) VALUE ZEROS.

      * --- LINHAS-ALVO: DEFINA AQUI QUAIS LINHAS DESEJA CAPTURAR ---
       01  WS-LINHAS-ALVO.
           05  WS-ALVO-1          PIC 9(04).
           05  WS-ALVO-2          PIC 9(04).
           05  WS-ALVO-3          PIC 9(04).

      * --- BUFFER PARA ARMAZENAR AS 3 LINHAS CAPTURADAS ---
       01  WS-BUFFER-SAIDA.
           05  WS-LINHA-1         PIC X(80) VALUE SPACES.
           05  WS-LINHA-2         PIC X(80) VALUE SPACES.
           05  WS-LINHA-3         PIC X(80) VALUE SPACES.

      * --- FLAGS DE CONTROLE ---
       01  WS-FLAGS.
           05  WS-FIM-LEITURA     PIC X(01) VALUE 'N'.
               88  CONTINUAR-LENDO     VALUE 'N'.
               88  PARAR-LEITURA       VALUE 'S'.

      * --- MENSAGENS DE SAIDA ---
       01  WS-MSGS.
           05  WS-SEP             PIC X(50)
            VALUE '=================================================='.
           05  WS-TITULO          PIC X(50)
               VALUE 'RESULTADO: 3 LINHAS EXTRAIDAS DO ARQUIVO COBOL'.

      *----------------------------------------------------------------*
      * PROCEDURE DIVISION                                              *
      *----------------------------------------------------------------*
       PROCEDURE DIVISION.

           DISPLAY 'DIGITE AS LINHAS QUE DESEJA CAPTURAR: '.
           DISPLAY ''.
           DISPLAY 'PRIMEIRA LINHA: '.
           ACCEPT WS-ALVO-1.
           DISPLAY 'SEGUNDA LINHA: '.
           ACCEPT WS-ALVO-2.
           DISPLAY 'TERCEIRA LINHA: '.
           ACCEPT WS-ALVO-3.


       0000-PRINCIPAL.
           PERFORM 1000-ABRIR-ARQUIVO
           PERFORM 2000-LER-E-PROCESSAR
               UNTIL PARAR-LEITURA
           PERFORM 3000-EXIBIR-RESULTADO
           PERFORM 9000-ENCERRAR
           STOP RUN.

      *----------------------------------------------------------------*
      * 1000-ABRIR-ARQUIVO                                              *
      *   Abre o arquivo e realiza a primeira leitura (priming read).   *
      *   O padrao "priming read" e uma boa pratica: faz o primeiro     *
      *   READ logo apos o OPEN para que o loop principal sempre        *
      *   processe um registro ja disponivel, simplificando o fluxo.    *
      *----------------------------------------------------------------*
       1000-ABRIR-ARQUIVO.
           OPEN INPUT ARQ-ENTRADA

           EVALUATE TRUE
               WHEN ARQ-OK
                   PERFORM 1100-LER-PROXIMA-LINHA
               WHEN ARQ-NAO-ENCONTRADO
                   DISPLAY 'ERRO: ARQUIVO NAO ENCONTRADO.'
                   MOVE 'S' TO WS-FIM-LEITURA
               WHEN OTHER
                   DISPLAY 'ERRO AO ABRIR. STATUS: ' WS-STATUS-ARQ
                   MOVE 'S' TO WS-FIM-LEITURA
           END-EVALUATE.

      *----------------------------------------------------------------*
      * 1100-LER-PROXIMA-LINHA                                          *
      *   Usa READ ... INTO para separar o buffer do FD da WORKING-     *
      *   STORAGE. Boa pratica: o FD (REG-LINHA-FONTE) fica como area   *
      *   de transito; WS e onde o dado e realmente manipulado.         *
      *----------------------------------------------------------------*
       1100-LER-PROXIMA-LINHA.
           READ ARQ-ENTRADA INTO REG-LINHA-FONTE
               AT END
                   MOVE 'S' TO WS-FIM-LEITURA
               NOT AT END
                   ADD 1 TO WS-CONTADOR-LINHA
           END-READ.

      *----------------------------------------------------------------*
      * 2000-LER-E-PROCESSAR                                            *
      *   Para cada linha lida, verifica se e uma das linhas-alvo e     *
      *   a armazena no buffer correspondente.                           *
      *----------------------------------------------------------------*
       2000-LER-E-PROCESSAR.
           EVALUATE WS-CONTADOR-LINHA
               WHEN WS-ALVO-1
                   MOVE REG-LINHA-FONTE TO WS-LINHA-1
               WHEN WS-ALVO-2
                   MOVE REG-LINHA-FONTE TO WS-LINHA-2
               WHEN WS-ALVO-3
                   MOVE REG-LINHA-FONTE TO WS-LINHA-3
                   MOVE 'S'             TO WS-FIM-LEITURA
           END-EVALUATE

           IF CONTINUAR-LENDO
               PERFORM 1100-LER-PROXIMA-LINHA
           END-IF.

      *----------------------------------------------------------------*
      * 3000-EXIBIR-RESULTADO                                           *
      *----------------------------------------------------------------*
       3000-EXIBIR-RESULTADO.
           DISPLAY WS-SEP
           DISPLAY WS-TITULO
           DISPLAY WS-SEP
           DISPLAY 'LINHA ' WS-ALVO-1 ': ' WS-LINHA-1
           DISPLAY 'LINHA ' WS-ALVO-2 ': ' WS-LINHA-2
           DISPLAY 'LINHA ' WS-ALVO-3 ': ' WS-LINHA-3
           DISPLAY WS-SEP.

      *----------------------------------------------------------------*
      * 9000-ENCERRAR                                                   *
      *----------------------------------------------------------------*
       9000-ENCERRAR.
           CLOSE ARQ-ENTRADA
           IF NOT ARQ-OK
               DISPLAY 'AVISO: ERRO AO FECHAR. STATUS: ' WS-STATUS-ARQ
           END-IF.