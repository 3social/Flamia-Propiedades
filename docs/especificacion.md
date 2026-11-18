# FLAMIA Luxury Real Estate System — Especificación para desarrollo

> Documento fuente (recibido 14-oct-2026; el árbol de la §16 está resumido, el desarrollo real está en `AGENTS.md`). **No editar**: los cambios y supuestos corregidos van en
> `docs/analisis-especificacion.md` y `docs/decisiones.md`. Lo marcado **[POR VALIDAR]** es un supuesto.
> Responsable: Michael (FLAMIA) · Socio comercial/canal: Halcón (Puerto Vallarta / Guadalajara)
> Hito duro: **demo funcional el miércoles 21-oct-2026** (conferencia AMPI).

---

## 1. Contexto y objetivo

**Qué es:** una plataforma inmobiliaria premium (no solo un CRM) que FLAMIA construye y Halcón vende a agentes y equipos inmobiliarios de lujo en Puerto Vallarta/Guadalajara. El CRM (GoHighLevel) es una pieza más.

**Problema que resuelve:**
- Agentes de alto nivel usan un "Frankenstein" de herramientas sin integración ni soporte.
- Seguimiento inconsistente de leads → oportunidades perdidas.
- El dueño/broker no sabe qué hace cada agente.
- Ciclos de venta largos (~9 meses en el mercado de Vallarta): sin nurture y reactivación se pierde el lead.

**Propuesta de valor (una frase):** responde a cada lead en menos de un minuto, atiende por texto y voz en español e inglés, ofrece propiedades reales del inventario del agente, da seguimiento 12 meses y le muestra al dueño qué hace cada agente.

**Qué NO es:** no es un MLS, no es un sistema contable ni de comisiones, no reemplaza al agente humano (la IA califica y agenda; el humano cierra).

**Canal de venta:** Halcón vende con su marca/credibilidad local; FLAMIA entrega, opera y da soporte. Posible catálogo digital vinculado a su revista "Prime Estates" (aún sin lanzar: **el sistema no puede depender de la revista**).

---

## 2. Principios de diseño

1. **Una sola fuente de verdad de inventario** (Supabase). Los agentes de IA nunca "recuerdan" precios: **solo citan lo que devuelve una herramienta**, con fecha de actualización.
2. **GHL es el canal y el CRM**; la lógica pesada vive en Supabase + n8n.
3. **Multi-tenant desde el día 1:** todo registro lleva `client_id`.
4. **Consentimiento primero:** no se envía marketing por WhatsApp sin opt-in registrado; la baja corta todo envío.
5. **Menos mensajes, más relevantes:** tope de alertas, resumen de 2–3 propiedades, horarios.
6. **Idempotencia:** toda sincronización puede correr dos veces sin duplicar (`external_id`).
7. **Datos ficticios en demo.** Nunca usar listings reales de agentes sin autorización escrita.
8. **Español primero, inglés soportado** en agentes, portal y plantillas.
9. **Simple antes que ingenioso:** filtros duros primero, búsqueda semántica después.

---

## 3. Arquitectura

```
1. PORTAL Y FUNNELS
   Portal inmobiliaria (rebrand) · Landing/funnel por propiedad o proyecto (GHL funnels / Next.js) · QR · click-to-WhatsApp
        │ leads, eventos ("me importa", vistas)
2. INVENTARIO (Supabase: Postgres + pgvector)
   properties · property_history · buyer_profiles · alerts_sent · lead_events · clients
   Fuentes: portal DB, EasyBroker API, Google Sheets, PDFs/WhatsApp (PropertyMatch), carga manual
        │ herramientas HTTP (Edge Functions) / MCP opcional
3. AGENTES IA
   Texto (GHL Conversation AI / n8n "Sofía") · Voz (GHL Voice AI o Retell/Vapi en Private) · Agente de vendedores
        │
4. MOTOR DE INGRESOS (GoHighLevel + n8n)
   CRM · pipelines · nurture 12 meses · reactivación de base · alertas de coincidencia · panel del dueño · reportes
```

