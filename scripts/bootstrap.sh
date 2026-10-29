#!/usr/bin/env bash
set -euo pipefail

# bootstrap.sh — Adaptive project bootstrap for dev-workflows
# Detects the project's stack and customizes constitution + sprint templates
# with the right test commands, lint commands, build commands, and conventions.

PROJECT_DIR="${1:-.}"
DOCS_DIR="${PROJECT_DIR}/docs"
AGENTS_DIR="${DOCS_DIR}/agents"
TEMPLATES_DIR="" # Will be set to the dev-workflows templates dir

# Find the dev-workflows templates directory (relative to this script)
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
if [ -d "${SCRIPT_DIR}/../templates" ]; then
  TEMPLATES_DIR="${SCRIPT_DIR}/../templates"
else
  echo "ERROR: Could not find templates directory relative to script."
  echo "Expected: ${SCRIPT_DIR}/../templates"
  exit 1
fi

# --- Stack detection ---

detect_stack() {
  local dir="$1"
  local detected=()

  [ -f "${dir}/package.json" ] && detected+=("node")
  [ -f "${dir}/requirements.txt" ] && detected+=("python-req")
  [ -f "${dir}/pyproject.toml" ] && detected+=("python-pyproject")
  [ -f "${dir}/Cargo.toml" ] && detected+=("rust")
  [ -f "${dir}/go.mod" ] && detected+=("go")
  [ -f "${dir}/Gemfile" ] && detected+=("ruby")
  [ -f "${dir}/pubspec.yaml" ] && detected+=("flutter")
  [ -f "${dir}/pom.xml" ] && detected+=("maven")
  [ -f "${dir}/build.gradle" ] && detected+=("gradle")
  [ -f "${dir}/build.gradle.kts" ] && detected+=("gradle")
  [ -f "${dir}/composer.json" ] && detected+=("php")
  [ -f "${dir}/mix.exs" ] && detected+=("elixir")
  [ -f "${dir}/CMakeLists.txt" ] && detected+=("cmake")
  [ -f "${dir}/deno.json" ] && detected+=("deno")
  [ -f "${dir}/bun.lockb" ] && detected+=("bun")

  if [ ${#detected[@]} -eq 0 ]; then
    echo "none"
    return
  fi

  echo "${detected[@]}"
}

# --- Per-stack configuration ---

# Each stack outputs: TEST_CMD | LINT_CMD | TYPECHECK_CMD | BUILD_CMD | LANGUAGE | CONVENTIONS
get_stack_config() {
  local stack="$1"
  local dir="$2"

  case "$stack" in
    node)
      # Check for specific runners in package.json
      local test_cmd="npm test"
      local lint_cmd="npm run lint"
      local typecheck_cmd="npx tsc --noEmit"
      local build_cmd="npm run build"

      if [ -f "${dir}/package.json" ]; then
        if grep -q '"jest"' "${dir}/package.json" 2>/dev/null; then
          test_cmd="npx jest"
        elif grep -q '"vitest"' "${dir}/package.json" 2>/dev/null; then
          test_cmd="npx vitest run"
        elif grep -q '"mocha"' "${dir}/package.json" 2>/dev/null; then
          test_cmd="npx mocha"
        fi
        if grep -q '"eslint"' "${dir}/package.json" 2>/dev/null; then
          lint_cmd="npx eslint ."
        elif grep -q '"biome"' "${dir}/package.json" 2>/dev/null; then
          lint_cmd="npx biome check ."
        fi
        if ! grep -q '"typescript"' "${dir}/package.json" 2>/dev/null; then
          typecheck_cmd="n/a (JavaScript project)"
        fi
        if ! grep -q '"build"' "${dir}/package.json" 2>/dev/null; then
          build_cmd="n/a (no build script)"
        fi
      fi

      echo "${test_cmd}|${lint_cmd}|${typecheck_cmd}|${build_cmd}|TypeScript/JavaScript|ES modules or CommonJS per project config. Follow existing import style."
      ;;

    python-req|python-pyproject)
      local test_cmd="pytest"
      local lint_cmd="ruff check ."
      local typecheck_cmd="mypy ."
      local build_cmd="pip install -e ."
      local conventions="Follow PEP 8. Use type hints. Prefer dataclasses or Pydantic for data models."

      if [ -f "${dir}/pyproject.toml" ]; then
        if grep -q '\[tool.poetry\]' "${dir}/pyproject.toml" 2>/dev/null; then
          build_cmd="poetry install"
          test_cmd="poetry run pytest"
          lint_cmd="poetry run ruff check ."
          typecheck_cmd="poetry run mypy ."
        elif grep -q 'hatch' "${dir}/pyproject.toml" 2>/dev/null; then
          build_cmd="hatch install"
          test_cmd="hatch run pytest"
        fi
      fi

      echo "${test_cmd}|${lint_cmd}|${typecheck_cmd}|${build_cmd}|Python|${conventions}"
      ;;

    rust)
      echo "cargo test|cargo clippy|cargo check|cargo build|Rust|Follow clippy suggestions. Use cargo fmt. Prefer idiomatic Rust — avoid unnecessary clones."
      ;;

    go)
      echo "go test ./...|golangci-lint run|go vet|go build|Go|FollowEffective Go. Use gofmt. Keep packages focused."
      ;;

    ruby)
      echo "bundle exec rspec|bundle exec rubocop|n/a (Ruby)|bundle exec rake|Ruby|Follow RuboCop config. Use frozen string literals. Prefer RSpec for tests."
      ;;

    flutter)
      echo "flutter test|flutter analyze|dart analyze|flutter build|Dart|Follow effective Dart. Use flutter_lints. Prefer const constructors."
      ;;

    maven)
      echo "mvn test|mvn checkstyle:check|mvn compile|mvn package|Java|Follow Google Java Style. Use JUnit 5. Prefer constructor injection."
      ;;

    gradle)
      echo "./gradlew test|./gradlew checkstyleMain|./gradlew compileJava|./gradlew build|Java/Kotlin|Follow existing Gradle config. Use JUnit 5. Prefer constructor injection."
      ;;

    php)
      echo "vendor/bin/phpunit|vendor/bin/php-cs-fixer check|vendor/bin/phpstan analyse|composer install|PHP|Follow PSR-12. Use PHPStan level 8. Prefer typed properties."
      ;;

    elixir)
      echo "mix test|mix credo|mix dialyzer|mix compile|Elixir|Follow mix format. Use Dialyxir. Prefer pattern matching over guards."
      ;;

    cmake)
      echo "ctest|clang-tidy|cppcheck|cmake --build build|C/C++|Follow project's existing style. Use CTest for test registration."
      ;;

    deno)
      echo "deno test|deno lint|deno check .|deno compile|TypeScript/JavaScript (Deno)|Follow Deno style guide. Use ES modules. Prefer deno.json for config."
      ;;

    bun)
      echo "bun test|bun run lint|bun run typecheck|bun run build|TypeScript/JavaScript (Bun)|Follow existing project config. Use Bun's built-in test runner."
      ;;

    *)
      echo "echo 'no test runner configured'|echo 'no linter configured'|n/a|echo 'no build step'|Unknown|Configure manually in docs/agents/constitution.md"
      ;;
  esac
}

