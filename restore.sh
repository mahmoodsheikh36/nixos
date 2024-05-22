sudo ln -sf "$PWD"/flake.nix /etc/nixos
sudo cp /etc/nixos/hardware-configuration.nix "$PWD/"
sudo mv /etc/nixos/ /tmp/moved_nixos
sudo ln -sf "$PWD"/ /etc/nixos
