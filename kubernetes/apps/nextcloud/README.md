# Nextcloud

## Secrets

Antes de aplicar, crie a secret do MariaDB:

```bash
# Criar secret manualmente
kubectl create secret generic mariadb \
  --namespace=nextcloud \
  --from-literal=database=nextcloud \
  --from-literal=username=nextcloud \
  --from-literal=password='SUA_SENHA_AQUI'
```

Ou instale o SealedSecrets e gere um SealedSecret criptografado.

## Instalação via ArgoCD

O ArgoCD sincroniza automaticamente este diretório. Após criar a secret, o Nextcloud será instalado com MariaDB.

## Acesso

- URL: http://192.168.0.100/nextcloud/
- Primeiro acesso: crie um usuário admin