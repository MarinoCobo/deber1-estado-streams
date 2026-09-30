# Deber 1 — Respuestas

**Programación Asistida de Aplicaciones — USFQ**

---

## Parte A · La misma app, tres veces

### 1. ¿Qué pasó al salir de Control con el botón atrás del sistema?

Partí de 3, entré a Control, pulsé **+1** (Control mostró 4) y salí con el botón atrás de
Android. El visor siguió mostrando **"Contador: 3"**. Al cerrar y volver a abrir la app
apareció **4**: el valor sí estaba guardado en disco.

Lo que quedó desactualizado fue la **copia** del contador que vive en el `State` de
`PantallaVisor` (`_contador`). El botón atrás del sistema hace un `pop` sin valor, así que el
`await Navigator.push<int>(...)` recibió `null` y el `setState` no se ejecutó. El disco decía
4, la pantalla decía 3: había dos verdades distintas y nadie las sincronizaba.

Para que el contador viajara entre las dos pantallas tuvieron que ponerse de acuerdo **cinco
lugares** repartidos en dos archivos:

1. el campo `_contador` del `State` del visor,
2. el parámetro `valorInicial` del constructor de `PantallaControl`,
3. el campo `_valor` del `State` de Control (una segunda copia),
4. el `Navigator.pop(context, _valor)` del botón "Volver",
5. el `await Navigator.push<int>` + `setState` del visor que recibe el resultado.

Basta con que una salida no pase por el punto 4 (el botón atrás, un gesto de iOS, un
`popUntil`) para que el visor quede mintiendo.

### 2. ¿Por qué ahora el botón atrás del sistema no rompe nada? ¿Dónde vive el contador?

Porque ya no hay copias que sincronizar. El contador vive en un solo lugar: el
`ContadorNotifier` de `contadorProvider`, dentro del `ProviderContainer` que crea
`ProviderScope` en `main.dart`, **fuera del árbol de widgets** y por encima de las dos
pantallas. Control llama a `incrementar()`, el notifier cambia su `state`, y el visor —que
hace `ref.watch(contadorProvider)`— se reconstruye solo. Da igual cómo se salga de Control:
nadie tiene que "devolver" nada, porque el visor nunca tuvo una copia propia.

### 3. ¿Qué te permite ver el `BlocObserver`?

La **historia completa** de los cambios de estado, en orden, con el valor anterior y el
nuevo. Con +1, +1, +1, −1 la consola mostró:

```text
ContadorCubit: 0 -> 0     ← cargar() leyó 0 del disco
ContadorCubit: 0 -> 1
ContadorCubit: 1 -> 2
ContadorCubit: 2 -> 3
ContadorCubit: 3 -> 2
```

En `setState` y en Riverpod (tal como los escribí, sin un `ProviderObserver`) el valor simplemente cambia y el anterior
se pierde. Aquí cada cambio es un estado nuevo que reemplaza al anterior, y el observer lo ve
pasar desde **un solo punto** para todos los Cubits de la app, sin tocar las pantallas.

Situación real: un usuario reporta "el carrito me cobró dos veces" o "el saldo saltó de 50 a
0". Con el observer enviando esos cambios a un log o a Crashlytics/Sentry puedes reconstruir
la secuencia exacta de estados que llevó al error, en vez de adivinar. También sirve para
analítica (qué acciones hace el usuario) y para depurar condiciones de carrera entre
llamadas asíncronas.

### 4. La prueba de la arquitectura

Comandos ejecutados dentro de `parte_a_contador/`:

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

Que los dos primeros salgan vacíos demuestra que `domain` y `data` son **byte por byte
idénticos** en las tres ramas: cambié de administrador de estado tres veces sin tocar una
sola regla del negocio (`Incrementar` sigue leyendo, sumando, guardando y devolviendo) ni la
persistencia. El tercero muestra que todo el cambio quedó contenido en `presentation/`. Esa
es la frontera: el administrador de estado es un detalle de la capa de presentación, no la
arquitectura de la app.

Si mañana cambiara Riverpod por otro paquete, reescribiría **solo `lib/presentation/`**
(el archivo de estado y las dos pantallas) y el cableado de `main.dart`. `domain/`, `data/`
y sus casos de uso se quedan exactamente igual.

---

## A.6 · La comparación

| | setState | Riverpod | Cubit |
|---|---|---|---|
| ¿Dónde vive el contador? | En el `State` de `PantallaVisor` (`_contador`), con una segunda copia en el `State` de Control | En `ContadorNotifier` dentro del `ProviderScope`, fuera del árbol de widgets | En la instancia de `ContadorCubit`, creada por un `BlocProvider` encima del `MaterialApp` |
| ¿Las pantallas se pasan datos? | Sí: el valor y los 3 casos de uso de ida por constructor, y el valor de vuelta con `pop` | No | No |
| Archivos de `presentation/` que tocaste | 2 (`pantalla_visor`, `pantalla_control`) + `main.dart` | 3 (`contador_provider` + 2 pantallas) + `main.dart` | 4 (`contador_cubit`, `contador_observer` + 2 pantallas) + `main.dart` |
| ¿Qué pasa con el botón atrás? | El visor queda desactualizado (muestra 3, el disco tiene 4) hasta reiniciar la app | Funciona: el visor ya muestra el valor nuevo | Funciona: el visor ya muestra el valor nuevo y el observer registra el cambio |
| ¿Tuviste que tocar `domain/`? | No | No | No (`git diff` vacío) |

