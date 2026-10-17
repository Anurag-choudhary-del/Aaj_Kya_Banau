function json(data, status = 200) {
  return new Response(JSON.stringify(data), {
    status,
    headers: {
      "content-type": "application/json; charset=utf-8",
      "access-control-allow-origin": "*",
      "access-control-allow-methods": "POST, OPTIONS, GET",
      "access-control-allow-headers": "content-type",
      "cache-control": "no-store",
    },
  });
}

export default {
  async fetch(request, env) {
    if (request.method === "OPTIONS") {
      return new Response(null, { status: 204, headers: {
        "access-control-allow-origin": "*",
        "access-control-allow-methods": "POST, OPTIONS, GET",
        "access-control-allow-headers": "content-type",
      }});
    }
    const url = new URL(request.url);
    if (request.method === "GET" && url.pathname === "/health") return json({ ok: true });
    if (request.method !== "POST" || url.pathname !== "/recognize") return json({ error: "Endpoint nahi mila." }, 404);
    if (!env.OPENAI_API_KEY) return json({ error: "AI backend key configure nahi hai." }, 503);

    let body;
    try { body = await request.json(); } catch (_) { return json({ error: "Photo request sahi format mein nahi hai." }, 400); }
    const imageBase64 = body?.imageBase64;
    const mimeType = body?.mimeType;
    if (typeof imageBase64 !== "string" || imageBase64.length < 100 ||
        imageBase64.length > 12_000_000 ||
        !["image/jpeg", "image/png", "image/webp"].includes(mimeType)) {
      return json({ error: "Valid JPG, PNG ya WEBP photo upload karo (size 9 MB ke aas-paas ya kam rakho)." }, 400);
    }

    const language = ["English", "Hindi", "Hinglish"].includes(body?.language) ? body.language : "English";
    const labelLanguage = language === "Hindi"
      ? "Hindi in Devanagari script"
      : language === "Hinglish"
        ? "natural Hinglish written in Latin script"
        : "English";
    const prompt = `Identify only clearly visible food ingredients in this kitchen/pantry photo. Return ONLY JSON with this shape: {"items":[{"name":"Tomato","displayName":"Tomato","emoji":"🍅"}]}. The "name" field MUST be a short, common, singular English ingredient name for stable recipe matching. The "displayName" field MUST be the same ingredient expressed in ${labelLanguage}. Keep the canonical English name in "name" even when the display language is Hindi or Hinglish. Use relevant emoji. Do not guess hidden items or return dishes, utensils, text, or background objects. If none are clear, return {"items":[]}. Maximum 20 distinct ingredients.`;
    let upstream;
    try {
      upstream = await fetch("https://api.openai.com/v1/responses", {
        method: "POST",
        headers: { "authorization": `Bearer ${env.OPENAI_API_KEY}`, "content-type": "application/json" },
        body: JSON.stringify({
          model: "gpt-4.1-mini",
          max_output_tokens: 500,
          input: [{ role: "user", content: [
            { type: "input_text", text: prompt },
            { type: "input_image", image_url: `data:${mimeType};base64,${imageBase64}`, detail: "low" }
          ]}]
        })
      });
    } catch (_) { return json({ error: "AI service tak connection nahi hua. Internet check karke retry karo." }, 502); }
    if (!upstream.ok) {
      const status = upstream.status;
      return json({ error: status === 401 ? "AI backend key invalid hai." :
        status === 429 ? "AI service ki rate limit ya billing limit hit hui. Baad mein try karo." :
        "AI service ne photo process nahi ki. Dobara try karo." }, status === 429 ? 429 : 502);
    }
    const data = await upstream.json();
    const outputText = (data.output || []).flatMap(item => item.content || [])
      .filter(item => item.type === "output_text").map(item => item.text).join("\n");
    if (!outputText) return json({ error: "AI ne readable result nahi diya. Dobara photo lo." }, 502);
    try {
      const cleaned = outputText.replace(/^```(?:json)?\s*/i, "").replace(/\s*```$/, "");
      const parsed = JSON.parse(cleaned);
      const items = Array.isArray(parsed.items) ? parsed.items : [];
      const unique = new Map();
      for (const item of items) {
        if (typeof item?.name !== "string") continue;
        const name = item.name.trim().slice(0, 60);
        if (!name) continue;
        const key = name.toLocaleLowerCase();
        const displayName = typeof item.displayName === "string" && item.displayName.trim()
          ? item.displayName.trim().slice(0, 60)
          : name;
        if (!unique.has(key)) unique.set(key, {
          name,
          displayName,
          emoji: typeof item.emoji === "string" ? item.emoji.slice(0, 8) : "🥬"
        });
      }
      return json({ items: [...unique.values()].slice(0, 20) });
    } catch (_) { return json({ error: "AI response parse nahi hua. Dobara photo try karo." }, 502); }
  }
};
