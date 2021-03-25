# Author: Viacheslav Lotsmanov
# License: Public Domain https://raw.githubusercontent.com/unclechu/termiterc/master/LICENSE

let sources = import nix/sources.nix; in
{ callPackage
, writeText
, lib
, termite

# Overridable dependencies
, __nix-utils ? callPackage sources.nix-utils {}

# Build options
, __darkConfigSrc  ? ./config
, __lightConfigSrc ? ./config-light
}:
let
  inherit (__nix-utils) esc wrapExecutable shellCheckers;
  termite-exe = "${termite}/bin/termite";

  basicCheckPhase = ''
    ${shellCheckers.fileIsExecutable termite-exe}
    ${shellCheckers.fileIsReadable "${__darkConfigSrc}"}
    ${shellCheckers.fileIsReadable "${__lightConfigSrc}"}
  '';

  configuredTermite = name: config:
    assert builtins.isString config;
    let savedConfig = writeText "${name}-termite-config-file" config; in
    wrapExecutable termite-exe {
      inherit name;
      args = [ "--config=${savedConfig}" ];

      checkPhase = ''
        ${basicCheckPhase}
        ${shellCheckers.fileIsReadable savedConfig}
      '';
    } // { config = savedConfig; };

  isDerivationLike = x:
    let f = x: builtins.isPath x || lib.isDerivation x; in f x || (
      builtins.isAttrs x &&
      builtins.hasAttr "outPath" x &&
      (builtins.isString x.outPath || f x.outPath)
    );

  customize =
    { defaultName ? "termite"
    , darkName    ? "${defaultName}-dark"
    , lightName   ? "${defaultName}-light"

    , font ? null # ‘Hack’ by default

    , defaultConfig ? __darkConfigSrc
    , darkConfig    ? __darkConfigSrc
    , lightConfig   ? __lightConfigSrc
    }:
    assert builtins.isString defaultName;
    assert builtins.isString darkName;
    assert builtins.isString lightName;
    assert ! isNull font -> builtins.isString font;
    assert builtins.isString defaultConfig || isDerivationLike defaultConfig;
    assert builtins.isString darkConfig    || isDerivationLike darkConfig;
    assert builtins.isString lightConfig   || isDerivationLike lightConfig;
    let
      replaceFont =
        if isNull font
        then x: x
        else builtins.replaceStrings [ "Hack" ] [ font ];

      readConfigFile = config:
        if builtins.isString config
        then config
        else builtins.readFile config;

      readConfig = lib.mapAttrs (n: v: readConfigFile v) {
        default = defaultConfig;
        dark    = darkConfig;
        light   = lightConfig;
      };

      config = lib.mapAttrs (n: v: replaceFont v) {
        default = replaceFont readConfig.default;
        dark    = replaceFont readConfig.dark;
        light   = replaceFont readConfig.light;
      };

      default = configuredTermite defaultName config.default;
    in
    default // {
      inherit default;
      dark  = configuredTermite darkName  config.dark;
      light = configuredTermite lightName config.light;
    };
in
customize {} // {
  inherit customize;
  darkConfigSrc  = __darkConfigSrc;
  lightConfigSrc = __lightConfigSrc;
}