### 5. ¿Cuál elegirías?

**Una sola pantalla:** `setState`. El dato no tiene que viajar a ningún lado, el estado
nace y muere con esa pantalla, y no hace falta añadir un paquete ni un archivo de estado.
Con una pantalla el problema de la pregunta 1 simplemente no existe.

**Ocho pantallas que comparten cinco datos:** Riverpod o Cubit. Con `setState` cada dato
tendría que subir hasta un ancestro común y bajar por constructor por cada pantalla
intermedia, con copias que se desincronizan como pasó con el botón atrás, multiplicado por
cinco. Elegiría **Cubit** si me importa rastrear la historia de cambios (el observer) y una
estructura estricta de estado inmutable; **Riverpod** si quiero menos ceremonia y
providers que dependan unos de otros (por ejemplo, el repositorio inyectado con un
`override`).

`setState` sí es la opción correcta cuando el estado es **local y efímero**: pertenece a
un solo widget y a nadie más le importa (un checkbox, una pestaña seleccionada, si un campo
de contraseña muestra el texto, una animación).

---

## Parte B · Future vs Stream

### 6. ¿Por qué la pantalla siguió mostrando "Wi-Fi"?

Porque la pantalla "Con Future" solo pregunta **cuando pulso el botón**. `consultarAhora()`
devolvió `wifi` a las 10:42:15 (por ejemplo), el `Future` se completó, se hizo `setState`, y
ahí terminó la relación entre la app y el sistema. Cuando apagué el Wi-Fi el sistema operativo
sí se enteró, pero nadie en la app estaba escuchando.

La app no tenía un dato incorrecto: tenía un **dato correcto de un momento equivocado**.
"A las 10:42:15 había Wi-Fi" era verdad; el error es mostrarlo como si fuera el presente. Por
eso la hora en pantalla es importante: es lo único que delata que es una foto vieja.

### 7. ¿Qué pasa si borras el `cancel()` y entras y sales 50 veces?

Cada vez que entro a la pestaña "Con Stream" se crea un `ConexionCubit` nuevo que se
suscribe a `onConnectivityChanged`. Al salir, `BlocProvider` llama a `close()`. Si `close()`
no cancela la suscripción, el Cubit queda cerrado pero **el stream sigue sosteniendo una
referencia a él** a través del callback `listen(emit)`.

Tras 50 entradas y salidas tendría **50 suscripciones vivas** escuchando la conexión (más la
de la pantalla abierta). Consecuencias:

- **Fuga de memoria:** ninguno de esos 50 Cubits puede ser recolectado por el GC.
- **Trabajo inútil:** cada cambio de red se entrega 51 veces.
- **Errores:** cuando llega un cambio, cada Cubit cerrado intenta hacer `emit` y lanza
  `StateError: Cannot emit new states after calling close`.

En el test `close() cancela la suscripcion` comprobé que, con el `cancel()`, el
`StreamController` falso queda sin oyentes (`hasListener == false`) apenas se cierra el
Cubit, y lo mismo al cambiar de la pestaña "Con Stream" a "Con Future".

### 8. ¿Por qué un Future es una foto y un Stream una película?

Con el `Future` le pregunté al teléfono "¿cómo está la conexión?" y me contestó **una vez**.
Esa respuesta quedó congelada en pantalla aunque el Wi-Fi ya estuviera apagado: una foto,
con su hora, que envejece en cuanto la tomas. Para saber algo nuevo tengo que volver a
tomar otra foto (pulsar "Consultar ahora").

Con el `Stream` no pregunté: me **suscribí**. Apagué el Wi-Fi y la pantalla pasó sola a
"Sin conexión"; lo encendí y volvió sola a "Wi-Fi", y el contador de cambios subió con cada
cuadro. Es una película: la app ve cada cambio en el momento en que ocurre, sin que yo haga
nada, mientras la suscripción esté abierta (y por eso hay que cerrarla).

La pregunta que decide es: *¿lo voy a pedir una vez, o va a seguir cambiando mientras la app
está abierta?*

- **Con `Future`** (una foto basta):
  1. El perfil del usuario al abrir su pantalla de cuenta.
  2. El resultado de enviar un formulario de pago (se procesa una vez y responde).
- **Con `Stream`** (hay que observar):
  1. La ubicación GPS del repartidor en una app de delivery.
  2. Los mensajes nuevos de un chat (o el estado de sesión del usuario, que puede expirar
     en cualquier momento).
