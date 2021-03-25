# Author: Viacheslav Lotsmanov
# License: Public Domain https://raw.githubusercontent.com/unclechu/termiterc/master/LICENSE

let sources = import nix/sources.nix; in
#
# An example of running it with a default configuration:
#   nix-shell --run termite
#
# An example with customized arguments:
#   nix-shell --argstr name term-ibm-font --argstr font 'IBM Plex Mono' --run term-ibm-font-light
#
{ pkgs ? import sources.nixpkgs {}
, name ? null
, font ? null
, termiterc ? pkgs.callPackage ./. {}
}:
let
  extractInputs = pkgs.lib.attrVals ["default" "dark" "light"];

  argsForCustomize =
    (if isNull name then {} else { defaultName = name; }) //
    (if isNull font then {} else { inherit font; });
in
pkgs.mkShell {
  buildInputs = extractInputs (
    if isNull name && isNull font
    then termiterc
    else termiterc.customize argsForCustomize
  );
}
