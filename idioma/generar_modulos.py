"""Genera idioma/lang/vendor/plugins/<módulo>/<es|en>/<archivo>.php a partir de idioma/modulos.py.

Comprueba contra las copias del servidor (idioma/origen/<módulo>/en/<archivo>.php) que cada clave
exista y que los marcadores (:name, :count…) se conserven.
"""
import json
import os
import re
import subprocess
import sys

HERE = os.path.dirname(os.path.abspath(__file__))
sys.path.insert(0, HERE)
import modulos  # noqa: E402

ORIGEN = os.path.join(HERE, "origen")
DESTINO = os.path.join(HERE, "lang", "vendor", "plugins")
MARKER = re.compile(r":[a-z_]+")

FLATTEN = r"""
function flat($a, $p = '') { $o = []; foreach ($a as $k => $v) { $kk = $p === '' ? "$k" : "$p.$k";
  if (is_array($v)) { $o += flat($v, $kk); } else { $o[$kk] = $v; } } return $o; }
"""


def origen():
    """{'<módulo>/<archivo>:<clave>': texto} de los archivos en inglés del servidor."""
    code = FLATTEN + r"""
$out = [];
foreach (glob($argv[1] . '/*/en/*.php') as $f) {
  $plugin = basename(dirname(dirname($f))); $file = basename($f, '.php');
  foreach (flat(include $f) as $k => $v) { $out["$plugin/$file:$k"] = $v; }
}
echo json_encode($out);
"""
    res = subprocess.run(["php", "-r", code, "--", ORIGEN], capture_output=True, text=True, check=True)
    return json.loads(res.stdout)


def php_str(s):
    return "'" + s.replace("\\", "\\\\").replace("'", "\\'") + "'"


def php_array(tree, indent=1):
    pad = "    " * indent
    lines = ["["]
    for k, v in tree.items():
        val = php_array(v, indent + 1) if isinstance(v, dict) else php_str(v)
        lines.append(f"{pad}{php_str(k)} => {val},")
    lines.append("    " * (indent - 1) + "]")
    return "\n".join(lines)


def write(locale, entries):
    files = {}
    for key, text in entries.items():
        path, dotted = key.split(":", 1)
        node = files.setdefault(path, {})
        parts = dotted.split(".")
        for part in parts[:-1]:
            node = node.setdefault(part, {})
        node[parts[-1]] = text
    for path, tree in sorted(files.items()):
        plugin, file = path.split("/")
        out = os.path.join(DESTINO, plugin, locale, file + ".php")
        os.makedirs(os.path.dirname(out), exist_ok=True)
        with open(out, "w", encoding="utf-8") as f:
            f.write("<?php\n\nreturn " + php_array(tree) + ";\n")
        subprocess.run(["php", "-l", out], capture_output=True, check=True)
    return len(files)


def check(src, entries, name):
    problems = []
    for key, text in entries.items():
        if key not in src:
            problems.append(f"{name}: la clave no existe en el servidor: {key}")
        elif sorted(MARKER.findall(src[key])) != sorted(MARKER.findall(text)):
            problems.append(f"{name}: marcadores distintos en {key}")
    return problems


if __name__ == "__main__":
    src = origen()
    problems = check(src, modulos.ES, "ES") + check(src, modulos.EN, "EN")
    if problems:
        print("\n".join(problems))
        sys.exit(1)
    n_es = write("es", modulos.ES)
    n_en = write("en", modulos.EN)
    print(f"ok: {len(modulos.ES)} textos en {n_es} archivos (es), {len(modulos.EN)} en {n_en} archivos (en) -> {DESTINO}")
