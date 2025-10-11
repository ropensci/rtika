---
pkgdown: false
---

# Repository Guidelines

## Project Structure & Module Organization
- `R/` hosts exported helpers (e.g., `tika_text()`, `tika_html()`) plus install checks.
- `inst/extdata/` contains sample documents used in vignettes and tests; keep additions small.
- `tests/testthat/` covers integration flows via Apache Tika; mirror new features with targeted fixtures.
- `vignettes/` and `docs/` drive the pkgdown site; refresh vignettes when user-facing behaviour changes.
- `java/` and `inst/java/` carry Tika jars; replace jars through the `tika_fetch()` routine only.

## Agent Role & Collaboration Expectations
- Treat yourself as an experienced peer reviewer. Suggest strategic changes, highlight risks, and implement only the edits the maintainer explicitly requests or that are required to keep the repository coherent.
- When tasks rely on interactive tooling (e.g., `devtools`, pkgdown), guide the maintainer through running the commands locally instead of executing `Rscript` wrappers. Assume they are working in RStudio/Positron and can copy commands into their console.
- Before large edits, verify whether the maintainer prefers to execute them manually; fall back to minimal diffs when uncertainty exists.
- Remind maintainers that additional step-by-step update guidance lives midway through `R/tika.R` comments; point them there when a Tika version bump or release prep is underway.

## Build, Test, and Development Workflow
- Ask the maintainer to run `devtools::load_all()` to refresh the package in their IDE session.
- Recommend `devtools::document()` and `devtools::test()` for incremental updates; remind the maintainer to execute them in their console.
- For release validation, have the maintainer run `devtools::check()` interactively. If a tarball is needed, suggest `devtools::build()` afterwards.
- When docs change, prompt the maintainer to set `Sys.setenv(NOT_CRAN = "true")` and run `pkgdown::clean_site(); pkgdown::build_site()` themselves, ensuring Pandoc is available.
- After rebuilding pkgdown, remind the maintainer to delete `docs/AGENTS.html`; the contributor guide should not be published on the site.

## Coding Style & Naming Conventions
- Use base R/roxygen style: two-space indents, no tabs, ~80 character lines, snake_case helpers, exported APIs prefixed `tika_`.
- Document every exported function with roxygen blocks and regenerate via `Rscript -e "devtools::document()"`.
- Keep Java paths lowercase; describe fixture formats directly in filenames.

## Testing Guidelines
- Tests live in `tests/testthat`; name files `test_<feature>.R` and wrap assertions in `test_that()`.
- Reuse fixtures from `inst/extdata` or add new ones under 200 KB to keep checks fast.
- Run `Rscript -e "devtools::test()"` locally; full pre-push validation is `Rscript -e "devtools::check()"`.
- Measure coverage with `Rscript -e "covr::report()"`; GitHub Actions publishes results to Codecov.

## Commit & Pull Request Guidelines
- Keep commit subjects short and action-oriented (see `git log`: "fix broken link to openjdk"); avoid bundling unrelated work.
- Reference issues in commit or PR bodies (`Closes #123`) and summarize the user impact.
- PRs should list testing performed, attach screenshots for pkgdown/docs updates, and note Java/Tika version changes explicitly.
- Confirm CI passes and call out any required follow-up before requesting review.

## Security & Environment Notes
- Requires Java ≥ 11; confirm with `java -version` before invoking Tika helpers.
- Prefer `tika_fetch()` over manual jar downloads to ensure checksums match and updates propagate to the cache.
