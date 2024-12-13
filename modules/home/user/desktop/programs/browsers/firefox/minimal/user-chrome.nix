''
  /* Base color for the theme, dependent on whether it's a light theme or not */
  @media (prefers-color-scheme: dark) {
      :root {
          --lwt-accent-color: #1c1b22;
      }
  }

  @media (prefers-color-scheme: light) {
      :root {
          --lwt-accent-color: #FAFAFC;
      }
  }

  /*====== Aesthetics ======*/

  #navigator-toolbox {
      background: var(--lwt-accent-color) !important;
      border-bottom: none !important;
  }

  #titlebar {
      background: var(--lwt-accent-color) !important;
  }

  /* Sets the toolbar color */
  toolbar#nav-bar {
      background: var(--lwt-accent-color) !important;
      box-shadow: none !important;
  }

  /* Sets the URL bar color */
  #urlbar {
      background: var(--lwt-accent-color) !important;
  }

  #urlbar-background {
      background: var(--lwt-accent-color) !important;
      border: none !important;
  }

  #urlbar-input-container {
      border: none !important;
  }

  /*====== UI Settings ======*/

  :root {
      --navbarWidth: 500px; /* Set width of navbar */
  }

  /* If the window is wider than 1000px, use flex layout */
  @media (min-width: 1000px) {
      #navigator-toolbox {
          display: flex;
          flex-direction: row-reverse;
          flex-wrap: wrap;
      }

      /*  Url bar  */
      #nav-bar {
          order: 1;
          width: var(--navbarWidth);
      }

      /* Tab bar */
      #titlebar {
          order: 2;
          width: calc(100vw - var(--navbarWidth) - 1px);
      }

      /* Bookmarks bar */
      #PersonalToolbar {
          order: 3;
          width: 100%;
      }

      /* Fix urlbar sometimes being misaligned */
      :root[uidensity="compact"] #urlbar {
          --urlbar-toolbar-height: 39.60px !important;
      }

      :root[uidensity="touch"] #urlbar {
          --urlbar-toolbar-height: 49.00px !important;
      }
  }

  /*====== Simplifying interface ======*/

  /* Autohide back button when disabled */
  #back-button, #forward-button {
      transform: scale(1, 1) !important;
      transition: margin-left 150ms var(--animation-easing-function), opacity 250ms var(--animation-easing-function), transform 350ms var(--animation-easing-function) !important;
  }

  #back-button[disabled="true"], #forward-button[disabled="true"] {
      margin-left: -34px !important;
      opacity: 0 !important;
      transform: scale(0.8, 0.8) !important;
      pointer-events: none !important;
  }

  /* Remove UI elements */
  #identity-box, /* Site information */
  #tracking-protection-icon-container, /* Shield icon */
  #page-action-buttons > :not(#urlbar-zoom-button, #star-button-box), /* All url bar icons except for zoom level and bookmarks */
  #urlbar-go-button, /* Search URL magnifying glass */
  #alltabs-button, /* Menu to display all tabs at the end of tabs bar */
  #toolbar-menubar,
  .titlebar-buttonbox-container /* Minimize, maximize, and close buttons */ {
      display: none !important;
  }

  #nav-bar {
      box-shadow: none !important;
  }

  /* Remove "padding" left and right from tabs */
  .titlebar-spacer {
      display: none !important;
  }

  /* Fix URL bar overlapping elements */
  #urlbar-container {
      min-width: initial !important;
  }

  /* Remove gap after pinned tabs */
  #tabbrowser-tabs[haspinnedtabs]:not([positionpinnedtabs])
  > #tabbrowser-arrowscrollbox
  > .tabbrowser-tab[first-visible-unpinned-tab] {
      margin-inline-start: 0 !important;
  }

  /* Hide the hamburger menu */
  #PanelUI-menu-button {
      padding: 0px !important;
  }

  #PanelUI-menu-button .toolbarbutton-icon {
      width: 1px !important;
  }

  #PanelUI-menu-button .toolbarbutton-badge-stack {
      padding: 0px !important;
  }
''
