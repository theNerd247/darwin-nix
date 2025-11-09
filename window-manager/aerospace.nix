{
  services.aerospace =
  { enable = false;
    settings =
    {after-startup-command =
      [ #"layout-tiles"
      ];

    start-at-login = true;
    default-root-container-layout = "tiles";
    };
  };
}
