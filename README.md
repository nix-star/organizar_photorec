# Organizador de Archivos Recuperados por PhotoRec

Este script en Bash permite reorganizar, clasificar y estructurar los archivos recuperados por herramientas como **PhotoRec** (o cualquier otra estructura de carpetas desordenada). Agrupa los archivos automáticamente según su extensión o formato, manteniendo de forma opcional las subcarpetas de origen y evitando la sobrescritura de archivos duplicados.

---

## 🚀 Características

- **Organización por extensión:** Clasifica automáticamente los archivos en carpetas según su extensión (`jpg`, `mp4`, `pdf`, etc.).
- **Manejo de archivos sin extensión:** Redirige los archivos sin extensión conocida o con extensión `.other` a una carpeta unificada `other/`.
- **Prevención de sobrescritura:** Si detecta archivos con el mismo nombre en el destino, les añade automáticamente un sufijo numérico incremental (ej. `imagen-1.jpg`, `imagen-2.jpg`).
- **Soporte para Mover o Copiar:** Por defecto desplaza (`mv`) los archivos, pero permite la opción de duplicar (`cp`) mediante banderas.
- **Estructura flexible de subdirectorios:** Conserva los nombres de los directorios de origen o junta todo directamente por extensión.
- **Registro detallado (Logging):** Genera un informe de operaciones exitosas (`log.txt`) y un registro aislado de errores (`log-fail.txt`) si se presentan fallos de lectura/escritura.
- **Generación automática de destino:** Si no especificas un directorio de salida, crea una carpeta con un identificador único aleatorio (ej. `folder-a1b2c3d4`).

---

## 📋 Requisitos Previos

- Entorno Unix/Linux/macOS con soporte de **Bash**.
- Utilidades estándar del sistema: `find`, `mkdir`, `cp`, `mv`, `tr`, `head`.

Asegúrate de darle permisos de ejecución al archivo antes de usarlo:

```bash
chmod +x organizar_photorec.sh
```

---

## 🛠️ Uso y Sintaxis

```bash
./organizar_photorec.sh [--copy] [--no-subdir] <origen> [destino]
```

### Argumentos:
- `<origen>` **(Obligatorio):** Ruta de la carpeta que contiene los archivos recuperados.
- `[destino]` *(Opcional):* Ruta de la carpeta donde se guardará la estructura organizada. Si se omite, se creará automáticamente una carpeta `folder-<HASH>`.

### Banderas / Opciones:
- `--copy`: En lugar de mover los archivos, realiza una copia. Recomendado si deseas mantener intacta la fuente de recuperación original.
- `--no-subdir`: Omite la creación de subcarpetas basadas en el directorio de origen, agrupando todos los archivos directamente dentro de su correspondiente carpeta de extensión.

---

## 💡 Ejemplos de Uso

### 1. Reorganizar moviendo archivos (Comportamiento por defecto)
Mueve todos los archivos desde la carpeta `recup_dir` hacia la carpeta `archivos_ordenados`:
```bash
./organizar_photorec.sh ./recup_dir ./archivos_ordenados
```

### 2. Copiar archivos sin modificar el origen
Copia todo el contenido en lugar de moverlo:
```bash
./organizar_photorec.sh --copy ./recup_dir ./respaldo_ordenado
```

### 3. Agrupar todo directamente por extensión (Sin subcarpetas de origen)
Organiza los archivos eliminando la estructura previa de subdirectorios:
```bash
./organizar_photorec.sh --no-subdir ./recup_dir ./archivos_planos
```

### 4. Generar destino automático
Si no indicas destino, creará una carpeta aleatoria (ej. `folder-X9aL2p8q`):
```bash
./organizar_photorec.sh --copy ./recup_dir
```

---

## 📁 Estructura del Resultado

Si el proceso finaliza correctamente, el directorio de destino quedará estructurado de forma similar a esto:

```text
destino/
├── jpg/
│   ├── recup_dir.1/
│   │   ├── f00001.jpg
│   │   └── f00002.jpg
│   └── recup_dir.2/
│       └── f00003.jpg
├── mp4/
│   └── recup_dir.1/
│       └── f00004.mp4
├── other/
│   └── recup_dir.1/
│       └── archivo_sin_extension
└── log.txt
```

---

## 📝 Control de Logs y Errores

El script crea registros de la ejecución en la carpeta de destino:
- **`log.txt`:** Contiene la trazabilidad cronológica de cada archivo procesado, la acción tomada (COPIADO/MOVIDO) y un resumen final con el total de operaciones.
- **`log-fail.txt`:** Si ocurren errores durante el procesamiento (por permisos de lectura/escritura u origen corrupto), los archivos fallidos se anotan aquí para su revisión. Si todo se procesa sin fallos, este archivo se elimina automáticamente.