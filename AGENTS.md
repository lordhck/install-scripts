## Code philosophy

- Repository: https://github.com/lordhck/install-scripts
- Keep it simple. Avoid unnecessary complexity.
- Don't reinvent the wheel. If a package or binary already does exactly what we need, use it.
- Don't overengineer simple problems.
- If 200 lines of code can be reduced to 50, do it.
- Solve the actual problem, not imaginary future problems.
- Don't add features that weren't requested.
- Prefer readability over cleverness.

## Code comments
- Keep comments short and to the point.
- Comments must explain why, not what.
- Don't describe code that is already self-explanatory.
- Avoid unnecessary comments and long explanations.
- Never write essays or documentation inside source files.
- Don't use comments as a substitute for clean code.
- Only comment non-obvious logic, workarounds, or important decisions.
- All code comments must be written in English.

## Build Files
- Keep Makefiles minimal.
- Only define commands that are actually needed.
- Don't create variables unless they are reused or genuinely useful.
- Avoid unnecessary targets and aliases.
- Prefer a few useful commands over dozens of rarely used ones.
- Typical targets: `make`, `build`, `clean`, and `shell`.
- Create shortcuts for long commands that are used frequently.
- Don't wrap short commands unnecessarily.
- Don't turn simple build files into complex automation systems.

## Git and Repo Hygiene
- Use Conventional Commits.
- In this format `<type>(optional scope): <description>`
- Keep commit messages short and descriptive. Max 50 chars.
- Never commit secrets, credentials, or API keys.
- Never commit generated files unless explicitly required.
- Keep `.gitignore` up to date.
- Don't modify unrelated files.
- Review changes before staging them.
- Never commit or push without explicit permission.

If you can't explain why the code is needed, it probably doesn't belong in the project.
