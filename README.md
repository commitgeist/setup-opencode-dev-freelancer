# setup-opencode-dev-freelancer

Workflow prático para **um freelancer e um cliente/projeto por repositório**.
Spec, plano e status vivem em arquivos versionáveis do projeto, não dependem da
memória do chat. O humano define requisitos e revisa entregas; agentes planejam,
implementam uma fatia por vez e documentam dentro do escopo aprovado.

Este repositório contém o **setup do OpenCode**, não o aplicativo do cliente.
Clone/guarde-o numa pasta de ferramentas e rode o instalador a partir da raiz de
cada projeto freelance.

## Qual setup usar?

| Setup | Indicado para | Processo e artefatos | Proteções / especialização |
|---|---|---|---|
| [`setup-opencode`](https://github.com/commitgeist/setup-opencode) | DevOps/SRE e mudanças de infraestrutura | ADR para decisões de infra; engineer implementa; reviewer valida | Skills e MCPs de cloud, IaC, Kubernetes e CI/CD |
| [`setup-opencode-dev`](https://github.com/commitgeist/setup-opencode-dev) | Times que desenvolvem aplicações | Wizard de stack; architect/developer/reviewer/tester; ADR para mudanças estruturais | Skills condicionais de linguagem, framework, teste e Docker |
| [`setup-opencode-spec`](https://github.com/commitgeist/setup-opencode-spec) | Times que querem Spec-Driven Development rigoroso | Spec → aprovação → plano/tasks → aprovação → implementação → review | Specs por feature, gates/plugins e rastreabilidade |
| [`setup-opencode-devtools`](https://github.com/commitgeist/setup-opencode-devtools) | Quem constrói CLIs, SDKs e ferramentas de plataforma | Ciclo de desenvolvimento de ferramenta, adaptado à stack | Skills de CLI, AWS SDK, cliente Kubernetes e linguagens de ferramentas |
| [`setup-opencode-harness`](https://github.com/commitgeist/setup-opencode-harness) | Times que precisam impor processo via checks executáveis | Spec/plan/tasks + gates e evaluator loop | Harness determinístico compartilhado entre agente, comando e CI |
| [`setup-opencode-msp`](https://github.com/commitgeist/setup-opencode-msp) | MSP que opera vários clientes e clouds | Triage, mudança controlada e handoff | Cliente/role ativos, plugin harness, regras contra contexto cruzado/destruição |
| **Este setup** | **Projeto freelance pequeno, um cliente por vez** | **Spec única → plano fatiado → execução → review → entrega** | **Enxuto: sem wizard de stack, MCPs, plugin ou ciclo de ADR obrigatório** |

Escolha este setup quando quiser pouco atrito e contexto persistente por
projeto. Escolha `setup-opencode-spec` ou `setup-opencode-harness` quando as
features forem grandes, houver equipe/gates formais ou rastreabilidade rígida.
Escolha MSP se operar vários clientes na mesma estação e precisar de isolamento
de contexto e políticas para cada cliente.

Outras variantes no repositório: `setup-opencode-loop` foca em loops de
implementação/verificação; `setup-opencode-os` em memória operacional e
aprendizado; `setup-opencode` cobre operação DevOps/SRE. `setup-claude-code`,
`setup-copilot` e `setup-antigravity*` adaptam setups a outros hosts, não são
alternativas de workflow OpenCode para comparar diretamente.

## Workflow em cinco fases

1. **Spec:** `/spec <texto ou caminho>` prepara `docs/spec.md`; você revisa.
2. **Plano:** `/plano` prepara `docs/plan.md` com fatias; você revisa e aprova.
3. **Execução:** `/fatia <n>` implementa uma fatia por branch, com testes.
4. **Revisão:** `/revisar <n>` envia diff para `@revisor`, sem permissão de escrita.
5. **Entrega:** `/entrega` prepara README e `docs/runbook.md`; você revisa e faz deploy.

`/status` atualiza `docs/status.md` ao longo do trabalho. Os artefatos de
`docs/` são fonte de verdade entre sessões.

### Este setup usa ADR?

Não há pasta `docs/adr/` nem comando `/new-adr` neste setup. É uma decisão de
escopo: para entrega pequena, uma spec de produto (`docs/spec.md`) e um plano de
execução (`docs/plan.md`) são os artefatos centrais; um ADR por mudança seria
cerimônia extra. A spec responde **o que/por quê**; o plano responde **como/em
quais fatias**. Você revisa ambos antes da execução.

Se projeto exigir decisão arquitetural duradoura (por exemplo, trocar banco,
introduzir serviço externo ou definir estratégia de migração), registre decisão
e alternativas em `docs/plan.md` ou crie ADR manualmente em `docs/adr/`. Para
um fluxo com criação/revisão de ADR como etapa de primeira classe, use
`setup-opencode-dev` (desenvolvimento) ou `setup-opencode` (infra). `setup-opencode-spec`
é alternativa quando o centro do trabalho deve ser spec/plan/tasks por feature.

## Instalação num projeto novo

Requisitos: Git, OpenCode 1.x e Bash 4.3+. Bats e ShellCheck servem para
validar/desenvolver o instalador. Ele não instala dependências do projeto nem
cria um `.git` para você.

```bash
git clone git@github.com:commitgeist/setup-opencode-dev-freelancer.git ~/tools/setup-opencode-dev-freelancer
mkdir -p ~/projects/cliente-exemplo
cd ~/projects/cliente-exemplo
git init -b main
~/tools/setup-opencode-dev-freelancer/setup.sh --scope local
git add .
git commit -m "chore: initialize freelance project"
opencode
```

Isso instala agents/commands em `.opencode/` do projeto e copia, sem sobrescrever
arquivos existentes, `AGENTS.md`, `docs/spec.md`, `docs/plan.md` e
`docs/status.md`. A aplicação continua isolada no próprio repositório; o setup
fica em `~/tools/`. Versione `.opencode/`, `AGENTS.md` e documentos do workflow
no repositório do projeto para manter configuração/contexto disponíveis após
clone e entre sessões. O commit inicial cria `main`, usada pelo `/revisar` como
base de comparação.

Comece dentro do TUI:

```text
/spec <resumo da conversa com o cliente ou caminho do briefing>
# revise docs/spec.md; alinhe escopo e critérios com cliente
/plano
# revise docs/plan.md e aprove fatias
/fatia 1
/revisar 1
/status
/entrega
```

Repita `/fatia N` → `/revisar N` → `/status` por fatia. `/entrega` prepara
README e runbook; publicação/deploy ficam com você. Para iniciar mais tarde,
rode `opencode` novamente na pasta do projeto: contexto operacional vem dos
arquivos `docs/`, não de uma conversa anterior.

### Instalação global

```bash
cd ~/tools/setup-opencode-dev-freelancer
./setup.sh --scope global
```

Agents e commands passam a aparecer em todos os projetos, em
`~/.config/opencode/agents/` e `~/.config/opencode/commands/`. Esqueletos do
projeto ficam em `~/.config/opencode/templates/freela/`; copie-os manualmente
para cada repositório. Instalação global **não** grava `AGENTS.md` nem `docs/`
num projeto específico e, portanto, não cria contexto isolado por cliente.

Use global se quiser os comandos disponíveis em toda parte; use local
(recomendado) se quiser carregar workflow e artefatos somente no projeto alvo.
Agents/commands globais preexistentes ganham backup `.bak.<timestamp>` antes de
serem substituídos.

### Modelos

Defaults usam IDs que apareceram em `opencode models opencode` nesta máquina:

- Planejador: `opencode/kimi-k2.7-code`
- Construtor: `opencode/glm-5.3-flash`
- Revisor: `opencode/claude-haiku-4-5`

Revise os IDs disponíveis no seu provider com `opencode models`. Para
personalizar, copie o exemplo para o projeto e passe caminho do arquivo ao
instalador:

```bash
cp ~/tools/setup-opencode-dev-freelancer/answers.env.example ./answers.env
# ajuste modelos e steps no projeto
~/tools/setup-opencode-dev-freelancer/setup.sh --answers ./answers.env
```

`answers.env` aceita `SCOPE`, três IDs de modelo e `CONSTRUCTOR_STEPS`. O
instalador valida formato dos IDs e steps, mas não confirma que cada ID está
disponível para sua conta; verifique com `opencode models`. Esse arquivo não
contém credenciais e pode ser removido após instalação.

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
