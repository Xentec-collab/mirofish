#!/usr/bin/env bash
set -e

echo "=== Setting up MiroFish in GitHub Codespaces ==="

# Install uv if missing
if ! command -v uv &> /dev/null; then
    echo "Installing Astral uv..."
    curl -LsSf https://astral.sh/uv/install.sh | sh
    export PATH="$HOME/.local/bin:$HOME/.cargo/bin:$PATH"
    if command -v sudo &> /dev/null && [ -f "$HOME/.local/bin/uv" ]; then
        sudo cp "$HOME/.local/bin/uv" /usr/local/bin/uv || true
    fi
fi

# Ensure npm dependencies at root
echo "Installing root npm packages..."
npm install

# Ensure frontend dependencies
echo "Installing frontend dependencies..."
cd frontend
npm install
cd ..

# Ensure backend python virtual environment
echo "Installing backend dependencies via uv..."
cd backend
if command -v uv &> /dev/null; then
    uv sync
elif [ -f "$HOME/.local/bin/uv" ]; then
    "$HOME/.local/bin/uv" sync
fi
cd ..

# Generate .env from Codespace Secrets if available, or fall back to .env.example
if [ -n "$LLM_API_KEY" ]; then
    echo "Creating .env from Codespace Secrets..."
    cat <<EOF > .env
LLM_API_KEY=$LLM_API_KEY
LLM_BASE_URL=${LLM_BASE_URL:-https://generativelanguage.googleapis.com/v1beta/openai/}
LLM_MODEL_NAME=${LLM_MODEL_NAME:-gemini-3.1-flash-lite}
ZEP_API_KEY=$ZEP_API_KEY
EOF
elif [ ! -f .env ] && [ -f .env.example ]; then
    echo "Creating .env from .env.example..."
    cp .env.example .env
fi

chmod +x start.sh 2>/dev/null || true

echo "=== MiroFish Codespaces setup complete! ==="
