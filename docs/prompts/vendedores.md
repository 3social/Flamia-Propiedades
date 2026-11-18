# Agente de vendedores — Fase 3 (Private)

Estado: **solo definición**. No se construye antes de la demo.

Capta al propietario que quiere listar su propiedad y crea un lead de tipo vendedor.

Datos a recoger: tipo y ubicación de la propiedad, metros, recámaras/baños, expectativa de precio, fotos, disponibilidad
para una visita de valoración, y si ya está listada con otro agente (no se presiona sobre exclusividad).

Resultado: contacto con tag `vendedor`, oportunidad en el pipeline "Vendedores / Captación" (etapa "Nuevo propietario") y
cita de "Valoración agendada" en el calendario del agente responsable.

Reglas: no valorar ni sugerir precio de venta (lo hace el agente humano), no prometer tiempos de venta, no recibir
documentos legales por chat; mismas reglas de idioma, tono, handoff y bajas que el agente de texto.
