# `pgAgent` for PostgreSQL Container with Extender

The **PostgreSQL Container Extender** is a lightweight tool designed to enhance the official PostgreSQL container by enabling **pgAdmin** and supporting the installation of additional extensions and tools—all without the need to create custom container images. This makes it easier to customize and manage your PostgreSQL environment efficiently.

## Key Features

- **Enable pgAdmin**: Seamlessly integrate `pgAdmin` into the official `PostgreSQL` container.
- **Install Extensions and Tools**: Easily add custom extensions and tools using `.deb` packages.
- **No Custom Images Required**: Extend the official PostgreSQL container directly, saving time and effort.
- **Simple Configuration**: Uses a custom entrypoint script to streamline setup.

## Why docker-pgagent?

**docker-pgagent** solves a critical challenge for PostgreSQL users running containerized environments: seamlessly integrating **pgAgent**, the powerful job scheduling agent for PostgreSQL, without the need for custom container images. This lightweight tool enhances the official PostgreSQL container by enabling automated task scheduling for database maintenance, backups, and custom scripts, all while maintaining simplicity and flexibility. Additionally, **docker-pgagent** allows users to easily install their own PostgreSQL extensions and tools via .deb packages, overcoming the limitations of the standard PostgreSQL container, which typically does not support custom extensions without complex workarounds. With **docker-pgagent**, you get a streamlined, efficient way to extend and automate your PostgreSQL environment, saving time and effort while leveraging the full power of pgAgent and custom extensions in a containerized setup.

## pgAgent

**pgAgent** is an open-source job scheduling agent designed **specifically for PostgreSQL databases**, enabling the automation of tasks such as database maintenance, backups, and custom scripts. It operates as a background daemon, storing job definitions (including steps and schedules) in a dedicated PostgreSQL schema, and supports executing SQL commands, stored procedures, or external shell scripts at specified intervals or times. Integrated with pgAdmin for easy management, pgAgent ensures reliable, ACID-compliant execution within the Postgres environment.

## Your Own Custom Postgres Extensions and Tools

PostgreSQL extensions are modular add-ons that enhance database functionality, such as adding new data types, functions, or indexing methods. With **docker-pgagent**, you can automatically install your own custom extensions and tools as `.deb` packages when the container runs for the first time.

**.deb packages** are Debian-based software packages used to distribute and install software on Debian-compatible systems, including the PostgreSQL container environment. These packages bundle binaries, configuration files, and dependencies, ensuring seamless installation.

To include your custom extensions or tools, place the `.deb` packages in a designated directory . There are multiple ways to achieve this:

1. **Using a Temporary Volume**: Create a temporary volume, import your `.deb` packages into it, and link it to the builder container during the `docker-pgagent` volume creation (see section **Install `docker-pgagent`**).
2. **Direct Copy**: Copy the `.deb` packages directly into the `docker-pgagent` volume before its first usage (`/var/lib/docker-pgagent/apt/pkg`).

Follow the instructions in **Install `docker-pgagent`** to ensure the packages are automatically installed during the container's initial startup, simplifying the process of extending your PostgreSQL environment.

## Usage

There are two primary use cases for `docker-pgagent`: installing it on a new PostgreSQL instance or extending an existing PostgreSQL installation. We recommend testing the deployment in a non-production environment before applying it to a production environment.

Please note that the provided code examples use Podman. For other scenarios, you should adapt your approach based on these examples.

### New PostgreSQL instance

1. Create volumes:
   1. Create a data volume for the PostgreSQL container to store data at `/var/lib/postgresql/data`.
   2. Create a volume for the `docker-pgagent`.
   3. Create temp volume for your own custom packages.

2. Install `docker-pgagent` on the target volume, either using an *installation container* or *manually*.
3. Verify installation.
4. Create a new PostgreSQL container instance with a custom entry point: `/var/lib/docker-pgagent/entrypoint.sh`.
5. Start the new PostgreSQL container.

#### 1. Create volumes

```shell
podman volume create vol_tmp_ext # Temporary volume
podman volume create vol_docker_pgagent # Volume containing docker-pgagent
podman volume create vol_postgres_data # PostgreSQL data volume
```

#### 2. Install `docker-pgagent`

```shell
PATH_DIR_PACKAGES=/home/dev/my-dep-packages # Path to the additional extensions (.deb)

# Copy your custom extensions into vol_tmp_ext
podman run --rm \
    -v "${PATH_DIR_PACKAGES}:/source:z" \
    -v vol_tmp_ext:/root/extra_packages:z \
    --platform linux/amd64 \
    docker.io/library/debian:trixie-slim cp -rv /source/. /root/extra_packages/

# Install docker-pgagent into vol_docker_pgagent
podman run --rm \
    -v vol_tmp_ext:/root/extra_packages:z \
    -v vol_docker_pgagent:/var/lib/docker-pgagent:z \
    --platform linux/amd64 \
    quay.io/pg_share/docker_pgagent:pg17

podman volume rm vol_tmp_ext # Remove temporary volume
```

#### 3. Verify installation

```shell
podman run --rm -v vol_docker_pgagent:/var/lib/docker-pgagent:z alpine tree /var/lib/docker-pgagent
```

#### 4. Create PostgreSQL Container

```shell
echo -n "12345678" | podman secret create ps_pg_server - # Secret, use your own pswd
podman create \
    --name postgres_with_pg_agent \
    --restart always \
    -v vol_docker_pgagent:/var/lib/docker-pgagent:z \
    -v vol_postgres_data:/var/lib/postgresql/data:z \
    -p 5432:5432 \
    --secret ps_pg_server,type=env,target=POSTGRES_PASSWORD \
    --entrypoint /var/lib/docker-pgagent/entrypoint.sh \
    --platform linux/amd64 \
    docker.io/library/postgres:17
```

#### 5. Start PostgreSQL Container

```shell
podman start postgres_with_pg_agent # Start PostgreSQL
timeout 60 podman logs -f postgres_with_pg_agent # Print logs to the screen
```

### Existing PostgreSQL Instance

1. Save the container configuration of the target PostgreSQL container instance.
2. Create volumes:
   1. Create a volume for the `docker-pgagent`.
   2. Create temp volume for your own custom packages.

3. Install `docker-pgagent` on the target volume, either using an *installation container* or *manually*.
4. Verify installation.
5. Stop the target PostgreSQL container instance.
6. Remove the target PostgreSQL container instance.
7. Create a new PostgreSQL container instance with the custom entry point `/var/lib/docker-pgagent/entrypoint.sh` and the saved configuration from step 1.
8. Start the new PostgreSQL container.

## Support

**docker-pgagent** is provided as-is, with no free support available. The toolset is designed to be robust and user-friendly, but users are responsible for their own setup and troubleshooting. Bugs can be reported via GitHub Issues, but they will be reviewed and addressed based on availability, not immediately. 

*Paid support may be available in certain scenarios where it is economically feasible, offered as a pre-paid service. For inquiries about paid support, please contact us directly to discuss your specific needs.*
