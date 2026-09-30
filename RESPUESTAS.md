# Deber 1 — Respuestas

Programación Asistida de Aplicaciones — USFQ

Nota: probé las apps en la Mac. Ahí no existe el botón atrás de Android, así que usé la
flecha de regresar que aparece arriba a la izquierda, que hace lo mismo: sale de la pantalla
sin pasar por el botón "Volver" de la app.

## Parte A

### 1.

Cuando salí de Control con el botón "Volver" de la app, el visor mostraba bien el número.
Pero cuando entré, sumé uno y salí con la flecha de regresar, el visor se quedó con el
número de antes, como si el último +1 no hubiera pasado. Lo curioso es que al cerrar la app
y abrirla de nuevo sí apareció el número correcto, o sea que el valor sí se había guardado.

Lo que quedó desactualizado no fue el dato guardado, sino la copia del contador que tenía la
pantalla del visor. Esa copia solo se actualiza cuando Control le devuelve el número al
salir con "Volver". Si sales por otro lado, no le llega nada y se queda con el valor viejo.
Entonces había dos versiones del número: la guardada, que estaba bien, y la que se veía en
pantalla, que estaba mal.

Para que el contador pasara de una pantalla a la otra tuvieron que ponerse de acuerdo como
cinco partes del código entre los dos archivos: el visor guarda su número, se lo pasa a
Control al abrirla, Control guarda su propia copia, la devuelve al darle "Volver" y el visor
la recibe y se actualiza. Si una de esas partes falla, como pasó con la flecha, el visor
muestra algo que ya no es cierto.

### 2.

Porque ahora el contador ya no le pertenece a ninguna pantalla. Vive en el provider de
Riverpod, que está por fuera de las pantallas y que las dos pueden ver. Cuando sumo en
Control, el cambio pasa en ese lugar compartido y el visor se entera solo. Ya no hay una
copia en cada pantalla que haya que mantener sincronizada, así que da igual si salgo con
"Volver" o con la flecha: el visor siempre muestra el mismo número que Control.

### 3.

El BlocObserver me dejó ver en la consola cada cambio que tenía el contador, con el valor de
antes y el de después, por ejemplo "ContadorCubit: 3 -> 4". Cada vez que tocaba +1 o -1
aparecía una línea nueva, así que quedaba toda la historia de lo que había pasado. Con
setState y con Riverpod el número simplemente cambiaba y no había forma de ver qué pasó
antes.

Esto sería útil, por ejemplo, si un usuario reporta que un saldo o un carrito de compras
quedó con un valor raro. Con ese registro se podría ver paso a paso cómo se llegó a ese
valor, en vez de tener que adivinar qué hizo el usuario.

### 4.

Estos son los resultados de los comandos, corridos dentro de `parte_a_contador`:

```text
$ git diff version/setstate version/riverpod -- lib/domain lib/data
(salida vacía)

$ git diff version/setstate version/bloc -- lib/domain lib/data
(salida vacía)

$ git diff version/setstate version/bloc --stat -- lib/presentation
 parte_a_contador/lib/presentation/estado/contador_cubit.dart    | 20 +++++++++
 parte_a_contador/lib/presentation/estado/contador_observer.dart | 15 +++++++
 .../lib/presentation/pantallas/pantalla_control.dart            | 56 ++++++++---------------
 parte_a_contador/lib/presentation/pantallas/pantalla_visor.dart | 69 ++++++-----------------------
 4 files changed, 66 insertions(+), 94 deletions(-)
```

Que los dos primeros salgan vacíos quiere decir que la lógica de la app y la parte que
guarda los datos son exactamente iguales en las tres versiones. Cambié la forma de manejar
el estado tres veces y no tuve que tocar ni una línea de eso. Todos los cambios quedaron
dentro de presentation, que es lo que muestra el tercer comando. Eso demuestra que el
administrador de estado es solo una parte de la interfaz y no la base de la app.

Si mañana tuviera que cambiar Riverpod por otro paquete, solo tendría que volver a escribir
la carpeta de presentation y un poco del main. El dominio y los datos se quedarían igual.

