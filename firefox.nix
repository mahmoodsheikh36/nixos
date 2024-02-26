{ pkgs, ... }:

# from https://nixos.org/manual/nixpkgs/unstable/
# nix firefox addons only work with the firefox-esr package.
with pkgs;
wrapFirefox firefox-esr-unwrapped {

  nixExtensions = [
    (fetchFirefoxAddon {
      name = "ublock"; # Has to be unique!
      url = "https://addons.mozilla.org/firefox/downloads/file/3679754/ublock_origin-1.31.0-an+fx.xpi";
      hash = "sha256-2e73AbmYZlZXCP5ptYVcFjQYdjDp4iPoEPEOSCVF5sA=";
    })
  ];

  extraPolicies = {
    CaptivePortal = false;
    DisableFirefoxStudies = true;
    DisablePocket = true;
    DisableTelemetry = true;
    DisableFirefoxAccounts = true;
    FirefoxHome = {
      Pocket = false;
      Snippets = false;
    };
    UserMessaging = {
      ExtensionRecommendations = false;
      SkipOnboarding = true;
    };
    SecurityDevices = {
      # Use a proxy module rather than `nixpkgs.config.firefox.smartcardSupport = true`
      "PKCS#11 Proxy Module" = "${pkgs.p11-kit}/lib/p11-kit-proxy.so";
    };
  };

  extraPrefs = ''
    // Show more ssl cert infos
    lockPref("security.identityblock.show_extended_validation", true);

    // Enable dark dev tools
    lockPref("devtools.theme","dark");

    // Disable add-on signing
    lockPref("xpinstall.signatures.required", false)

    // Disable language pack signing
    lockPref("extensions.langpacks.signatures.required", false)
  '';
}