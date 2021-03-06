#!/bin/bash
set +x

echo "NOTE: importing data only works for data with the same domain / LDAP base"

echo "Extracting data..."

tar -xzf $HABIDAT_BACKUP_DIR/$HABIDAT_DOCKER_PREFIX/auth/$1 -C $HABIDAT_BACKUP_DIR/$HABIDAT_DOCKER_PREFIX/auth 

echo "Restoring user module activation store..."
docker cp $HABIDAT_BACKUP_DIR/$HABIDAT_DOCKER_PREFIX/auth/activationStore.json "$HABIDAT_DOCKER_PREFIX-user":/habidat-user/data/activationStore.json
docker cp $HABIDAT_BACKUP_DIR/$HABIDAT_DOCKER_PREFIX/auth/emailTemplateStore.json "$HABIDAT_DOCKER_PREFIX-user":/habidat-user/data/emailTemplateStore.json

echo "Import ldap data..."

cp $HABIDAT_BACKUP_DIR/$HABIDAT_DOCKER_PREFIX/auth/export.ldif ../store/auth/bootstrap/import.ldif

rm $HABIDAT_BACKUP_DIR/$HABIDAT_DOCKER_PREFIX/auth/activationStore.json
rm $HABIDAT_BACKUP_DIR/$HABIDAT_DOCKER_PREFIX/auth/emailTemplateStore.json
rm $HABIDAT_BACKUP_DIR/$HABIDAT_DOCKER_PREFIX/auth/export.ldif 

envsubst < config/bootstrap-update.ldif > ../store/auth/bootstrap/bootstrap.ldif

docker-compose -f ../store/auth/docker-compose.yml -p "$HABIDAT_DOCKER_PREFIX-auth" down -v
docker-compose -f ../store/auth/docker-compose.yml -p "$HABIDAT_DOCKER_PREFIX-auth" up -d

echo "Finished, imported: $1"
