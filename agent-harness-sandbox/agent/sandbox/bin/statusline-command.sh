#!/bin/sh
# Claude Code status line for agent-harness-sandbox.
# Reads Claude's status JSON on stdin and prints:
# cwd | model | context | rate limits | optional tokenbank savings

input=$(cat)

cwd=$(echo "$input" | jq -r '.workspace.current_dir // .cwd // empty' 2>/dev/null)
model=$(echo "$input" | jq -r '.model.display_name // .model.name // empty' 2>/dev/null)
used=$(echo "$input" | jq -r '.context_window.used_percentage // empty' 2>/dev/null)
remaining=$(echo "$input" | jq -r '.context_window.remaining_percentage // empty' 2>/dev/null)

[ -n "$cwd" ] || cwd="$(pwd)"
[ -n "$model" ] || model="model"

if [ -n "$used" ] && [ -n "$remaining" ]; then
  ctx="${used}% used / ${remaining}% remaining"
else
  ctx="no messages yet"
fi

bar() {
  pct=$(printf '%.0f' "$1" 2>/dev/null || printf '0')
  filled=$(( (pct + 5) / 10 ))
  [ "$filled" -gt 10 ] && filled=10
  i=0; out=""
  while [ "$i" -lt 10 ]; do
    if [ "$i" -lt "$filled" ]; then out="${out}▓"; else out="${out}░"; fi
    i=$((i + 1))
  done
  printf '%s' "$out"
}

fmt_time() {
  date -r "$1" +"$2" 2>/dev/null || date -d "@$1" +"$2" 2>/dev/null
}

limits=""
fh_pct=$(echo "$input" | jq -r '.rate_limits.five_hour.used_percentage // empty' 2>/dev/null)
fh_reset=$(echo "$input" | jq -r '.rate_limits.five_hour.resets_at // empty' 2>/dev/null)
wk_pct=$(echo "$input" | jq -r '.rate_limits.seven_day.used_percentage // empty' 2>/dev/null)
wk_reset=$(echo "$input" | jq -r '.rate_limits.seven_day.resets_at // empty' 2>/dev/null)

if [ -n "$fh_pct" ]; then
  reset_str=""
  [ -n "$fh_reset" ] && reset_str=" ↻$(fmt_time "$fh_reset" %H:%M)"
  limits="5h $(bar "$fh_pct") $(printf '%.0f' "$fh_pct")%${reset_str}"
fi
if [ -n "$wk_pct" ]; then
  reset_str=""
  [ -n "$wk_reset" ] && reset_str=" ↻$(fmt_time "$wk_reset" "%a %H:%M")"
  limits="${limits:+$limits  }wk $(bar "$wk_pct") $(printf '%.0f' "$wk_pct")%${reset_str}"
fi

tb=""
for candidate in "${TB_STATUSLINE:-}" "$HOME/.tokenbank/tb-statusline.cjs" "$HOME/.tokenbank/tb-statusline.js"; do
  if [ -n "$candidate" ] && command -v node >/dev/null 2>&1 && [ -f "$candidate" ]; then
    tb=$(node "$candidate" 2>/dev/null || true)
    [ -n "$tb" ] && break
  fi
done

printf "\033[34m%s\033[0m  |  \033[33m%s\033[0m  |  context: \033[32m%s\033[0m" "$cwd" "$model" "$ctx"
[ -n "$limits" ] && printf "  |  \033[36m%s\033[0m" "$limits"
[ -n "$tb" ] && printf "  |  %s" "$tb"
exit 0
