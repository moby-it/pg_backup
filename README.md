# PG Back up container

Bash script running inside that back up the given postgress database and send the backup to an S3.

## Requirements

This script works with 2 mandatory pieces of informations:

- The `.s3cfg` that contains the auth-to-s3 info
- the `connection_string`

## How to run

- Create a `.s3cfg` file in this repo directory.
- create a `connection_string` file in this repo that inclues the postgres connection string.

By Moby IT
