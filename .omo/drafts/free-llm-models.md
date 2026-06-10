# Free Cloud LLM APIs: Comprehensive Guide

> **Compiled**: June 10, 2026
> **Purpose**: Find free LLM APIs (no credit card required, or free tier) to use as model backends for opencode, CLI tools, and development workflows.
> **Caveat emtor**: Free tiers change. Verify current limits before depending on any provider.

---

## Quick Comparison

| Provider | No CC Required | Best Free Model(s) | Rate Limit | OpenAI Compatible | opencode Config Key |
|----------|:---:|:---|:---|:---:|:---|
| **Google Gemini AI Studio** | ✅ | Gemini 2.0 Flash, 1.5 Pro | 60 req/min (Flash) | ✅ (proxy) | `google/gemini-2.0-flash-exp` |
| **Groq** | ✅ | Llama 3.3 70B, Mixtral 8x7B | 30 req/min | ✅ native | `groq/llama-3.3-70b-versatile` |
| **GitHub Models** | ✅ | GPT-4o-mini, DeepSeek V3, Llama 3.3 | 10-50 req/min | ✅ native | `github/gpt-4o-mini` |
| **Cerebras** | ✅ | Llama 3.1 70B | 10 req/min | ✅ native | `cerebras/llama-3.1-70b` |
| **Mistral AI** | ✅ | Mistral Small, Codestral | 50 req/min | ✅ native | `mistral/mistral-small-latest` |
| **Hugging Face** | ✅ | DeepSeek V3, Qwen 2.5 | 30 req/min | ✅ (Inference API) | `huggingface/deepseek-v3` |
| **Cloudflare Workers AI** | ✅ | Llama 3.1 70B, Qwen 2.5 Coder | 10000 req/day | ✅ | `cloudflare/@cf/meta/llama-3.1-70b` |
| **NVIDIA NIM** | ✅ | Llama 3.1 70B, Mixtral 8x7B | 20 req/min | ✅ | `nvidia/llama-3.1-70b` |
| **DeepInfra** | ✅ | Llama 3.3 70B, Qwen 2.5 72B | 30 req/min | ✅ native | `deepinfra/meta-llama/llama-3.3-70b` |
| **Together AI** | ❌ (CC) | Mixtral 8x7B, DeepSeek V3 | 10 req/min (free) | ✅ native | `together/mistralai/Mixtral-8x7B-v0.1` |
| **OpenRouter** | ✅ | Many free models listed | Varies by model | ✅ native | `openrouter/google/gemini-2.0-flash-free` |
| **Replicate** | ❌ (CC) | Llama 3, Mixtral | Free tier limits | ✅ (proxy) | — |

---

## 1. Google Gemini (AI Studio) ⭐ BEST OVERALL

**Why it's #1**: Best free model quality (Gemini 2.0 Flash beats most paid models), no credit card, 60 req/min, available globally.

