# zeus-database

Migraciones de **Liquibase** de la base de datos PostgreSQL compartida del chat. Una sola base de datos, **un esquema por servicio** (hoy `chat`). Decisión: [ADR-023](https://github.com/zeus-chat/zeus-chat-docs/blob/main/05-architecture/decisions/records/ADR-023-shared-database-repository.md). Documentación del modelo: [06-data](https://github.com/zeus-chat/zeus-chat-docs/blob/main/06-data/README.md).

## Estructura

```
zeus-database/
├── liquibase.properties        # valores por defecto, sin credenciales
├── db.changelog-master.yaml    # lista explícita y ordenada de archivos
├── init/ddl/                   # esquemas y roles; se aplica primero
├── chat/                       # esquema "chat"
│   ├── ddl/                    # estructura: tablas, índices, restricciones
│   ├── dml/                    # datos de referencia (todos los entornos)
│   └── seed/                   # datos de prueba (contexto dev)
├── scripts/migrate.sh          # aplica las migraciones con el contenedor de Liquibase
├── Dockerfile                  # ejecutor de Liquibase con los changelogs incluidos
└── .github/                    # CI (aplicar, revertir, reaplicar), CD (imagen a GHCR), Dependabot
```

## Convenciones
- **Un archivo por cambio:** `NNNN-tipo-descripcion.sql` con una secuencia global (por ejemplo `0003-ddl-create-conversation.sql`). El tipo es `ddl`, `dml` o `seed`.
- **Formato:** SQL de Liquibase (`--liquibase formatted sql`), un solo *changeset* por archivo: `--changeset team:NNNN-tipo-descripcion`.
- **Orden:** se declara a mano en `db.changelog-master.yaml`. No se usa `includeAll`, porque el DML puede depender de DDL posterior.
- **Rollback:** todo *changeset* lleva `--rollback` (o `--rollback empty` justificado).
- **Inmutabilidad:** un *changeset* aplicado **nunca se edita**; se crea otro nuevo.
- **Esquemas separados:** los objetos se califican con su esquema (`chat.conversation`). **No hay claves foráneas ni consultas entre esquemas.**
- **Datos de prueba:** solo en `seed/` con `context:dev`; nunca en producción.
- **Cambios incompatibles:** patrón *expand/contract* (añadir → migrar datos → eliminar en otra versión).
- **Sin secretos:** en Git solo hay roles de grupo `NOLOGIN`. Los usuarios de login y sus contraseñas se crean fuera del repositorio y se asignan al rol (`chat_app`).

## Ejecutar en local
Requiere Docker y un PostgreSQL accesible (por ejemplo el del `compose` de `zeus-chat-service`).

```bash
cp .env.example .env              # completa DB_PASSWORD; .env no se commitea
./scripts/migrate.sh              # aplica init + chat (con datos de prueba en dev)
./scripts/migrate.sh status       # lista los cambios pendientes
./scripts/migrate.sh rollback-count --count=1   # revierte el último
```

## Cómo lo usan los servicios
- Las migraciones son un **paso aparte**: el servicio no incluye Liquibase y usa `spring.jpa.hibernate.ddl-auto=validate`.
- En el *compose* de staging, el servicio `migrate` usa la imagen `ghcr.io/zeus-chat/zeus-database:<tag>` y corre antes de los servicios.
- Las pruebas de integración de cada servicio hacen *checkout* de este repositorio en una **versión fija** y la aplican sobre Testcontainers.

## Flujo de trabajo
`main` está protegida: cambios por PR con una aprobación y el check `build` (aplica, revierte y vuelve a aplicar todo desde cero sobre PostgreSQL 16). Commits en inglés, descripción del PR en español ([git-conventions](https://github.com/zeus-chat/zeus-chat-docs/blob/main/00-governance/git-conventions.md)).
