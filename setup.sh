#!/usr/bin/env bash
set -euo pipefail

VERSION="1.0.0"
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
TEMPLATE_DIR="$SCRIPT_DIR/templates"

usage() {
  cat <<'EOF'
OpenCode Dev Freelancer Setup

Uso:
  ./setup.sh [--scope local|global] [--answers FILE]
  ./setup.sh --help

Variáveis opcionais no arquivo de respostas:
  SCOPE, MODEL_PLANNER, MODEL_CONSTRUCTOR, MODEL_REVIEWER, CONSTRUCTOR_STEPS
EOF
}

SCOPE="local"
CLI_SCOPE=""
ANSWERS_FILE=""
while (( $# )); do
  case "$1" in
    --scope)
      [[ $# -ge 2 ]] || { printf '%s\n' "--scope exige local ou global" >&2; exit 2; }
      SCOPE="$2"
      CLI_SCOPE="$2"
      shift 2
      ;;
    --answers)
      [[ $# -ge 2 ]] || { printf '%s\n' "--answers exige um arquivo" >&2; exit 2; }
      ANSWERS_FILE="$2"
      shift 2
      ;;
    -h|--help)
      usage
      exit 0
      ;;
    *)
      printf 'Argumento desconhecido: %s\n' "$1" >&2
      usage >&2
      exit 2
      ;;
  esac
done

if [[ -n "$ANSWERS_FILE" ]]; then
  [[ -f "$ANSWERS_FILE" ]] || { printf 'Arquivo não encontrado: %s\n' "$ANSWERS_FILE" >&2; exit 1; }
  # shellcheck source=/dev/null
  source "$ANSWERS_FILE"
  SCOPE="${CLI_SCOPE:-${SCOPE:-local}}"
fi

case "$SCOPE" in
  local)
    TARGET="$(pwd)"
    AGENTS_DIR="$TARGET/.opencode/agents"
    COMMANDS_DIR="$TARGET/.opencode/commands"
    PROJECT_TEMPLATE_DIR="$TARGET"
    ;;
  global)
    TARGET="${XDG_CONFIG_HOME:-$HOME/.config}/opencode"
    AGENTS_DIR="$TARGET/agents"
    COMMANDS_DIR="$TARGET/commands"
    PROJECT_TEMPLATE_DIR="$TARGET/templates/freela"
    ;;
  *)
    printf 'Escopo inválido: %s (use local ou global)\n' "$SCOPE" >&2
    exit 2
    ;;
esac

MODEL_PLANNER="${MODEL_PLANNER:-opencode/kimi-k2.7-code}"
MODEL_CONSTRUCTOR="${MODEL_CONSTRUCTOR:-opencode/glm-5.3-flash}"
MODEL_REVIEWER="${MODEL_REVIEWER:-opencode/claude-haiku-4-5}"
CONSTRUCTOR_STEPS="${CONSTRUCTOR_STEPS:-60}"

for model in "$MODEL_PLANNER" "$MODEL_CONSTRUCTOR" "$MODEL_REVIEWER"; do
  if [[ ! "$model" =~ ^[A-Za-z0-9._:/-]+$ ]]; then
    printf 'ID de modelo inválido: %s\n' "$model" >&2
    exit 2
  fi
done

if [[ ! "$CONSTRUCTOR_STEPS" =~ ^[1-9][0-9]*$ ]]; then
  printf 'CONSTRUCTOR_STEPS deve ser inteiro positivo: %s\n' "$CONSTRUCTOR_STEPS" >&2
  exit 2
fi

mkdir -p "$AGENTS_DIR" "$COMMANDS_DIR"

install_agent() {
  local name="$1" model="$2" destination="$AGENTS_DIR/$1.md"
  if [[ -e "$destination" ]]; then
    cp -a "$destination" "$destination.bak.$(date +%Y%m%d%H%M%S)"
  fi
  sed -e "s|{{MODEL}}|$model|g" \
      -e "s|{{CONSTRUCTOR_STEPS}}|$CONSTRUCTOR_STEPS|g" \
      "$TEMPLATE_DIR/agents/$name.md" > "$destination"
}

install_agent planejador "$MODEL_PLANNER"
install_agent construtor "$MODEL_CONSTRUCTOR"
install_agent revisor "$MODEL_REVIEWER"

for command_file in "$TEMPLATE_DIR"/commands/*.md; do
  destination="$COMMANDS_DIR/$(basename "$command_file")"
  if [[ -e "$destination" ]]; then
    cp -a "$destination" "$destination.bak.$(date +%Y%m%d%H%M%S)"
  fi
  cp "$command_file" "$destination"
done

mkdir -p "$PROJECT_TEMPLATE_DIR/docs"
if [[ "$SCOPE" == "local" ]]; then
  for file in AGENTS.md docs/spec.md docs/plan.md docs/status.md; do
    destination="$PROJECT_TEMPLATE_DIR/$file"
    if [[ ! -e "$destination" ]]; then
      mkdir -p "$(dirname "$destination")"
      cp "$TEMPLATE_DIR/freela/$file" "$destination"
    else
      printf 'Preservado: %s\n' "$destination"
    fi
  done
else
  for file in AGENTS.md docs/spec.md docs/plan.md docs/status.md; do
    destination="$PROJECT_TEMPLATE_DIR/$file"
    if [[ -e "$destination" ]]; then
      cp -a "$destination" "$destination.bak.$(date +%Y%m%d%H%M%S)"
    fi
  done
  cp "$TEMPLATE_DIR/freela/AGENTS.md" "$PROJECT_TEMPLATE_DIR/AGENTS.md"
  cp "$TEMPLATE_DIR/freela/docs/"*.md "$PROJECT_TEMPLATE_DIR/docs/"
fi

printf 'OpenCode Dev Freelancer %s instalado (%s): %s\n' "$VERSION" "$SCOPE" "$TARGET"
printf 'Agentes: %s\n' "$AGENTS_DIR"
printf 'Comandos: %s\n' "$COMMANDS_DIR"
if [[ "$SCOPE" == "global" ]]; then
  printf 'Templates freela: %s\n' "$PROJECT_TEMPLATE_DIR"
fi
printf 'Modelos: planejador=%s construtor=%s revisor=%s; steps=%s\n' \
  "$MODEL_PLANNER" "$MODEL_CONSTRUCTOR" "$MODEL_REVIEWER" "$CONSTRUCTOR_STEPS"
