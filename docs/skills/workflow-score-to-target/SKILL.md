---
name: workflow-score-to-target
description: Use when the user asks to score, rate, grade, or judge visual work out of 10, names a target score, or asks what would improve a score. Use an anchored rubric, real visual evidence, and honest before/after reporting.
---

# Workflow: Score to a Target

Adapted from Meng To's `workflow-score-to-target` skill. See `../mengto-skills/README.md` for provenance and license.

## 1. Define the target and scope

- Record the numeric target and whether it applies to each item or the overall result.
- List the screens or elements being judged.
- Name the comparison benchmark. If none was supplied, describe the rubric in observable terms instead of inventing a benchmark.

## 2. Anchor the rubric

Use five criteria scored from 0 to 2 (10 points total). Adapt criteria to the request; for game UI, useful dimensions include:

- information hierarchy and action clarity;
- readability, contrast, and scaling;
- consistency with the game's visual language;
- useful state feedback and interaction clarity;
- restraint, polish, and performance of visual effects.

Define what each criterion's 0, 1, and 2 mean before scoring. Do not treat personal taste as objective evidence.

## 3. Score from evidence

- Score actual Godot captures or runtime behavior, not code or memory.
- Capture the baseline before changing it and use the same viewport and state after the change.
- Identify the evidence and who judged it. Use an independent reviewer only when available and appropriate; do not imply an independent review happened otherwise.
- Never round up to reach the requested target.

## 4. Improve in rounds

1. Fix the lowest-scoring criterion first.
2. Make a small, controlled change.
3. Capture and score again using the same rubric and conditions.
4. Stop at the user's target or report what remains below it and why.

Keep gameplay clarity, accessibility, performance, and rules-scope boundaries while improving appearance.

## 5. Report

Show a compact per-screen scorecard with before/after scores, the main issue addressed, capture conditions, and remaining limitations. Scores are judgements; distinguish measured facts from visual assessment.

## Source material

This project copy is adapted from Meng To, `workflow/workflow-score-to-target/SKILL.md`, in [MengTo/Skills](https://github.com/mengto/skills), MIT licensed. The project rubric is oriented to Godot game UI.
