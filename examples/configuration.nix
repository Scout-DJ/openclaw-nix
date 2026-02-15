# Example NixOS configuration using the OpenClaw module
#
# Add to your flake.nix inputs:
#   openclaw.url = "github:Scout-DJ/openclaw-nix";
#
# Then in your outputs, add the module:
#   nixosConfigurations.myhost = nixpkgs.lib.nixosSystem {
#     modules = [
#       openclaw.nixosModules.default
#       ./configuration.nix
#     ];
#   };

{ config, pkgs, ... }:

{
  services.openclaw = {
    enable = true;

    # Your public domain — Caddy handles TLS automatically
    domain = "agents.example.com";

    # Gateway binds to localhost:3000 (Caddy fronts it)
    gatewayPort = 3000;

    # Tool security — allowlist mode (default, recommended)
    toolSecurity = "allowlist";
    toolAllowlist = [
      "read"
      "write"
      "edit"
      "web_search"
      "web_fetch"
      "message"
      "tts"
      # Uncomment to enable (understand the risks):
      # "exec"
      # "browser"
      # "nodes"
    ];

    # Model provider
    modelProvider = "anthropic";
    modelApiKeyFile = "/run/secrets/anthropic-api-key"; # Use agenix/sops

    # Telegram bot (optional)
    telegram = {
      enable = true;
      tokenFile = "/run/secrets/telegram-bot-token";
    };

    # Discord bot (optional)
    # discord = {
    #   enable = true;
    #   tokenFile = "/run/secrets/discord-bot-token";
    # };

    # Auto-updates (optional)
    autoUpdate = {
      enable = true;
      schedule = "Sun *-*-* 03:00:00"; # Sunday 3 AM
    };
  };

  # SSH hardening (recommended)
  services.openssh = {
    enable = true;
    settings = {
      PasswordAuthentication = false;
      PermitRootLogin = "no";
      KbdInteractiveAuthentication = false;
    };
  };
}
