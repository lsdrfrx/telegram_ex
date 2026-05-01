{ pkgs ? import <nixpkgs> {} }:

pkgs.mkShell {
  packages = with pkgs; [
    beam28Packages.elixir_1_19
    beam28Packages.expert
  ];
}
