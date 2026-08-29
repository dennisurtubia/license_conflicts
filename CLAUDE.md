# Contexto: correção do `conflicts_map.rb` (license_conflicts)

## O que é este projeto

Gem Ruby (TCC) que detecta conflitos de licença entre um projeto open source e suas
dependências, usando o **LicenseFinder** para identificar a licença de cada dependência.
O modelo teórico é o artigo:

> Kapitsaki, G.M., Kramer, F., Tselikas, N.D. (2017). *Automating the license
> compatibility process in open source software with SPDX*. Journal of Systems and
> Software, 131, 386–401. (Grafo de compatibilidade da Fig. 2.)

O arquivo a corrigir é `lib/license_conflicts/conflicts_map.rb`, um hash onde:

- **chave** = licença declarada do projeto examinado (nome canônico do LicenseFinder)
- **valor** = array de licenças de dependência que **conflitam** com essa licença de projeto

Uso: para cada dependência, verifica-se se `dependency.licenses.first.name`
(normalizado via `LicenseNormalizer`) está em `CONFLICTS_MAP[licenca_do_projeto]`.

## Escopo da tarefa (premissas — NÃO ampliar)

1. **Manter a abordagem atual de hash + arrays hardcoded.** NÃO implementar grafo,
   BFS ou geração programática do mapa. A tarefa é apenas substituir o conteúdo das
   listas pelo conteúdo correto fornecido abaixo.
2. Apenas projetos com **uma única licença declarada**. Ignorar multi-licenciamento
   (dual/tri-license, expressões `OR`/`AND`).
3. Apenas as 16 licenças abaixo (cobertas pelo grafo do artigo).
4. Versões "ou posterior" (`+`, ex.: GPL-2.0+): o LicenseFinder não distingue
   `GPL-2.0` de `GPL-2.0+`. Premissa conservadora: **todo nome achatado é tratado como
   a versão exata ("only")**. Documentar como limitação em comentário.

## Por que o mapa atual está errado

A compatibilidade do artigo é **unidirecional** (Definition 1): código sob a licença
V1 pode ser combinado num produto licenciado sob V2 se existe caminho V1 → V2 no grafo.
A pergunta operacional da ferramenta é:

> A dependência D pode estar num projeto licenciado sob P?
> **Conflito(P, D) ⇔ NÃO existe caminho D → P no grafo.**

O mapa atual foi construído na **direção transposta** (cada chave X lista os projetos
onde código X não pode entrar, e não as dependências que não podem entrar num projeto X).
Exemplos do erro com o uso atual:

- `CONFLICTS_MAP["GPLv3"]` inclui MIT, BSDs, Apache 2.0, MPL 2.0, LGPL — todas são
  dependências **válidas** num projeto GPL-3.0 (falsos positivos).
- `CONFLICTS_MAP["MIT"]` omite GPL/LGPL/Apache — uma dependência GPL num projeto MIT
  é a violação clássica (falso negativo).
- Inconsistências internas: `GPL3_CONFLICTS` inclui `GPLv2` mas `GPL2_CONFLICTS` não
  inclui `GPLv3` (o artigo diz que a incompatibilidade vale nos dois sentidos);
  `MPL 1.1` omite LGPL 2.1, GPLv2, GPLv3 e AGPL 3 (a incompatibilidade central do
  artigo); `Apache 2.0` omite GPLv2 e LGPL 2.1 (caso Shopware do artigo).

## O mapa correto (substituir integralmente o conteúdo atual)

As listas abaixo já foram derivadas e validadas contra os resultados do artigo
(Tabela 4: casos opencsv, Joda-Time, py2exe, Shopware, Odoo, CuteFlow/FileZilla).
NÃO recalcular nem "melhorar" — apenas transcrever, mantendo `frozen_string_literal`,
`.freeze` e a interface pública (`LicenseConflicts::CONFLICTS_MAP`).

