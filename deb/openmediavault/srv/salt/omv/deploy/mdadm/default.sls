# This file is part of OpenMediaVault.
#
# @license   http://www.gnu.org/licenses/gpl.html GPL Version 3
# @author    Volker Theile <volker.theile@openmediavault.org>
# @copyright Copyright (c) 2009-2018 Volker Theile
#
# OpenMediaVault is free software: you can redistribute it and/or modify
# it under the terms of the GNU General Public License as published by
# the Free Software Foundation, either version 3 of the License, or
# any later version.
#
# OpenMediaVault is distributed in the hope that it will be useful,
# but WITHOUT ANY WARRANTY; without even the implied warranty of
# MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
# GNU General Public License for more details.
#
# You should have received a copy of the GNU General Public License
# along with OpenMediaVault. If not, see <http://www.gnu.org/licenses/>.

{% set email_config = salt['omv_conf.get']('conf.system.notification.email') %}
{% set notification_config = salt['omv_conf.get_by_filter'](
  'conf.system.notification.notification',
  {'operator': 'stringEquals', 'arg0': 'id', 'arg1': 'mdadm'})[0] %}

# Remove the '/etc/cron.daily/mdadm' cron file that is installed by
# the Debian package.
remove_cron_daily_mdadm:
  file.absent:
    - name: "/etc/cron.daily/mdadm"

configure_default_mdadm:
  file.managed:
    - name: "/etc/default/mdadm"
    - source:
      - salt://{{ slspath }}/files/etc-default-mdadm.j2
    - template: jinja
    - user: root
    - group: root
    - mode: 644

configure_mdadm_conf:
  file.managed:
    - name: "/etc/mdadm/mdadm.conf"
    - source:
      - salt://{{ slspath }}/files/etc-mdadm-mdadm.conf.j2
    - template: jinja
    - context:
        email_config: {{ email_config | json }}
        notification_config: {{ notification_config | json }}
    - user: root
    - group: root
    - mode: 644

# Save RAID configuration to config file and update initramfs.
mdadm_save_config:
  module.run:
    - name: raid.save_config
