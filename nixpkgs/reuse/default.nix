{ reuse, ... }:
reuse.overrideAttrs (
  _: previousAttrs: {
    patches = (previousAttrs.patches or [ ]) ++ [ ./jj.patch ];
  }
)
