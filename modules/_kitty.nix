{config, pkgs, lib, ...}:
  let
    cfg = config.programs.kitty;

    configFile =
    ''
    # Config Docs: https://sw.kovidgoyal.net/kitty/conf
    '';

    kittyWithCfg = pkgs.writeShellApplication
      { name = "kitty-wrapped";
        text =
        ''
        ${pkgs.kitty}/bin/kitty\
          --title kitty
          --config ${configFile}
        '';
      };

  in
  {
    options.programs.kitty =
    { enable = lib.options.mkEnableOption "enable kitty terminal";

      extraConfig = lib.options.mkOption
      { default = "";
        type = lib.types.lines;
        description = "Extra configuration to append to the kitty config";
      };

      package = lib.options.mkOption
      { default = kittyWithCfg;
        type = lib.types.package;
      };
    };

    config = lib.mkIf cfg.enable
    {
      environment.systemPackages = [ kittyWithCfg ];
    };
  }
