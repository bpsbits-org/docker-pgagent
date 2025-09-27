# Additional Extensions and Tools

To extend your PostgreSQL container with additional tools or extensions, provide them as `.deb` packages and place them in this directory. These packages will be automatically installed during the container’s first startup.

### Steps:

1. Copy the desired `.deb` packages into this directory.
2. Start the container, and the extender will handle the installation automatically.

---

**Please note that packages must be placed before the initial launch of the PostgreSQL container.**