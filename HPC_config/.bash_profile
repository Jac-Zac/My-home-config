# Start zsh only for interactive logins, avoid recursive exec on zsh and when running remote commands
if [ -n "$PS1" ] && [ -z "$ZSH_VERSION" ] && [ -z "$SSH_ORIGINAL_COMMAND" ]; then
  exec zsh -l
fi
