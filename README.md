# Aaj Kya Banau

Flutter kitchen companion with a user-managed pantry, photo-based ingredient recognition, recipes, a monthly meal planner, and grocery cart.

## Features

- **Pantry:** starts empty on a fresh install; manually added and confirmed photo-recognized items are saved locally.
- **Camera / Photo Upload:** take a photo with the device camera or select an image from the gallery. The AI result is shown for review; only selected items are added.
- **Monthly Planner:** automatically fills every day of the selected month from the included recipe catalogue. Recipe order is deterministic for a given month and changes for a different month. Users can edit individual days.
- **Recipes and Cart:** recipe matching uses the pantry contents; missing ingredients can be added to the grocery cart.

## AI recognition setup (required for photo scanning)

The API key must never be embedded in the Android app. The app sends photos to a Cloudflare Worker, which calls the OpenAI Responses API server-side.

In GitHub repository **Settings → Secrets and variables → Actions → Secrets**, create these repository secrets:

1. `OPENAI_API_KEY` — your OpenAI API key.
2. `CLOUDFLARE_API_TOKEN` — a Cloudflare API token with the minimum required Workers edit/deploy permissions.
3. `CLOUDFLARE_ACCOUNT_ID` — your Cloudflare account ID.

The workflow `.github/workflows/deploy_ai_worker.yml` deploys `worker/` and configures the OpenAI key as a Worker secret. Never commit an actual API key into source files, Dart code, or workflow YAML.

After the Worker deploys, its URL will look like `https://aaj-kya-banau-ai.<your-workers-subdomain>.workers.dev`. In **Settings → Secrets and variables → Actions → Variables**, create a repository variable named `AI_API_BASE_URL` and set it to that full HTTPS URL (without `/recognize`). Push or manually run the **Build Flutter APK** workflow again so the URL is compiled into the APK.

Test the deployed Worker health endpoint by opening `<AI_API_BASE_URL>/health`; it should return `{"ok":true}`.

**Important:** GitHub Actions secrets are available to workflows, not directly to an installed mobile app. The Worker is the secure server-side boundary for the OpenAI key. AI usage may incur OpenAI charges; set usage limits and monitor requests. Before public release, add Cloudflare rate limiting/abuse protection to the Worker endpoint.

## Build

The GitHub Actions workflow prepares the Flutter package from the Dart source files in the repository root, runs `flutter analyze`, runs widget tests, and builds the Android release APK.
