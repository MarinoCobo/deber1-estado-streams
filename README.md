# deber1-estado-streams

Deber 1 — Manejo de estado y uso de streams en Flutter (Programación Asistida de
Aplicaciones, USFQ).

```text
deber1-estado-streams/
├── parte_a_contador/   contador compartido y persistente, con arquitectura limpia
├── parte_b_conexion/   detector de conexion con Future y con Stream + Cubit
├── demo.mp4            la pestana "Con Stream" cambiando sola al apagar el Wi-Fi
└── RESPUESTAS.md       las 8 respuestas, la tabla de A.6 y la salida de A.5
```

## Parte A: una rama por administrador de estado

`main` solo tiene `domain/` y `data/`. Las tres ramas salen de `main` y cambian
únicamente `lib/presentation/`, `main.dart` y el test:

| Rama | Presentation |
|---|---|
| `version/setstate` | `setState`, el valor viaja por constructor y `Navigator.pop` |
| `version/riverpod` | `flutter_riverpod` (`NotifierProvider`) |
| `version/bloc` | `flutter_bloc` (`ContadorCubit` + `BlocObserver`) |

```bash
git switch version/bloc
cd parte_a_contador && flutter pub get && flutter run
```

Prueba de la arquitectura (desde `parte_a_contador/`):

```bash
git diff version/setstate version/riverpod -- lib/domain lib/data   # vacío
git diff version/setstate version/bloc     -- lib/domain lib/data   # vacío
```

## Parte B

```bash
cd parte_b_conexion && flutter pub get && flutter run
grep -r "connectivity" lib/ --include=*.dart -l   # solo data/repositories/conexion_plus_repository.dart
```

Cada proyecto tiene tests (`flutter test`) que reproducen los experimentos del deber: el
botón atrás en las tres versiones, la foto que no se actualiza, el stream que sí, y el
`cancel()` dentro de `close()`.
