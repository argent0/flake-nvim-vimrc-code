{
  description = "A very basic flake";

  outputs = { self, nixpkgs }:  let

    pkgs = nixpkgs.legacyPackages.x86_64-linux;

    baseVimrc = ''
" show number
set number
" highlight the 80th column
set colorcolumn=80
" set the column highlight color to light blue
highlight ColorColumn ctermbg=lightblue guibg=lightblue
" don't wrap lines
set nowrap
    '';

    nvimShell = {
      version = "1.0.0";
      neovim = {
        extraVimrcLines ? "",
        extraVimPlugins ? [ ],
        extraNixDerivations ? [ ],
      }:
      let
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
      in pkgs.mkShell {
        buildInputs = [
          pkgs.nodejs
          local-neovim
        ] ++ extraNixDerivations;
      };
    };
  in {

    lib = nvimShell;

    packages.x86_64-linux.default = pkgs.buildEnv {
      name = "nvimShell";
      paths = [];
    };

    devShell.x86_64-linux = nvimShell.neovim { };

  };
}
