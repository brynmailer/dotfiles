---
name: diagram
description: Use whenever about to write, embed, or update a Mermaid diagram in any document, doc-comment, README, or chat output. Validates via the mermaid_preview tool before committing, iterates on syntax errors, then saves the validated source. Single source of truth for the diagramming process — every agent (engineer, eng-*, professor, scribe) defers here. Invoke automatically when diagrams are involved, or directly via /diagram.
---

# Diagramming process

Every Mermaid diagram destined for a doc, README, or chat output goes through this loop. **Unvalidated Mermaid is the dominant cause of broken diagrams.**

## The loop

1. **Draft the source.** Write the Mermaid.
2. **Validate via `mermaid_preview`.** Pass the source to the tool. If it returns an error, you have a syntax problem — the message names the bad line.
3. **Fix and re-validate.** Don't guess. Iterate until it renders cleanly.
4. **Show the user the preview.** They see it in their browser (live-reload on ports 3737–3747).
5. **Commit the validated source** to the destination — never the unvalidated draft.

If the user asks for an exported file (PNG/SVG/PDF), use `mermaid_save` after validation succeeds, with a path adjacent to the destination doc (e.g., `docs/diagrams/<scope>.svg`).

## Picking a diagram type

| Showing                                       | Use                                     |
| --------------------------------------------- | --------------------------------------- |
| Sequential message exchange between actors    | `sequenceDiagram`                       |
| Branching control flow / process              | `flowchart TD` (top-down) or `flowchart LR` |
| State machine with transitions                | `stateDiagram-v2`                       |
| Class structure and relations                 | `classDiagram`                          |
| Entity-relationship                           | `erDiagram`                             |
| Timeline / Gantt                              | `gantt`                                 |
| User journey                                  | `journey`                               |

If unsure, prefer `flowchart` — most LLM-familiar, lowest syntax surprise rate.

## Conventions

- **One diagram per concept.** Don't cram three flows into one; split them and reference each from the prose.
- **Keep node count under ~15.** Beyond that, layout suffers and comprehension drops.
- **Include failure paths**, not just the happy path. Failure flows are usually more interesting and more often broken in code.
- **Theme**: `default` for docs going into the repo, `dark` for chat-only previews if the user prefers.

## When to skip the tool

- The user explicitly asks for raw Mermaid source to paste into an external system (GitHub issue, gist, etc.) — even then, validate once before handing off.
- The diagram is trivially short (`A --> B`).

## Common errors

- **Unterminated string in label** — wrap label text in `[` `]` or quotes consistently.
- **Reserved keyword as node ID** — `end`, `class`, `state` etc. Rename.
- **Bad arrow syntax** — `-->`, `-.->`, `==>` etc. each have type-specific grammar; check the diagram type's reference.
- **Unbalanced subgraph blocks** — every `subgraph` needs a matching `end`.

When stuck, render the smallest version that works and add complexity one node at a time. A 3-node diagram that renders is more useful than a 20-node diagram that doesn't.
