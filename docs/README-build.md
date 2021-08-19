# Build system

We are simply using GitHub actions as it is too easy to set them up ;). See [workflows](.github/workflows/maim.yml) directory for the build setup.
Therefore, go to the github actions to check the status of the build.

Otherwise, just build a docker image from the (Dockerfile)[Dockerfile] which will build the system for the latest ubuntu version only.
```bash
docker build -t amolofos/automated-workstation-setup .
```

Once the image has been build, we can go ahead and run it.
```bash
docker run amolofos/automated-workstation-setup
```

Or we can go into the container.
```bash
docker run -it --entrypoint /bin/bash amolofos/automated-workstation-setup
./docker-entrypoint.sh
```
