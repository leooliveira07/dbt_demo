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

- **Mudança de schema em models incrementais exige atenção especial.** Delta Lake não permite `DROP COLUMN` sem Column Mapping habilitado (`delta.columnMapping.mode = 'name'`, já configurado no `fct_orders`). Se uma mudança de coluna causar erro `DELTA_UNSUPPORTED_DROP_COLUMN` em qualquer ambiente, rode `--full-refresh` nesse ambiente específico — dev e prd têm tabelas físicas independentes, uma mudança de schema aplicada só em dev não se propaga pra prd automaticamente.

## Contexto do projeto

Dataset Olist (Kaggle), estático. Databricks Free Edition, Unity Catalog. Grão do `fct_orders`: item de pedido (`order_id` + `order_item_id`).

## Conexão MCP

Este projeto tem o `dbt-mcp` conectado ao Claude Code (modo local, via `uvx`), permitindo que o agente consulte lineage, models compilados e execute comandos dbt reais.

- **Configuração**: `DBT_PROJECT_DIR` aponta para a raiz deste repo, `DBT_PATH` para o `dbt` do virtualenv local. `DISABLE_SEMANTIC_LAYER`, `DISABLE_DISCOVERY` e `DISABLE_ADMIN_API` estão setados como `true` — não há conta dbt Platform paga associada a este projeto.
- **Target padrão do MCP**: o `dbt` usado pelo MCP é o mesmo do venv local, cujo `profiles.yml` tem `target: dev` como default. Comandos executados pelo agente sem `--target` explícito escrevem em `leo_dev`, nunca em `leo` (prd).
- **Comportamento validado**: ações de execução (`dbt run`, `dbt build`, etc.) pedem confirmação explícita antes de rodar — não são disparadas automaticamente pelo agente.
- **Nunca** peça ou aceite que o agente rode um comando com `--target prd` numa sessão exploratória. Se uma tarefa realmente exigir isso, trate como uma ação deliberada e única, não como parte de um fluxo automatizado do agente.

## Pendente (não assumir que já existe)

- **Snapshot roda via Databricks Job** (`job_dbt_olist`), agendado diariamente às 09:00, independente do CI do GitHub Actions. O CI cuida de validar código (push/PR); o Job cuida de manter o histórico de dados atualizado. São mecanismos independentes — nenhum aciona o outro.
- Incremental models — todos os models são full-refresh (`view` ou `table`) exceto `fct_orders`
- O modelo `fct_orders` é incremental com a estratégia de merge nativa do Databricks
