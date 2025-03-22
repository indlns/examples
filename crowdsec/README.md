# Crowdsec

Для динамического увеличения времени бана IP адреса в файле profiles.yaml в двух секциях (default_ip_remediation и efault_range_remediation) вставлена строчка:

```
duration_expr: "Sprintf('%dh', (GetDecisionsCount(Alert.GetValue()) + 1) * 8)"
```