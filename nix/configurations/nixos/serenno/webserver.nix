# SPDX-FileCopyrightText: 2025 Jonas Fierlings <fnoegip@gmail.com>
#
# SPDX-License-Identifier: 0BSD
{
  config,
  lib,
  pkgs,
  ...
}:
let
  cfg = config.croissant;
  inherit (lib) mkOption types;
in
{
  _file = ./webserver.nix;

  options = {
    croissant.serenno = {
      virtualhosts = mkOption {
        default = { };
        example = {
          "fierlings.family" = "raxus";
        };
        description = ''
          Mapping of domain names to haproxy backends.
        '';
        type = types.attrsOf types.str;
      };
    };
  };

  config = {
    environment = {
      persistence."/persist" = {
        directories = [ "/var/lib/acme" ];
      };
    };

    sops = {
      secrets = {
        # https://dash.cloudflare.com/profile/api-tokens
        "acme/fierlings.family/dns_token" = { }; # DNS:Edit (Zone.DNS)
        "acme/fierlings.family/zone_token" = { }; # Zone:Read (Zone.Zone)
      };
    };

    # The caddy dns challenge plugin is not shipped in nixpkgs, so we use the acme module instead.
    security = {
      acme = {
        acceptTerms = true;
        certs = {
          "fierlings.family" = {
            email = "fnoegip+letsencrypt@gmail.com";
            credentialFiles = {
              "CF_DNS_API_TOKEN_FILE" = config.sops.secrets."acme/fierlings.family/dns_token".path;
              "CF_ZONE_API_TOKEN_FILE" = config.sops.secrets."acme/fierlings.family/zone_token".path;
            };
            dnsProvider = "cloudflare";
            dnsResolver = "9.9.9.9:53";
            extraDomainNames = [ "*.fierlings.family" ];
            inherit (config.services.haproxy) group;
            reloadServices = [ "haproxy.service" ];
          };
        };
      };
    };

    services = {
      haproxy = {
        enable = true;
        config =
          let
            map = pkgs.writeText "haproxy.map" ''
              # DO NOT EDIT. Autogenerated by ${./webserver.nix}.
              ${lib.strings.concatStringsSep "\n" (
                lib.attrsets.mapAttrsToList (domain: backend: "${domain}  ${backend}") cfg.serenno.virtualhosts
              )}
            '';
          in
          ''
            global
              log "/dev/log" len 65535 format "rfc3164" daemon info err
              maxconn 4096
              ssl-default-bind-ciphers ECDHE-ECDSA-AES256-GCM-SHA384:ECDHE-RSA-AES256-GCM-SHA384:ECDHE-ECDSA-CHACHA20-POLY1305:ECDHE-RSA-CHACHA20-POLY1305:ECDHE-ECDSA-AES128-GCM-SHA256:ECDHE-RSA-AES128-GCM-SHA256:ECDHE-ECDSA-AES256-SHA384:ECDHE-RSA-AES256-SHA384:ECDHE-ECDSA-AES128-SHA256:ECDHE-RSA-AES128-SHA256
              ssl-default-bind-options ssl-min-ver TLSv1.2 no-tls-tickets

            crt-store acme
              crt-base /var/lib/acme
              key-base /var/lib/acme
              load crt "fierlings.family/cert.pem" key "fierlings.family/key.pem" alias "fierlings.family"

            defaults
              log global
              timeout client 30s
              timeout server 30s
              timeout connect 5s

            frontend http-redirect
              bind ipv4@:80
              bind ipv6@:80
              mode http
              option httplog
              redirect scheme https code 301

            frontend https-reverse-proxy
              # This haproxy instance is behind another haproxy instance, so we use the proxy protocol
              bind ipv4@:443 accept-proxy ssl crt "@acme/fierlings.family"
              bind ipv6@:443 accept-proxy ssl crt "@acme/fierlings.family"
              mode http
              option httpslog
              use_backend %[req.hdr(host),lower,map_dom(${map})]
              default_backend not-found

            backend not-found
              mode http
              http-request deny deny_status 400

            # Autogenerated by ${./webserver.nix}.
            ${lib.strings.concatStringsSep "\n" (
              lib.attrsets.mapAttrsToList (name: _value: ''
                backend ${name}
                  mode http
                  server ${name} ${config.croissant.microvms.vms.${name}.ipv4}:80 check send-proxy
              '') config.microvm.vms
            )}
          '';
      };
    };

    systemd.services = {
      "haproxy.service" = {
        after = [ "acme-fierlings.family.service" ];
        requires = [ "acme-fierlings.family.service" ];
      };
    };
  };
}