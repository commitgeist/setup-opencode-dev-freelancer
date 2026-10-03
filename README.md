# setup-opencode-dev-freelancer

Workflow leve para projetos freelance pequenos. Requisitos e decisões ficam em
arquivos do projeto, não dependem da memória do chat. Humano define e revisa;
agentes planejam, implementam e documentam dentro do escopo aprovado.

## Workflow em cinco fases

1. **Spec:** `/spec <texto ou caminho>` prepara `docs/spec.md`; você revisa.
2. **Plano:** `/plano` prepara `docs/plan.md` com fatias; você revisa e aprova.
3. **Execução:** `/fatia <n>` implementa uma fatia por branch, com testes.
4. **Revisão:** `/revisar <n>` envia diff para `@revisor`, sem permissão de escrita.
5. **Entrega:** `/entrega` prepara README e `docs/runbook.md`; você revisa e faz deploy.

`/status` atualiza `docs/status.md` ao longo do trabalho. Os artefatos de
`docs/` são fonte de verdade entre sessões.

## Instalação

Requisitos: OpenCode 1.x, Bash 4.3+, Bats para testes do setup. Nenhuma
dependência npm é instalada.

```bash
cd /caminho/do/projeto
/caminho/para/setup-opencode-dev-freelancer/setup.sh --scope local
opencode
```

Para preparar esqueletos sem executar instalador: copie
`templates/freela/AGENTS.md` e `templates/freela/docs/{spec,plan,status}.md` para
raiz e pasta `docs/` do projeto novo.

### Instalação global

```bash
./setup.sh --scope global
```

Agentes e comandos ficam em `~/.config/opencode/`; esqueletos são instalados em
`~/.config/opencode/templates/freela/` para cópia manual ao projeto. Instalação
local não sobrescreve `AGENTS.md` ou documentos existentes. Agentes e comandos
preexistentes no destino ganham backup `.bak.<timestamp>`.

### Modelos

Defaults usam IDs que apareceram em `opencode models opencode` nesta máquina:

- Planejador: `opencode/kimi-k2.7-code`
- Construtor: `opencode/glm-5.3-flash`
- Revisor: `opencode/claude-haiku-4-5`

Revise os IDs disponíveis no seu provider com `opencode models`. Personalize por `answers.env`:

```bash
cp answers.env.example answers.env
# ajuste modelos/steps; mantenha fora do Git se contiver dados locais
./setup.sh --answers answers.env
```

## Guardrails relevantes

- Ações proibidas são `deny`, não `ask`, portanto `--auto` não as aprova.
- Construtor só pode fazer commit local; push é negado.
- Revisor roda como subtask em modo subagent e não pode editar.
- `.env` e `.env.*` são negados em leitura, exceto `.env.example`.
- Acesso a diretórios externos ao projeto é negado.

Revise cada diff e execute deploy/publicação manualmente. O workflow não substitui
backup, revisão humana ou validação específica do ambiente do cliente.

## Testes e validação

```bash
bats tests/
bash -n setup.sh
shellcheck setup.sh
```

Após instalar localmente, valide carregamento com `opencode debug config` e
confira avisos no resultado. Mudanças em agents/commands pedem reinício do
OpenCode.
