{% macro normalize_plate(col) -%}
    nullif(upper(regexp_replace(trim({{ col }}), '[\s\-]', '', 'g')), '')
{%- endmacro %}
