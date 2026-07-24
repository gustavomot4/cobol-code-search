# 🔎 COBOL Search & Replace

Prova de conceito desenvolvida em ambiente profissional: um programa **COBOL que lê o código-fonte de outro programa COBOL**, localiza trechos dentro dele, aplica alterações e grava o resultado como um fonte novo.

O problema por trás é típico de manutenção de sistemas legados — em bases COBOL grandes, localizar e alterar um trecho repetido em vários fontes é trabalho manual, lento e sujeito a erro. A PoC valida que a própria linguagem consegue fazer essa varredura e edição, sem depender de ferramenta externa nem de tooling moderno no ambiente.

<!-- TODO: uma frase sobre o contexto real — que necessidade da equipe originou a PoC e qual foi o desfecho (virou ferramenta interna? ficou como estudo de viabilidade?). É isso que transforma o repositório em experiência profissional demonstrável. -->

---

## 🧩 Como funciona

| Arquivo | Papel |
| --- | --- |
| `searchCode.cbl` | **O motor.** Abre um fonte `.cbl` como arquivo de entrada, varre linha a linha, localiza o trecho informado, aplica a alteração e grava a saída |
| `IMC.cbl` | **Entrada (dummy).** Programa de cálculo de IMC usado como fonte de teste — código neutro, sem nada proprietário da empresa |
| `TEMP-EDICAO.cbl` | **Saída.** O `IMC.cbl` já alterado pelo programa — resultado gerado, mantido no repositório como exemplo do que a PoC produz |

O ponto central: o `searchCode` trata o arquivo `.cbl` como **dado, não como programa**. Lê o fonte sequencialmente, compara cada linha com o padrão buscado e escreve a versão alterada em um arquivo de saída, preservando o original intacto.

```
IMC.cbl  ──▶  searchCode  ──▶  TEMP-EDICAO.cbl
(entrada)      (busca e         (saída alterada)
                altera)
```

<!-- TODO: descreva o critério de busca e a alteração aplicada — qual trecho ele procura no IMC.cbl e o que substitui? -->

---

## 📋 Pré-requisitos

- **GnuCOBOL** (a PoC roda sobre WSL ou Linux)

```bash
sudo apt update
sudo apt install gnucobol
cobc -v          # confirma a instalação
```

---

## ▶️ Como executar

```bash
cobc -x searchCode.cbl   # compila o motor
./searchCode             # executa: lê IMC.cbl e gera TEMP-EDICAO.cbl
```

O fonte de entrada (`IMC.cbl`) precisa estar no mesmo diretório. A saída é gravada como `TEMP-EDICAO.cbl` — o original nunca é sobrescrito.

Para conferir que a saída continua sendo COBOL válido, basta compilá-la:

```bash
cobc -x TEMP-EDICAO.cbl
./TEMP-EDICAO
```

Esse é, na prática, o critério de aceite da PoC: o fonte gerado tem que compilar e rodar.

---

## 💡 Ambiente

**VS Code** com a extensão **COBOL Language Support** — destaque de sintaxe e navegação no fonte.
