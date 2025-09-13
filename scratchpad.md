# Scratchpad

<small>

_Random notes and collections of links_

</small>

-   Add additional layer in front of hosts: _deployments_.

    For example

    -   a _standalone_ deployment which contains mobile devices (i.e. laptops).
    -   a _home_ deployment for all devices which are deployed at home.
-   Each deployment should have a documented (and tested) backup strategy.
-   Each deployment should have a network diagram which describes the
    relationships between the different hosts. If possible the network diagram
    should be written with [`typst`](https://github.com/typst/typst) so that it can
    be printed.

    Consider which parts of the network diagram are confidential and think of a
    solution for keeping it in the repository.
-   Change naming scheme to something more self-explainatory.

    Instead of naming hosts after planets, name them after their functionality.

    For example a naming scheme like `<deployment>-<functionality>-<counter>`
    might be more appropriate.

    63 characters, all lowercase, only letters, digits, and hyphens.

    Depending on the deployment, the corresponding domain is likely to be [`.internal`](https://en.wikipedia.org/wiki/.internal).

    -   `infra`
    -   `storage`
    -   `dev`
    -   `routing`
-   Host a [gerrit](https://www.gerritcodereview.com/) instance.
-   Use a VPS as a workaround for a static IP (e.g. <https://mjg59.dreamwidth.org/72095.html>).


## Open Questions

-   How much of a host configuration should be copy-pasted, and how much should
    be refactored into common modules?
-   Are there any good open source surveillance cameras?
-   Should routing within a deployment depend on DHCP or BGP?
-   How to provision non-NixOS devices in a deployment (e.g. WiFi Access Points running OpenWRT)?
-   Are there any printers with open firmware?
-   How are NixOS IOT integrations (i.e. instead of something like Home Assistant)?
-   What about uninterruptible power supplies?
-   Use systemd-nspawnd for virtual machines?
