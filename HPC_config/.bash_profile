# Keep the cluster's default bash setup (modules, paths)
[ -f "$HOME/.bashrc" ] && . "$HOME/.bashrc"

# Hand interactive logins over to zsh (chsh is usually not allowed on HPC).
# Skipped for non-interactive sessions (scp, rsync, ssh host cmd) and inside zsh.
if [[ $- == *i* ]] && [ -z "${ZSH_VERSION:-}" ] && command -v zsh >/dev/null; then
  exec zsh -l
fi
