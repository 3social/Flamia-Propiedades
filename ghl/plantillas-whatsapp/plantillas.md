# Plantillas de WhatsApp (Meta) — ES / EN

Categoría **Marketing** (alertas) y **Utility** (recordatorio). Hay que enviarlas a aprobación **cuanto antes**: pueden tardar
días y la demo no debe depender de una aprobación nueva (riesgo WABA, D11). Variables en el formato de Meta `{{1}}…`.
Sin emojis ni mayúsculas agresivas: tono de concierge.

## alerta_nueva_propiedad_es  (Marketing, es)
```
Hola {{1}}, apareció una propiedad que coincide con lo que buscas: {{2}} en {{3}}, {{4}}. Más detalles y fotos aquí: {{5}}
Si prefieres no recibir más avisos, responde STOP.
```
Variables: 1 nombre · 2 título · 3 zona · 4 precio · 5 enlace (`Alerta Enlace`, con `ref` y UTM).

## alerta_nueva_propiedad_en  (Marketing, en)
```
Hi {{1}}, a new listing matches what you're looking for: {{2}} in {{3}}, {{4}}. Details and photos here: {{5}}
Reply STOP if you'd rather not receive further updates.
```

## alerta_baja_precio_es  (Marketing, es)
```
Hola {{1}}, {{2}} en {{3}} bajó de precio y ahora está en {{4}}. Puedes verla aquí: {{5}}
Responde STOP para dejar de recibir avisos.
```

## alerta_baja_precio_en  (Marketing, en)
```
Hi {{1}}, {{2}} in {{3}} has a new price: {{4}}. See it here: {{5}}
Reply STOP to stop receiving updates.
```

## recordatorio_visita_es  (Utility, es)
```
Hola {{1}}, te recordamos tu visita a {{2}} el {{3}} a las {{4}}. Si necesitas cambiarla, responde a este mensaje.
```

## recordatorio_visita_en  (Utility, en)
```
Hi {{1}}, a reminder of your viewing at {{2}} on {{3}} at {{4}}. If you need to reschedule, just reply to this message.
```

## Notas
- El enlace de alerta lleva `?ref=<ref_code>&utm_source=whatsapp&utm_medium=alerta&utm_campaign=<reason>`.
- Dentro de la ventana de 24 h tras una respuesta del comprador ya no se usa plantilla: responde el agente de texto.
- Costos de Meta por mensaje entregado **[POR VALIDAR]** (spec §15): modelar antes de fijar precios.
