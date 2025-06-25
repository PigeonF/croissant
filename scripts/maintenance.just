# Requires [just](https://just.systems).

lstopo := if os_family() == "windows" { require("lstopo.exe") } else { "" }

[group('maintenance')]
[doc('Output the hardware topology to the DESTINATION.')]
[unix]
topology DESTINATION=("images" / "topology.svg"):
    @mkdir -p {{ quote(parent_directory(clean(DESTINATION))) }}
    @rm -f {{ quote(clean(DESTINATION)) }}
    nix shell "nixpkgs#hwloc" --command lstopo {{ quote(clean(DESTINATION)) }}

[group('maintenance')]
[doc('Output the hardware topology to the DESTINATION.')]
[windows]
topology DESTINATION=("images" / "topology.svg"):
    @New-Item -ItemType Directory -Force -Path {{ quote(parent_directory(clean(DESTINATION))) }} | Out-Null
    @if (Test-Path {{ quote(clean(DESTINATION)) }}) { Remove-Item -Force -ErrorAction SilentlyContinue -Path {{ quote(clean(DESTINATION)) }} }
    & {{ quote(lstopo) }} {{ quote(clean(DESTINATION)) }}
