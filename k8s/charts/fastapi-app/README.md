# FastAPI App Helm Chart

This Helm chart deploys a FastAPI application with a PostgreSQL database in a Kubernetes cluster.

## Prerequisites

- Kubernetes 1.16+
- Helm 3.1+
- PV provisioner support in the underlying infrastructure

## Getting Started

### No external dependencies

This Helm chart uses a simple PostgreSQL deployment that matches your development environment.


### Build and push the Docker image

Before deploying, you'll need to build and push the Docker image to a repository accessible by your Kubernetes cluster.

```bash
# Build the Docker image
docker build -t your-registry/fastapi-app:latest .

# Push the image to your registry
docker push your-registry/fastapi-app:latest
```

### Installing the Chart

To install the chart with the release name `my-release`:

```bash
helm install my-release ./fastapi-app \
  --set fastapi.image.repository=your-registry/fastapi-app \
  --set fastapi.image.tag=latest
```

The command deploys the FastAPI application on the Kubernetes cluster with the default configuration. The [Parameters](#parameters) section lists the parameters that can be configured during installation.

### Uninstalling the Chart

To uninstall/delete the `my-release` deployment:

```bash
helm delete my-release
```

## Parameters

### FastAPI Application Parameters

| Name                                    | Description                                                  | Value           |
| --------------------------------------- | ------------------------------------------------------------ | --------------- |
| `fastapi.replicaCount`                  | Number of FastAPI replicas                                   | `1`             |
| `fastapi.image.repository`              | FastAPI image repository                                     | `fastapi-app`   |
| `fastapi.image.pullPolicy`              | FastAPI image pull policy                                    | `IfNotPresent`  |
| `fastapi.image.tag`                     | FastAPI image tag                                            | `latest`        |
| `fastapi.service.type`                  | Service type for FastAPI                                     | `ClusterIP`     |
| `fastapi.service.port`                  | Service port for FastAPI                                     | `80`            |
| `fastapi.env.normal.LOG_LEVEL`          | Log level for the application                                | `INFO`          |
| `fastapi.env.secret.DB_USER`            | Database username                                            | `myuser`        |
| `fastapi.env.secret.DB_PASSWORD`        | Database password                                            | `mypassword`    |
| `fastapi.env.secret.DB_NAME`            | Database name                                                | `mydatabase`    |

### PostgreSQL Parameters

| Name                                    | Description                                                  | Value           |
| --------------------------------------- | ------------------------------------------------------------ | --------------- |
| `postgresql.enabled`                    | Enable PostgreSQL                                            | `true`          |
| `postgresql.auth.username`              | PostgreSQL username                                          | `myuser`        |
| `postgresql.auth.password`              | PostgreSQL password                                          | `mypassword`    |
| `postgresql.auth.database`              | PostgreSQL database name                                     | `mydatabase`    |
| `postgresql.primary.persistence.enabled`| Enable persistence for PostgreSQL                            | `true`          |
| `postgresql.primary.persistence.size`   | Size of the persistent volume for PostgreSQL                 | `8Gi`           |

## Configuration and Installation Notes

### External Database

If you want to use an external database instead of the included PostgreSQL, set `postgresql.enabled=false` and configure the FastAPI application to use your external database:

```bash
helm install my-release ./fastapi-app \
  --set postgresql.enabled=false \
  --set fastapi.env.normal.db_host=your-external-db-host
```

### Ingress Configuration

To enable ingress, set `fastapi.ingress.enabled=true` and provide host information:

```bash
helm install my-release ./fastapi-app \
  --set fastapi.ingress.enabled=true \
  --set fastapi.ingress.hosts[0].host=fastapi-app.example.com \
  --set fastapi.ingress.hosts[0].paths[0].path=/
```

## Upgrading

### To 1.0.0

No special actions required.