```ruby
# frozen_string_literal: true

# Chave: licença declarada do PROJETO examinado.
# Valor: licenças de DEPENDÊNCIA que conflitam com ela, isto é, licenças que
# NÃO podem ser relicenciadas/combinadas sob a licença do projeto.
#
# Semântica direcional (Kapitsaki et al. 2017, Definition 1 e Fig. 2):
#   conflito(projeto P, dependência D) <=> não existe caminho D -> P no grafo
#   de compatibilidade do artigo.
#
# Premissas/limitações documentadas:
# - Projetos com licença única (multi-licenciamento OR/AND fora de escopo).
# - Nomes achatados tratados como versão exata ("only"): "GPLv2" = GPL-2.0-only etc.
# - Nomes canônicos conforme retornados pelo LicenseFinder, normalizados via
#   LicenseNormalizer.
module LicenseConflicts
  ALL_LICENSES = [
    "MIT",
    "Simplified BSD",
    "New BSD",
    "Zlib",
    "Apache 2.0",
    "AFL 3.0",
    "MPL 1.1",
    "MPL 2.0",
    "CDDL 1.0",
    "LGPL 2.1",
    "LGPL 3.0",
    "OSL 3.0",
    "GPLv2",
    "GPLv3",
    "AGPL 1.0",
    "AGPL 3"
  ].freeze

  CONFLICTS_MAP = {
    # Só código MIT (e domínio público) pode ser relicenciado como MIT.
    "MIT" => (ALL_LICENSES - ["MIT"]).freeze,

    "Simplified BSD" => (ALL_LICENSES - ["MIT", "Simplified BSD"]).freeze,

    "New BSD" => (ALL_LICENSES - ["MIT", "Simplified BSD", "New BSD"]).freeze,

    # Nenhuma outra licença flui para Zlib no grafo do artigo.
    "Zlib" => (ALL_LICENSES - ["Zlib"]).freeze,

    # Permissivas (MIT, BSDs, Zlib) fluem para Apache-2.0; todo o resto conflita.
    "Apache 2.0" => [
      "AFL 3.0",
      "MPL 1.1",
      "MPL 2.0",
      "CDDL 1.0",
      "LGPL 2.1",
      "LGPL 3.0",
      "OSL 3.0",
      "GPLv2",
      "GPLv3",
      "AGPL 1.0",
      "AGPL 3"
    ].freeze,

    "AFL 3.0" => [
      "MPL 1.1",
      "MPL 2.0",
      "CDDL 1.0",
      "LGPL 2.1",
      "LGPL 3.0",
      "OSL 3.0",
      "GPLv2",
      "GPLv3",
      "AGPL 1.0",
      "AGPL 3"
    ].freeze,

    # Nenhuma outra licença flui para MPL-1.1.
    "MPL 1.1" => (ALL_LICENSES - ["MPL 1.1"]).freeze,

    # MIT/BSDs (aresta sólida), Zlib/Apache-2.0 e MPL-1.1 (arestas não-transitivas
    # como última aresta do caminho) fluem para MPL-2.0. Caso py2exe do artigo:
    # MIT + MPL-1.1 são combináveis sob MPL-2.0.
    "MPL 2.0" => [
      "AFL 3.0",
      "CDDL 1.0",
      "LGPL 2.1",
      "LGPL 3.0",
      "OSL 3.0",
      "GPLv2",
      "GPLv3",
      "AGPL 1.0",
      "AGPL 3"
    ].freeze,

    # Apenas MPL-1.1 flui para CDDL-1.0 (CDDL é derivada da MPL-1.1).
    "CDDL 1.0" => (ALL_LICENSES - ["MPL 1.1", "CDDL 1.0"]).freeze,

    # Zlib e Apache-2.0 NÃO fluem para LGPL-2.1 (incompatibilidade explícita no
    # artigo — caso Shopware). GPL não pode "voltar" para LGPL.
    "LGPL 2.1" => [
      "Zlib",
      "Apache 2.0",
      "AFL 3.0",
      "MPL 1.1",
      "CDDL 1.0",
      "LGPL 3.0",
      "OSL 3.0",
      "GPLv2",
      "GPLv3",
      "AGPL 1.0",
      "AGPL 3"
    ].freeze,

    # Apache-2.0 e Zlib fluem para LGPL-3.0 (diferente da LGPL-2.1).
    "LGPL 3.0" => [
      "AFL 3.0",
      "MPL 1.1",
      "CDDL 1.0",
      "LGPL 2.1",
      "OSL 3.0",
      "GPLv2",
      "GPLv3",
      "AGPL 1.0",
      "AGPL 3"
    ].freeze,

    "OSL 3.0" => [
      "MPL 1.1",
      "MPL 2.0",
      "CDDL 1.0",
      "LGPL 2.1",
      "LGPL 3.0",
      "GPLv2",
      "GPLv3",
      "AGPL 1.0",
      "AGPL 3"
    ].freeze,

    # Apache-2.0 e Zlib são incompatíveis com GPL-2.0 (exemplos explícitos do
    # artigo, Seção 4.1 e Tabela 4). GPLv3 incompatível com GPLv2 "and vice versa".
    "GPLv2" => [
      "Zlib",
      "Apache 2.0",
      "AFL 3.0",
      "MPL 1.1",
      "CDDL 1.0",
      "LGPL 3.0",
      "OSL 3.0",
      "GPLv3",
      "AGPL 1.0",
      "AGPL 3"
    ].freeze,

    # Apache-2.0, Zlib, MPL-2.0 e LGPLs fluem para GPL-3.0.
    "GPLv3" => [
      "AFL 3.0",
      "MPL 1.1",
      "CDDL 1.0",
      "OSL 3.0",
      "GPLv2",
      "AGPL 1.0",
      "AGPL 3"
    ].freeze,

    # Premissa exact-only: nada flui para AGPL-1.0 (no grafo do artigo o nó é
    # AGPL-1.0+, com aresta apenas de saída para AGPL-3.0).
    "AGPL 1.0" => (ALL_LICENSES - ["AGPL 1.0"]).freeze,

    # GPL-3.0 flui para AGPL-3.0 (cláusula 13 da GPLv3); GPL-2.0 não (caso Odoo).
    "AGPL 3" => [
      "AFL 3.0",
      "MPL 1.1",
      "CDDL 1.0",
      "OSL 3.0",
      "GPLv2",
      "AGPL 1.0"
    ].freeze
  }.freeze
end
```