**Responsabilidades:**
- **Supabase** decide *quién* coincide con *qué* (match) y guarda historial.
- **n8n** decide *cuándo* y *a quién sí* se escribe (reglas de negocio) y orquesta sincronizaciones.
- **GHL** entrega el mensaje, registra la conversación en el CRM y mueve el pipeline.

**Stack propuesto [confirmar con el repo existente]:**
- Supabase (Postgres, pgvector, Edge Functions, RLS)
- n8n (instancia en Easypanel de FLAMIA)
- GoHighLevel (cuenta "Flamiagroup"; subcuentas por cliente; credencial PIT con Bearer Auth)
- Next.js 15 para panel del dueño y landings propias (Vercel)
- Portal inmobiliario existente: inmobiliaria.flamiagroup.com (PHP/Laravel en Hostinger)
- WhatsApp: API oficial de Meta vía GHL nativo (**ver riesgo de WABA en sección 15**)

---

## 4. Módulo 1 — Portal y funnels

### 4.1 Portal inmobiliaria.flamiagroup.com (existente)

**Estado actual (observado):** portal con proyectos, propiedades, agentes (con cuenta y carga de propiedades propias), filtros (categoría, precio, recámaras, baños, pisos), lista de deseos ("me importa"), ES/EN, multimoneda, noticias. Alojado en Hostinger. Datos de ejemplo de Colombia. Aparenta estar basado en un tema comercial (ruta `flex-home`) **[POR VALIDAR: producto exacto y licencia para múltiples clientes]**.

**Tareas:**
- [ ] Rebranding total FLAMIA (nombre nuevo **pendiente de definir**; usar variable de configuración, no hardcode).
- [ ] Limpiar restos de plantilla: enlaces sociales ajenos, moneda VND, noticias de 2024, textos en inglés mezclados.
- [ ] Quitar datos personales de prueba (correos/teléfonos de agentes demo).
- [ ] Cargar datos de demo de Puerto Vallarta (ver sección 11).
- [ ] Webhook de formulario de contacto y de "me importa" → n8n → GHL.
- [ ] Enlaces rastreados por propiedad (parámetro `ref` + UTM) y QR por propiedad.
- [ ] Sincronización portal → Supabase (ver 5.3). Determinar si hay API/webhooks o si se lee la BD directamente **[POR VALIDAR]**.
- [ ] Seguridad: actualizar versión, SSL, respaldos automáticos, política de privacidad y cookies.
- [ ] Decidir modelo: instancia por cliente vs. portal compartido (decisión D1).

### 4.2 Funnel por proyecto o propiedad

Cada proyecto/propiedad destacada tiene una landing con:
- Hero con fotos/video, precio con fecha de actualización, ficha técnica, mapa, galería.
- CTA doble: **formulario corto** y **botón WhatsApp** con mensaje precargado que incluye código de referencia (`ref=PV-0042`).
- Captura de UTM y `ref` → GHL (campos personalizados).
- Pixel/eventos para medir vistas y clics (alimenta el motor conductual).
- Versión ES/EN.
- QR imprimible por propiedad/anunciante (atribución para revista y letreros).

**Implementación:** plantilla en GHL funnels (rápida, Esencial) y/o landing Next.js (Signature/Private) generada desde `properties`. Una plantilla única parametrizada por `property_id`.

---

## 5. Módulo 2 — Inventario (cerebro)

### 5.1 Esquema de datos (Supabase)

> Esquema de referencia. Ajusta tipos al implementar; mantén `client_id` en todas las tablas y activa RLS.

