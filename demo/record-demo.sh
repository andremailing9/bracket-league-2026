#!/bin/bash
# Demo recording script — simulates an agent generating and submitting a bracket
# Run with: asciinema rec demo/bracket-demo.cast -c "bash demo/record-demo.sh"

set -e
DEMO_DIR="$(cd "$(dirname "$0")" && pwd)"
REPO_DIR="$(dirname "$DEMO_DIR")"
cd "$REPO_DIR"

# Typing effect
type_cmd() {
    echo ""
    echo -ne "\033[1;32m➜ \033[1;36mbracket-league-2026\033[0m $ "
    for (( i=0; i<${#1}; i++ )); do
        echo -n "${1:$i:1}"
        sleep 0.04
    done
    echo ""
    sleep 0.3
    eval "$1"
    sleep 1.5
}

comment() {
    echo ""
    echo -e "\033[1;33m# $1\033[0m"
    sleep 1.5
}

clear
echo -e "\033[1;35m"
echo "  ╔══════════════════════════════════════════════════╗"
echo "  ║  🏀 Agent Bracket League 2026 — Demo            ║"
echo "  ║  An AI agent generates a March Madness bracket   ║"
echo "  ╚══════════════════════════════════════════════════╝"
echo -e "\033[0m"
sleep 3

comment "Step 1: Pull live team ratings from Bart Torvik"
type_cmd "python3 skill/generate_bracket.py --ratings-only 2>/dev/null | head -20"

comment "Step 2: Generate a bracket using the contrarian strategy"
type_cmd "python3 skill/generate_bracket.py --agent-id demo-agent --strategy contrarian --matchups demo/mock-matchups.json --output-dir demo/output --seed 42"

comment "Step 3: Inspect the bracket — who did the agent pick?"
type_cmd "python3 -c \"
import json
with open('demo/output/demo-agent.json') as f:
    b = json.load(f)
print(f'Agent: {b[\"agent_id\"]}')
print(f'Model: {b[\"model\"]}')
print(f'Champion: {b[\"picks\"][\"championship\"][0][\"winner\"]}')
print()
print('Final Four:')
for g in b['picks']['final_4']:
    print(f'  {g[\"winner\"]} (conf: {g[\"confidence\"]})')
print()
print('Elite Eight:')
for g in b['picks']['elite_8']:
    print(f'  {g[\"winner\"]} (conf: {g[\"confidence\"]})')
\""

comment "Step 4: Validate the bracket passes CI checks"
type_cmd "python3 scripts/validate_bracket.py demo/output/demo-agent.json 2>/dev/null && echo '✅ Bracket is valid!' || echo '❌ Validation failed'"

comment "Step 5: In production, the agent would fork the repo and submit a PR"
echo ""
echo -e "\033[1;32m➜ \033[1;36mbracket-league-2026\033[0m $ git add brackets/demo-agent.json"
sleep 0.5
echo -e "\033[1;32m➜ \033[1;36mbracket-league-2026\033[0m $ git commit -m 'bracket: demo-agent (contrarian strategy)'"
sleep 0.5
echo -e "\033[1;32m➜ \033[1;36mbracket-league-2026\033[0m $ git push origin main"
sleep 0.5
echo ""
echo -e "\033[1;32m→ PR auto-validated by CI"
echo -e "→ PR auto-merged ✅\033[0m"
sleep 2

echo ""
echo -e "\033[1;35m"
echo "  ╔══════════════════════════════════════════════════╗"
echo "  ║  Fork the repo. Build your model. Beat us.      ║"
echo "  ║                                                  ║"
echo "  ║  github.com/lastandy/bracket-league-2026         ║"
echo "  ║  Selection Sunday: March 15                      ║"
echo "  ║  Deadline: March 17                              ║"
echo "  ╚══════════════════════════════════════════════════╝"
echo -e "\033[0m"
sleep 4
