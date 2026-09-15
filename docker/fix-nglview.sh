#!/usr/bin/env bash
set -euo pipefail

# Locate nglview's Python frontend file
NGLVIEW_DIR=$(python -c "import nglview, os; print(os.path.dirname(nglview.__file__))")
FRONTEND_FILE="$NGLVIEW_DIR/_frontend.py"

if [[ ! -f "$FRONTEND_FILE" ]]; then
    echo "nglview _frontend.py not found, skipping patch" >&2
    exit 0
fi

# Locate the installed labextension's package.json by searching
# every labextensions directory Jupyter knows about (handles conda's
# $CONDA_PREFIX/share/jupyter/labextensions layout automatically)
LABEXT_PKG=$(python -c "
from jupyter_core.paths import jupyter_path
import os, sys
for d in jupyter_path('labextensions'):
    candidate = os.path.join(d, 'nglview-js-widgets', 'package.json')
    if os.path.isfile(candidate):
        print(candidate)
        sys.exit(0)
sys.exit(1)
") || { echo "nglview-js-widgets labextension not found, skipping patch" >&2; exit 0; }

PY_VERSION=$(python -c "import re; print(re.search(r\"__frontend_version__ = '([^']+)'\", open('$FRONTEND_FILE').read()).group(1))")
JS_VERSION=$(python -c "import json; print(json.load(open('$LABEXT_PKG'))['version'])")

# If there is a version mismatch then make them the same python side.
if [[ "$PY_VERSION" != "$JS_VERSION" ]]; then
    echo "nglview mismatch: python=$PY_VERSION js=$JS_VERSION (found at $LABEXT_PKG) -- patching"
    sed -i "s/__frontend_version__ = '$PY_VERSION'/__frontend_version__ = '$JS_VERSION'/" "$FRONTEND_FILE"
else
    echo "nglview versions already match ($PY_VERSION), skipping patch"
fi
