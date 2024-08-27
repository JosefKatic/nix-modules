{
  # // SV-16925 - DTBF030
  "security.enable_tls" = true;
  # // SV-16925 - DTBF030
  "security.tls.version.min" = 2;
  # // SV-16925 - DTBF030
  "security.tls.version.max" = 4;

  # // SV-111841 - DTBF210
  "privacy.trackingprotection.fingerprinting.enabled" = true;

  # // V-252881 - Retaining Data Upon Shutdown
  "browser.sessionstore.privacy_level" = 0;

  # // SV-251573 - Customizing the New Tab Page
  "browser.newtabpage.activity-stream.enabled" = false;
  "browser.newtabpage.activity-stream.feeds.section.topstories" = false;
  "browser.newtabpage.activity-stream.showSponsored" = false;
  "browser.newtabpage.activity-stream.feeds.snippets" = false;

  # // V-251580 - Disabling Feedback Reporting
  "browser.chrome.toolbar_tips" = false;
  "browser.selfsupport.url" = "";
  "extensions.abuseReport.enabled" = false;
  "extensions.abuseReport.url" = "";

  # // V-251558 - Controlling Data Submission
  "datareporting.policy.dataSubmissionEnabled" = false;
  "datareporting.healthreport.uploadEnabled" = false;
  "datareporting.policy.firstRunURL" = "";
  "datareporting.policy.notifications.firstRunURL" = "";
  "datareporting.policy.requiredURL" = "";

  # // V-252909 - Disabling Firefox Studies
  "app.shield.optoutstudies.enabled" = false;
  "app.normandy.enabled" = false;
  "app.normandy.api_url" = "";

  # // V-252908 - Disabling Pocket
  "extensions.pocket.enabled" = false;

  # // V-251555 - Preventing Improper Script Execution
  "dom.disable_window_flip" = true;

  # // V-251554 - Restricting Window Movement and Resizing
  "dom.disable_window_move_resize" = true;

  # // V-251551 - Disabling Form Fill Assistance
  "browser.formfill.enable" = false;

  # // V-251550 - Blocking Unauthorized MIME Types
  "plugin.disable_full_page_plugin_for_types" = "application/pdf,application/fdf,application/xfdf,application/lso,application/lss,application/iqy,application/rqy,application/lsl,application/xlk,application/xls,application/xlt,application/pot,application/pps,application/ppt,application/dos,application/dot,application/wks,application/bat,application/ps,application/eps,application/wch,application/wcm,application/wb1,application/wb3,application/rtf,application/doc,application/mdb,application/mde,application/wbk,application/ad,application/adp";
}
