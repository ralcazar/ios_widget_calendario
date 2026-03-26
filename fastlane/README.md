fastlane documentation
----

# Installation

Make sure you have the latest version of the Xcode command line tools installed:

```sh
xcode-select --install
```

For _fastlane_ installation instructions, see [Installing _fastlane_](https://docs.fastlane.tools/#installing-fastlane)

# Available Actions

## iOS

### ios certs

```sh
[bundle exec] fastlane ios certs
```

Descarga/renueva certificados y provisioning profiles

### ios build

```sh
[bundle exec] fastlane ios build
```

Actualiza repo, incrementa build y genera el IPA

### ios beta

```sh
[bundle exec] fastlane ios beta
```

Compila y sube a TestFlight para testers internos

### ios metadata

```sh
[bundle exec] fastlane ios metadata
```

Sube metadatos y screenshots a App Store Connect (sin enviar a revisión)

### ios release

```sh
[bundle exec] fastlane ios release
```

Compila, sube IPA y metadatos a App Store y envía a revisión de Apple

### ios screenshots

```sh
[bundle exec] fastlane ios screenshots
```

Genera screenshots en simulador para todos los dispositivos requeridos

----

This README.md is auto-generated and will be re-generated every time [_fastlane_](https://fastlane.tools) is run.

More information about _fastlane_ can be found on [fastlane.tools](https://fastlane.tools).

The documentation of _fastlane_ can be found on [docs.fastlane.tools](https://docs.fastlane.tools).