```sql
create extension if not exists vector;

create table clients (
  id uuid primary key default gen_random_uuid(),
  name text not null,
  ghl_location_id text,
  plan text check (plan in ('esencial','signature','private')),
  timezone text default 'America/Mexico_City',
  created_at timestamptz default now()
);

create table properties (
  id uuid primary key default gen_random_uuid(),
  client_id uuid not null references clients(id),
  external_id text,                    -- id en la fuente (EasyBroker, portal, hoja)
  source text,                         -- 'portal' | 'easybroker' | 'sheet' | 'pdf' | 'manual'
  ref_code text,                       -- código corto para QR/WhatsApp (ej. PV-0042)
  title text not null,
  description text,
  operation text check (operation in ('sale','rent')),
  category text,                       -- casa, villa, condominio, terreno, comercial
  price numeric,
  currency text default 'USD',
  zone text,                           -- Marina Vallarta, Zona Romántica, Nuevo Vallarta...
  city text,
  bedrooms int,
  bathrooms numeric,
  area_m2 numeric,
  amenities text[],
  media jsonb,                         -- [{url,type}]
  brochure_url text,
  location geography(point),           -- requiere postgis si se usa; opcional
  visibility text default 'public' check (visibility in ('public','private')),
  status text default 'active' check (status in ('active','reserved','sold','withdrawn')),
  embedding vector(1536),              -- ajustar a la dimensión del modelo elegido
  source_updated_at timestamptz,
  updated_at timestamptz default now(),
  unique (client_id, source, external_id)
);

create table property_history (
  id bigserial primary key,
  client_id uuid not null,
  property_id uuid not null references properties(id),
  field text not null,                 -- 'price' | 'status'
  old_value text,
  new_value text,
  changed_at timestamptz default now()
);

create table buyer_profiles (
  id uuid primary key default gen_random_uuid(),
  client_id uuid not null references clients(id),
  ghl_contact_id text not null,
  language text default 'es',
  operation text,
  budget_min numeric,
  budget_max numeric,
  currency text default 'USD',
  zones text[],
  bedrooms_min int,
  categories text[],
  preferences_text text,               -- "frente al mar, tranquilo, para rentar"
  embedding vector(1536),
  whatsapp_opt_in boolean default false,
  opt_in_at timestamptz,
  opted_out boolean default false,
  last_alert_at timestamptz,
  updated_at timestamptz default now(),
  unique (client_id, ghl_contact_id)
);

create table alerts_sent (
  id bigserial primary key,
  client_id uuid not null,
  buyer_profile_id uuid not null references buyer_profiles(id),
  property_id uuid not null references properties(id),
  reason text,                         -- 'new_listing' | 'price_drop'
  score numeric,
  sent_at timestamptz default now(),
  result text                          -- 'sent' | 'replied' | 'visit_booked' | 'failed'
);

create table lead_events (
  id bigserial primary key,
  client_id uuid not null,
  ghl_contact_id text,
  property_id uuid,
  event text,                          -- 'view' | 'wishlist' | 'click_whatsapp' | 'form' ...
  meta jsonb,
  occurred_at timestamptz default now()
);
```

**Trigger de historial (cambio de precio y estado):**

```sql
create or replace function log_property_change() returns trigger as $$
begin
  if new.price is distinct from old.price then
    insert into property_history(client_id, property_id, field, old_value, new_value)
    values (new.client_id, new.id, 'price', old.price::text, new.price::text);
  end if;
  if new.status is distinct from old.status then
    insert into property_history(client_id, property_id, field, old_value, new_value)
    values (new.client_id, new.id, 'status', old.status, new.status);
  end if;
  new.updated_at = now();
  return new;
end; $$ language plpgsql;

create trigger trg_property_change before update on properties
for each row execute function log_property_change();
```

**RLS:** políticas por `client_id` (JWT claim o service role solo desde n8n/Edge Functions). Nunca exponer `buyer_profiles` ni `lead_events` con la anon key.

### 5.2 Función de coincidencia (match)

Fase 1 (demo): **solo filtros duros**. Fase 2: añadir similitud semántica.

```sql
create or replace function match_buyers_for_property(p_property_id uuid)
returns table (buyer_profile_id uuid, ghl_contact_id text, score numeric)
language sql stable as $$
  select b.id, b.ghl_contact_id,
         -- Fase 2: 1 - (b.embedding <=> p.embedding)
         1.0::numeric as score
  from properties p
  join buyer_profiles b on b.client_id = p.client_id
  where p.id = p_property_id
    and p.status = 'active' and p.visibility = 'public'
    and b.opted_out = false and b.whatsapp_opt_in = true
    and (b.operation is null or b.operation = p.operation)
    and (b.budget_max is null or p.price <= b.budget_max)
    and (b.budget_min is null or p.price >= b.budget_min)
    and (b.zones is null or p.zone = any(b.zones))
    and (b.bedrooms_min is null or p.bedrooms >= b.bedrooms_min)
    and (b.categories is null or p.category = any(b.categories))
$$;
```

