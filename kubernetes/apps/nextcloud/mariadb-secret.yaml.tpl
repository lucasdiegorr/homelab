# Template para Secret do MariaDB
# NÃO COMMITAR com senha real!
# Copie para mariadb-secret.yaml, altere a senha, e apply
---
apiVersion: v1
kind: Secret
metadata:
  name: mariadb
  namespace: nextcloud
type: Opaque
stringData:
  database: nextcloud
  username: nextcloud
  password: "CHANGE_ME_PASSWORD"