Propriedades que DEVEM valer no resultado final (verificar em spec):

- Toda chave e todo valor pertencem a `ALL_LICENSES`.
- Nenhuma licença aparece na própria lista de conflitos.
- O hash tem exatamente 16 chaves.

## Casos de teste (derivados do artigo) — escrever specs para todos

Sem conflito (não devem ser sinalizados):

- Projeto `Apache 2.0` + dep `MIT` / `New BSD` / `Simplified BSD` / `Zlib`.
- Projeto `GPLv3` + dep `Apache 2.0` — compatibilidade Apache-2.0 → GPL-3.0
  (licenças propostas para opencsv/Joda-Time na Tabela 4).
- Projeto `GPLv3` + dep `MIT` / `New BSD` / `Zlib` / `MPL 2.0` / `LGPL 2.1` / `LGPL 3.0`.
- Projeto `GPLv2` + dep `MIT` / `New BSD` / `MPL 2.0` / `LGPL 2.1`.
- Projeto `AGPL 3` + dep `GPLv3` / `Apache 2.0` / `MPL 2.0` / `MIT`.
- Projeto `MPL 2.0` + dep `MPL 1.1` — caso py2exe (aresta não-transitiva como última).
- Projeto `MPL 2.0` + dep `Apache 2.0` / `Zlib` — exemplo do zlib na Seção 4.1.
- Projeto `CDDL 1.0` + dep `MPL 1.1`.
- Projeto `LGPL 3.0` + dep `Apache 2.0`.

Com conflito (devem ser sinalizados):

- Projeto `MIT` + dep `GPLv3` / `Apache 2.0` / `New BSD` — nada flui de volta para MIT.
- Projeto `Apache 2.0` + dep `GPLv2` / `LGPL 2.1` / `GPLv3` / `MPL 1.1`.
- Projeto `GPLv2` + dep `Apache 2.0` — caso Shopware.
- Projeto `GPLv2` + dep `Zlib` — exemplo explícito da Seção 4.1.
- Projeto `GPLv3` + dep `GPLv2` E projeto `GPLv2` + dep `GPLv3` — "and vice versa"
  (casos CuteFlow/FileZilla).
- Projeto `GPLv2` / `GPLv3` / `LGPL 2.1` / `LGPL 3.0` / `AGPL 3` + dep `MPL 1.1` —
  casos CKEditor, HandBrake, Odoo.
- Projeto `GPLv2` + dep `AGPL 3` E projeto `AGPL 3` + dep `GPLv2` — caso Odoo.
- Projeto `AGPL 3` + dep `AGPL 1.0`.
- Projeto `LGPL 2.1` + dep `Apache 2.0` / `Zlib` / `GPLv2`.

## Instruções de implementação

1. Ler `lib/license_conflicts/conflicts_map.rb`, o `LicenseNormalizer` e os specs
   existentes antes de mudar qualquer coisa.
2. Conferir se os nomes canônicos usados pelo `LicenseNormalizer` batem exatamente com
   os de `ALL_LICENSES` acima (ex.: `"GPLv2"` vs `"GPL 2.0"`, `"AGPL 3"` vs
   `"AGPL 3.0"`). Se houver divergência, ajustar os NOMES no mapa novo para os nomes
   canônicos reais do projeto — sem alterar o CONTEÚDO lógico das listas.
3. Substituir o conteúdo do arquivo pelo mapa correto acima. As constantes
   intermediárias atuais (`APACHE2_CONFLICTS`, `GPL2_CONFLICTS` etc.) podem ser
   removidas, a menos que sejam referenciadas em outros arquivos — verificar com grep
   antes e, se forem usadas externamente, mantê-las apontando para as novas listas.
4. Adicionar/atualizar os specs com os casos listados, mais as três propriedades
   estruturais do mapa.
5. Rodar a suíte de testes e o rubocop (se configurado) ao final.
