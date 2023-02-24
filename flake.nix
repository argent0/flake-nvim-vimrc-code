{
  description = "A vimrc to configure vim for coding";

  outputs = { self, nixpkgs }: 
  let
    src = ./vimrc;
    pkgs = nixpkgs.legacyPackages.x86_64-linux;
  in {

    # The package output for this flake, which installs the Vim configuration
    # file into the Nix store at the path /etc/nvim/vimrc
    packages.x86_64-linux.default = pkgs.stdenv.mkDerivation {
      name = "nvim-vimrc-code";
      src = ./.;
      installPhase = ''
        mkdir -p $out/etc/nvim
        cp vimrc $out/etc/nvim/vimrc
      '';
    };

    # The devShell environment output for this flake, which provides a shell
    # environment that includes the custom Vim configuration and other
    # development tools
    devShells.x86_64-linux.default = pkgs.mkShell {
      buildInputs = with pkgs; let
        vimrcPath =
          self.packages.x86_64-linux.default.outPath + "/etc/nvim/vimrc";
          local-neovim = neovim.override {
            configure = {
              # Additional plugins to be installed
              packages.myVimPackages = with pkgs.vimPlugins; {
                start = [
                  vim-nix
                  copilot-vim
                ];
                opt = [ ];
              };
              customRC = builtins.readFile vimrcPath;
            };
          };
      in [
        self.packages.x86_64-linux.default
        nodejs
        local-neovim
        git
      ];
    };

  };
}
