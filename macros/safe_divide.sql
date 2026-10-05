{% macro safe_divide(num, den) -%}
    case when ({{ den }}) = 0 or ({{ den }}) is null then null else ({{ num }}) * 1.0 / ({{ den }}) end
{%- endmacro %}
