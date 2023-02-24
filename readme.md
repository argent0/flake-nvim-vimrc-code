# flake-nvim-vimrc-code

A vimrc to configure vim for coding

# Use

As part of other flakes

```{nix}
{
	# ...
	inputs = {
		nixpkgs.url = "github:nixos/nixpkgs/nixpkgs-unstable";
		project-a.url = "github:user/flake-nvim-vimrc-code";
		# ...
	};

}

```

# Develop

```
nix develop
```

