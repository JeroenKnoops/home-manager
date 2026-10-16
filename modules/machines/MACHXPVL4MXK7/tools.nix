{ pkgs, ... }:
{
  home.packages = with pkgs; [
    awscli2
    cacert
    cargo
    chafa
    devbox
    direnv
    docker
    docker-buildx
    docker-credential-helpers
    fd
    fh
    fly
    gnugrep
    graphviz
    gti
    jq
    kubo
    libiconv
    nodejs
    pipenv
    protobuf
    python313
    python313Packages.pip
    qemu
    ratchet
    ripgrep
    secretspec
    stack
    stow
    (toilet.overrideAttrs (old: {
      preferLocalBuild = true;
      allowSubstitutes = false;
    }))
    typescript
    virtualenv
    watch
    wget
    yq-go
    zld
  ];
}
