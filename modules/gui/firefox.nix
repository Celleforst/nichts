{
  config,
  lib,
  inputs,
  pkgs,
  ...
}:
with lib; let
  username = config.modules.other.system.username;
  cfg = config.modules.programs.firefox;
in {
  options.modules.programs.firefox = {
    enable = mkEnableOption "firefox";
    extensions = mkOption {
      description = "firefox extensions (format like https://discourse.nixos.org/t/declare-firefox-extensions-and-settings/36265)";
      type = types.attrs;
      default = {};
    };
  };

  config = mkIf cfg.enable {
    home-manager.users.${username} = {
      programs.firefox = {
        enable = true;
        profiles = {
          main = {
            id = 0;
            isDefault = true;
            search.default = "DuckDuckGo";
            userChrome = ''
              @namespace url("http://www.mozilla.org/keymaster/gatekeeper/there.is.only.xul"); /* set default namespace to XUL */

              #TabsToolbar {visibility: collapse; !important; }
              /* #navigator-toolbox {visibility: collapse;} */
              browser {margin-right: -14px; margin-bottom: -14px; !important; }
            '';
            search.force = true;
            settings = {
              "toolkit.legacyUserProfileCustomizations.stylesheets" = true;
              "media.ffmpeg.vaapi.enabled" = true; # enable hardware accelerated video playback (vaapi)
              "media.peerconnection.enabled" = false;
              "browser.newtabpage.activity-stream.showSponsored" = false;
              "browser.newtabpage.activity-stream.showSponsoredTopSites" = false;
            };
            containersForce = true;
            containers = {
              nix = {
                color = "blue";
                icon = "circle";
                id = 0;
              };
              dangerous = {
                color = "red";
                icon = "fruit";
                id = 1;
              };
              shopping = {
                color = "yellow";
                icon = "cart";
                id = 2;
              };
              video = {
                color = "pink";
                icon = "vacation";
                id = 3;
              };
              studying = {
                color = "green";
                icon = "fence";
                id = 4;
              };
            };
          };
        };

        policies = {
          DisableTelemetry = true;
          DisableFirefoxStudies = true;
          EnableTrackingProtection = {
            Value = true;
            Locked = true;
            Cryptomining = true;
            Fingerprinting = true;
          };
          DisablePocket = true;
          DisableFirefoxAccounts = true;
          DisableAccounts = true;
          DisableFirefoxScreenshots = true;
          OverrideFirstRunPage = "";
          OverridePostUpdatePage = "";
          DontCheckDefaultBrowser = true;
          DisplayBookmarksToolbar = "never"; # alternatives: "always" or "newtab"
          DisplayMenuBar = "default-off"; # alternatives: "always", "never" or "default-on"
          SearchBar = "unified"; # alternative: "separate"
          FirefoxSuggest = {
            WebSuggestions = true;
            ImproveSuggest = true;
            Locked = true;
          };
          SearchSuggestEnabled = true;
          theme = {
            colors = {
              background-darker = "181825";
              background = "1e1e2e";
              foreground = "cdd6f4";
            };
          };

          OfferToSaveLogins = false;
          font = "Lexend";
          ExtensionSettings = lib.mkMerge [
            {
              "uBlock0@raymondhill.net" = {
                install_url = "https://addons.mozilla.org/firefox/downloads/latest/ublock-origin/latest.xpi";
                installation_mode = "force_installed";
              };
            }
            cfg.extensions
          ];
        };
      };
    };
  };
}
