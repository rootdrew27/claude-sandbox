# claude-sandbox

`bin/claude-sandbox` is a bash script that manages Docker containers running Claude Code. `docker/` holds the sandbox image and `docker/proxy/` the proxy image; `templates/` holds built-in starting `~/.claude` folders. User docs: README.md.

- The script must run on macOS's bash 3.2: no `local -n`, `mapfile` or `${var,,}`; expand possibly-empty arrays as `${arr[@]+"${arr[@]}"}`.
- Help is the comment block at the top of the script: `--help` up to `#--more`, `--help-more` after. Keep both in sync with the commands and README.
- Tokens are passed only with `docker exec -e` at launch, never stored in the container's configuration (`docker run -e`, labels, the image).
- Internet: sandboxes send web traffic to `http://proxy:8888`; `net` moves the container between the `claude-sandbox-online` and `-offline` networks, where `proxy` is an open or a filtering proxy. Don't set `CLAUDE_CODE_DISABLE_NONESSENTIAL_TRAFFIC`: it makes Claude start in auto mode instead of the template's bypass mode.
- Git: `git NAME off` moves `.git` to root-only `/var/lib/sandbox-git` via `docker exec -u root`; Claude runs as `node` with no-new-privileges, so it can't reach it. Never switch git in `--mount` sandboxes: that would move the user's real `.git`.
- Test changes end to end with throwaway sandboxes in a temp folder (`new`, `attach`, `stop`/`start`, `net`, `git`, `import`/`export`), then `rm -f` them.
