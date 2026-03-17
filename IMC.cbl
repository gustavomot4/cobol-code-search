       IDENTIFICATION DIVISION.
       PROGRAM-ID. IMC.
       AUTHOR. Gustavo Mota.

       ENVIRONMENT DIVISION.

       DATA DIVISION.
       WORKING-STORAGE SECTION.
           
       01 PESO PIC 999V99.
       01 ALTURA PIC 9V99.
       01 IMC PIC 99V99.

       PROCEDURE DIVISION.
            
            DISPLAY "DIGITE SEU PESO: ".
            ACCEPT PESO.

            DISPLAY "DIGITE SUA ALTURA:".
            ACCEPT ALTURA.

            COMPUTE IMC = PESO / (ALTURA ** 2).
            DISPLAY "SEU IMC É: " IMC.

            STOP RUN.
        END PROGRAM IMC.


           