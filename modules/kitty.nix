{moduleWithSystem, ...}: 
{ flake.nixosModules.default = moduleWithSystem ({config, pkgs, lib, ...}: {...}:
  let
    cfg = config.programs.kitty;

    configFile =
    ''
    # https://sw.kovidgoyal.net/kitty/conf
    ${config.programs.kitty.extraConfig};
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
    { enable = lib.options.mkEnableOption "enable kitty";

      extraConfig = lib.options.mkOption
      { default = "";
        type = lib.types.lines;
        description = "Extra configuration to append to the kitty config";
      };
    };

    config = lib.mkIf cfg.enable
    {
      environment.systemPackages = [ kittyWithCfg ];

      programs.kitty.bin = kittyWithCfg;
    };
  });
}
