# Calificación de leads (voz, texto y landing)

Decidido el 2026-11-17 (D26). Un solo modelo para los tres canales: **los canales capturan datos, un flujo central decide el nivel**.
Así un lead que empieza en la landing y sigue por WhatsApp no repite respuestas, y la regla se cambia en un solo lugar.

## 1. Criterios

| Criterio | Campo de contacto | Notas del nicho (lujo, Puerto Vallarta) |
|---|---|---|
| Operación | `Operacion` | Compra / Renta |
| Zona | `Zonas de Interes` | Marina, Zona Romántica, Conchas Chinas, Nuevo Vallarta… |
| Presupuesto | `Presupuesto Maximo` (+ `Moneda`) | Se pregunta como **rango**, nunca una cifra exacta |
| Plazo | `Plazo de Decision` | El que mejor separa comprador de curioso |
| Pago | `Financiamiento` | Contado / Fideicomiso / Crédito / Por definir |
| Propósito | `Proposito` (**nuevo**) | Vivir / Inversión / Vacacional. Cambia qué se ofrece y cómo se habla |
| Residencia | `Residencia` (**nuevo**) | Nacional / Extranjero. Extranjero en zona restringida = fideicomiso, tema del asesor |
| Nivel | `Nivel Lead` (**nuevo**) | Caliente / Tibio / Frío. **Solo lo escribe el flujo central** |

## 2. Niveles

| Nivel | Regla | Acción |
|---|---|---|
| **Calificado** | Operación + Zona + Presupuesto + Plazo | Tag `lead_calificado` → *FLR · 2 Calificado* mueve la etapa |
| **Caliente** | Calificado **y** plazo `Inmediato` o `1 a 3 meses` **y** (pago `Contado`/`Fideicomiso`/`Credito` **o** visita pedida) | Tag `lead_caliente` → tarea al asesor en ≤ 15 min + aviso |
| **VIP** | `Presupuesto Maximo` ≥ custom value `Umbral VIP USD` (demo: **USD 1,000,000**) | Tag `handoff_humano` (pase a humano directo), aunque falten datos |
| **Tibio** | Calificado con plazo `3 a 6 meses` o `Mas de 6 meses` | Sigue el agente; alertas de coincidencia; seguimiento semanal |
| **Frío** | `Solo explorando`, o sin presupuesto tras 2 intentos | Nurture de 12 meses (alertas mensuales). **Nunca se descarta** |

Un lead pasa de nivel solo hacia arriba por datos nuevos; baja únicamente si el propio lead cambia su plazo o presupuesto.

### Por qué USD 1,000,000 como umbral VIP
En Vallarta la mayoría del inventario de lujo está entre USD 400k y 1M; arriba de 1M hay pocos compradores y el ticket
justifica atención humana inmediata (comisión alta, cliente que espera trato personal y suele rechazar un bot). Es un
**custom value por cliente**: un agente cuyo inventario arranca en 2M lo sube; uno de 300k–800k lo baja a ~750k.

## 3. Qué hace cada canal y cuándo

Regla común: **nunca preguntar lo que ya está en un campo**. Cada dato se guarda en cuanto el lead lo dice.

### Agente de texto (WhatsApp, chat web, redes)
1. **< 60 s**: saludo en el idioma del lead + **una** pregunta abierta ("¿qué buscas en Vallarta?").
2. Zona y tipo → rango de presupuesto. Máximo 1–2 preguntas por mensaje.
3. **Valor temprano**: con zona + presupuesto, `search_properties` y 2–3 opciones con fecha de actualización.
4. Plazo y pago, justificados con la visita ("para coordinar tu visita, ¿para cuándo lo necesitas?"). Propósito y residencia, en la conversación natural.
5. Ofrece visita privada cuando está calificado o la pide.
6. **Pasa a humano** (tag `handoff_humano`) si: lo pide · quiere negociar u ofertar · pregunta legal/fideicomiso a detalle ·
   herramienta falla o precio no encontrado · molestia · VIP (lo dispara el flujo central).
7. Baja: tag `no_contactar` → *FLR · 5 Baja*.

### Agente de voz
- **Entrante**: máximo 3 preguntas antes de dar valor; confirma datos en voz alta; cierra **siempre** con visita agendada o
  ficha por WhatsApp (pidiendo el opt-in).
- **Saliente (speed-to-lead)**: 1–5 min después de un formulario con teléfono y consentimiento, solo 08:00–21:00.
- Caliente o VIP con asesor disponible → transferencia en caliente.

### Landing o funnel
- Formulario **multi-paso**: nombre + WhatsApp → 3 botones (operación, rango de presupuesto, plazo) → casilla de opt-in. Llega semi-calificado.
- Campos ocultos: `Ref Propiedad Origen` y UTM.
- Página de gracias con calendario *Visitas privadas* incrustado: si agenda, sube a caliente.
- Luego el agente de texto continúa con lo que ya sabe.

## 4. Flujo central (diseño; ver estado en `ghl/workflows.md`)

```
Cambio en campos del contacto (agente de voz, de texto, formulario)
  └─ GHL · FLR · 0 Calificación  (disparador: contacto cambiado; permite reingreso)
       └─ webhook → n8n · FLR · calificacion  (regla de §2 en código, idempotente: solo escribe si cambia)
            ├─ escribe Nivel Lead
            ├─ tags lead_calificado / lead_caliente / handoff_humano (VIP)
            └─ los workflows 2, 4 y 6 reaccionan a esos tags
```

Por qué la regla vive en n8n y no en if/else de GHL: son 7 campos con combinaciones; en código se prueba con casos
(`tests/agentes`), y el builder de GHL por API solo arma condiciones por tag. GHL sigue siendo quien reacciona (D25).

## 5. Landing / funnel (D27)

- **Marca del cliente**, no de FLAMIA. El diseño se decide **por cliente** (cada agente de lujo tiene su gusto); FLAMIA
  entrega una estructura y un sistema de diseño que se viste con la marca del cliente.
- **Una landing por proyecto o por propiedad**, desde una plantilla parametrizada.
- Antes de construir en GHL: wireframe y propuesta visual que el cliente aprueba.
- Base de lujo: mobile first, foto a pantalla completa, poco texto, mucho blanco, asesor con foto, mapa, precio con fecha,
  sin contadores ni urgencia falsa. Imágenes comprimidas (GHL se vuelve lento con fotos pesadas).
- Herramientas de GHL a usar: funnel multi-paso, encuesta con lógica, calendario incrustado, botón WhatsApp con `ref`,
  trigger links y QR, UTM ocultos, pixel Meta/GA4, A/B, ES/EN.

## 6. Estado (2026-11-17)
- `FLR · calificacion` (n8n `PtU5gnp8hqaAJeb5`, cada 2 min) publicado. Probado: Prueba3 (USD 1.2M, inmediato, contado) → Caliente + VIP →
  `handoff_humano` → FLR · 4 (ia_pausada + tarea) + tarea "contactar en 15 min"; Prueba4 → Tibio. También asigna el asesor a las
  oportunidades abiertas (el builder de GHL no lo guarda). Rangos de la landing: VIP se mide con el mínimo del rango.
- No se usa un workflow GHL "0 Calificación": los workflows de GHL no permiten reingreso por API; el sondeo de 2 min basta.
- `FLR · lead-landing` (n8n `j33djngyFRlvpfZu`) publicado: valida, honeypot, upsert con calificación, opt-in, `ref` y UTM. Probado ✅.
- Agentes: acciones para Propósito y Residencia en voz y texto; prompts con el orden de §3 aplicados.
- **Falta:** la landing de prueba (PV-0005) y su despliegue.
