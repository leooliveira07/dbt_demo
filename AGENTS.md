# AGENTS.md

Contexto para agentes de código atuarem neste projeto dbt. Leia antes de criar ou modificar models, macros ou configuração.

## Regras que não são óbvias pelo código

- **Raw é único, nunca duplicar por ambiente.** As tabelas `raw.*` existem só no catalog `leo`, mesmo quando você está rodando `--target dev`. O `sources.yml` aponta fixo pra `database: leo` — não altere isso pra apontar pro catalog de dev, mesmo que pareça mais "consistente" fazer isso.

- **Ambientes são separados por catalog, não por schema.** `dev` → catalog `leo_dev`. `prd` → catalog `leo`. Os schemas (`bronze`/`silver`/`gold`) são idênticos nos dois. Não crie schemas com prefixo de ambiente (ex: `dev_bronze`).

- **A macro `generate_schema_name` está sobrescrita.** O schema final de um model é exatamente o valor de `+schema`, sem concatenar com o schema do profile. Se você criar um profile/target novo sem saber disso, pode assumir erroneamente que vai ter o comportamento default do dbt (que concatena) — não vai.

- **`relationships` só no lado "many".** Declare o teste no fato/tabela com FK apontando pra dimensão, nunca o inverso. O inverso (dimensão apontando pro fato) testaria completude de negócio, não integridade referencial, e vai falhar por design (é normal ter cliente sem pedido).

- **`marts` é sempre `table`, nunca `view`** — já configurado no `dbt_project.yml`. Não sobrescreva por model sem uma razão explícita documentada no PR.

- **`profiles.yml` nunca vai pro repo.** Fica em `~/.dbt/`, fora da pasta do projeto. Se precisar de um exemplo, use `profiles.yml.example` com valores fake — nunca cole token real em nenhum arquivo versionado.

- **Ingestão é fora do dbt.** Scripts de carga de CSV/raw ficam em `ingestion/`, são SQL puro (sem Jinja), e são executados manualmente — não fazem parte do `dbt build`.

## Contexto do projeto

Dataset Olist (Kaggle), estático. Databricks Free Edition, Unity Catalog. Grão do `fct_orders`: item de pedido (`order_id` + `order_item_id`).

## Pendente (não assumir que já existe)

- **Snapshot roda via Databricks Job** (`job_dbt_olist`), agendado diariamente às 09:00, independente do CI do GitHub Actions. O CI cuida de validar código (push/PR); o Job cuida de manter o histórico de dados atualizado. São mecanismos independentes — nenhum aciona o outro.
- Incremental models — todos os models são full-refresh (`view` ou `table`)
