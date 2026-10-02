# Escape del Laboratorio — Proyecto Godot 4

Juego top-down 2D (Godot 4, GDScript) hecho con el pack **Modern Interiors Free v2.2**.

## Cómo abrirlo
1. Descomprime el .zip.
2. Godot 4 → **Importar** → selecciona `project.godot`.
3. Espera a que termine de importar y presiona **F5**.

Probado sin errores en la primera importación con **Godot 4.3 y 4.4.1** en modo headless (importación, recorrido completo de los 3 niveles, disparo, dash, colisiones, audio y fuente). La fuente y el audio se cargan por código (no por `preload`) para evitar el error típico de "recurso no importado todavía" la primera vez que se abre un proyecto nuevo — esto es independiente de la versión de Godot 4.x.

## Controles
| Acción | Tecla |
|---|---|
| Moverse | Flechas |
| Dash | Espacio o Shift |
| Disparar | Clic izquierdo o J |
| Pausa | Esc |

## Cómo se juega
Recolecta **todas las estrellas** del nivel: la salida está **roja (CERRADA)** hasta que las tengas todas, y se pone **verde (SALIDA)** al completarlas. Los enemigos patrullan y quitan una vida al tocarte (3 vidas). Puedes dispararles; las balas se detienen contra los muebles/paredes. Al terminar el nivel 3 ganas.

## Niveles y dificultad
| Nivel | Dificultad | Diseño | Estrellas | Enemigos |
|---|---|---|---|---|
| 1 | Fácil | 1 sala | 3 | 2 lentos |
| 2 | Medio | 2 salas + 1 pasillo | 5 | 4 (uno en el pasillo) |
| 3 | Difícil | 3 salas + 2 pasillos | 6 | 8 (varios resisten 2 disparos) |

La cámara sigue al jugador con suavizado en los niveles 2 y 3 (más anchos que la pantalla).

## Arte y recursos usados del pack
- **Personajes:** Adam (jugador), Bob, Alex y Amelia (enemigos), con animaciones idle/run en 4 direcciones.
- **Paredes:** una textura distinta por nivel (panel crema nivel 1, piedra nivel 2, azulejo nivel 3) más una textura de ladrillo exclusiva para los pasillos, todas recortadas del Room Builder.
- **Objetos del tileset de interiores:** estrella coleccionable, alfombras, escritorios, armarios (con colisión, actúan como obstáculos), plantas, lámparas de pie y de mesa, globo terráqueo, silla y la flecha indicadora de los pasillos.
- Todo el mobiliario tiene colisión real y se dibuja ordenado por profundidad (y-sort); los personajes proyectan sombra.

## Interfaz y estilo retro
- **Fuente:** Press Start 2P (licencia OFL), aplicada a todo el juego por código en `Main.gd`.
- **Portada:** marco tipo arcade (borde dorado + línea cian), scanlines estilo CRT, título con sombra y brillo pulsante, y los 4 personajes ilustrados a los lados.
- **Pantalla de victoria/derrota:** mismo tratamiento (marco, scanlines, sombra de título).
- **HUD:** vidas, puntos, nivel actual (n/3) y estrellas restantes.

## Audio
Música de fondo en loop y 6 efectos (moneda, golpe, dash, disparo, victoria, game over), generados específicamente para este proyecto (síntesis por ondas, sin depender de archivos de terceros) y ya enlazados en `AudioManager.gd`. Para cambiarlos, reemplaza el `.wav` correspondiente dentro de `assets/audio/` manteniendo el mismo nombre de archivo.

## Estructura
```
assets/  audio, characters, decor, fonts, tiles, ui (scanlines)
scenes/  Main, ui/, player/, enemy/, item/, levels/
scripts/ autoload/ (GameManager, AudioManager), util/, player/, enemy/, item/, levels/, ui/, Main.gd
```

## Verificación realizada
- Importación limpia (sin errores) en Godot 4.3 y 4.4.1, ambas a la primera.
- Recorrido automático completo de los 3 niveles: cruce de pasillos, recolección de estrellas por contacto real, salida cerrada→abierta, y victoria final.
- Derrota por contacto con enemigos, pausa (Esc), disparo destruyendo enemigos, dash, y balas detenidas por muebles.
- Verificación por búsqueda de rutas (BFS) de que las estrellas y la salida son alcanzables caminando en los 3 niveles.
- Fuente y audio verificados como correctamente cargados y reproduciéndose.

## Licencias
- Pack Modern Interiors Free v2.2: uso no comercial (`assets/ASSETS_LICENSE.txt`).
- Press Start 2P: SIL OFL 1.1 (`assets/fonts/OFL.txt`).
- Audio: generado para este proyecto, sin restricciones.
