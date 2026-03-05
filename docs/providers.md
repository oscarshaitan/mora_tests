# Provider Setup Guide

Step-by-step instructions for obtaining credentials for each supported LLM provider.

---

## OVH AI Endpoints

OVH AI Endpoints exposes OpenAI-compatible models (including multimodal ones like Qwen 2.5 VL) through a managed API.

### 1. Create an OVH account

Sign up at [ovhcloud.com](https://www.ovhcloud.com) if you don't already have one.

### 2. Subscribe to AI Endpoints

1. Go to the [OVH AI Endpoints product page](https://www.ovhcloud.com/en/public-cloud/ai-endpoints/)
2. Select a Public Cloud project (or create one)
3. Follow the activation flow — no GPU quota is needed; billing is per-token

### 3. Generate an access token

OVH uses its own IAM token (not an API key string) as the Bearer credential.

1. Open the [OVH Control Panel](https://www.ovh.com/manager/)
2. Go to **Account** → **My profile** → **API keys** (or visit [api.ovh.com/createToken](https://api.ovh.com/createToken/))
3. Create a token with at least read access to AI services
4. Copy the token — you will not be able to view it again

Paste this token into the **API Key** field of the OVH AI card in Mora Tests' Settings.

### 4. Find the endpoint URL

The default base URL for OVH's OpenAI-compatible gateway is:

```
https://oai.endpoints.kepler.ai.cloud.ovh.net/v1
```

This is already pre-filled in Settings. You only need to change it if OVH publishes a new endpoint URL.

### 5. Choose a model

Browse available models in the [OVH AI Endpoints model catalogue](https://endpoints.ai.cloud.ovh.net).

Mora Tests defaults to:

| Role | Model |
|------|-------|
| Primary | `Qwen2.5-VL-72B-Instruct` (vision) |
| Fallback | `Mistral-Small-3.2-24B-Instruct-2506` |

> Use a vision-capable model as the primary — Mora Tests sends screenshots with every step.

### Official documentation

- [OVH AI Endpoints documentation](https://help.ovhcloud.com/csm/en-public-cloud-ai-endpoints?id=kb_category&kb_id=574a8325272b4950d4a9153d05c33b60)
- [Available models and pricing](https://endpoints.ai.cloud.ovh.net)

---

## Vertex AI (Google Cloud)

Vertex AI exposes Gemini models through an OpenAI-compatible endpoint, allowing Mora Tests to talk to Gemini with no SDK changes.

### 1. Create a Google Cloud project

1. Go to [console.cloud.google.com](https://console.cloud.google.com)
2. Create a new project or select an existing one
3. Note your **Project ID** (visible in the project selector — looks like `my-project-123456`)

### 2. Enable the Vertex AI API

1. In the Cloud Console, go to **APIs & Services** → **Enable APIs and Services**
2. Search for **Vertex AI API** and click **Enable**

### 3. Set up authentication

Mora Tests uses a service account JSON key to obtain and automatically refresh access tokens — you only need to configure this once.

1. Go to **IAM & Admin** → **Service Accounts** → **Create Service Account**
2. Grant the role **Vertex AI User** (`roles/aiplatform.user`)
3. Click **Keys** → **Add Key** → **Create new key** → choose **JSON** → **Create**
4. A `.json` file is downloaded to your machine — keep it safe, this is your credential

In Mora Tests' Settings, open the Vertex AI configuration dialog and either:
- Click **Load file** and select the downloaded `.json` file, or
- Paste the file contents directly into the **Service Account JSON** text area

The app exchanges the key for a short-lived access token automatically and refreshes it whenever it expires. No manual token management is needed.

### 4. Configure the endpoint URL

The Vertex AI OpenAI-compatible base URL follows this pattern:

```
https://us-central1-aiplatform.googleapis.com/v1beta1/projects/YOUR_PROJECT_ID/locations/us-central1/endpoints/openapi
```

Replace `YOUR_PROJECT_ID` with your actual project ID. This is pre-filled in Settings — just edit the project ID segment.

> Change `us-central1` if you want to use a different region. Gemini 2.5 Flash is available in most regions.

### 5. Choose a model

| Role | Model |
|------|-------|
| Primary | `google/gemini-2.5-flash` (vision, fast) |
| Fallback | `google/gemini-3.1-flash-lite` (lower cost) |

Model identifiers must be prefixed with `google/` when using the OpenAI-compatible endpoint.

### Official documentation

- [Vertex AI OpenAI compatibility guide](https://cloud.google.com/vertex-ai/generative-ai/docs/multimodal/call-gemini-using-openai-library)
- [Gemini model versions and availability](https://cloud.google.com/vertex-ai/generative-ai/docs/learn/model-versioning)
- [Service account authentication](https://cloud.google.com/iam/docs/service-account-overview)
