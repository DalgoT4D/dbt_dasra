{% macro generate_schema_name(custom_schema_name, node) -%}
    {%- set default_schema = target.schema -%}

    {%- if custom_schema_name is none -%}

        {# Use the first folder under /models as the schema prefix #}
        {% set prefix = node.fqn[1] %}

        {# Staging models can be same for prod or dev profiles/target schema #}
        {% if 'prod' in default_schema or 'seed_data' in node.fqn %}
            {{ prefix | trim }}
        {% else %}
            {{ default_schema }}_{{ prefix | trim }}
        {% endif %}

    {%- else -%}

        {% if 'elementary' not in custom_schema_name %}
            {{ default_schema }}_{{ custom_schema_name | trim }}
        {% else %}
            {{ custom_schema_name | trim }}
        {% endif %}

    {%- endif -%}
{%- endmacro %}
