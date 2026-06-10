apiVersion: v1
kind: Secret
metadata:
  name: hermes-secrets
  namespace: hermes
type: Opaque
stringData:
  dashboard-user: "admin"
  dashboard-pass: "REPLACE_WITH_STRONG_PASSWORD"
  dashboard-secret: "REPLACE_WITH_OPENSSL_RAND_HEX_32"