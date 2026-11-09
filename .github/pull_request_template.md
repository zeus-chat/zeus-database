## Cambio
<!-- Qué cambia en la base de datos y por qué (en español). El título del PR es un Conventional Commit en inglés: feat(HU-04): add chat.conversation table -->

## Historia
<!-- HU-xx · ADR-NNN -->

## Checklist (Definition of Done)
- [ ] Un archivo `NNNN-tipo-descripcion.sql` por cambio, con un solo *changeset* (`--changeset team:NNNN-tipo-descripcion`) y el número siguiente de la secuencia global
- [ ] Incluido en `db.changelog-master.yaml` **en el orden real** de ejecución (sin `includeAll`)
- [ ] Tiene `--rollback` (o `--rollback empty` justificado); ningún *changeset* aplicado fue editado
- [ ] Sin claves foráneas ni consultas entre esquemas; los objetos van calificados con su esquema (`chat.tabla`)
- [ ] Los datos de prueba están en `seed/` con el contexto `dev`
- [ ] Cambios incompatibles con la versión anterior del servicio siguen el patrón *expand/contract*
- [ ] El CI (aplicar, revertir y volver a aplicar) está en verde
- [ ] `06-data` en `zeus-chat-docs` actualizado
- [ ] Sin contraseñas, usuarios de login ni datos personales en el repositorio
