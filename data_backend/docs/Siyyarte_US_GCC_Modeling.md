# Siyyarte — US-spec vs GCC-spec Modeling Proposal

**Version 1.0 · 2026-06-12.** Proven on the Phase-2 pilots (Tahoe, Yukon, Explorer, F-150).

## The problem (real in Lebanon)
Lebanon imports the **same nameplate from multiple source markets** — a Ford Explorer or Jeep Grand Cherokee arrives US-spec; a Toyota Land Cruiser arrives GCC-spec; a Mercedes C-Class arrives US **or** Europe. Same model name, **different engines, fluids, capacities, fuel-octane, and service intervals.** Merging them corrupts the data.

**Evidence from the pilots:** GM Tahoe (US) uses **dexos1 0W-20, 87/91 AKI fuel, GM Oil Life System**; a GCC Land Cruiser uses **0W-20 preferred but 95 RON, fixed km intervals**. Ford Explorer trans fluid = **MERCON ULV**; F-150 = **MERCON LV** — even within one brand. These cannot be inferred from each other.

## The model (already supported by the schema)
Every spec is the unit **(model · generation · model_year · engine · market)**. `vehicle_specs.market` is mandatory:

```
market ∈ { GCC, Europe, North America, Japan, Lebanon Import, Unknown }
```

**Rules:**
1. **One vehicle_specs row per source market.** A US Explorer and a (hypothetical) GCC Explorer are two rows, never merged.
2. **Never merge US and GCC values** unless the official documents *explicitly* state they are identical (rare; must be cited).
3. **No field copied across markets.** Each market's values come from that market's official document.
4. **`Lebanon Import` is a routing layer, not a spec source.** A physical Lebanese car is matched (by VIN WMI / plant / fuel filler) to its *source* market, then served that market's specs. Store `source_market` so the app knows which record applies.
5. **Citation carries the market.** Each value's `source_id` points to a market-specific document (e.g. US owner manual vs GCC owner manual).

## Required per-record fields (all present)
`market` · `engine_id` (engine code) · `transmission` · `source_market` (via market + source doc) · `source_id` (document) · field-level `confidence_grade` + `verification_status` + `verification_date`.

## API / frontend implication
- `GET /v1/specs?make=Ford&model=Explorer&market=North America` returns the US record; `…&market=GCC` returns the GCC record (or 404 → "GCC spec not yet verified").
- VIN decode → resolve source market → select the matching record. If unknown, prompt the user ("Is your car US-import or GCC?") rather than guess.
- Frontend shows a **market badge** on every spec card; mismatched-market values are never blended.

## Pilot proof
The four pilots are stored as `market='North America'` with US owner-manual citations. When GCC versions of these (where sold) are later extracted, they become **separate rows** — the schema, citation model, and API already handle it. No remodeling required to scale.
