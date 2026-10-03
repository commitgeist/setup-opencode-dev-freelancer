---
description: Criar plano fatiado a partir da especificação aprovada.
agent: planejador
---

Primeiro confirme a raiz do repositório ativo com uma chamada Bash isolada: `git rev-parse --show-toplevel`. Leia @docs/spec.md somente dentro dessa raiz. Não liste, leia nem compare repositórios irmãos/outros projetos no workspace. Não use pipes, `&&`, `||`, `;`, substitutions nem encadeie comandos para contornar permissões.

Gate obrigatório: só planeje se @docs/spec.md contiver objetivo, escopo, critérios de aceite revisados e `Status: Approved` explicitamente definido pelo humano. Arquivo vazio/incompleto, status ausente, Draft ou Proposed: não crie nem altere docs/plan.md; pergunte ao usuário e pare. Não use código existente, ADRs Proposed ou outros arquivos para inferir aprovação. ADR só conta como requisito aprovado se usuário declarar isso explicitamente.

Com gate aprovado, inspecione código relevante dentro da raiz, escreva @docs/plan.md em status Draft, divida em fatias pequenas ordenadas por dependência e dê a cada fatia objetivo, arquivos prováveis, critério de aceite testável e teste que prova. Liste riscos e perguntas. Pare para revisão/aprovação humana; não implemente.
