#!/usr/bin/env bats

SCRIPT_DIR="$(cd "$(dirname "$BATS_TEST_FILENAME")/.." && pwd)"

setup() {
  WORK_DIR="$(mktemp -d)"
  mkdir -p "$WORK_DIR/project"
  cd "$WORK_DIR/project"
}

teardown() {
  rm -rf "$WORK_DIR"
}

@test "instala três agentes, seis comandos e templates de projeto" {
  run bash "$SCRIPT_DIR/setup.sh" --answers "$SCRIPT_DIR/tests/fixtures/answers.env"
  [ "$status" -eq 0 ]
  [ -f .opencode/agents/planejador.md ]
  [ -f .opencode/agents/construtor.md ]
  [ -f .opencode/agents/revisor.md ]
  [ -f .opencode/commands/spec.md ]
  [ -f .opencode/commands/plano.md ]
  [ -f .opencode/commands/fatia.md ]
  [ -f .opencode/commands/revisar.md ]
  [ -f .opencode/commands/status.md ]
  [ -f .opencode/commands/entrega.md ]
  [ -f AGENTS.md ]
  [ -f docs/spec.md ]
  [ -f docs/plan.md ]
  [ -f docs/status.md ]
}

@test "substitui modelos e limite de steps" {
  bash "$SCRIPT_DIR/setup.sh" --answers "$SCRIPT_DIR/tests/fixtures/answers.env"
  run grep -F 'model: test/strong' .opencode/agents/planejador.md
  [ "$status" -eq 0 ]
  run grep -F 'model: test/fast' .opencode/agents/construtor.md
  [ "$status" -eq 0 ]
  run grep -F 'model: test/other-family-reviewer' .opencode/agents/revisor.md
  [ "$status" -eq 0 ]
  run grep -F 'steps: 42' .opencode/agents/construtor.md
  [ "$status" -eq 0 ]
}

line_of() {
  local file="$1" text="$2"
  grep -nF "$text" "$file" | cut -d: -f1 | head -n1
}

assert_before() {
  local file="$1" first="$2" second="$3" first_line second_line
  first_line="$(line_of "$file" "$first")"
  second_line="$(line_of "$file" "$second")"
  [ -n "$first_line" ] && [ -n "$second_line" ]
  [ "$first_line" -lt "$second_line" ]
}

@test "guardrails estão presentes e ordenados nos três agentes" {
  bash "$SCRIPT_DIR/setup.sh" --answers "$SCRIPT_DIR/tests/fixtures/answers.env"
  for agent in planejador construtor revisor; do
    file=".opencode/agents/$agent.md"
    case "$agent" in
      planejador) last_allow='"ls*": allow' ;;
      construtor) last_allow='"git switch*": allow' ;;
      revisor) last_allow='"git show*": allow' ;;
    esac
    for rule in '"git push": deny' '"git push *": deny' '"git reset --hard*": deny' \
      '"rm -rf *": deny' '"sudo *": deny' '"ssh *": deny' '"scp *": deny' \
      '"docker push *": deny' '"kubectl *": deny' '"terraform *": deny' \
      '"cat .env*": deny' '"cat *.env*": deny' '"sed * .env*": deny' \
      '"head* .env*": deny' '"tail* .env*": deny' '"less .env*": deny' \
      '"more .env*": deny' '"awk* .env*": deny' '"grep* * .env*": deny' \
      '"rg* * .env*": deny' '"cut* .env*": deny' '"source .env*": deny' \
      '"bash .env*": deny' '"sh .env*": deny' '"* | *": deny' \
      '"* && *": deny' '"* || *": deny' '"* ; *": deny' '"*$( *": deny' \
      '"*`*": deny' '"* .env*": deny' '"* *.env*": deny'; do
      run grep -F "$rule" "$file"
      [ "$status" -eq 0 ]
      assert_before "$file" "$last_allow" "$rule"
    done
    run grep -F 'external_directory:' "$file"
    [ "$status" -eq 0 ]
    run grep -A1 -F 'external_directory:' "$file"
    [[ "$output" == *'"*": deny'* ]]
    run grep -F '"*.env": deny' "$file"
    [ "$status" -eq 0 ]
    run grep -F '"*.env.*": deny' "$file"
    [ "$status" -eq 0 ]
    run grep -F '"*.env.example": allow' "$file"
    [ "$status" -eq 0 ]
    run grep -F '"**/.env.example": allow' "$file"
    [ "$status" -eq 0 ]
    assert_before "$file" '"*.env.*": deny' '"*.env.example": allow'
  done
}

