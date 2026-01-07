{ lib
, stdenvNoCC
, fetchzip
}:

stdenvNoCC.mkDerivation {
  pname = "clawdbot-app";
  version = "2.0.0-beta5";

  src = fetchzip {
    url = "https://github.com/clawdbot/clawdbot/releases/download/v2.0.0-beta5/Clawdis-2.0.0-beta5.zip";
    hash = "sha256-1MrLVS65VOaVgRCCeN7YqLaA8KGSk2C8C+MXpl1qfiQ=";
    stripRoot = false;
  };

  dontUnpack = true;

  installPhase = "${../scripts/clawdbot-app-install.sh}";

  meta = with lib; {
    description = "Clawdbot macOS app bundle";
    homepage = "https://github.com/clawdbot/clawdbot";
    license = licenses.mit;
    platforms = platforms.darwin;
  };
}
