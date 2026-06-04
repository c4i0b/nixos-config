# Browser policies and enterprise configuration.
{...}: {
  programs.firefox = {
    enable = true;
    policies = {
      AIControls = {
        Default.Value = "blocked";
        Default.Locked = true;
        PDFAltText.Value = "blocked";
        PDFAltText.Locked = true;
        SmartTabGroups.Value = "blocked";
        SmartTabGroups.Locked = true;
        LinkPreviewKeyPoints.Value = "blocked";
        LinkPreviewKeyPoints.Locked = true;
        SidebarChatbot.Value = "blocked";
        SidebarChatbot.Locked = true;
        SmartWindow.Value = "blocked";
        SmartWindow.Locked = true;
      };
      CaptivePortal = false;
      Cookies.AcceptThirdParty = "never";
      Cookies.Locked = true;
      DisableFirefoxStudies = true;
      DisablePocket = true;
      DisableTelemetry = true;
      DontCheckDefaultBrowser = true;
      DNSOverHTTPS = {
        Enabled = true;
        Locked = true;
        ProviderURL = "https://dns.adguard.com/dns-query";
        Fallback = true;
      };
      EnableTrackingProtection = {
        Value = true;
        Locked = true;
        Cryptomining = true;
        Fingerprinting = true;
        EmailTracking = true;
        SuspectedFingerprinting = true;
        Category = "strict";
      };
      Extensions = {
        Install = [
          "https://addons.mozilla.org/firefox/downloads/latest/ublock-origin/latest.xpi"
          "https://addons.mozilla.org/firefox/downloads/latest/ultimadark/latest.xpi"
          "https://addons.mozilla.org/firefox/downloads/latest/uaswitcher/latest.xpi"
          "https://addons.mozilla.org/firefox/downloads/latest/sponsorblock/latest.xpi"
        ];
        Locked = ["uBlock0@raymondhill.net"];
      };
      ExtensionSettings."pt-BR@dictionaries.addons.mozilla.org" = {
        installation_mode = "force_installed";
        install_url = "https://addons.mozilla.org/firefox/downloads/latest/corretor/latest.xpi";
      };
      FirefoxSuggest.SponsoredSuggestions = false;
      FirefoxSuggest.ImproveSuggest = false;
      FirefoxSuggest.Locked = true;
      HttpsOnlyMode.Enabled = true;
      HttpsOnlyMode.Locked = true;
      NetworkPrediction = false;
      Preferences."general.autoScroll".Value = true;
      SanitizeOnShutdown = {
        Cache = true;
        Cookies = false;
        Downloads = false;
        FormData = true;
        History = false;
        Sessions = true;
        SiteSettings = false;
        Locked = true;
      };
      SearchSuggestEnabled = false;
      SSLVersionMin = "tls1.2";
      UserMessaging = {
        ExtensionRecommendations = false;
        FeatureRecommendations = false;
        MoreFromMozilla = false;
        SkipOnboarding = true;
        FirefoxLabs = false;
        Locked = true;
      };
      VisualSearchEnabled = false;
    };
  };

  environment.etc."brave/policies/managed/policies.json".text = builtins.toJSON {
    BraveAIChatEnabled = false;
    BraveNewsDisabled = true;
    BravePlaylistEnabled = false;
    BraveP3AEnabled = false;
    BraveRewardsDisabled = true;
    BraveStatsPingEnabled = false;
    BraveTalkDisabled = true;
    BraveVPNDisabled = true;
    BraveWalletDisabled = true;
    BraveWebDiscoveryEnabled = false;
    BackgroundModeEnabled = false;
    BlockThirdPartyCookies = true;
    ClearBrowsingDataOnExitList = ["cached_images_and_files"];
    DefaultBrowserSettingEnabled = false;
    DnsOverHttpsMode = "secure";
    DnsOverHttpsTemplates = "https://dns.adguard.com/dns-query";
    HttpsUpgradesEnabled = true;
    MetricsReportingEnabled = false;
    NetworkPredictionOptions = 2;
    PromotionalTabsEnabled = false;
    SearchSuggestEnabled = false;
    SSLVersionMin = "tls1.2";
  };
}
