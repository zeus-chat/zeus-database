# Liquibase runner with this repository's changelogs baked in.
# Used by the staging compose as the "migrate" step before the services start.
# Credentials are passed at run time (LIQUIBASE_COMMAND_URL / _USERNAME / _PASSWORD), never baked in.
FROM liquibase/liquibase:5.0.4

COPY --chown=liquibase:liquibase . /liquibase/changelog

ENTRYPOINT ["/liquibase/docker-entrypoint.sh", "--search-path=/liquibase/changelog", "--changelog-file=db.changelog-master.yaml"]
CMD ["update"]
