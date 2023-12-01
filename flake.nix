{
  inputs.nixpkgs.url = "github:NixOS/nixpkgs/bb069d84b1e8dd8b6bb60e3368d0d77aa9a49f9c"; # last commit before bitstring 4* upgrade
  inputs.flake-utils.url = "github:numtide/flake-utils";
  inputs.plover_plugins_registry = { url = "github:openstenoproject/plover_plugins_registry"; flake = false; };
  inputs.plover = { url = "github:openstenoproject/plover"; flake = false; };
  inputs.rtf-tokenize = { url = "github:openstenoproject/rtf_tokenize"; flake = false; };
  inputs.plover-stroke = { url = "github:openstenoproject/plover_stroke"; flake = false; };
  inputs.plover-machine-hid = { url = "github:dnaq/plover-machine-hid"; flake = false; };
  inputs.plover_auto_reconnect_machine = { url = "github:tschulte/plover_auto_reconnect_machine"; flake = false; };
  inputs.plover2cat = { url = "github:greenwyrt/plover2CAT"; flake = false; };
  inputs.my-plover-hid-machine = { url = "path:/home/stites/git/python/my-plover-hid-machine"; flake = false; };

  outputs = { self, nixpkgs, flake-utils, ... }@sources:
    flake-utils.lib.eachDefaultSystem
      (system:
      let pkgs = nixpkgs.legacyPackages.${system};
      in {
        devShells.default = pkgs.mkShell {
          PLUGINREGISTRY="${sources.plover_plugins_registry}/registry.json";
          packages = with pkgs; with python3Packages; [
            curl
            ipython
            jq
          ];
        };
        packages.default = self.packages.${system}.plover;
        packages.plover = let
          pyqt5 = pkgs.python3Packages.pyqt5.override { withMultimedia = true; };
          plover = pkgs.python3Packages.callPackage ./plover.nix { inherit sources pyqt5; };
          with-plugins =  f: let
            plugins = pkgs.python3Packages.callPackage ./plugins.nix { inherit plover sources; };
            in plover.overrideAttrs (old: {
              propagatedBuildInputs = old.propagatedBuildInputs ++ (f plugins);
            });
          in plover // { inherit with-plugins; };
      }
    );
}
