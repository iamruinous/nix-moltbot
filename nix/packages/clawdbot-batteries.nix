{ lib
, buildEnv
, clawdbot-gateway
, clawdbot-app ? null
, extendedTools ? []
}:

let
  appPaths = lib.optional (clawdbot-app != null) clawdbot-app;
  appLinks = lib.optional (clawdbot-app != null) "/Applications";
in
buildEnv {
  name = "clawdbot-2.0.0-beta5";
  paths = [ clawdbot-gateway ] ++ appPaths ++ extendedTools;
  pathsToLink = [ "/bin" ] ++ appLinks;

  meta = with lib; {
    description = "Clawdbot batteries-included bundle (gateway + app + tools)";
    homepage = "https://github.com/clawdbot/clawdbot";
    license = licenses.mit;
    platforms = platforms.darwin ++ platforms.linux;
  };
}
