---
description: Revisar diff da branch contra main em contexto separado.
agent: revisor
subtask: true
---

Revise esta implementação. Diff da branch atual contra `main`:

!`git diff main...HEAD`

Compare com @docs/spec.md e @docs/plan.md, focando na fatia `$1`. Siga checklist e formato obrigatório do agente revisor. Não corrija arquivos. Se o comando de diff falhar ou vier vazio quando se esperam mudanças, informe isso no relatório e não invente achados.
