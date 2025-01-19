# SPDX-FileCopyrightText: 2025 Jonas Fierlings <fnoegip@gmail.com>
#
# SPDX-License-Identifier: 0BSD
{
  config,
  ...
}:
{
  _file = ./homepage-dashboard.nix;

  config = {
    sops = {
      secrets = {
        "adguard/user" = { };
        "adguard/password" = { };
      };
    };

    systemd.services.homepage-dashboard = {
      environment = {
        HOMEPAGE_FILE_ADGUARD_USER = "%d/adguard.user";
        HOMEPAGE_FILE_ADGUARD_PASSWORD = "%d/adguard.password";
      };
      serviceConfig = {
        LoadCredential = [
          "adguard.user:${config.sops.secrets."adguard/user".path}"
          "adguard.password:${config.sops.secrets."adguard/password".path}"
        ];
      };
    };

    services = {
      homepage-dashboard = {
        enable = true;
        bookmarks = [
          {
            "WiFi Access Points" = [
              {
                "AX820-1F" = [
                  {
                    abbr = "A1";
                    href = "http://192.168.178.20";
                    description = "Ground Floor";
                  }
                ];
              }
              {
                "AX820-2F" = [
                  {
                    abbr = "A2";
                    href = "http://192.168.178.22";
                    description = "2nd Floor";
                  }
                ];
              }
              {
                "AX820-Garage" = [
                  {
                    abbr = "AG";
                    href = "http://192.168.178.24";
                    description = "Garage";
                  }
                ];
              }
            ];
          }
          {
            "Network Switches (VLAN1 only)" = [
              {
                "DGS-1210-8P-0" = [
                  {
                    abbr = "S0";
                    href = "http://192.168.178.80";
                    description = "Garage (PoE)";
                  }
                ];
              }
              {
                "DGS-1210-10-2" = [
                  {
                    abbr = "S2";
                    href = "http://192.168.178.102";
                    description = "Rack U2";
                  }
                ];
              }
              {
                "DGS-1210-8P-4" = [
                  {
                    abbr = "S4";
                    href = "http://192.168.178.84";
                    description = "Rack U4 (PoE)";
                  }
                ];
              }
            ];
          }
        ];
        settings = {
          startUrl = "https://fierlings.family";
        };
        services = [
          {
            "Network" = [
              {
                "Fritz!Box" = {
                  href = "http://fritz.box";
                  widget = {
                    type = "fritzbox";
                    url = "http://192.168.178.1";
                  };
                };
              }
              {
                "Adguard" = {
                  href = "http://192.168.178.53";
                  description = "The advertisement blocker";
                  widget = {
                    type = "adguard";
                    url = "http://192.168.178.53";
                    username = "{{HOMEPAGE_FILE_ADGUARD_USER}}";
                    password = "{{HOMEPAGE_FILE_ADGUARD_PASSWORD}}";
                  };
                };
              }
            ];
          }
        ];
        widgets = [
          {
            datetime = {
              text_size = "x1";
              format = {
                timeStyle = "short";
              };
            };
          }
        ];
      };

      nginx = {
        virtualHosts = {
          "fierlings.family" = {
            locations."/" = {
              proxyPass = "http://localhost:${toString config.services.homepage-dashboard.listenPort}";
            };
          };
        };
      };
    };
  };
}
