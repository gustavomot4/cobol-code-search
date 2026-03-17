# Execução do Sistema COBOL

Este projeto utiliza **GnuCOBOL** para compilação e execução dos programas.

## Pré-requisitos

Antes de executar o sistema, é necessário ter:

* **WSL (Windows Subsystem for Linux)** instalado
* **Ubuntu ou outra distribuição Linux**
* **GnuCOBOL**

## Instalação do GnuCOBOL

No terminal do Linux (WSL):

```bash
sudo apt update
sudo apt install gnucobol
```

Verifique se instalou corretamente:

```bash
cobc -v
```

---

## Compilar o programa

Para compilar o sistema:

```bash
cobc -x nomePrograma.cob
```

Isso irá gerar o executável do programa.

---

## Executar o sistema

Após compilar, execute:

```bash
./nomePrograma
```

---

## Observação

Para edição do código, recomenda-se utilizar o **VS Code** com a extensão **COBOL Language Support**.