Ordenar por `score` desc; el límite y los topes los aplica n8n (5.4).

### 5.3 Fuentes y sincronización

Una **fuente principal por cliente** (la define la entrevista con el agente). Todas escriben a `properties` con `upsert` por `(client_id, source, external_id)`.

| Fuente | Método | Frecuencia |
|---|---|---|
| Portal propio | Lectura de BD/API/export **[POR VALIDAR]** | 15 min |
| EasyBroker | API (cuenta de pago; API key del agente, solo lectura; MLS requiere plan aparte) **[POR VALIDAR por cliente]** | 15–30 min |
| Google Sheets | n8n lee hoja con plantilla fija | 15 min |
| PDFs / grupos de WhatsApp | PropertyMatch extrae campos | evento |
| Manual | Panel simple | — |

**Reglas:**
- Guardar `source_updated_at`; el agente de IA muestra "actualizado el …".
- Una propiedad que desaparece de la fuente pasa a `withdrawn`, no se borra.
- No importar datos de contactos de clientes del agente: solo propiedades.
- API keys de clientes cifradas (Supabase Vault o equivalente); nunca en el repo.

### 5.4 Herramientas expuestas a los agentes (HTTP / Edge Functions)

Contrato mínimo. Autenticación por secreto compartido o JWT de servicio. Respuestas **cortas** (voz) y con `updated_at`.

| Herramienta | Entrada | Salida |
|---|---|---|
| `search_properties` | `client_id`, filtros (operation, price_max, zone, bedrooms_min, category), `query_text` opcional, `limit` (default 3) | lista de {ref_code, title, price, currency, zone, bedrooms, bathrooms, updated_at, short_url} |
| `get_property` | `client_id`, `ref_code` | ficha completa + media + brochure_url |
| `send_brochure` | `client_id`, `ghl_contact_id`, `ref_code`, `channel` | confirmación (envía por WhatsApp vía GHL) |
| `book_viewing` | `client_id`, `ghl_contact_id`, `ref_code`, fecha/hora | cita creada en calendario GHL + aviso al agente |
| `upsert_buyer_profile` | `client_id`, `ghl_contact_id`, campos extraídos | perfil actualizado |

**Requisitos de voz:** p95 < 1.5 s; nunca más de 3 resultados; la ficha/fotos se envían por WhatsApp después de la llamada.
**Opcional:** exponer las mismas herramientas como servidor MCP (para Agent Studio de GHL y otros clientes MCP).

---

## 6. Módulo 3 — Agentes de IA

### 6.1 Agente de texto (WhatsApp, web, redes)
- Plataforma: GHL Conversation AI (flujo con webhooks a las herramientas) y/o agente en n8n ("Sofía" como base).
- Funciones: responder en < 60 s, detectar idioma, calificar (presupuesto, zona, tipo, plazo, financiamiento contado/fideicomiso, fechas de visita), consultar inventario, enviar ficha, agendar visita privada, handoff a humano.
- **Reglas de prompt (obligatorias):**
  - Solo citar precio/disponibilidad devueltos por herramienta; si no hay dato, decirlo y ofrecer contactar al agente.
  - Nunca prometer descuentos, rendimientos ni resultados.
  - Tono de concierge de lujo: breve, cálido, sin presión.
  - Filtrar curiosos sin ser descortés; escalar compradores de alta intención.
  - Registrar en GHL: tags por canal, nota-resumen, campos personalizados, oportunidad en pipeline.
- Base de conocimiento por cliente: FAQ (fideicomiso, proceso de compra para extranjeros, costos de cierre, zonas), políticas, horarios.

