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

## Resources

For detailed instructions, code examples, and troubleshooting, visit the project homepage.