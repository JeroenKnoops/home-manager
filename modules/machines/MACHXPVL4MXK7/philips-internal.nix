{
  pkgs,
  config,
  meta,
  ...
}:
let
  kas-changes = builtins.getFlake "git+ssh://git@github.com/philips-internal/synergy-build-analyse?dir=kas-changes&rev=0a7d7571a459c2b4fa6f161078d106179ff33a00";
  binary-table = builtins.getFlake "git+ssh://git@github.com/philips-internal/synergy-build-analyse?dir=binary-table&rev=0a7d7571a459c2b4fa6f161078d106179ff33a00";
  group-git-logs = builtins.getFlake "git+ssh://git@github.com/philips-internal/synergy-build-analyse?dir=group-git-logs&rev=0a7d7571a459c2b4fa6f161078d106179ff33a00";
  dot-analyse-rs = builtins.getFlake "git+ssh://git@github.com/philips-internal/synergy-dotfile?rev=78ed07bd3bd518112f4f9244f9f8e7eeac985fe2";
  github-uses = builtins.getFlake "git+ssh://git@github.com/philips-internal/synergy-build-analyse?dir=workflow-overview&rev=0a7d7571a459c2b4fa6f161078d106179ff33a00";
  tag-prs = builtins.getFlake "git+ssh://git@github.com/philips-internal/synergy-build-analyse?dir=tag-prs&rev=0a7d7571a459c2b4fa6f161078d106179ff33a00";
  pn-buildlist-tool = builtins.getFlake "git+ssh://git@github.com/philips-internal/synergy-build-analyse?dir=pn-buildlist-tool&rev=0a7d7571a459c2b4fa6f161078d106179ff33a00";
in
{
  home.packages = [
    kas-changes.packages.${meta.system}.default
    binary-table.packages.${meta.system}.default
    group-git-logs.packages.${meta.system}.default
    dot-analyse-rs.packages.${meta.system}.recipe-grep
    dot-analyse-rs.packages.${meta.system}.recipe-neighbour
    github-uses.packages.${meta.system}.default
    tag-prs.packages.${meta.system}.default
    pn-buildlist-tool.packages.${meta.system}.default
  ];

  home.file.".local/bin/git-find-build" = {
    executable = true;
    text = ''
      #!/usr/bin/env bash
      set -euo pipefail

      if [ "$#" -lt 1 ]; then
        echo "Usage: git find-build key=value [key=value ...]" >&2
        echo "Example: git find-build target=qemuarm64 variant=vnv build_id addd9c90227a092fb7f1ef86a017552a67ab49ae" >&2
        exit 1
      fi

      NOTES_REF="refs/notes/commits"
      JQ_FILTER="true"

      for arg in "$@"; do
        if [[ "$arg" != *=* ]]; then
          echo "Invalid argument: $arg (expected key=value)" >&2
          exit 1
        fi
        key="''${arg%%=*}"
        value="''${arg#*=}"
        JQ_FILTER="$JQ_FILTER and .[\"$key\"] == \"$value\""
      done

      git notes --ref "$NOTES_REF" list | awk '{print $2}' | while read -r sha; do
        git notes --ref "$NOTES_REF" show "$sha" 2>/dev/null \
          | jq -e "$JQ_FILTER" >/dev/null \
          && echo "$sha"
      done
    '';
  };
}
