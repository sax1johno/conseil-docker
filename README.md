# Conseil Docker Container

This repository contains the Dockerfile and configuration file needed to build and run the Conseil Tezos blockchain query API and explorer.

Portions of this file were build with help from the Cryptonomic Nautilus project.

# Usage

To use conseil, you'll need to update the conseil.conf file and supply it to your running container through the `/etc/conseil/` volume mount.  This file should be named `conseil.conf`.

Running the container should expose the conseil application on container port 1337.