### 6.2 Agente de voz
- Plataforma: GHL Voice AI (custom action POST a `search_properties`/`get_property`/`book_viewing`). En plan Private evaluar Retell/Vapi **[POR VALIDAR: latencia y costo]**.
- Entrantes 24/7 y salientes de seguimiento/rellamada.
- Flujo: saludo → calificación breve → búsqueda → resumen de ≤3 opciones → envío de ficha por WhatsApp → agenda de visita → transferencia en caliente si procede.
- **Cumplimiento:** aviso de IA configurable en llamadas salientes; respetar horarios y listas de no contactar. Definir qué aplica para México **[POR VALIDAR]**.

### 6.3 Agente de vendedores (Private)
- Capta al propietario que quiere listar: datos de la propiedad, expectativa de precio, fotos, disponibilidad → crea lead de tipo "seller" y agenda visita de valoración.

### 6.4 Handoff humano
- Palabras/intención de alta prioridad, solicitud explícita, o falla de herramienta → pausa de IA en esa conversación + notificación al agente asignado (WhatsApp/push).
- Re-asignación si nadie responde en X minutos (configurable, default 10).

---

## 7. Módulo 4 — Alertas de coincidencia

**Disparadores:** propiedad nueva (`insert` activo/público) o baja de precio (`property_history.field='price'` con `new < old`). Webhook de BD + barrido cada 15 min como respaldo.

**Flujo n8n:**
1. Recibe `property_id` y motivo.
2. Llama `match_buyers_for_property`.
3. Aplica reglas (todas obligatorias):
   - `whatsapp_opt_in = true` y `opted_out = false`.
   - Máximo **2 alertas por comprador por semana** (configurable).
   - No repetir la misma propiedad (consultar `alerts_sent`).
   - Horario del comprador: no enviar entre 21:00 y 08:00 (zona del cliente).
   - **Agrupar:** si coinciden varias propiedades, un solo mensaje con las mejores 2–3.
4. Actualiza campos personalizados del contacto en GHL (propiedad sugerida, enlace con `ref`) y agrega etiqueta que dispara el workflow de GHL "Alerta de coincidencia".
5. El workflow de GHL envía la **plantilla de WhatsApp** (categoría marketing, aprobada de antemano, ES y EN).
6. Registra en `alerts_sent`.
7. Si el comprador responde, se abre la ventana de 24 h y el agente de texto continúa (más fotos, agenda).
8. Si responde "no más alertas" → `opted_out = true` + etiqueta que corta todo envío.

**Plantillas a aprobar en Meta:** alerta de nueva propiedad, alerta de baja de precio, recordatorio de visita. Variables: nombre, título, zona, precio, enlace.

**Alimentar `buyer_profiles`:** el agente extrae preferencias durante la conversación → campos de GHL → n8n sincroniza a Supabase al cambiar. Fase 2: capa conductual (vistas/"me importa" repetidos → mensaje sobre esa propiedad).

---

## 8. Módulo 5 — Reactivación de base y nurture

**Reactivación (proyecto puntual):**
1. Importar y **limpiar** la base del agente (duplicados, teléfonos inválidos, formato internacional).
2. Segmentar (última interacción, tipo de interés, antigüedad).
3. Verificar base legal/consentimiento antes de escribir por WhatsApp; usar plantillas aprobadas.
4. Campaña escalonada con respuestas manejadas por el agente de texto.
5. Reporte: contactados, respuestas, visitas agendadas, bajas.

**Nurture 12 meses (workflows GHL):**
- Secuencias por etapa/tipo de lead; mensajes de valor (reporte de mercado mensual personalizado por zona, nuevas propiedades, bajas de precio).
- Salida automática al agendar visita o al pasar a negociación.
- Tareas automáticas al agente si hay señal de intención.

---

## 9. Módulo 6 — Panel del dueño y reportes

**Resumen diario (WhatsApp/email, 8:00 hora local):**
- Leads nuevos y tiempo medio de primera respuesta.
- Leads **sin atender** > X minutos (lista con agente asignado).
- Negocios estancados (sin actividad > N días).
- Visitas agendadas de hoy y de la semana.
- Alertas enviadas y respuestas.

