"""Términos y condiciones de Ardenza Propiedades (es / en). Texto base: revisar con un abogado antes de publicar."""


def page(sections, outro):
    out = []
    for title, paras in sections:
        out.append(f"<h3>{title}</h3>")
        out.extend(f"<p>{x}</p>" for x in paras)
    out.append(f"<p><em>{outro}</em></p>")
    return "".join(out)


ES_NAME = "Términos y condiciones"
ES = page([
    ("1. Quiénes somos", [
        "Ardenza Propiedades es un portal inmobiliario de FLAMIA que reúne propiedades y desarrollos de lujo en México, Costa Rica y Miami. "
        "Al usar inmobiliaria.flamiagroup.com aceptas estos términos."]),
    ("2. Información de las propiedades", [
        "Las fichas son publicadas por agentes y desarrolladores. Precios, medidas, disponibilidad e imágenes son informativos, pueden cambiar sin aviso y no constituyen una oferta vinculante.",
        "Los precios se muestran en dólares estadounidenses (USD); las conversiones a MXN o CRC son aproximadas."]),
    ("3. Agentes y anunciantes", [
        "Cada agente es responsable de la veracidad de sus anuncios y de contar con las licencias que exija su país. "
        "Ardenza Propiedades no es parte en las operaciones de compraventa o renta entre usuarios y anunciantes."]),
    ("4. Uso del sitio", [
        "No está permitido publicar información falsa, copiar el contenido con fines comerciales ni usar el sitio para actividades ilícitas. "
        "Podemos suspender cuentas que incumplan estas reglas."]),
    ("5. Datos personales", [
        "Usamos los datos que envías en formularios únicamente para responder a tu solicitud y ponerte en contacto con el agente correspondiente. "
        "Puedes pedir el acceso, la corrección o la eliminación de tus datos escribiendo a contacto@flamiagroup.com."]),
    ("6. Asesoría", [
        "El contenido del blog es informativo. Antes de comprar o invertir consulta a un asesor legal y fiscal en el país de la propiedad."]),
    ("7. Contacto", [
        "Ardenza Propiedades by FLAMIA · contacto@flamiagroup.com · +506 8940-1202"]),
], "Última actualización: octubre de 2026.")

EN_NAME = "Terms & Conditions"
EN = page([
    ("1. Who we are", [
        "Ardenza Estates is a FLAMIA real estate portal featuring luxury properties and developments in Mexico, Costa Rica and Miami. "
        "By using inmobiliaria.flamiagroup.com you accept these terms."]),
    ("2. Property information", [
        "Listings are published by agents and developers. Prices, sizes, availability and images are for information only, may change without notice and are not a binding offer.",
        "Prices are shown in US dollars (USD); conversions to MXN or CRC are approximate."]),
    ("3. Agents and advertisers", [
        "Each agent is responsible for the accuracy of their listings and for holding the licenses required in their country. "
        "Ardenza Estates is not a party to any sale or rental between users and advertisers."]),
    ("4. Use of the site", [
        "You may not post false information, copy content for commercial purposes or use the site for unlawful activities. "
        "We may suspend accounts that break these rules."]),
    ("5. Personal data", [
        "We use the data you send through our forms only to answer your request and put you in touch with the right agent. "
        "You can request access to, correction or deletion of your data by writing to contacto@flamiagroup.com."]),
    ("6. Advice", [
        "Blog content is for information only. Before buying or investing, consult a legal and tax advisor in the property's country."]),
    ("7. Contact", [
        "Ardenza Estates by FLAMIA · contacto@flamiagroup.com · +506 8940-1202"]),
], "Last updated: October 2026.")