@test "ações shell proibidas aparecem por último no construtor" {
  bash "$SCRIPT_DIR/setup.sh" --answers "$SCRIPT_DIR/tests/fixtures/answers.env"
  file=.opencode/agents/construtor.md
  for rule in '"git push": deny' '"git push *": deny' '"git reset --hard*": deny' '"rm -rf *": deny' \
    '"sudo *": deny' '"ssh *": deny' '"scp *": deny' '"docker push *": deny' \
    '"kubectl *": deny' '"terraform *": deny' '"cat .env*": deny' '"cat *.env*": deny' \
    '"sed * .env*": deny' '"head* .env*": deny' '"tail* .env*": deny' '"less .env*": deny' \
    '"more .env*": deny' '"awk* .env*": deny' '"grep* * .env*": deny' '"rg* * .env*": deny' \
    '"cut* .env*": deny' '"source .env*": deny' '"bash .env*": deny' '"sh .env*": deny' \
    '"* | *": deny' '"* && *": deny' '"* || *": deny' '"* ; *": deny' \
    '"*$( *": deny' '"*`*": deny' \
    '"* .env*": deny' '"* *.env*": deny'; do
    run grep -F "$rule" "$file"
    [ "$status" -eq 0 ]
    assert_before "$file" '"git status*": allow' "$rule"
  done
  assert_before "$file" '"*": ask' '"git status*": allow'
  assert_before "$file" '"*": deny' '"explore": allow'
  assert_before "$file" '"*.env.*": deny' '"*.env.example": allow'
  assert_before "$file" '"*": allow' '"*.env": deny'
  assert_before "$file" '"*": ask' '"* | *": deny'
}

@test "planejador pode editar somente docs e gate impede spec não aprovada" {
  bash "$SCRIPT_DIR/setup.sh" --answers "$SCRIPT_DIR/tests/fixtures/answers.env"
  file=.opencode/agents/planejador.md
  assert_before "$file" '"*": deny' '"**/docs/**": allow'
  assert_before "$file" '"*": deny' '"**/docs/*": allow'
  assert_before "$file" '"*": deny' '"*/docs/*": allow'
  run grep -F 'Status: Approved' "$file"
  [ "$status" -eq 0 ]
  run grep -F 'sem status, `Draft` ou `Proposed`' "$file"
  [ "$status" -eq 0 ]
  run grep -F 'Não liste, leia nem compare repositórios irmãos' "$file"
  [ "$status" -eq 0 ]
}

@test "instalação global disponibiliza template copiável" {
  export HOME="$WORK_DIR/home"
  mkdir -p "$HOME"
  run bash "$SCRIPT_DIR/setup.sh" --answers "$SCRIPT_DIR/tests/fixtures/answers.env" --scope global
  [ "$status" -eq 0 ]
  [ -f "$HOME/.config/opencode/agents/planejador.md" ]
  [ -f "$HOME/.config/opencode/commands/revisar.md" ]
  [ -f "$HOME/.config/opencode/templates/freela/AGENTS.md" ]
}

@test "help lista opções e scope inválido falha" {
  run bash "$SCRIPT_DIR/setup.sh" --help
  [ "$status" -eq 0 ]
  [[ "$output" == *"--scope local|global"* ]]
  run bash "$SCRIPT_DIR/setup.sh" --scope invalid
  [ "$status" -eq 2 ]
}
