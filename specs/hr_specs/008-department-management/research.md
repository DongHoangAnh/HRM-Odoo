# Phase 0 Research: Department Management and Hierarchy

Decision: Use Odoo ORM patterns to implement department hierarchy features inside a dedicated addon (recommended name: `hrm_department_ext`) under `addons/hrm_custom`.

Rationale:
- Keeps changes modular and avoids touching Odoo core (aligns with project rules).
- Easier testing and packaging for downstream deployment.

Unknowns / NEEDS CLARIFICATION:
- Constitution file: `.specify/memory/constitution.md` is a placeholder. Recommendation: adopt `rules.md` as constitution content. Please confirm.
- Addon path: confirm preferred addons folder name (existing repository conventions). Recommendation: `addons/hrm_custom`.

Dependencies & Best Practices:
- Use Odoo ORM (`models.Model`, `_inherit` where needed) — do not modify core.
- Add tests under `tests/` using Odoo testing framework (tests for quick-create, circular prevention, complete_name, manager reassignment).
- Add ACL entries if new models or fields require specific access.

Alternatives Considered:
- Implement changes inside upstream `hr` module: rejected because it modifies core areas and complicates upgrades.
- Implement as cross-module patch via monkeypatching: rejected by constitution rules.

Decision Log:
- Implement as dedicated addon `hrm_department_ext` under `addons/hrm_custom` (tentative, pending confirmation of addons path).
- Adopt `rules.md` content as de-facto constitution unless user asks to persist a different constitution file.