### Tabla comparativa

| | setState | Riverpod | Cubit |
|---|---|---|---|
| ¿Dónde vive el contador? | En la pantalla del visor, y Control tiene su propia copia | En el provider, fuera de las pantallas | En el Cubit, que está por encima de las dos pantallas |
| ¿Las pantallas se pasan datos? | Sí, de ida y de vuelta | No | No |
| Archivos de presentation que toqué | 2, más el main | 3, más el main | 4, más el main |
| ¿Qué pasa con el botón atrás? | El visor se queda con el número viejo hasta reiniciar la app | Funciona bien | Funciona bien y además sale en la consola |
| ¿Tuve que tocar domain? | No | No | No |

### 5.

Si la app tuviera una sola pantalla usaría setState, porque el dato no tiene que ir a
ningún otro lado y no vale la pena agregar un paquete ni más archivos. El problema que vi en
la pregunta 1 solo aparece cuando hay que compartir el dato entre pantallas.

Si tuviera ocho pantallas que comparten cinco datos, usaría Riverpod o Cubit. Con setState
tendría que estar pasando cada dato de pantalla en pantalla y cuidar que todas las copias
estén al día, y ya con dos pantallas y un solo dato se me desincronizó. Me iría por Cubit si
me interesa poder ver la historia de los cambios, y por Riverpod si quiero algo con menos
código.

setState no es malo: es la mejor opción cuando el estado solo le importa a una pantalla o a
un widget, como un checkbox, una pestaña seleccionada o mostrar u ocultar una contraseña.

## Parte B

### 6.

Porque la pantalla solo preguntó por la conexión en el momento en que toqué "Consultar
ahora". En ese momento sí había Wi-Fi, así que eso fue lo que mostró. Después apagué el
Wi-Fi, pero la app no volvió a preguntar, entonces se quedó mostrando lo último que sabía.
Solo cuando volví a tocar el botón dijo "Sin conexión".

Creo que la app no tenía un dato incorrecto, sino un dato correcto de un momento equivocado.
Es verdad que a esa hora había Wi-Fi, el problema es que lo seguía mostrando como si fuera
lo que pasa ahora. Por eso sirve que aparezca la hora de la consulta: es lo único que
avisa que el dato puede estar viejo.

### 7.

Cada vez que entro a la pestaña del Stream se crea un Cubit nuevo que se pone a escuchar los
cambios de conexión. Al salir, el Cubit se cierra, y con el cancel también deja de escuchar.
Si borro el cancel, el Cubit se cerraría pero la suscripción seguiría viva, escuchando por
detrás.

Si el usuario entra y sale cincuenta veces, quedarían cincuenta suscripciones abiertas que
nadie usa. Eso gasta memoria, porque esos Cubits nunca se pueden liberar, y cada vez que
cambie la conexión todos intentarían actualizarse aunque ya estén cerrados, lo que además
provoca errores. Es una fuga de memoria que va creciendo mientras más se usa la app.

### 8.

Con el Future la app le preguntó una sola vez al sistema cómo estaba la conexión, y esa
respuesta se quedó fija en la pantalla aunque yo apagara el Wi-Fi. Es como una foto: muestra
cómo estaban las cosas en ese instante, y para saber algo nuevo hay que tomar otra.

Con el Stream la app no pregunta, sino que se queda escuchando. Cuando apagué el Wi-Fi la
pantalla cambió sola a "Sin conexión", cuando lo prendí volvió sola a "Wi-Fi", y el
contador de cambios iba subiendo, como se ve en el video. Es como una película: va
mostrando cada cambio en el momento en que pasa, sin que yo tenga que hacer nada.

En una app real pediría con Future el perfil del usuario cuando abre su cuenta y el
resultado de enviar un pago, porque son cosas que se piden una vez y ya. En cambio,
observaría con Stream la ubicación del repartidor en una app de delivery y los mensajes
nuevos de un chat, porque esas cosas siguen cambiando mientras la app está abierta.
