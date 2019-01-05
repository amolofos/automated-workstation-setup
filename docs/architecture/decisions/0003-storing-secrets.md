# 2. Ansible: Storing secrets

Date: 2020-05-03

## Status

Accepted

## Context

How do we store sensitive data that are needed for this project?
Sensitive data can be usernames, passwords, ssh keys etc.

## Decision

It is expect sensitive data to be encrypted using ansible vault tool. As
part of this project we specify expect sensitive data to be provided in
the local machine in specific locations. See `docs/README-secrets.md` for
these locations.

It is left to the end user to decide how they want to store and protect the
sensitive data, the ansible vault password and the respective files these
live in. One can review an example approach that we took as part of our
personal workstation setup in `docs/README-secrets.md` document.

## Consequences

Secrets leaking out and our setup being compromised.