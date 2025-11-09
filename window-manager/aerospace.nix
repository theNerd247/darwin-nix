{pkgs, ...}:
{
  services.aerospace =
  { enable = true;
    settings =
    { after-startup-command =
      [ # "layout tiles"
      ];

      enable-normalization-flatten-containers = true;
      enable-normalization-opposite-orientation-for-nested-containers = true;

      accordion-padding = 10;

      start-at-login = false;
      default-root-container-layout = "tiles";

      on-window-detected =
      [ { "if" =
          { app-name-regex-substring = "kitty";
          };
          run = ["move-node-to-workspace 2"];
        }
        { "if" =
          { app-name-regex-substring = "firefox";
          };
          run = ["move-node-to-workspace 1"];
        }
        { "if" =
          { app-name-regex-substring = "preview";
          };
          run = ["move-node-to-workspace 3"];
        }
      ];

      mode.main.binding =
      let
        mod = "alt";
        terminalCmd = "${pkgs.kitty}/Applications/kitty.app/Contents/MacOS/kitty -1";
      in
      { # All possible commands: https://nikitabobko.github.io/AeroSpace/commands
        "${mod}-j" = "focus down";
        "${mod}-k" = "focus up";
        "${mod}-h" = "focus left";
        "${mod}-l" = "focus right";

        "${mod}-shift-j" = "move down";
        "${mod}-shift-k" = "move up";
        "${mod}-shift-h" = "move left";
        "${mod}-shift-l" = "move right";
        
        #"${mod}-shift-j" = "exec-and-forget aerospace list-windows --workspace focused | tail -n 1 | wc -l | xargs aerospace focus --dfs-index && aerospace move left && aerospace move left && aerospace move left";
        "${mod}-1" = "workspace 1";
        "${mod}-2" = "workspace 2";
        "${mod}-3" = "workspace 3";
        "${mod}-4" = "workspace 4";
        "${mod}-5" = "workspace 5";
        "${mod}-6" = "workspace 6";

        "${mod}-shift-1" = "move-node-to-workspace 1";
        "${mod}-shift-2" = "move-node-to-workspace 2";
        "${mod}-shift-3" = "move-node-to-workspace 3";
        "${mod}-shift-4" = "move-node-to-workspace 4";
        "${mod}-shift-5" = "move-node-to-workspace 5";
        "${mod}-shift-6" = "move-node-to-workspace 6";

        "${mod}-z" = "fullscreen";

        "${mod}-shift-enter" = "exec-and-forget ${terminalCmd}";

        "${mod}-space" = "layout tiles accordion";
        "${mod}-shift-space" = "layout tiles horizontal vertical";

        #"${mod}-shift-tab" = "move-workspace-to-monitor --wrap-around next";
        # alt-shift-enter = "exec-and-forget aerospace list-windows --workspace T | grep -q "kitty" && { aerospace list-workspaces --focused | grep -q "T" && aerospace workspace-back-and-forth || aerospace workspace T; } || open -a kitty";
        # alt-shift-ctrl-q = "exec-and-forget zsh -c "cat ~/.xmonad-shortcuts | head -n 1 | tail -1 | xargs activate-chrome-tab";
        # alt-shift-ctrl-q = "exec-and-forget aerospace list-windows --workspace S | grep -q "Slack" && { aerospace list-workspaces --focused | grep -q "S" && aerospace workspace-back-and-forth || aerospace workspace S; } || open -a Slack";
        # alt-shift-ctrl-q = "exec-and-forget open -a "Slack";
        # alt-shift-ctrl-w = "exec-and-forget zsh -c "cat ~/.xmonad-shortcuts | head -n 2 | tail -1 | xargs activate-chrome-tab";
        # alt-shift-ctrl-e = "exec-and-forget zsh -c "cat ~/.xmonad-shortcuts | head -n 3 | tail -1 | xargs activate-chrome-tab";
        # alt-shift-ctrl-r = "exec-and-forget zsh -c "cat ~/.xmonad-shortcuts | head -n 4 | tail -1 | xargs activate-chrome-tab";
        # alt-shift-n = "exec-and-forget open -a "Roam Research";
        # alt-shift-ctrl-p = "exec-and-forget /etc/profiles/per-user/dhines/bin/flameshot gui"
        # alt-shift-ctrl-"${mod}-p" = "exec-and-forget /etc/profiles/per-user/dhines/bin/flameshot gui --raw --accept-on-select | /etc/profiles/per-user/dhines/bin/tesseract stdin stdout -l eng --psm 6 | pbcopy"
        alt-shift-c = "close";

        # See: https://nikitabobko.github.io/AeroSpace/commands#mode
        # alt-shift-semicolon = "mode service";
      };
    };
  };
}
