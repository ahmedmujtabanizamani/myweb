#!/usr/bin/env bash

main() {
  declare hugo_publish_dir=public

  declare stork_config_file=myweb/stork.config.json   # generated by hugo
  declare stork_index_file=myweb/stork.index.json     # generated by stork (json suffix triggers gzip/br compression)

  declare stork_arch=stork-ubuntu-20-04
  declare stork_releases=https://files.stork-search.net/releases
  declare stork_version=1.4.2

  declare stork_exec=${stork_arch}-${stork_version}
  declare stork_url=${stork_releases}/v${stork_version}/${stork_arch}

  # Install Stork if it's not already installed.
  if [[ ! -f "${stork_exec}" ]]; then
    echo -e "\nInstalling Stork...\n"
    wget --no-verbose "${stork_url}" ||
      { echo "Error: unable to wget ${stork_url}"; exit 1; }
    mv "${stork_arch}" "${stork_exec}" ||
      { echo "Error: unable to mv ${stork_arch} ${stork_exec}"; exit 1; }
    chmod +x "${stork_exec}" ||
      { echo "Error: unable to chmod ${stork_exec}"; exit 1; }
  fi

  # Configure Git
  # See https://github.com/gohugoio/hugo/issues/9810
  if [[ "${CI:-false}" == "true" ]]; then
    git config --global core.quotepath false ||
      { echo "Error: unable to configure Git"; exit 1; }
  fi

  # Build the site.
  echo -e "\nBuilding site...\n"
  hugo --gc --minify ||
    { echo "Error: unable to run hugo"; exit 1; }

  # Build the Stork index.
  echo -e "\nBuilding Stork index...\n"
  ./${stork_exec} build --input "${hugo_publish_dir}/${stork_config_file}" --output "${hugo_publish_dir}/${stork_index_file}" ||
    { echo "Error: unable to run stork"; exit 1; }
}

set -euo pipefail
main "$@"
