{
  description = "One flake. Fully hardened. Your agents, secured.";

  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/nixos-unstable";
  };

  outputs = { self, nixpkgs }:
    let
      supportedSystems = [ "x86_64-linux" "aarch64-linux" ];
      forAllSystems = nixpkgs.lib.genAttrs supportedSystems;
    in
    {
      # NixOS module — import this in your configuration.nix
      nixosModules.default = import ./modules/openclaw.nix;
      nixosModules.openclaw = import ./modules/openclaw.nix;

      # Overlay that provides pkgs.openclaw
      overlays.default = final: prev: {
        openclaw = self.packages.${final.system}.openclaw;
      };

      # Standalone packages
      packages = forAllSystems (system:
        let
          pkgs = nixpkgs.legacyPackages.${system};

          # OpenClaw package — built from npm
          openclawPkg = pkgs.callPackage ./package.nix { };
        in
        {
          # The OpenClaw package itself
          openclaw = openclawPkg;

          # Quick setup script
          quick-setup = pkgs.writeShellScriptBin "openclaw-setup" (builtins.readFile ./scripts/quick-setup.sh);

          default = pkgs.writeShellScriptBin "openclaw-nix" ''
            echo ""
            echo "  ╔══════════════════════════════════════════════════╗"
            echo "  ║  OpenClaw NixOS — Hardened Agent Infrastructure  ║"
            echo "  ║  One flake. Fully hardened. Your agents, secured ║"
            echo "  ╚══════════════════════════════════════════════════╝"
            echo ""
            echo "  Usage:"
            echo ""
            echo "    1. Add to your flake inputs:"
            echo "       openclaw.url = \"github:Scout-DJ/openclaw-nix\";"
            echo ""
            echo "    2. Import the module:"
            echo "       imports = [ openclaw.nixosModules.default ];"
            echo ""
            echo "    3. Enable it:"
            echo "       services.openclaw.enable = true;"
            echo "       services.openclaw.domain = \"agents.example.com\";"
            echo ""
            echo "    Quick setup (interactive):"
            echo "       nix run github:Scout-DJ/openclaw-nix#quick-setup"
            echo ""
            echo "    What you get:"
            echo "      ✓ OpenClaw gateway as hardened systemd service"
            echo "      ✓ Caddy reverse proxy with automatic TLS"
            echo "      ✓ Gateway auth enabled (auto-generated token)"
            echo "      ✓ Localhost-only binding (no exposed panels)"
            echo "      ✓ Tool allowlists (no 'full' mode)"
            echo "      ✓ Firewall: only 443 + SSH"
            echo "      ✓ Fail2ban for SSH"
            echo "      ✓ DynamicUser, PrivateTmp, NoNewPrivileges"
            echo ""
            echo "  Docs: https://github.com/Scout-DJ/openclaw-nix"
            echo ""
          '';
        });

      # nix run github:Scout-DJ/openclaw-nix
      apps = forAllSystems (system: {
        default = {
          type = "app";
          program = "${self.packages.${system}.default}/bin/openclaw-nix";
        };
        quick-setup = {
          type = "app";
          program = "${self.packages.${system}.quick-setup}/bin/openclaw-setup";
        };
      });
    };
}
