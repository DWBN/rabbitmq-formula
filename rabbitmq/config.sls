{% for name, plugin in salt["pillar.get"]("rabbitmq:plugin", {}).items() %}
{{ name }}:
  rabbitmq_plugin:
    {% for value in plugin %}
    - {{ value }}
    {% endfor %}
    - runas: root
    - require:
      - pkg: rabbitmq-server
      - file: rabbitmq_binary_tool_plugins
    - watch_in:
      - service: rabbitmq-server
{% endfor %}



{% if salt["pillar.get"]("rabbitmq:ssl") %}
/etc/rabbitmq/ssl:
  file.directory:
    - user: root
    - group: root
    - dir_mode: 755
    - file_mode: 644

/etc/rabbitmq/ssl/cacert.pem:
  file.managed:
    - contents_pillar: rabbitmq:ssl:cacert

/etc/rabbitmq/ssl/cert.pem:
  file.managed:
    - contents_pillar: rabbitmq:ssl:cert

/etc/rabbitmq/ssl/key.pem:
  file.managed:
    - contents_pillar: rabbitmq:ssl:key    
{% endif %}

/etc/rabbitmq/rabbitmq.config:
  file.managed:
    - source: salt://rabbitmq/files/rabbitmq.config
    - watch_in:
      - service: rabbitmq-server


{% for name, policy in salt["pillar.get"]("rabbitmq:policy", {}).items() %}
{{ name }}:
  rabbitmq_policy.present:
    {% for value in policy %}
    - {{ value }}
    {% endfor %}
    - require:
      - service: rabbitmq-server
{% endfor %}

{% for name, vhost in salt["pillar.get"]("rabbitmq:vhost", {}).items() %}
rabbitmq_vhost_{{ name }}:
  rabbitmq_vhost.present:
    - name: {{ vhost }}
    - require:
      - service: rabbitmq-server
{% endfor %}

{% for name, user in salt["pillar.get"]("rabbitmq:user", {}).items() %}
rabbitmq_user_{{ name }}:
  rabbitmq_user.present:
    - name: {{ name }}
    {% for value in user %}
    - {{ value }}
    {% endfor %}
    - require:
      - service: rabbitmq-server
{% endfor %}
