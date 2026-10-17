# Aaj Kya Banau

Flutter kitchen companion with a user-managed pantry, photo-based ingredient recognition, recipes, a monthly meal planner, and grocery cart.

## Features

- **Pantry:** starts empty on a fresh install; manually added and confirmed photo-recognized items are saved locally.
- **Camera / Photo Upload:** take a photo with the device camera or select an image from the gallery. The AI result is shown for review; only selected items are added.
- **Monthly Planner:** shows Breakfast, Lunch, Dinner, and Snacks for every day, with five rotating options per category. Tap an option to inspect ingredients, add missing items to the cart, and select it. Selections are saved locally.
- **Grocery Cart:** quantity is expressed in a unit (such as kg, L, pack, or pcs), with an estimated unit price and line total. Estimates are not live Blinkit prices. Blinkit checkout is not connected, so the app does not place orders.
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
