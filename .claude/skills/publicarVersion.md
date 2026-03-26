# Publicar Versión

Incrementa el número de versión en `VERSION.txt`, hace commit y push al repositorio remoto.

## Instrucciones

Ejecuta estos pasos en orden:

1. Lee el archivo `VERSION.txt` en la raíz del proyecto para obtener la versión actual.

2. Incrementa el número de versión siguiendo estas reglas:
   - El formato es `MAJOR.MINOR` (ej: `0.3`)
   - Incrementa siempre el MINOR en 1 (ej: `0.3` → `0.4`)
   - Si el usuario especifica `--major`, incrementa MAJOR y resetea MINOR a 0 (ej: `0.3` → `1.0`)

3. Escribe la nueva versión en `VERSION.txt`.

4. Haz commit y push:
   ```bash
   git add VERSION.txt
   git commit -m "chore: bump version to <nueva_version>"
   git push
   ```

5. Confirma al usuario la versión anterior y la nueva versión publicada.

## Argumentos opcionales

- `--major` — incrementa el número MAJOR en lugar del MINOR
