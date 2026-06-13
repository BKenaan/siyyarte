# Siyyarte — Market-Routing Model (Lebanon mixed-import)

**For Siyyarte, market identification is as important as vehicle identification.** A "Chevrolet Tahoe 2021 5.3L" in Lebanon may be US-spec **or** GCC-spec — different fluids, octane, intervals. The app must route to the correct source-market record, and **never guess blindly**.

## Output contract (every routing call returns)
```json
{
  "likely_market": "North America",
  "confidence_score": 0.0-1.0,
  "required_user_confirmation_fields": ["odometer_unit","octane_label"],
  "matching_vehicle_records": [ {vehicle_spec_id, market, engine, ...}, ... ]
}
```

## Algorithm
1. **Resolve candidate records.** Look up (make, model, year, engine) → all `vehicle_specs` rows. If only **one market** exists for that model (`v_market_options`), route to it with confidence 1.0 — done.
2. **If multiple markets exist**, score each market by summing the weights of matched clues (`market_routing_clues`).
3. **Decisive clues short-circuit:** a market-exclusive engine (e.g. 6.2L L87, 3.0L PowerStroke), or a user-stated import origin → route directly (confidence ≥ 0.9).
4. **Otherwise** compute `confidence_score = matched_weight / total_possible_weight`. If below threshold (e.g. 0.7), return `required_user_confirmation_fields` = the cheapest high-weight clues still unknown (odometer unit, octane label, manual region) and **ask the user** rather than assume.
5. Return all `matching_vehicle_records` so the UI can show "US-spec vs GCC-spec" if still ambiguous.

## Clue weights (in `market_routing_clues`)
| Clue | Points to | Weight | Decisive? |
|------|-----------|--------|-----------|
| Engine availability (market-exclusive) | varies | 0.50 | **Yes** |
| User-stated import origin | varies | 0.55 | **Yes** |
| VIN WMI (pos 1: 1/4/5=US…) | assembly→market | 0.45 | No |
| Emissions label region (EPA) | NA | 0.40 | No |
| Owner-manual region | NA | 0.40 | No |
| Odometer unit (miles/km) | NA / other | 0.40 | No |
| Fuel octane label (AKI vs RON) | NA / GCC | 0.35 | No |
| Trim naming (US-only trims) | NA | 0.35 | No |
| GCC heat package badge | GCC | 0.30 | No |
| Rear fog light | Europe | 0.20 | No |

## Why no single clue is trusted alone (except decisive ones)
- **VIN** encodes the *assembly plant*, not always the *sale market* (a US-built car can be GCC-export). Strong but not absolute.
- **Odometer in miles** is a near-certain US tell, but a swapped cluster can mislead — hence weighted, not decisive.
- Only a **market-exclusive engine** or an **explicit user statement** routes with high confidence by itself.

## Frontend behaviour (the Tahoe example)
User picks "Chevrolet Tahoe 2021 5.3L." `v_market_options` shows the model has a North America record (and later, if added, a GCC one). The app:
1. Tries VIN/clues; 2. if confidence < 0.7, shows: *"Is your Tahoe a US import or GCC spec?"* with a one-tap choice (and offers "scan VIN" / "check your odometer: miles or km?"). 3. Only then serves the matching record's specs — with a **market badge** visible.

**Integrity tie-in:** routing never *fabricates* a spec; it *selects* among officially-cited market records, or asks. If the needed market record doesn't exist yet, it says "GCC spec not yet verified" rather than serving the US values as if they were GCC.
