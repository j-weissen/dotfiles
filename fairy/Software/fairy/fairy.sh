fairy_marker="# Fairy"
fairy_dotfiles_repo_path="$HOME/dotfiles"
fairy_nixos_config_flake_path="$fairy_dotfiles_repo_path/nixos"
fairy_nixos_config_file_path="$fairy_nixos_config_flake_path/$HOSTNAME/configuration.nix"

fairy_install() {
  for package in ${@}; do
    sed -i "/$fairy_marker/a\
    $package" $fairy_nixos_config_file_path
  done
  nixos-rebuild switch --flake $fairy_nixos_config_flake_path#$HOSTNAME
  if [ $? != 0 ]; then
    echo "ERROR: nixos-rebuild failed"
    exit 1
  fi
  cd $fairy_dotfiles_repo_path && git commit -m "fairy: installed $1"
}

case "$1" in
    install)
        echo "trying to install ${@:2}"
        fairy_install ${@:2}
        ;;
    push)
        echo "trying to push"
        cd $fairy_dotfiles_repo_path && git push
        ;;
    *)
        echo "Unknown command: $1"
        exit 1
        ;;
esac

alias fairy="$HOME/Software/fairy.sh"
