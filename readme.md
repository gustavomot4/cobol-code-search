# 🔎 COBOL Code Search

Prova de conceito desenvolvida em ambiente profissional: um programa **COBOL que lê o código-fonte de outro programa COBOL** e localiza trechos dentro dele.

O problema por trás é típico de manutenção de sistemas legados — em bases COBOL grandes, encontrar onde um trecho, uma variável ou uma rotina aparece no fonte é trabalho manual e caro. A PoC valida que a própria linguagem consegue fazer essa varredura, sem depender de ferramenta externa.

<!-- TODO: uma frase sobre o contexto real — que necessidade da equipe originou a PoC e qual foi o desfecho (virou ferramenta interna? ficou como estudo de viabilidade?). É isso que transforma o repositório em experiência profissional demonstrável. -->

---

## 🧩 Como funciona

| Arquivo | Papel |
| --- | --- |
| `searchCode.cbl` | **O buscador.** Abre um fonte `.cbl` como arquivo de entrada e varre linha a linha procurando o trecho informado |
| `IMC.cbl` | **O alvo da busca.** Programa de cálculo de IMC usado como fonte de teste — código neutro, sem nada proprietário |
| `TEMP-EDICAO.cbl` | <!-- TODO: descreva o papel deste arquivo (segundo alvo de teste? variação com cláusulas de edição?) --> |

O `searchCode` trata o arquivo `.cbl` como dado, não como programa: lê o fonte sequencialmente e compara cada linha com o padrão buscado.

<!-- TODO: descreva o que o programa devolve — número da linha, a linha inteira, contagem de ocorrências? -->

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
cobc -x searchCode.cbl   # compila o buscador
./searchCode             # executa e informa o trecho a procurar
```

O programa alvo (`IMC.cbl`) precisa estar no mesmo diretório para ser lido.

Para rodar o alvo isoladamente e ver o que ele faz:

```bash
cobc -x IMC.cbl
./IMC
```

---

## 💡 Ambiente

**VS Code** com a extensão **COBOL Language Support** — destaque de sintaxe e navegação no fonte.
