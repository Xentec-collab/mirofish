#!/usr/bin/env bash
export PATH="$HOME/.local/bin:$HOME/.cargo/bin:$PATH"

echo "=========================================="
echo "    Starting MiroFish Cloud Simulation    "
echo "=========================================="

# Terminate any previously running backend or frontend processes so new code loads
echo "Cleaning up any old server processes..."
pkill -f "python run.py" 2>/dev/null || true
pkill -f "vite" 2>/dev/null || true
sleep 1

# Check if .env has the API keys configured
if [ ! -f .env ] && [ -n "$LLM_API_KEY" ]; then
    cat <<EOF > .env
LLM_API_KEY=$LLM_API_KEY
LLM_BASE_URL=${LLM_BASE_URL:-https://generativelanguage.googleapis.com/v1beta/openai/}
LLM_MODEL_NAME=${LLM_MODEL_NAME:-gemini-3.1-flash-lite}
ZEP_API_KEY=$ZEP_API_KEY
EOF
fi

if [ -f .env ]; then
    # Auto-migrate deprecated/overloaded models in existing .env
    sed -i 's/gemini-3.5-flash-lite/gemini-3.1-flash-lite/g' .env 2>/dev/null || true
    sed -i 's/gemini-2.5-flash-lite/gemini-3.1-flash-lite/g' .env 2>/dev/null || true
    sed -i 's/gemini-2.5-flash/gemini-3.1-flash-lite/g' .env 2>/dev/null || true
    sed -i 's/gemini-3.8-flash/gemini-3.1-flash-lite/g' .env 2>/dev/null || true

    if grep -q "LLM_API_KEY=your_api_key_here" .env && [ -z "$LLM_API_KEY" ]; then
        echo "[WARNING] You have not configured LLM_API_KEY in .env yet!"
        echo "Please edit .env with your Gemini/OpenAI and Zep API keys."
    fi
fi

# Run backend and frontend concurrently
echo "Starting backend and frontend..."
npm run dev