**Panel web (Next.js, Signature/Private):**
- Vista por agente: leads asignados, respuesta, citas, conversiones por etapa.
- Vista por fuente/propiedad/anunciante (atribución QR/UTM).
- Embudo por pipeline.
- Inventario: propiedades activas, cambios de precio recientes, propiedades con más interés.
- Filtros por rango de fechas; export CSV.
- Auth: Supabase Auth con rol `owner` y `agent` (el agente solo ve lo suyo).

**Datos:** leer de GHL (API) y Supabase; cachear. Nada de datos de otro `client_id`.

---

## 10. Módulo 7 — Configuración de GHL (snapshot por cliente)

Crear un **snapshot reutilizable** y un procedimiento de alta de cliente nuevo.

- **Subcuenta** por cliente (location). Roles: owner, agent, partner (Halcón: acceso de revendedor, definir alcance).
- **Pipelines:** Compradores (Nuevo lead → Calificado → Visita agendada → Visita realizada → Negociación → Cerrado ganado/perdido) y Vendedores/Captación. Pipeline demo existente: "Lead-DEMO".
- **Campos personalizados:** idioma, operación, presupuesto min/max, moneda, zonas, recámaras, tipo, plazo, financiamiento, propiedad sugerida, `ref` de origen, UTM, opt-in WhatsApp, idioma preferido.
- **Etiquetas:** canal (`site_chat`, `whatsapp`, `voz`, `qr`), estado (`alerta_pendiente`, `no_contactar`), segmento.
- **Calendarios:** visitas privadas (por agente y round-robin), con recordatorios.
- **Workflows:** respuesta inmediata, escalamiento por falta de respuesta, alerta de coincidencia, recordatorio de visita, nurture, reactivación, reseñas post-visita, notificación al agente.
- **Conversation AI y Voice AI:** agentes configurados con custom actions apuntando a las herramientas (5.4).
- **WhatsApp:** número, WABA y plantillas (ver riesgos).
- **Reseñas:** solicitud automática post-visita/cierre.
- Preferir el calendario de GHL sobre Google Calendar (las citas deben entrar al CRM).

---

## 11. Datos de demo (obligatorio para el 21-oct)

Construir una **subcuenta demo** de una inmobiliaria ficticia de Puerto Vallarta ("[Nombre ficticio] Realty"):
- 12–15 propiedades **ficticias** en zonas reales (Marina Vallarta, Zona Romántica, Conchas Chinas, Nuevo Vallarta, etc.), precios USD, ES/EN, con fotos de stock.
- 3–4 compradores ficticios con perfiles distintos (uno con opt-in de prueba conectado al celular de la demo).
- 3 agentes ficticios con carga de leads distinta (para el panel del dueño).
- Cliente demo en Supabase con `plan='signature'`.

**Guion de demo (7–8 min):**
1. Lead entra por QR/anuncio → WhatsApp → el agente responde en < 60 s en el idioma del lead.
2. El comprador pide: *"2 recámaras frente al mar bajo $600k en Marina Vallarta"* → el agente devuelve 2–3 propiedades con ficha/fotos → agenda visita privada.
3. Llamada de voz en vivo (Halcón marca desde su celular): mismo flujo por voz → ficha por WhatsApp.
4. Se agrega una propiedad nueva en el portal/hoja → ~20 s después llega la **alerta de coincidencia** al celular de la demo.
5. El panel del dueño muestra ese lead, el tiempo de respuesta y el resumen diario.
6. Reactivación: mostrar la campaña sobre contactos dormidos (con datos ficticios).

---

## 12. Plan por fases

### Fase 0 — Descubrimiento y decisiones (14–15 oct)
- [ ] Confirmar decisiones D1–D6 (sección 14).
- [ ] Acceso al portal (panel admin / Hostinger) y diagnóstico: ¿API? ¿BD? ¿licencia?
- [ ] Estado de WABA/Tech Provider y de plantillas (sección 15).
- [ ] Repo + `CLAUDE.md` + `docs/decisiones.md` + estructura (sección 16).

