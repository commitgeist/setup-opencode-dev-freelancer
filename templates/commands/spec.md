---
description: Criar ou ajustar docs/spec.md a partir dos requisitos do cliente.
agent: planejador
---

Crie ou refine `docs/spec.md` usando como entrada `$ARGUMENTS`. A entrada pode ser texto bruto da conversa com cliente ou caminho de arquivo; se for um caminho existente, leia esse arquivo.

Confirme primeiro raiz ativa com `git rev-parse --show-toplevel`; não leia arquivos de repositórios irmãos. Crie ou refine `docs/spec.md` usando como entrada `$ARGUMENTS`. A entrada pode ser texto bruto da conversa com cliente ou caminho de arquivo; caminho só pode ser lido se estiver dentro da raiz ativa.

Inclua objetivo, escopo incluído, fora de escopo, critérios de aceite testáveis, perguntas em aberto e rodadas de ajuste. Diferencie fatos confirmados de suposições. Não invente respostas. Sempre marque spec nova/alterada como `Status: Draft`; só humano pode marcar `Status: Approved`. Não trate ADR `Proposed` como requisito aprovado. Escreva documentação apenas dentro da pasta `docs/` do repositório ativo. Apresente dúvidas e pare para revisão humana.
