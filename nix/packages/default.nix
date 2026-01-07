{ pkgs
, sourceInfo ? import ../sources/clawdbot-source.nix
, steipetePkgs ? {}
}:
let
  isDarwin = pkgs.stdenv.hostPlatform.isDarwin;
  toolSets = import ../tools/extended.nix {
    pkgs = pkgs;
    steipetePkgs = steipetePkgs;
  };
  clawdbotGateway = pkgs.callPackage ./clawdbot-gateway.nix {
    inherit sourceInfo;
    pnpmDepsHash = sourceInfo.pnpmDepsHash or null;
  };
  clawdbotApp = if isDarwin then pkgs.callPackage ./clawdbot-app.nix { } else null;
  clawdbotToolsBase = pkgs.buildEnv {
    name = "clawdbot-tools-base";
    paths = toolSets.base;
  };
  clawdbotToolsExtended = pkgs.buildEnv {
    name = "clawdbot-tools-extended";
    paths = toolSets.extended;
  };
  clawdbotBundle = pkgs.callPackage ./clawdbot-batteries.nix {
    clawdbot-gateway = clawdbotGateway;
    clawdbot-app = clawdbotApp;
    extendedTools = toolSets.base;
  };
in {
  clawdbot-gateway = clawdbotGateway;
  clawdbot = clawdbotBundle;
  clawdbot-tools-base = clawdbotToolsBase;
  clawdbot-tools-extended = clawdbotToolsExtended;
} // (if isDarwin then { clawdbot-app = clawdbotApp; } else {})