### Fase 1 — MVP de demo (15–20 oct)
- [ ] Supabase: esquema, trigger, RLS, función de match por filtros.
- [ ] Herramientas HTTP: `search_properties`, `get_property`, `book_viewing`, `send_brochure`, `upsert_buyer_profile`.
- [ ] Sync de hoja de Google → `properties` (n8n).
- [ ] Agente de texto conectado a herramientas (GHL o n8n).
- [ ] Agente de voz con una custom action de búsqueda.
- [ ] Workflow de alerta de coincidencia (versión mínima, 1 plantilla).
- [ ] Datos de demo cargados; resumen diario simple por WhatsApp/email.
- [ ] Portal: limpieza mínima visible + webhook de lead → GHL.
- [ ] Ensayo completo del guion (dos veces) el 20-oct.

### Fase 2 — Producción Signature (después del 21)
- [ ] Sincronización con portal en producción; EasyBroker si aplica.
- [ ] Panel del dueño (Next.js) con auth y roles.
- [ ] Búsqueda semántica (embeddings) en match y en `search_properties`.
- [ ] Funnels por propiedad/proyecto parametrizados + QR.
- [ ] Reactivación de base como flujo repetible; nurture 12 meses.
- [ ] Snapshot de GHL + procedimiento de alta de cliente (< 1 día).
- [ ] Observabilidad: logs de herramientas, alertas de fallo de sync, dashboard de costos.

### Fase 3 — Private
- [ ] Multi-agente con cuentas y ruteo; bóveda de listings privados (`visibility='private'` + permisos).
- [ ] Motor conductual (vistas, "me importa") + mensajes por propiedad.
- [ ] Agente de vendedores; grabación/scoring de llamadas.
- [ ] Voz premium (Retell/Vapi) si las pruebas lo justifican.
- [ ] Portal con dominio propio por cliente.

---

## 13. Criterios de aceptación

**Fase 1 (demo):**
- Respuesta del agente de texto < 60 s en 9 de 10 pruebas.
- `search_properties` responde < 1.5 s (p95) con ≤ 3 resultados.
- Un cambio de precio en la fuente genera fila en `property_history` y, si hay coincidencia con opt-in, una alerta en < 2 min.
- Ninguna alerta se envía sin opt-in, fuera de horario o repetida (probar los tres casos).
- El agente **nunca** cita un precio que no vino de la herramienta (probar con preguntas trampa).
- Fallo de herramienta → el agente lo admite y deriva a humano (probar apagando el endpoint).
- Todos los leads de la demo aparecen en GHL con tags, nota y oportunidad.

**Fase 2:**
- Un cliente nuevo queda operativo con snapshot + importación en ≤ 1 día de trabajo.
- RLS verificada: un usuario de un `client_id` no puede leer datos de otro (test automatizado).
- Sync idempotente: ejecutar 2 veces no duplica ni pierde registros.
- Panel muestra métricas consistentes con GHL (muestreo manual).

---

## 14. Decisiones abiertas

| # | Decisión | Opciones | Default propuesto |
|---|---|---|---|
| D1 | Modelo del portal | Instancia por cliente vs. portal compartido (tipo Prime Estates) | Instancia por cliente para Signature/Private; compartido solo si Halcón lo pide para la revista |
| D2 | Fuente de inventario | EasyBroker / Tokko / propio / hoja / PDFs | Hoja de Google para la demo; resto según entrevista con agentes |
| D3 | Voz | GHL Voice AI vs. Retell/Vapi | GHL para Signature; evaluar Retell/Vapi para Private |
| D4 | Nombre/marca del producto y del portal | Pendiente | Variable de configuración |
| D5 | Reparto con Halcón y contrato | Mayorista/minorista con rango de precio | Cerrar con Tomás (fuera del alcance técnico) |
| D6 | Licencia del software del portal | Verificar si permite uso multi-cliente/marca blanca | Verificar antes de vender |

---

## 15. Riesgos, seguridad y cumplimiento

