#!/usr/bin/env bash
export PATH="$HOME/.local/bin:$HOME/.cargo/bin:$PATH"

echo "=========================================="
echo "    Starting MiroFish Cloud Simulation    "
echo "=========================================="

# Check if .env has the API keys configured
if [ ! -f .env ] && [ -n "$LLM_API_KEY" ]; then
    cat <<EOF > .env
LLM_API_KEY=$LLM_API_KEY
LLM_BASE_URL=${LLM_BASE_URL:-https://generativelanguage.googleapis.com/v1beta/openai/}
LLM_MODEL_NAME=${LLM_MODEL_NAME:-gemini-3.5-flash-lite}
ZEP_API_KEY=$ZEP_API_KEY
EOF
fi

if [ -f .env ]; then
    if grep -q "LLM_API_KEY=your_api_key_here" .env && [ -z "$LLM_API_KEY" ]; then
        echo "[WARNING] You have not configured LLM_API_KEY in .env yet!"
        echo "Please edit .env with your Gemini/OpenAI and Zep API keys."
    fi
fi

# Run backend and frontend concurrently
npm run dev
