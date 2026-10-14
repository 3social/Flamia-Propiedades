# Runbook — alta de cliente nuevo

Objetivo (Fase 2): cliente operativo con snapshot + importación en ≤ 1 día de trabajo.
Borrador; se afina con el primer cliente real tras la demo.

## 1. Antes de empezar
- [ ] Entrevista: fuente principal de inventario y responsable de mantenerla (D2).
- [ ] Plan contratado (`esencial` / `signature` / `private`) → define qué se activa.
- [ ] Nombre comercial, dominio, logo, idiomas, zona horaria, moneda.
- [ ] Autorización escrita para usar sus listings; aviso de privacidad y texto de opt-in del cliente.

## 2. Alta técnica
1. **Supabase:** insertar fila en `clients` (`plan`, `timezone`); generar secreto de herramientas y ligarlo a `client_id` (D10).
2. **GHL:** crear subcuenta desde el snapshot (API de agencia, patrón de `SaaS - Provisioning Stripe a GHL`); registrar `ghl_location_id` en `clients`.
3. Completar `Custom Values` (ver `ghl/custom-values.json`, los `required_input`).
4. Conectar WhatsApp (número, WABA) y enviar las 3 plantillas ES/EN (`ghl/plantillas-whatsapp`).
5. Número de voz y agente de voz (si el plan lo incluye).
6. Configurar agentes con los prompts de `docs/prompts/` apuntando a las herramientas del cliente.
7. Conectar fuente de inventario (hoja / portal / EasyBroker con API key cifrada en Vault) y correr el primer sync.
8. Activar workflows `FLR · *` para ese `client_id`.

## 3. Verificación
- [ ] `tests/rls` y `tests/sync` en verde para el nuevo `client_id`.
- [ ] `tests/agentes/preguntas-trampa.md` con datos del cliente.
- [ ] Un lead de prueba recorre: entrada → respuesta < 60 s → búsqueda → visita → alerta.

## 4. Definición de "terminado" para producción (spec §18)
- [ ] Fuente de inventario definida, conectada y con responsable.
- [ ] Opt-in/aviso de privacidad configurados; plantillas aprobadas.
- [ ] Agentes probados con el set de preguntas trampa del cliente.
- [ ] Panel/resumen diario entregando datos reales.
- [ ] Respaldos, monitoreo de sync y alertas de fallo activos.
- [ ] Capacitación a agentes y al dueño; guía de uso de una página.
- [ ] Contrato firmado (alcance, soporte, precios, propiedad del cliente).

## 5. Reglas permanentes
- Honestidad comercial: se reportan métricas controlables (tiempo de respuesta, % contactados, visitas agendadas), no ventas garantizadas.
- Retención de datos de compradores: 24 meses por defecto hasta revisión legal (D15).
