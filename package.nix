{
  pkgs ? import <nixpkgs> { },
  version ? "2026.2.14",
}:
pkgs.stdenv.mkDerivation {
  pname = "openclaw";
  inherit version;
  __noChroot = true;

  # We fetch from npm at build time
  nativeBuildInputs = with pkgs; [
    nodejs_22
    cacert
    git
    cmake
  ];
  buildInputs = with pkgs; [
    nodejs_22
    libxpm
  ];

  # No source — we install from npm
  dontUnpack = true;
  dontConfigure = true;

  buildPhase = ''
    export HOME=$TMPDIR
    export npm_config_cache=$TMPDIR/npm-cache
    mkdir -p $npm_config_cache

    # Install OpenClaw globally to a local prefix
    npm install --global --prefix=$out openclaw@${version}
  '';

  installPhase = ''
    # npm install --global --prefix already puts things in $out
    # Ensure the bin directory exists and is linked
    mkdir -p $out/bin

    # Create wrapper that sets NODE_PATH
    for f in $out/lib/node_modules/.bin/*; do
      name=$(basename $f)
      if [ ! -e "$out/bin/$name" ]; then
        ln -sf "$f" "$out/bin/$name"
      fi
    done
  '';

  meta = with pkgs.lib; {
    description = "OpenClaw — AI agent infrastructure platform";
    homepage = "https://github.com/openclaw/openclaw";
    license = licenses.mit;
    platforms = platforms.linux;
  };
}
