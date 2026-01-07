self: super:
let
  packages = import ./packages { pkgs = super; };
in
packages // {
  clawdbotPackages = packages;
}
