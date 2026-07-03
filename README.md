# dbt Demo — Olist E-Commerce (Medallion Architecture)

Projeto de prática de dbt aplicando arquitetura medalhão (bronze/silver/gold) sobre o [Olist Brazilian E-Commerce Dataset](https://www.kaggle.com/datasets/olistbr/brazilian-ecommerce), rodando em **Databricks Free Edition** com Unity Catalog.

## Stack

- **dbt-core** + **dbt-databricks** como adapter
- **Databricks Free Edition** (Unity Catalog, SQL Warehouse Serverless)
- **Python 3.12** em virtualenv
- **GitHub Actions** para CI/CD

## Arquitetura
```
Volume (arquivos brutos)
      ↓
Tabelas raw (schema leo.raw)
      ↓
dbt staging (bronze)  — limpeza, cast de tipos, renomeação
      ↓
dbt intermediate (silver)  — joins, regras de negócio
      ↓
dbt marts (gold)  — tabelas analíticas finais
```

## Ingestão de dados

A ingestão **não é feita pelo dbt** — o dbt aqui cuida apenas de transformação, seguindo a separação clássica entre camada de ingestão e camada de transformação.

Fluxo:
1. Os CSVs do dataset Olist são baixados manualmente do Kaggle
2. Upload manual para um **Volume** do Unity Catalog (`leo.raw.olist_files`)
3. As tabelas raw são criadas a partir dos arquivos via `read_files()`, com o script documentado em [`ingestion/setup_raw_tables.sql`](ingestion/setup_raw_tables.sql)
4. O dbt lê essas tabelas raw como **sources** (`models/staging/olist/_olist__sources.yml`) e a partir daí assume a transformação

Esse script de ingestão é executado manualmente no SQL Editor do Databricks — não faz parte do pipeline automatizado do dbt.

## Ambientes

O projeto usa dois catalogs do Unity Catalog para isolar ambientes:

| Target | Catalog | Onde roda |
|---|---|---|
| `dev` | `leo_dev` | Localmente, na máquina do desenvolvedor |
| `prd` | `leo` | Via GitHub Actions, a cada push/PR na `main` |

Dentro de cada catalog, os schemas seguem a camada medalhão: `bronze`, `silver`, `gold`.

> A geração de nomes de schema é customizada via `macros/generate_schema_name.sql` para evitar duplicação de prefixo (ex: `bronze_bronze`) — o schema final é sempre o nome definido em `+schema` no `dbt_project.yml`, sem concatenar com o schema do profile.

## Setup local

```bash
# Criar e ativar virtualenv
python3 -m venv venv
source venv/bin/activate

# Instalar dependências
pip install --upgrade pip
pip install dbt-core dbt-databricks

# Configurar variável de ambiente com o token do Databricks
export DBT_DATABRICKS_TOKEN="seu_token_aqui"

# Validar conexão
dbt debug
```

O `profiles.yml` fica em `~/.dbt/profiles.yml` (fora do repositório, por segurança) com os targets `dev` e `prd` configurados.

## Comandos úteis

```bash
dbt run --select staging.olist     # roda só os models de staging
dbt build                          # roda + testa tudo (run + test)
dbt test                           # roda só os testes
dbt docs generate && dbt docs serve  # gera e abre a documentação do projeto
dbt list --resource-type source    # lista as sources configuradas
```

## CI/CD

A cada `push` ou `pull request` na branch `main`, o workflow [`.github/workflows/dbt_ci.yml`](.github/workflows/dbt_ci.yml) roda `dbt build` contra o catalog de produção (`leo`), autenticando via secrets do GitHub (token, host, http_path, catalog). Nenhuma credencial fica em texto puro no repositório.

## Recomendação de tooling

Pra quem for editar este projeto no VS Code, vale instalar a extensão **[dbt Power User](https://marketplace.visualstudio.com/items?itemName=innoverio.vscode-dbt-power-user)**. Ela adiciona:

- Autocomplete de `{{ ref() }}` e `{{ source() }}`
- Visualização do lineage (grafo de dependências) direto no editor
- Preview de resultado de queries sem sair do VS Code
- Geração automática de arquivos `.yml` de schema (colunas, tipos, testes básicos) a partir dos models
- Navegação rápida entre um model e suas dependências (Ctrl+clique em `ref`/`source`)

Instalação: abra a aba de Extensions no VS Code, busque "dbt Power User", instale. Ele detecta automaticamente o projeto dbt na pasta aberta.

## Estrutura do projeto
```
dbt_demo/
├── ingestion/              # scripts de ingestão (fora do escopo do dbt)
│   └── setup_raw_tables.sql
├── macros/
│   └── generate_schema_name.sql
├── models/
│   ├── staging/
│   │   └── olist/          # bronze — um model por tabela raw
│   ├── intermediate/       # silver — joins e regras de negócio
│   └── marts/               # gold — tabelas analíticas finais
├── seeds/
├── snapshots/
├── tests/
├── .github/
│   └── workflows/
│       └── dbt_ci.yml
├── dbt_project.yml
└── README.md
```

## Fonte dos dados

[Brazilian E-Commerce Public Dataset by Olist](https://www.kaggle.com/datasets/olistbr/brazilian-ecommerce) — dataset público no Kaggle, ~100k pedidos entre 2016 e 2018.
