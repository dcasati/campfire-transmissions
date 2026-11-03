# Campfire Transmissions

A daily situational-awareness brief (about 400–600 words) on geopolitical, security, cyber, infrastructure and disaster developments, organised by region. Every claim is tied to a cited source, and a deterministic verifier rejects anything the cited evidence does not support.

Published at 06:00 America/Edmonton by GitHub Actions to <https://campfire.dcasati.net/> as:

| Format | URL |
|---|---|
| Atom feed (full text, last 14 editions) | `/feed.xml` |
| OPDS catalog (EPUB, for KOReader) | `/opds.xml` |
| Per edition | `/editions/briefing-YYYY-MM-DD.{epub,md,json}` |
| Health | `/status.json` |

It reproduces only cited headlines and links from third-party sources, never their articles.

## How it works

```
RSS/Atom sources → normalize + quarantine injection → cluster events → rank → evidence packets
  → LLM writer (GitHub Copilot CLI or any OpenAI-compatible API) → verifier → EPUB / MD / JSON / feeds
```

- **Verification is code, not a model** (`verify.py`): citations must resolve to the same event; numbers, names and strong verbs must appear in the cited evidence; single-source claims must be attributed; the Top Line is at most three sentences.
- **Fallback:** if the LLM draft fails verification after `llm.max_attempts` tries, an evidence-only edition is published, built from verbatim headlines. Events whose headline fails verification are omitted, never edited.
- **Untrusted input:** feed text is treated as data and instruction-like content is quarantined. The Copilot CLI runs with no tools in an empty directory.

Details: [architecture](docs/architecture.md), [editorial policy](docs/editorial-policy.md), [evaluation](docs/evaluation.md).

## Run locally (no API key)

```bash
python3 -m venv .venv && . .venv/bin/activate
pip install ".[dev]"
pytest -q && daily-wire eval
daily-wire run --fixtures tests/fixtures --site /tmp/site --now 2026-10-30T12:00:00Z --no-llm \
  --label "TEST EDITION: synthetic fixtures"
```

A sample edition is in [`docs/sample/`](docs/sample).

## Deploy

1. Public repo; Settings → Pages → *Deploy from a branch* → `gh-pages` `/`. The first workflow run creates the branch.
2. Pick an LLM provider (no provider means an evidence-only edition):
   - **GitHub Copilot:** variable `DAILY_WIRE_PROVIDER=copilot_cli`, variable `DAILY_WIRE_MODEL=auto`, and secret `COPILOT_GITHUB_TOKEN` (fine-grained PAT with *Copilot Requests*).
   - **OpenAI-compatible:** secret `DAILY_WIRE_API_KEY`, plus `llm.base_url`, `llm.model` and token prices in `config/briefing.yaml`.
3. Set `site.feed_base_url` in `config/briefing.yaml` to your Pages URL.
4. Run **Actions → daily-brief → Run workflow** once.

GitHub's cron is best-effort and often starts hours late. [`scripts/dispatch-daily.sh`](scripts/dispatch-daily.sh) is an optional once-a-day backstop to run from your own machine; see [operations](docs/operations.md).

## Read it

- **Feed reader / iPhone:** subscribe to `…/feed.xml`.
- **KOReader (Kobo):** OPDS catalog → `…/opds.xml` → download the newest EPUB. News Downloader can also read `feed.xml`.

## Layout

`config/` sources and editorial config · `src/daily_wire/` pipeline · `tests/` and `tests/fixtures/` · `docs/` design, policy, operations. The CLI is `daily-wire run | eval | health | check-sources`.