### Sign Up
1. Go to [aistudio.google.com](https://aistudio.google.com/)
2. Sign in with any Google account (Gmail, Workspace)
3. No credit card needed — free tier activated immediately
4. Get API key: Click **"Get API Key"** → **"Create API Key"** → Copy key

### Models & Limits
| Model | Free Limit |
|-------|-----------|
| Gemini 2.0 Flash | 60 req/min, 1,500 req/day |
| Gemini 2.0 Flash-Lite | 60 req/min, 1,500 req/day |
| Gemini 1.5 Pro | 10 req/min, 400 req/day |
| Gemini 1.5 Flash | 30 req/min, 1,000 req/day |

### OpenAI-Compatible Endpoint
Google provides a proxy endpoint:
```
https://generativelanguage.googleapis.com/v1beta/openai/
```
With API key passed via HTTP header `x-goog-api-key`.

**opencode config**:
```json
{
  "providers": {
    "google": {
      "baseUrl": "https://generativelanguage.googleapis.com/v1beta/openai",
      "apiKey": "YOUR_API_KEY",
      "headerPrefix": "x-goog-api-key"
    }
  },
  "models": {
    "google/gemini-2.0-flash-exp": {
      "provider": "google",
      "model": "google/gemini-2.0-flash-exp",
      "maxTokens": 8192,
      "contextLength": 1048576
    }
  }
}
```

### Notes
- ✅ No credit card required
- ✅ Huge context window (1M tokens for Flash)
- ✅ Works worldwide
- ⚠️ Google sometimes changes terms — always check

---

## 2. Groq ⭐ FASTEST

**Why it's great**: Insane inference speed (up to 1000 tok/s on Llama 3), no credit card, OpenAI-compatible.

### Sign Up
1. Go to [console.groq.com](https://console.groq.com/)
2. Sign up with Google/GitHub/email
3. No credit card needed
4. API key auto-generated in dashboard

### Free Models & Limits
| Model | Rate Limit | Speed |
|-------|-----------|-------|
| Llama 3.3 70B | 30 req/min | ~250 tok/s |
| Llama 3.1 8B | 30 req/min | ~1000 tok/s |
| Mixtral 8x7B | 30 req/min | ~500 tok/s |
| Gemma 2 9B | 30 req/min | ~500 tok/s |

**opencode config**:
```json
{
  "providers": {
    "groq": {
      "baseUrl": "https://api.groq.com/openai/v1",
      "apiKey": "YOUR_GROQ_API_KEY"
    }
  },
  "models": {
    "groq/llama-3.3-70b-versatile": {
      "provider": "groq",
      "model": "llama-3.3-70b-versatile",
      "maxTokens": 8192,
      "contextLength": 128000
    }
  }
}
```

### Notes
- ✅ No credit card required
- ✅ Fastest inference of any free provider
- ✅ Native OpenAI-compatible API
- ⚠️ Rate limited to 30 req/min on free tier (adequate for coding)

---

## 3. GitHub Models ⭐ EASIEST FOR DEVELOPERS

**Why it's great**: Use your existing GitHub account, access GPT-4o-mini, DeepSeek V3, Llama 3.3, and more — all free, no credit card.

### Sign Up
1. Go to [github.com/marketplace/models](https://github.com/marketplace/models)
2. Sign in with your GitHub account
3. Click **"Get developer access"** → Agree to terms
4. Generate token: `Settings` → `Developer settings` → `Personal access tokens` → `Fine-grained tokens`
   - No special permissions needed — just create a token with any name and use it
5. Copy the token — this is your API key

### Free Models & Limits
| Model | Requests per minute |
|-------|:---:|
| GPT-4o-mini | 50 |
| GPT-4o | 10 |
| DeepSeek V3 | 10 |
| DeepSeek R1 | 10 |
| Llama 3.3 70B | 10 |
| Llama 3.1 70B | 10 |
| Mistral Large | 10 |
| Phi-4 | 50 |
| Cohere Command R+ | 10 |
| Azure AI models | 10 |

### OpenAI-Compatible Endpoint
```
https://models.inference.ai.azure.com
```
Uses standard `Authorization: Bearer <token>` header.

**opencode config**:
```json
{
  "providers": {
    "github": {
      "baseUrl": "https://models.inference.ai.azure.com",
      "apiKey": "YOUR_GITHUB_TOKEN"
    }
  },
  "models": {
    "github/gpt-4o-mini": {
      "provider": "github",
      "model": "gpt-4o-mini",
      "maxTokens": 16384,
      "contextLength": 128000
    },
    "github/deepseek-v3": {
      "provider": "github",
      "model": "DeepSeek-V3",
      "maxTokens": 8192,
      "contextLength": 128000
    },
    "github/llama-3.3-70b": {
      "provider": "github",
      "model": "Llama-3.3-70B-Instruct",
      "maxTokens": 4096,
      "contextLength": 128000
    }
  }
}
```

### Notes
- ✅ Uses existing GitHub account — no new signup
- ✅ No credit card required
- ✅ Wide model selection including GPT-4o
- ✅ Native OpenAI-compatible API
- ⚠️ Token expires — set a long expiry or create a service account
- Rate limits seem generous and may change

---

## 4. Cerebras ⭐ FASTEST HARDWARE

**Why it's great**: Specialized hardware (wafer-scale chips) delivers extremely fast Llama inference. No credit card.

### Sign Up
1. Go to [inference.cerebras.ai](https://inference.cerebras.ai/)
2. Click **"Get API Key"** → Sign up with email
3. No credit card needed
4. API key emailed to you immediately

### Free Models & Limits
| Model | Rate Limit |
|-------|:---:|
| Llama 3.1 8B | 10 req/min |
| Llama 3.1 70B | 10 req/min |

**opencode config**:
```json
{
  "providers": {
    "cerebras": {
      "baseUrl": "https://api.cerebras.ai/v1",
      "apiKey": "YOUR_CEREBRAS_API_KEY"
    }
  },
  "models": {
    "cerebras/llama-3.1-70b": {
      "provider": "cerebras",
      "model": "llama3.1-70b",
      "maxTokens": 4096,
      "contextLength": 8192
    }
  }
}
```

### Notes
- ✅ No credit card required
- ✅ Very fast inference
- ⚠️ Limited model selection (only Llama 3.1 variants)

---

## 5. Mistral AI

**Why it's great**: French AI lab offering their latest models free. Codestral is excellent for code generation.

### Sign Up
1. Go to [console.mistral.ai](https://console.mistral.ai/)
2. Sign up with Google/email
3. No credit card needed
4. API key in dashboard → API Keys → Create

### Free Models & Limits
| Model | Limit |
|-------|:---:|
| Mistral Small (v3.1) | 50 req/min |
| Codestral (v25.03) | 50 req/min |
| Mistral Nemo | 50 req/min |
| Mistral Embeddings | 50 req/min |

**opencode config**:
```json
{
  "providers": {
    "mistral": {
      "baseUrl": "https://api.mistral.ai/v1",
      "apiKey": "YOUR_MISTRAL_API_KEY"
    }
  },
  "models": {
    "mistral/mistral-small-latest": {
      "provider": "mistral",
      "model": "mistral-small-latest",
      "maxTokens": 8192,
      "contextLength": 128000
    },
    "mistral/codestral-latest": {
      "provider": "mistral",
      "model": "codestral-latest",
      "maxTokens": 8192,
      "contextLength": 256000
    }
  }
}
```

### Notes
- ✅ No credit card required
- ✅ Codestral is specialized for code — great for opencode
- ✅ 256K context on Codestral
- ⚠️ French company — data stored in EU (GDPR, may be pro or con)

---

## 6. Hugging Face Inference API

**Why it's great**: Access dozens of models through one API. Free tier available with rate limits.

### Sign Up
1. Go to [huggingface.co](https://huggingface.co/)
2. Sign up with email/GitHub/Google
3. No credit card needed
4. API key: Settings → Access Tokens → New Token

### Free Tier
- **Rate Limit**: ~30 requests per minute (varies by model)
- **Models**: DeepSeek V3, Qwen 2.5 72B, Llama 3.3, and hundreds more
- **Note**: Free models change frequently. Check [huggingface.co/chat/models](https://huggingface.co/chat/models) for current free offerings.

**opencode config**:
```json
{
  "providers": {
    "huggingface": {
      "baseUrl": "https://api-inference.huggingface.co",
      "apiKey": "YOUR_HF_API_KEY"
    }
  },
  "models": {
    "huggingface/deepseek-v3": {
      "provider": "huggingface",
      "model": "deepseek-ai/DeepSeek-V3",
      "maxTokens": 4096,
      "contextLength": 32768
    }
  }
}
```

### Notes
- ✅ No credit card required
- ✅ Huge model selection
- ⚠️ Free tier queue — paid users get priority
- ⚠️ Model availability changes frequently

---

## 7. Cloudflare Workers AI

**Why it's great**: 10,000 requests/day free, no credit card, integrated with Cloudflare ecosystem.

### Sign Up
1. Go to [dash.cloudflare.com](https://dash.cloudflare.com/)
2. Sign up with email
3. **No credit card needed for Workers AI**
4. API key: `My Profile` → `API Tokens` → `Create Token` → `Workers AI` template

### Free Models & Limits
| Model | Free Limit |
|-------|:---:|
| Llama 3.1 70B | 10,000 req/day |
| Llama 3.1 8B | 10,000 req/day |
| Qwen 2.5 Coder 7B | 10,000 req/day |
| DeepSeek Coder 6.7B | 10,000 req/day |
| Mistral 7B | 10,000 req/day |

**opencode config**:
```json
{
  "providers": {
    "cloudflare": {
      "baseUrl": "https://api.cloudflare.com/client/v4/accounts/YOUR_ACCOUNT_ID/ai/v1",
      "apiKey": "YOUR_CF_API_TOKEN",
      "headerPrefix": "Authorization"
    }
  },
  "models": {
    "cloudflare/@cf/meta/llama-3.1-70b": {
      "provider": "cloudflare",
      "model": "@cf/meta/llama-3.1-70b-instruct",
      "maxTokens": 2048,
      "contextLength": 8192
    },
    "cloudflare/@cf/qwen/qwen2.5-coder-7b": {
      "provider": "cloudflare",
      "model": "@cf/qwen/qwen2.5-coder-7b-instruct",
      "maxTokens": 2048,
      "contextLength": 32768
    }
  }
}
```

### Notes
- ✅ No credit card required
- ✅ 10,000 req/day — generous free tier
- Needs your Cloudflare Account ID (viewable in dashboard URL)
- ⚠️ Not a standard OpenAI-compatible API — may need custom adapter
- ⚠️ Requires Cloudflare account (global)

---

## 8. NVIDIA NIM

**Why it's great**: NVIDIA's managed inference service with free tier. Access Llama 3.1, Mixtral, and other popular models.

### Sign Up
1. Go to [build.nvidia.com](https://build.nvidia.com/)
2. Sign up with email
3. No credit card needed
4. API key: Dashboard → API Keys → Generate

### Free Models & Limits
| Model | Rate Limit |
|-------|:---:|
| Llama 3.1 70B | 20 req/min |
| Llama 3.1 8B | 20 req/min |
| Mixtral 8x7B | 20 req/min |

**opencode config**:
```json
{
  "providers": {
    "nvidia": {
      "baseUrl": "https://integrate.api.nvidia.com/v1",
      "apiKey": "YOUR_NVIDIA_API_KEY"
    }
  },
  "models": {
    "nvidia/llama-3.1-70b": {
      "provider": "nvidia",
      "model": "meta/llama-3.1-70b-instruct",
      "maxTokens": 4096,
      "contextLength": 128000
    }
  }
}
```

### Notes
- ✅ No credit card required
- ✅ Runs on NVIDIA hardware — optimized inference
- ⚠️ Portal can be confusing to navigate

---

## 9. DeepInfra

**Why it's great**: Free tier with no credit card. Wide model selection including Llama 3.3, Qwen 2.5, and more.

### Sign Up
1. Go to [deepinfra.com](https://deepinfra.com/)
2. Sign up with Google/GitHub/email
3. No credit card needed
4. API key: Dashboard → API Keys → Create

### Free Models & Limits
| Model | Rate Limit |
|-------|:---:|
| Llama 3.3 70B | 30 req/min |
| Qwen 2.5 72B | 30 req/min |
| DeepSeek V3 | 30 req/min |
| Mixtral 8x7B | 30 req/min |

**opencode config**:
```json
{
  "providers": {
    "deepinfra": {
      "baseUrl": "https://api.deepinfra.com/v1/openai",
      "apiKey": "YOUR_DEEPINFRA_API_KEY"
    }
  },
  "models": {
    "deepinfra/meta-llama/llama-3.3-70b": {
      "provider": "deepinfra",
      "model": "meta-llama/Llama-3.3-70B-Instruct",
      "maxTokens": 4096,
      "contextLength": 128000
    }
  }
}
```

### Notes
- ✅ No credit card required
- ✅ Native OpenAI-compatible API
- ⚠️ Free tier has queue priority — slower during peak

---

## 10. OpenRouter (Aggregator)

**Why it's great**: Aggregator that connects to all providers. Many free models listed. Access everything from one API key.

### Sign Up
1. Go to [openrouter.ai](https://openrouter.ai/)
2. Sign up with Google/GitHub/email
3. **No credit card** — free tier works immediately
4. API key: Dashboard → Keys → Create

### Free Models Available
OpenRouter maintains a list of models with $0 pricing:
- Google Gemini 2.0 Flash (free)
- Google Gemini 1.5 Flash (free)
- Llama 3.1 8B (free)
- Mistral 7B (free)
- Qwen 2.5 72B (free, via DeepInfra)
- Many more — check [openrouter.ai/models?order=pricing](https://openrouter.ai/models?order=pricing)

**opencode config**:
```json
{
  "providers": {
    "openrouter": {
      "baseUrl": "https://openrouter.ai/api/v1",
      "apiKey": "YOUR_OPENROUTER_API_KEY",
      "headers": {
        "HTTP-Referer": "https://github.com/Sabir-test/dotfiles",
        "X-Title": "dotfiles"
      }
    }
  },
  "models": {
    "openrouter/google/gemini-2.0-flash-free": {
      "provider": "openrouter",
      "model": "google/gemini-2.0-flash-exp:free",
      "maxTokens": 8192,
      "contextLength": 1048576
    }
  }
}
```

### Notes
- ✅ Single API key for all providers
- ✅ Credit-based free tier — $1 free credit
- Optional: Set `HTTP-Referer` and `X-Title` headers so providers can see usage source
- ⚠️ Free model availability changes frequently

---

## 11. Together AI

**Why it's great**: Broadest model selection of any provider. $1 free credit (requires credit card for signup, but free credits are usable without spending).

### Sign Up
1. Go to [together.ai](https://together.ai/)
2. Sign up with Google/GitHub/email
3. ⚠️ **Requires credit card** for initial signup, but $1 free credit usable without spending
4. API key: Dashboard → API Keys → Create

### Free Models
| Model | Cost |
|-------|:---:|
| Mixtral 8x7B | $0.60/M tok |
| Llama 3.1 8B | $0.10/M tok |
| DeepSeek V3 | $0.90/M tok |
| Qwen 2.5 72B | $0.90/M tok |

### Notes
- ❌ Requires credit card
- Has the widest model selection
- $1 free credit = ~1M tokens of Mixtral output

---

## 12. Cohere

**Why**: Specializes in enterprise RAG and embeddings. Free API tier.

### Sign Up
1. Go to [dashboard.cohere.com](https://dashboard.cohere.com/)
2. Sign up with Google/email
3. No credit card needed
4. API key auto-generated

### Free Tier
- **Command R+**: 100 requests/month free
- **Command R**: 1000 requests/month free
- **Embeddings**: Free trial API key

### Notes
- ✅ No credit card required
- ⚠️ Very limited free tier for chat
- Best for embeddings (text represention vectors)

---

## 13. Ollama (LOCAL)

**Why**: Not cloud, but worth including. Run models on your own hardware. Completely free, no API key.

### Install
```bash
curl -fsSL https://ollama.com/install.sh | sh
```

### Models
| Model | Size | Quality |
|-------|:---:|:--------|
| Llama 3.1 8B | 4.7GB | Good for most tasks |
| Qwen 2.5 Coder 7B | 4.7GB | Good for coding |
| Mistral 7B | 4.1GB | Good all-around |
| DeepSeek R1 7B | 4.7GB | Good for reasoning |

**opencode config**:
```json
{
  "providers": {
    "ollama": {
      "baseUrl": "http://localhost:11434/v1",
      "apiKey": "ollama"
    }
  },
  "models": {
    "ollama/llama3.1-8b": {
      "provider": "ollama",
      "model": "llama3.1:8b",
      "maxTokens": 4096,
      "contextLength": 8192
    }
  }
}
```

### Notes
- ✅ Completely free, no API key
- ✅ Runs offline, no data leaves your machine
- ⚠️ Requires GPU or decent CPU + 8GB+ RAM for 7B models
- ⚠️ Slower than cloud for large models

---

## 14. Recommended Config Strategy for opencode

### Primary + Fallback Setup

Configure multiple providers so opencode falls back gracefully when one is rate-limited:

```json
{
  "providers": {
    "openrouter": {
      "baseUrl": "https://openrouter.ai/api/v1",
      "apiKey": "YOUR_OPENROUTER_KEY"
    },
    "google": {
      "baseUrl": "https://generativelanguage.googleapis.com/v1beta/openai",
      "apiKey": "YOUR_GOOGLE_KEY",
      "headerPrefix": "x-goog-api-key"
    },
    "github": {
      "baseUrl": "https://models.inference.ai.azure.com",
      "apiKey": "YOUR_GITHUB_TOKEN"
    },
    "groq": {
      "baseUrl": "https://api.groq.com/openai/v1",
      "apiKey": "YOUR_GROQ_KEY"
    },
    "ollama": {
      "baseUrl": "http://localhost:11434/v1",
      "apiKey": "ollama"
    }
  },
  "models": {
    "primary": "openrouter/google/gemini-2.0-flash-free",
    "fallbacks": [
      "github/gpt-4o-mini",
      "groq/llama-3.3-70b-versatile",
      "ollama/llama3.1-8b"
    ]
  }
}
```

### Recommended Tier System

| Tier | Provider | Model | Use For |
|:----:|:---------|:------|:--------|
| 🥇 **Primary** | OpenRouter → Google | Gemini 2.0 Flash | Daily driver — best quality/limit ratio |
| 🥈 **Fallback A** | GitHub Models | GPT-4o-mini | When Gemini is rate-limited (rare) |
| 🥉 **Fallback B** | Groq | Llama 3.3 70B | When all API tiers fail |
| 🏠 **Local** | Ollama | Llama 3.1 8B | Offline / no internet |

---

## Appendix: Quick-Start Script

Save as `scripts/setup-free-llms.sh`:

```bash
#!/usr/bin/env bash
# Setup free LLM API keys for opencode
# Run this, then follow the prompts

set -euo pipefail

echo "=== Free LLM API Key Setup ==="
echo ""
echo "You'll need:"
echo "  1. A Google account (for Gemini) - RECOMMENDED"
echo "  2. A GitHub account (for GitHub Models)"
echo "  3. A Groq account (optional)"
echo ""

echo "=== Step 1: Google Gemini ==="
echo "Go to: https://aistudio.google.com/app/apikey"
echo "Sign in, click 'Create API Key', paste below:"
read -rp "Gemini API Key (leave blank to skip): " gemini_key
if [ -n "$gemini_key" ]; then
    echo "export GEMINI_API_KEY=$gemini_key" >> ~/.bashrc
    echo "✓ Saved to ~/.bashrc"
fi

echo ""
echo "=== Step 2: GitHub Models ==="
echo "Go to: https://github.com/settings/tokens"
echo "Create a Fine-grained token (no special permissions needed)"
read -rp "GitHub Token (leave blank to skip): " github_token
if [ -n "$github_token" ]; then
    echo "export GITHUB_TOKEN=$github_token" >> ~/.bashrc
    echo "✓ Saved to ~/.bashrc"
fi

echo ""
echo "=== Step 3: Groq ==="
echo "Go to: https://console.groq.com/keys"
read -rp "Groq API Key (leave blank to skip): " groq_key
if [ -n "$groq_key" ]; then
    echo "export GROQ_API_KEY=$groq_key" >> ~/.bashrc
    echo "✓ Saved to ~/.bashrc"
fi

echo ""
echo "=== Done! Run 'source ~/.bashrc' to load keys ==="
```

---

## Quick Reference: Endpoints & Auth

| Provider | Base URL | Auth Header | Auth Value |
|----------|:---------|:------------|:-----------|
| Google Gemini | `https://generativelanguage.googleapis.com/v1beta/openai` | `x-goog-api-key` | API key |
| Groq | `https://api.groq.com/openai/v1` | `Authorization: Bearer` | API key |
| GitHub Models | `https://models.inference.ai.azure.com` | `Authorization: Bearer` | GitHub PAT |
| Cerebras | `https://api.cerebras.ai/v1` | `Authorization: Bearer` | API key |
| Mistral | `https://api.mistral.ai/v1` | `Authorization: Bearer` | API key |
| Hugging Face | `https://api-inference.huggingface.co` | `Authorization: Bearer` | API token |
| Cloudflare | `https://api.cloudflare.com/client/v4/accounts/{id}/ai/v1` | `Authorization: Bearer` | API token |
| NVIDIA NIM | `https://integrate.api.nvidia.com/v1` | `Authorization: Bearer` | API key |
| DeepInfra | `https://api.deepinfra.com/v1/openai` | `Authorization: Bearer` | API key |
| OpenRouter | `https://openrouter.ai/api/v1` | `Authorization: Bearer` | API key |
| Ollama | `http://localhost:11434/v1` | `Authorization: Bearer` | `ollama` (ignored) |
