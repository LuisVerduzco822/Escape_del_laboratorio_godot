# Escapa del Laboratorio — Plataformas 2D (Godot 4)

Juego de plataformas estilo Mario Bros (GDScript, Godot 4): te mueves
y saltas sobre una pasarela metálica fija, esquivas o pisas bolas de
fuego que avanzan desde la derecha, y recolectas monedas.

## Cómo abrirlo
1. Descomprime el .zip.
2. Godot 4 → **Importar** → selecciona `project.godot`.
3. Espera a que termine de importar y presiona **F5**.

Probado sin errores en la primera importación con **Godot 4.4.1** en
modo headless (importación, físicas de salto/pisotón/golpe lateral,
monedas, spawner de enemigos, progresión de los 3 niveles) y con
capturas de pantalla reales del motor (no mockups) para verificar
que todo se vea bien.

## Controles
| Acción | Tecla |
|---|---|
| Moverse | Flechas izquierda/derecha |
| Saltar | Espacio o flecha arriba |
| Pausa | Esc |
| Menús | Flechas arriba/abajo o Tab para elegir; Enter o Espacio para activar |

## Cómo se juega
- Las bolas de fuego aparecen por el borde derecho y avanzan en línea
  recta hacia la izquierda sobre la pasarela.
- **Salta sobre una bola de fuego** (cayendo desde arriba) para
  destruirla y rebotar.
- **Si la tocas de lado**, pierdes al instante y aparece la pantalla
  de Game Over.
- Recolecta todas las monedas del nivel para pasar al siguiente. Al
  completar el nivel 3 ganas.

## Niveles y dificultad
| Nivel | Fondo | Enemigos | Velocidad | Monedas |
|---|---|---|---|---|
| 1 Fácil | Laboratorio (tanques) | 1 cada 3 s | 120 px/s | 5 |
| 2 Medio | Alcantarillado | 1 cada 2 s | 170 px/s | 6 |
| 3 Difícil | Azotea nocturna | 1 cada 1 s + ráfagas | 230 px/s | 7 |

## Assets utilizados (los que subiste)
- **Fondos:** `nivel1.jfif` (laboratorio), `nivel2.jpg` (alcantarillado)
  y `nivel3.jfif` (azotea) — uno por nivel, a pantalla completa.
- **Enemigo:** tu sprite `Enemy.png` (bola de fuego), usado tal cual
  en `Fireball.tscn`.
- **Fuente:** `PressStart2P-Regular.ttf`, asignada al tema editable
  `scenes/ui/GameTheme.tres`.
- El jugador sigue usando el sprite "Adam" (del pack Modern
  Interiors que ya tenías en el proyecto) con sus animaciones de
  caminar/quieto; no se pidió cambiarlo.
- Las monedas recolectables usan `assets/tiles/toolbox.png`.

## Lógica de pisotón vs. golpe lateral
`Fireball.gd` decide el resultado al tocar al jugador comparando su
velocidad vertical y posición: si el jugador está cayendo
(`velocity.y > 0`) y sus pies siguen por encima del centro de la
bola de fuego, es un pisotón (la bola se destruye y el jugador
rebota); en cualquier otro caso (de lado o por debajo) es golpe
lateral y pierde. Verificado con pruebas automáticas para ambos
casos.

## Estructura
```
assets/
  backgrounds/  level1_bg.png, level2_bg.png, level3_bg.png
  enemies/      Fireball.png
  fonts/        PressStart2P-Regular.ttf
  characters/   Adam (jugador)
  tiles/        toolbox.png (moneda recolectable)
  audio/        música + efectos (ya generados, conectados)
scenes/
  Main.tscn, ui/MainMenu.tscn, ui/HUD.tscn
  player/Player.tscn, enemy/Fireball.tscn, item/Coin.tscn
  levels/Level1.tscn, Level2.tscn, Level3.tscn
scripts/
  autoload/GameManager.gd   (monedas, nivel, puntos, señales)
  autoload/AudioManager.gd  (música + efectos)
  player/Player.gd          (movimiento, gravedad, salto)
  enemy/Fireball.gd         (movimiento + pisotón/golpe)
  item/Coin.gd
  levels/LevelBase.gd       (fondo, piso, spawner, monedas)
  ui/MainMenu.gd, ui/HUD.gd, Main.gd
```

## Ajustes desde el Inspector
- `scenes/Main.tscn`: lista ordenada de niveles. El total del HUD se
  actualiza con esa lista.
- `scenes/player/Player.tscn`: animaciones del personaje; en su nodo
  raíz, velocidad, gravedad, salto y rebote.
- `scenes/levels/Level1.tscn` (igual en los otros niveles): escena de
  bola de fuego, intervalo, velocidad, ráfagas, monedas y marcador
  `FireballSpawn`.
- `scenes/autoload/AudioManager.tscn`: música y efectos en cada
  `AudioStreamPlayer`.
- `scenes/ui/GameTheme.tres`: fuente y apariencia de botones.
- `project.godot` → **Mapa de entrada**: acción `jump`.

## Decisión de diseño (no especificada en el pedido)
No se indicó cómo se gana cada nivel, así que: **recolectar todas
las monedas del nivel hace que se cargue automáticamente el
siguiente** (y el nivel 3 lleva a la pantalla de victoria). Si
prefieres otro criterio (ej. sobrevivir un tiempo fijo, o cruzar
una meta), es un cambio pequeño en `LevelBase.gd`.

## Verificación realizada
- Importación limpia (sin errores) en Godot 4.4.1.
- Jugador cae y se asienta en el piso por gravedad; salto alcanza
  ~100px de altura (suficiente para pasar por encima de una bola de
  fuego).
- Pisotón destruye al enemigo y hace rebotar al jugador; golpe
  lateral dispara Game Over — ambos probados por separado.
- Monedas suman al contador por contacto real y se eliminan de la
  escena.
- El spawner genera bolas de fuego y estas se autodestruyen al
  salir por la izquierda.
- Progresión automática confirmada hasta la victoria en el nivel 3.
- Capturas de pantalla reales (motor Godot vía Xvfb + Mesa) de
  portada, los 3 niveles, una bola de fuego en pantalla y Game Over.

## Créditos y licencias
- Fondos, sprite de enemigo y fuente: los que subiste (Press Start 2P
  bajo SIL OFL 1.1, incluida en `assets/fonts/OFL.txt` si la trae el
  zip original).
- **Assets de laboratorio:** [590+ Pixel Cargo, Tech & Laboratory Loot](https://rehandev.itch.io/590-pixel-cargo-tech-laboratory-loot),
  por RehanDev.
- **Personaje Adam:** [Modern Interiors](https://limezu.itch.io/moderninteriors),
  por LimeZu. Se usa la versión gratuita, cuya licencia incluida en
  `assets/ASSETS_LICENSE.txt` permite el uso no comercial.
- **Música:** [Retro Synthwave Music Pack](https://swarajthegreat.itch.io/retro-synthwave-music-pack),
  por swarajthegreat (CC0, según la página del autor).
- **Efectos de sonido:** generados para este proyecto.
