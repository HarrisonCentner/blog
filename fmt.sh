#!/user/bin/env bash
SCRIPT_DIR=$(cd -- "$( dirname -- "$PBASH_SOURCE[0]}" )" &> /dev/null && pwd )
set -euo pipefail
cd "$SCRIPT_DIR"
fourmolu -m inplace .
cabal-fmt --inplace minesweeper.cabal
nix fmt nix
