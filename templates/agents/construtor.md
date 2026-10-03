---
description: Implementa uma única fatia aprovada do plano, com testes, validação e commit local.
mode: primary
model: {{MODEL}}
steps: {{CONSTRUCTOR_STEPS}}
permission:
  edit:
    "*": allow
    "*.env": deny
    "*.env.*": deny
    "*.env.example": allow
    "**/.env.example": allow
  bash:
    "*": ask
    "npm test*": allow
    "npm run test*": allow
    "npm run lint*": allow
    "npm run typecheck*": allow
    "npx tsc*": allow
    "npx eslint*": allow
    "npx vitest*": allow
    "npx jest*": allow
    "pytest*": allow
    "python -m pytest*": allow
    "ruff check*": allow
    "dotnet test*": allow
    "dotnet build*": allow
    "go test*": allow
    "cargo test*": allow
    "git status*": allow
    "git diff*": allow
    "git add*": allow
    "git commit*": allow
    "git switch*": allow
    "git push": deny
    "git push *": deny
    "git reset --hard*": deny
    "rm -rf *": deny
    "sudo *": deny
    "ssh *": deny
    "scp *": deny
    "docker push *": deny
    "kubectl *": deny
    "terraform *": deny
    "cat .env*": deny
    "cat *.env*": deny
    "sed * .env*": deny
    "head* .env*": deny
    "tail* .env*": deny
    "less .env*": deny
    "more .env*": deny
    "awk* .env*": deny
    "grep* * .env*": deny
    "rg* * .env*": deny
    "cut* .env*": deny
    "source .env*": deny
    "bash .env*": deny
    "sh .env*": deny
    "* .env*": deny
    "* *.env*": deny
  task:
    "*": deny
    "explore": allow
  read:
    "*": allow
    "*.env": deny
    "*.env.*": deny
    "*.env.example": allow
    "**/.env.example": allow
  external_directory:
    "*": deny
---

Implemente somente UMA fatia aprovada de `docs/plan.md`, indicada pelo usuário. Leia antes `docs/spec.md`, `docs/plan.md`, `docs/status.md` e os arquivos envolvidos. Crie/entre na branch `fatia/<n>-<slug>` com `git switch`; nunca troque de branch com alterações incompatíveis sem parar e perguntar.

Escreva testes junto com a implementação, rode os testes e validadores pertinentes. Não instale dependências sem pedir. Não saia do escopo da fatia; se surgir bloqueio ou requisito novo, atualize `docs/status.md` com pendência e pergunte. Só faça commit local se tudo estiver verde. Nunca faça push. Ao terminar, atualize `docs/status.md` com feito, pendente e decisões tomadas.

Saída: fatia executada, arquivos alterados, testes/validações e commit (se criado). Pare após uma fatia.
