# license_conflicts

**license_conflicts** detecta incompatibilidades de licenças de software entre um projeto e suas dependências. Ele identifica a licença do projeto, verifica as licenças de todas as dependências utilizando o [LicenseFinder](https://github.com/pivotal/LicenseFinder) e reporta quaisquer conflitos encontrados.

---

## Índice

- [Como Funciona](#como-funciona)
- [Linguagens Suportadas](#linguagens-suportadas)
- [Requisitos](#requisitos)
- [Instalação](#instalação)
- [Uso](#uso)
- [Saída](#saída)
- [Formatos de Relatório](#formatos-de-relatório)
- [Licenças Suportadas](#licenças-suportadas)
- [Códigos de Saída](#códigos-de-saída)
- [Contribuindo](#contribuindo)
- [Licença](#licença)

---

## Como Funciona

1. **Detecta a licença do projeto** a partir do seu arquivo de metadados (`package.json`, `gemspec`, `pom.xml`, etc.)
2. **Verifica todas as dependências** utilizando o LicenseFinder
3. **Normaliza os nomes das licenças** — identificadores SPDX, aliases comuns e variações ortográficas são mapeados para nomes canônicos
4. **Verifica conflitos** utilizando uma matriz de compatibilidade integrada
5. **Reporta os resultados** na saída padrão e encerra com o código de saída apropriado

---

## Linguagens Suportadas

| Linguagem  | Gerenciador de Pacotes | Arquivo de Metadados          |
|------------|------------------------|-------------------------------|
| JavaScript | npm                    | `package.json`                |
| JavaScript | Bower                  | `bower.json`                  |
| Ruby       | Bundler                | `*.gemspec`                   |
| Python     | pip / Poetry           | `setup.cfg`, `pyproject.toml` |
| Go         | Go modules             | `go.mod`                      |
| Go         | Godep                  | `Godeps/Godeps.json`          |
| Java       | Maven                  | `pom.xml`                     |

---

## Requisitos

- Ruby >= 2.6.0
- O gerenciador de pacotes do seu tipo de projeto deve estar instalado (ex: `npm`, `bundler`, `mvn`)

---

## Instalação

```bash
gem install license_conflicts
```

---

## Uso

Execute dentro do diretório raiz do projeto que deseja analisar:

```bash
license_conflicts
```

Para gerar um relatório detalhado das dependências junto à verificação de conflitos:

```bash
license_conflicts check --format markdown
```

Para exibir a versão instalada:

```bash
license_conflicts version
```

### Opções

| Flag              | Alias       | Descrição                                                                        |
|-------------------|-------------|----------------------------------------------------------------------------------|
| `--format FORMAT` | `-f FORMAT` | Formato do relatório: `text`, `html`, `markdown`, `csv`, `xml`, `json`, `junit`  |

---

## Saída

Os resultados são impressos na **saída padrão (stdout)** em uma única linha separada por vírgulas:

```
{quantidade_dependencias}, {licenca_projeto}, {licencas_conflitantes}, {relatorio}
```

| Campo                    | Descrição                                                                          |
|--------------------------|------------------------------------------------------------------------------------|
| `quantidade_dependencias`| Número de dependências verificadas                                                 |
| `licenca_projeto`        | Licença detectada do projeto analisado                                             |
| `licencas_conflitantes`  | Lista de licenças incompatíveis encontradas, separadas por ponto e vírgula (vazia se não houver conflitos) |
| `relatorio`              | Relatório completo das dependências (apenas quando `--format` é especificado)      |

### Exemplos

Nenhum conflito encontrado:

```
42, MIT, ,
```

Conflitos detectados:

```
42, MIT, GPLv2;AGPL 3,
```

Com relatório em Markdown:

```
42, MIT, GPLv2, ## Dependencies ...
```

Mensagens de diagnóstico e erros são escritos na **saída de erro (stderr)** e não afetam o formato de saída do stdout.

---

## Formatos de Relatório

Quando `--format` é fornecido, um relatório completo das dependências é anexado à saída. Formatos disponíveis:

| Formato     | Valor da flag |
|-------------|---------------|
| Texto puro  | `text`        |
| HTML        | `html`        |
| Markdown    | `markdown`    |
| CSV         | `csv`         |
| XML         | `xml`         |
| JSON        | `json`        |
| JUnit XML   | `junit`       |

---

## Licenças Suportadas

As seguintes licenças são reconhecidas na matriz de conflitos:

`MIT` · `Apache 2.0` · `New BSD` · `Simplified BSD` · `GPLv2` · `GPLv3` · `LGPL 2.1` · `LGPL 3.0` · `MPL 1.1` · `MPL 2.0` · `CDDL 1.0` · `AFL 3.0` · `OSL 3.0` · `AGPL 3` · `AGPL 1.0` · `EPL 1.0` · `EPL 2.0` · `ISC` · `Zlib` · `Unlicense`

O normalizador reconhece identificadores SPDX e aliases comuns para todas as licenças acima (ex: `Apache-2.0`, `GPL-3.0-only`, `BSD-3-Clause`). Nomes de licenças não reconhecidos são repassados como estão e verificados contra a matriz.

---

## Códigos de Saída

| Código | Significado                                                                              |
|--------|------------------------------------------------------------------------------------------|
| `0`    | Nenhum conflito de licença encontrado                                                    |
| `1`    | Um ou mais conflitos de licença detectados                                               |
| `2`    | Erro durante a execução (licença não encontrada, licença não suportada, opção inválida)  |

---

## Contribuindo

Contribuições são bem-vindas! Siga os passos abaixo:

1. Faça um fork do repositório
2. Crie uma branch para sua feature (`git checkout -b feature/minha-feature`)
3. Escreva testes para suas alterações
4. Execute a suíte de testes (`bundle exec rspec`)
5. Abra um Pull Request

### Executando os Testes

```bash
bundle install
bundle exec rspec
```

---

## Licença

Este projeto está disponível como open source sob os termos da [Licença MIT](LICENSE).
