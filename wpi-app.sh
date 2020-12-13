#!/bin/bash

# WPI APP
# by DimaMinka (https://dima.mk)
# https://github.com/wpi-pw/app

# Get config files and put to array
wpi_confs=()
for ymls in wpi-config/*
do
  wpi_confs+=("$ymls")
done

# Get wpi-source for yml parsing, noroot, errors etc
source <(curl -s https://raw.githubusercontent.com/wpi-pw/template-workflow/master/wpi-source.sh)

# Run shell runner before app install
shell_runner before_install $(get_cur_env $1)

# Run workflow install after setup checking
if [ "$(wpi_yq init.workflow)" != "false" ]; then

  # Download and run default workflow template or custom from the config
  template_runner $(wpi_yq templates.workflow) "template-workflow/wpi-workflow" $(wpi_yq init.workflow) $(get_cur_env $1)

  # Download and run default env template or custom from the config
  template_runner $(wpi_yq templates.env) "template-env/env-init" $(wpi_yq init.env) $(get_cur_env $1)

  # Download and run default settings template or custom from the config
  template_runner $(wpi_yq templates.settings) "template-settings/settings-init" $(wpi_yq init.settings) $(get_cur_env $1)

  # WP CLI helper for successful plugins/themes install
  if ! $(wp core is-installed); then
      wp core install --url=tmp --title=tmp --admin_user=tmp --admin_password=tmp --admin_email=tmp@tmp.tmp --quiet
      touch wp_tmp_file.txt
  fi

  # Download and run default mu-plugins template or custom from the config
  template_runner $(wpi_yq templates.mu_plugins) "template-mu-plugins/mu-plugins-init" $(wpi_yq init.mu_plugins)

  # Download and run default plugins template or custom from the config
  template_runner $(wpi_yq templates.plugins_single) "template-plugins/plugins-single-init" $(wpi_yq init.plugins) $(get_cur_env $1)

  # Download and run default plugins bulk template or custom from the config
  template_runner $(wpi_yq templates.plugins_bulk) "template-plugins/plugins-bulk-init" $(wpi_yq init.plugins_bulk) $(get_cur_env $1)

  # Download and run default themes template or custom from the config
  template_runner $(wpi_yq templates.theme) "template-theme/theme-init" $(wpi_yq init.theme) $(get_cur_env $1)

  # Download and run default child theme template or custom from the config
  template_runner $(wpi_yq templates.child_theme) "template-child-theme/child-theme-init" $(wpi_yq init.child_theme) $(get_cur_env $1)

  # Download and run default child theme template or custom from the config
  template_runner $(wpi_yq templates.extra) "template-extra/extra-init" $(wpi_yq init.extra) $(get_cur_env $1)

  # WP CLI helper for plugins/themes remover
  if [ -f "${PWD}/wp_tmp_file.txt" ]; then
    wp db reset --yes --quiet
    rm ${PWD}/wp_tmp_file.txt
  fi
fi