# --- Constitution generation ---

generate_constitution() {
  local project_name="$1"
  local stack_config="$2"
  local stack_name="$3"

  IFS='|' read -r test_cmd lint_cmd typecheck_cmd build_cmd language conventions <<< "$stack_config"

  local template
  template=$(cat "${TEMPLATES_DIR}/constitution.md")

  # Replace placeholders with detected values
  local constitution
  constitution=$(echo "$template" | \
    sed "s|\[Project Name\]|${project_name}|g" | \
    sed "s|\[BOOTSTRAP: TEST_CMD\]|${test_cmd}|g" | \
    sed "s|\[BOOTSTRAP: LINT_CMD\]|${lint_cmd}|g" | \
    sed "s|\[BOOTSTRAP: TYPECHECK_CMD\]|${typecheck_cmd}|g" | \
    sed "s|\[BOOTSTRAP: BUILD_CMD\]|${build_cmd}|g" | \
    sed "s|\[BOOTSTRAP: LANGUAGE\]|${language}|g" | \
    sed "s|\[BOOTSTRAP: CONVENTIONS\]|${conventions}|g")

  # If the template doesn't have bootstrap markers, append a detected config section
  if ! echo "$template" | grep -q '\[BOOTSTRAP:'; then
    constitution+=$(cat <<EOF

## Detected Stack Configuration

- **Language:** ${language}
- **Test command:** \`${test_cmd}\`
- **Lint command:** \`${lint_cmd}\`
- **Typecheck command:** \`${typecheck_cmd}\`
- **Build command:** \`${build_cmd}\`
- **Conventions:** ${conventions}
EOF
)
  fi

  echo "$constitution"
}

# --- Main ---

echo "=== dev-workflows bootstrap ==="
echo ""

# Detect project name
PROJECT_NAME=$(basename "$(cd "${PROJECT_DIR}" && pwd)")
echo "Project: ${PROJECT_NAME}"

# Detect stack
STACKS=$(detect_stack "${PROJECT_DIR}")
echo "Detected stack(s): ${STACKS}"

if [ "$STACKS" = "none" ]; then
  echo ""
  echo "WARNING: No recognized project stack detected."
  echo "Looked for: package.json, requirements.txt, pyproject.toml, Cargo.toml,"
  echo "go.mod, Gemfile, pubspec.yaml, pom.xml, build.gradle, composer.json, etc."
  echo ""
  echo "Creating docs structure with generic defaults. Edit constitution.md manually."
  
  # Create dirs
  mkdir -p "${AGENTS_DIR}"
  
  # Copy templates with generic defaults
  cp "${TEMPLATES_DIR}/constitution.md" "${AGENTS_DIR}/constitution.md" 2>/dev/null || true
  cp "${TEMPLATES_DIR}/current-sprint.md" "${AGENTS_DIR}/current-sprint.md" 2>/dev/null || true
  cp "${TEMPLATES_DIR}/build-log.md" "${AGENTS_DIR}/build-log.md" 2>/dev/null || true
  cp "${TEMPLATES_DIR}/decision-log.md" "${AGENTS_DIR}/decision-log.md" 2>/dev/null || true
  cp "${TEMPLATES_DIR}/assumptions.md" "${AGENTS_DIR}/assumptions.md" 2>/dev/null || true
  cp "${TEMPLATES_DIR}/open-questions.md" "${AGENTS_DIR}/open-questions.md" 2>/dev/null || true
  cp "${TEMPLATES_DIR}/agent-file-templates.md" "${AGENTS_DIR}/agent-file-templates.md" 2>/dev/null || true
  
  echo ""
  echo "Created: ${AGENTS_DIR}/"
  echo "Done. Edit docs/agents/constitution.md to configure your stack manually."
  exit 0
fi

# Use the first detected stack as primary
PRIMARY_STACK=$(echo "$STACKS" | awk '{print $1}')
STACK_CONFIG=$(get_stack_config "$PRIMARY_STACK" "${PROJECT_DIR}")

# Parse config
IFS='|' read -r test_cmd lint_cmd typecheck_cmd build_cmd language conventions <<< "$STACK_CONFIG"

echo ""
echo "=== Detected Configuration ==="
echo "Primary stack: ${PRIMARY_STACK}"
echo "Language:      ${language}"
echo "Test:          ${test_cmd}"
echo "Lint:          ${lint_cmd}"
echo "Typecheck:     ${typecheck_cmd}"
echo "Build:         ${build_cmd}"
echo "Conventions:   ${conventions}"
echo ""

# Create docs structure
echo "Creating docs structure..."
mkdir -p "${AGENTS_DIR}"

# Generate constitution
echo "Generating constitution..."
CONSTITUTION=$(generate_constitution "${PROJECT_NAME}" "${STACK_CONFIG}" "${PRIMARY_STACK}")
echo "${CONSTITUTION}" > "${AGENTS_DIR}/constitution.md"

# Copy log templates (these don't need stack-specific customization)
for tmpl in current-sprint.md build-log.md decision-log.md assumptions.md open-questions.md agent-file-templates.md; do
  if [ -f "${TEMPLATES_DIR}/${tmpl}" ]; then
    cp "${TEMPLATES_DIR}/${tmpl}" "${AGENTS_DIR}/${tmpl}"
  fi
done

# Create empty PRD and implementation plan placeholders if they don't exist
if [ ! -f "${DOCS_DIR}/prd.md" ]; then
  echo "# ${PROJECT_NAME} — PRD" > "${DOCS_DIR}/prd.md"
  echo "" >> "${DOCS_DIR}/prd.md"
  echo "> Run the PRD Builder skill to populate this document." >> "${DOCS_DIR}/prd.md"
fi

if [ ! -f "${DOCS_DIR}/implementation-plan.md" ]; then
  echo "# ${PROJECT_NAME} — Implementation Plan" > "${DOCS_DIR}/implementation-plan.md"
  echo "" >> "${DOCS_DIR}/implementation-plan.md"
  echo "> Run the PRD Builder skill to populate this document." >> "${DOCS_DIR}/implementation-plan.md"
fi

# Summary
echo ""
echo "=== Bootstrap Complete ==="
echo ""
echo "Files created:"
echo "  ${AGENTS_DIR}/constitution.md          (customized for ${language})"
echo "  ${AGENTS_DIR}/current-sprint.md         (empty template)"
echo "  ${AGENTS_DIR}/build-log.md              (empty template)"
echo "  ${AGENTS_DIR}/decision-log.md           (empty template)"
echo "  ${AGENTS_DIR}/assumptions.md            (empty template)"
echo "  ${AGENTS_DIR}/open-questions.md         (empty template)"
echo "  ${AGENTS_DIR}/agent-file-templates.md   (format reference)"
echo "  ${DOCS_DIR}/prd.md                      (placeholder)"
echo "  ${DOCS_DIR}/implementation-plan.md      (placeholder)"
echo ""
echo "Next steps:"
echo "  1. Edit docs/agents/constitution.md — add project-specific safety rules and constraints"
echo "  2. Run the PRD Builder skill to generate your PRD and implementation plan"
echo "  3. Run the Sprint Orchestrator skill to start building"
echo ""
if [ $(echo "$STACKS" | wc -w) -gt 1 ]; then
  echo "NOTE: Multiple stacks detected (${STACKS}). Constitution was customized for"
  echo "      ${PRIMARY_STACK}. Review and adjust for your primary stack."
  echo ""
fi