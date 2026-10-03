---
description: Implementar uma única fatia aprovada do plano.
agent: construtor
---

Confirme raiz ativa com chamada Bash isolada `git rev-parse --show-toplevel`; não acesse repositórios irmãos. Implemente apenas fatia `$1` de @docs/plan.md após ler @docs/spec.md e @docs/status.md. Exija `Status: Approved` explícito na spec, no plano e na fatia. Se algum status for Draft/Proposed/ausente, a fatia não existir ou houver ambiguidade, não escreva código: pergunte e pare. Siga construtor: branch `fatia/<n>-<slug>`, testes, validação, commit local somente com tudo verde e atualização do status. Nunca faça push. Não encadeie comandos Bash.
