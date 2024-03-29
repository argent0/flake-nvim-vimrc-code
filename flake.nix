{
  description = "A very basic flake";

  outputs = { self, nixpkgs }:  let

    pkgs = nixpkgs.legacyPackages.x86_64-linux;

  in {

    packages.x86_64-linux.vimrc = pkgs.stdenv.mkDerivation {
      name = "vimrc";
      src = ./.;
      installPhase = ''
        mkdir -p $out
        cp vimrc $out/vimrc
      '';
    };

    lib = let
      vimrcPath = "${self.packages.x86_64-linux.vimrc}/vimrc";
      baseVimrc = builtins.readFile vimrcPath;
    in {
      version = "1.0.0";
      neovim = {
        extraVimrcLines ? "",
        extraVimPlugins ? [ ],
        extraNixDerivations ? [ ],
      }: let
        vimrc = baseVimrc + "\n" + extraVimrcLines;
        vimPlugins = {
          start = ( with pkgs.vimPlugins; [
            vim-nix
            copilot-vim
          ]) ++ extraVimPlugins;
          opt = [ ];
        };
        local-neovim = pkgs.neovim.override {
          configure = {
            customRC = vimrc;
            packages.myVimPackage = {
              start = vimPlugins.start;
              opt = vimPlugins.opt;
            };
          };
        };
      in pkgs.stdenv.mkDerivation {
        name = "nvim-vimrc-code";
        src = ./.;
        buildInputs = [
          pkgs.nodejs
          local-neovim
        ] ++ extraNixDerivations;
        installPhase = ''
          mkdir -p $out
          cp -r ${local-neovim}/* $out
        '';
      };
    };


    packages.x86_64-linux.default = self.lib.neovim { };

    # devShell.x86_64-linux = self.lib.neovim { };

  };
}
