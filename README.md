# claude-sandbox

Run Claude Code in Docker containers. Each sandbox has its own copy of a folder and its own `~/.claude`, and lasts until you remove it. Claude runs in tmux, so you can close the terminal and come back later.

- **Control context**: Claude sees only the files, `~/.claude`, git history and internet access you give it.
- **Keep your machine clean**: whatever Claude installs or creates stays in the container.
- **Run unattended**: start a long task, detach, check back later.

## Requirements

- macOS or Linux with Docker ([OrbStack](https://orbstack.dev) works well on macOS)
- Claude Code and a Claude subscription (Pro or Max)

## Install

```sh
git clone https://github.com/rootdrew27/claude-sandbox.git
cd claude-sandbox
./install.sh            # links claude-sandbox into ~/.local/bin
```

Create a long-lived Claude token with `claude setup-token`, then store it:

```sh
# macOS (Keychain)
security add-generic-password -U -a "$USER" -s claude-oauth-token -w '<token>'
# Linux (file)
mkdir -p ~/.config/claude-sandbox && (umask 077; echo '<token>' > ~/.config/claude-sandbox/claude-oauth-token)
```

The Docker images build automatically on first use.

## Usage

```sh
cd ~/projects/my-app
claude-sandbox new -- "Read TASK.md and do it"   # copy this folder into a sandbox, start Claude
claude-sandbox attach my-app-sandbox-01          # watch or steer; Ctrl-b d to leave
```

| Command | Effect |
|---|---|
| `new [NAME] [options] [-- claude args]` | Create a sandbox and start Claude. `NAME` defaults to `<folder>-sandbox-NN` |
| `attach NAME` | Open Claude. Ctrl-b d or closing the terminal leaves it running |
| `stop NAME` / `start NAME` | Shut down / boot again; Claude resumes the conversation |
| `ls` | List sandboxes |
| `rm [-f] NAME` | Delete a sandbox and everything in it |
| `net NAME [on\|off]` | Show or switch internet access, live |
| `net reload` | Apply allowlist changes |
| `git NAME [on\|off]` | Show or switch access to `.git`, live |
| `import NAME PATH... [--to DIR]` | Copy files in |
| `export NAME [PATH...] [--to DIR]` | Copy files out (default: `./NAME-export`) |
| `shell NAME` | Bash in the workspace |
| `rebuild` | Update Claude Code (for new sandboxes) |

`new` options:

| Option | Default | Effect |
|---|---|---|
| `--from DIR` | current folder | Folder to copy in |
| `--template T` | `default` | Starting `~/.claude`: a template name or a path |
| `--isolate` | | Start with git and internet off |
| `--no-git` | | Start with git off |
| `--offline` | | Start with internet off |
| `--mount` | | Use the real folder live instead of a copy (not with `--isolate`) |
| `--cpus N` | `8` | CPU limit |
| `--memory SIZE` | `8g` | Memory limit; processes that exceed it are killed |

`claude-sandbox --help` lists the common commands; `--help-more` lists everything.

## Controlling context

### Files

`new` copies `--from` once; nothing on your machine is mounted, so changes don't leak either way.

- In a git repo, it copies what git sees (tracked and new files, not ignored ones) plus `.git`.
- Elsewhere, it copies the whole folder.
- To leave out more, list tar patterns in a `.sandboxignore` file, e.g. `.env` or `data/*.csv`. Excluded files that git tracks are hidden from git, so they're never committed as deleted.
- Add files later with `import`; remove them from `shell`.

### Git

`.git` lets Claude commit and push, and gives it the repo's history: useful context, but it can bias Claude toward past approaches. `git NAME off` moves `.git` to a root-only folder Claude can't read; `git NAME on` restores it unchanged. `--no-git` starts with it off.

Limits: Claude keeps whatever it already saw, including the recent commits Claude Code reads when a session starts with git on. With internet on, it could also fetch history from GitHub.

### Internet

`net NAME off` and `net NAME on` switch instantly without interrupting Claude; `--offline` starts with it off. Off allows only Anthropic's API and the domains in `~/.config/claude-sandbox/allowlist`:

```
# one domain per line; wildcards allowed
pypi.org
*.pythonhosted.org
```

Run `claude-sandbox net reload` after editing it. Docker networking enforces this, not Claude: an offline sandbox's only route out is a filtering proxy. See what was blocked with `docker logs claude-sandbox-proxy-offline`.

### Isolation

`new --isolate` turns git and internet off, so Claude works only from the current files. Turn either back on when needed, e.g. `git NAME on` and `net NAME on` to let Claude push.

### Templates

A template is the starting `~/.claude` (`CLAUDE.md`, `settings.json`, skills, agents, ...). `--template NAME` looks in `~/.config/claude-sandbox/templates/`, then this repo's `templates/`. To make one, copy `templates/default` there and edit it. Changes apply to new sandboxes only.

The `default` template turns permission prompts off and auto-compaction on, so unattended runs don't stall. It also denies pushing to `main`/`master`, force-pushing and merging PRs. That guards against mistakes, not determined workarounds such as calling the GitHub API with `curl`.

Your own `~/.claude`, home folder and credentials are never in a sandbox.

## Pushing to GitHub

Store a GitHub token as `claude-sandbox-github`, the same way as the Claude token. Use a fine-grained token limited to the repos you want, with Contents: read and write.

Tokens are passed in each time Claude launches and never stored in the container's configuration. `CLAUDE_CODE_OAUTH_TOKEN` and `GH_TOKEN`, if set in your environment, take priority.

## Configuration

| Setting | Where |
|---|---|
| Default CPU / memory limits | `CLAUDE_SANDBOX_CPUS`, `CLAUDE_SANDBOX_MEMORY` |
| Templates, allowlist, token files | `~/.config/claude-sandbox/` (or `$XDG_CONFIG_HOME/claude-sandbox/`) |
| Tools in every sandbox | `docker/Dockerfile`, then `claude-sandbox rebuild` |

## Uninstall

```sh
claude-sandbox ls        # rm any sandboxes you no longer need
rm ~/.local/bin/claude-sandbox
docker rm -f claude-sandbox-proxy claude-sandbox-proxy-offline
docker network rm claude-sandbox-online claude-sandbox-offline
docker image rm claude-sandbox claude-sandbox-proxy
```

## License

MIT
