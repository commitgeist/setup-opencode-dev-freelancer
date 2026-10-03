# Projeto freelance

## Contexto

- Cliente/projeto: preencher
- Stack: preencher
- Comandos para rodar: preencher
- Comandos para testar: preencher

## Convenções

- Siga estilo e arquitetura existentes.
- Código novo deve vir com testes adequados.
- Não instale dependências sem pedir autorização.
- Nunca grave segredos em código, logs ou documentação; `.env` não deve ser lido nem commitado. Use `.env.example` com nomes e valores fictícios.
- Não faça deploy, push, reset destrutivo, remoção ampla ou alteração de infraestrutura via agente.

## Workflow obrigatório

Trabalho segue cinco fases, com arquivos como fonte de verdade (não o histórico do chat):

1. `docs/spec.md` — requisitos, escopo e critérios de aceite; usuário revisa.
2. `docs/plan.md` — fatias ordenadas, cada uma com critério e teste; usuário revisa.
3. Execução — construtor implementa uma fatia por vez, com testes e branch `fatia/<n>-<slug>`.
4. Revisão — revisor read-only avalia diff contra spec e fatia do plano.
5. Entrega — README e `docs/runbook.md`; usuário valida e realiza publicação/deploy.

Atualize `docs/status.md` ao concluir fatias ou tomar decisões. Em dúvida, pare e pergunte. Humano define requisitos e revisa artefatos; agentes redigem e implementam dentro do escopo aprovado.
