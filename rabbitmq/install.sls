{% from "rabbitmq/package-map.jinja" import pkgs with context %}

{% set module_list = salt['sys.list_modules']() %}
{% if 'rabbitmqadmin' in module_list %}
include:
  - .config_bindings
  - .config_queue
  - .config_exchange
{% endif %}

rabbitmq-server:
  pkg.installed:
    - name: {{ pkgs['rabbitmq-server'] }}
    {%- if 'version' in salt['pillar.get']('rabbitmq', {}) %}
    - version: {{ salt['pillar.get']('rabbitmq:version') }}
    {%- endif %}

  service:
    - running
    - enable: True
    - watch:
      - pkg: rabbitmq-server

rabbitmq_binary_tool_env:
  file.symlink:
    - makedirs: True
    - name: /usr/local/bin/rabbitmq-env
    - target: /usr/lib/rabbitmq/bin/rabbitmq-env
    - require:
      - pkg: rabbitmq-server

plugin_rabbitmq_delayed_message_exchange:
  file.managed:
    - name: /usr/lib/rabbitmq/lib/rabbitmq_server-3.6.1/plugins/rabbitmq_delayed_message_exchange-0.0.1.ez
    - source: http://www.rabbitmq.com/community-plugins/v3.6.x/rabbitmq_delayed_message_exchange-0.0.1.ez
    - source_hash: 'md5=10277778b4c08d3fa9847b1fd164d47b'
    - require:
      - pkg: rabbitmq-server
      - file: rabbitmq_binary_tool_env

rabbitmq_binary_tool_plugins:
  file.symlink:
    - makedirs: True
    - name: /usr/local/bin/rabbitmq-plugins
    - target: /usr/lib/rabbitmq/bin/rabbitmq-plugins
    - require:
      - pkg: rabbitmq-server
      - file: rabbitmq_binary_tool_env

