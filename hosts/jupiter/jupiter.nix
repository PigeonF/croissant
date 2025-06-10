{
  croissantModulesPath,
  inputs,
  ...
}:
{
  _file = ./jupiter.nix;

  imports = [
    (croissantModulesPath + "/profiles/jupiter.nix")
  ];

  config = {
    networking = {
      hostName = "jupiter";
      computerName = "Jupiter Mac Mini";
    };

    sops = {
      defaultSopsFile = ./secrets/jupiter.yaml;
    };

    system = {
      configurationRevision = inputs.self.rev or inputs.self.dirtyRev or null;
      stateVersion = 6;
    };
  };
}