**Riesgos técnicos**
- **WABA / WhatsApp:** hay un ticket abierto con Meta por el bloqueo "WhatsApp necesita más información" en el onboarding como Tech Provider. Hasta resolverlo, **plan B para la demo:** número/cuenta ya verificada o conexión alternativa; no depender de plantillas nuevas aprobadas a último minuto.
- **Costos de Meta:** desde octubre de 2026 Meta empieza a cobrar respuestas de servicio por mensaje entregado **[POR VALIDAR]**; modelar costo por cliente y refacturar consumo.
- **Latencia de voz:** probar en llamada real; mantener respuestas cortas.
- **Fuentes de datos desactualizadas:** el sistema solo detecta cambios que aparezcan en la fuente; definir quién la mantiene.
- **Calidad del portal:** software de terceros → actualizaciones de seguridad, respaldos, SSL.

**Seguridad y privacidad**
- Secretos (API keys de clientes, PIT de GHL, claves de Supabase) en variables de entorno/Vault; nada en el repo; rotación documentada.
- Datos de compradores de alto patrimonio: acceso mínimo, RLS, logs de acceso, retención definida.
- Aviso de privacidad y consentimiento para WhatsApp/llamadas; registro de opt-in con fecha y origen.
- Bóveda privada: propiedades `visibility='private'` jamás expuestas por herramientas públicas.
- Respetar términos de cada fuente (EasyBroker, portales); no hacer scraping sin autorización escrita.

**Honestidad comercial:** no garantizar ventas ni rendimientos; reportar métricas controlables (tiempo de respuesta, % contactados, visitas agendadas).

---

## 16. Estructura sugerida del repositorio

```
/
├── CLAUDE.md
├── docs/ (decisiones.md, runbook-alta-cliente.md, prompts/)
├── supabase/ (migrations/, functions/, seed/)
├── n8n/workflows/
├── ghl/ (snapshot-notas.md, plantillas-whatsapp/)
├── apps/ (dashboard/, landings/)
├── portal/notas-rebrand.md
└── tests/ (rls/, sync/, agentes/)
```

**Workflows n8n a crear:** `sync-sheet-properties` · `sync-portal-properties` · `sync-easybroker` · `alerta-coincidencia` · `lead-portal-a-ghl` · `perfil-comprador-ghl-a-supabase` · `resumen-diario-dueno` · `reactivacion-base` · `handoff-humano`

---

## 17. Planes comerciales (para definir feature flags)

> Precios de venta propuestos, **a validar** con Tomás y con costos reales de GHL/Meta. Sirven para decidir qué se activa por plan (`clients.plan`).

| | **Esencial** | **Signature** | **Private** |
|---|---|---|---|
| Para | Agente individual | Agente top o equipo | Brokerage 10+ |
| Portal/funnels | Funnels y landing por propiedad/proyecto en GHL | Portal en subdominio propio, hasta N propiedades | Portal con dominio propio, multi-agente con cuentas |
| IA | Agente de texto con catálogo | + Voz + alertas de coincidencia | + Motor conductual, bóveda privada, agente de vendedores, voz premium |
| Base de datos | Reactivación básica | Reactivación completa + nurture 12 meses | + Scoring de llamadas, ruteo |
| Gestión | Reporte semanal | Panel del dueño | + Integración EasyBroker, SLA prioritario |
| Setup | $1,500–2,000 | $4,500–6,000 | $8,000–12,000 |
| Mensual | $450–600 | $1,000–1,400 | $2,000–3,500 + uso |

Extras opcionales: contenido mensual (reels/carruseles/reporte de mercado), conexiones de inventario adicionales, voz premium.

---

## 18. Definición de "terminado" para pasar a producción con un cliente

- [ ] Fuente de inventario definida, conectada y con responsable.
- [ ] Opt-in/aviso de privacidad configurados; plantillas aprobadas.
- [ ] Agentes probados con el set de preguntas trampa del cliente.
- [ ] Panel/resumen diario entregando datos reales.
- [ ] Respaldos, monitoreo de sync y alertas de fallo activos.
- [ ] Capacitación a agentes y al dueño; guía de uso de una página.
- [ ] Contrato firmado (alcance, soporte, precios, propiedad del cliente).
