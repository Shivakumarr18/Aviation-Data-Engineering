# Aviation Data Engineering

Structured journey toward becoming a decision-grade Data Engineer with aviation domain depth.

## Phase 1 – Foundation Stability

### Focus Areas
- Grain discipline
- Duplication prevention
- NULL handling
- Financially aware metric modeling
---
## Implemented (Phase 1)
- Delay cost exposure per aircraft per day
- Weighted load factor using:
SUM(boarded_seats) / SUM(capacity)

## Modeling Assumptions

- Only flights with `status = 'completed'` are included
- `delay_penalty_cost` NULL treated as 0 (as per dataset definition)
- Weighted load factor computed at aggregate level
- Division protected using `NULLIF(SUM(capacity), 0)`
