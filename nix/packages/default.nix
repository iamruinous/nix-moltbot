{ pkgs
, sourceInfo ? import ../sources/clawdbot-source.nix
, steipetePkgs ? {}
}:
let
  isDarwin = pkgs.stdenv.hostPlatform.isDarwin;
  steipetePkgsPatched =
    if steipetePkgs ? summarize then
      steipetePkgs // {
        summarize = steipetePkgs.summarize.overrideAttrs (old: {
          env = (old.env or {}) // {
            PNPM_CONFIG_MANAGE_PACKAGE_MANAGER_VERSIONS = "false";
          };
        });
      }
    else
      steipetePkgs;
  toolSets = import ../tools/extended.nix {
    pkgs = pkgs;
    steipetePkgs = steipetePkgsPatched;
  };
  clawdbotGateway = pkgs.callPackage ./clawdbot-gateway.nix {
    inherit sourceInfo;
    pnpmDepsHash = sourceInfo.pnpmDepsHash or null;
  };
  clawdbotApp = if isDarwin then pkgs.callPackage ./clawdbot-app.nix { } else null;
  clawdbotTools = pkgs.buildEnv {
    name = "clawdbot-tools";
    paths = toolSets.tools;
  };
  clawdbotBundle = pkgs.callPackage ./clawdbot-batteries.nix {
    clawdbot-gateway = clawdbotGateway;
    clawdbot-app = clawdbotApp;
    extendedTools = toolSets.tools;
  };
in {
  clawdbot-gateway = clawdbotGateway;
  clawdbot = clawdbotBundle;
  clawdbot-tools = clawdbotTools;
} // (if isDarwin then { clawdbot-app = clawdbotApp; } else {})
