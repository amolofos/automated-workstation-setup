# Build system

We are simply using GitHub actions as it is too easy to set them up ;). See [workflows](.github/workflows/maim.yml) directory for the build setup.
Therefore, go to the github actions to check the status of the build.

Otherwise, just build a docker image from the (Dockerfile)[Dockerfile] which will build the system for the latest ubuntu version only.
```bash
# If you want the create a contaier where you can run
# the docker-entrypoint scripts, use the default docker file.
docker build -t amolofos/automated-workstation-setup .
# or
docker build -t amolofos/automated-workstation-setup --file Dockerfile.noIntegrationTests .

# If you want the docker build to create a container
# where all the ansible steps have been executed,
# use the full build docker file.
docker build -t amolofos/automated-workstation-setup --file Dockerfile.fullBuild .
```

Once the image has been build, we can go ahead and run it.
```bash
docker run --restart=always amolofos/automated-workstation-setup
```

Or we can go into the container.
```bash
docker run -it --restart=always --entrypoint /bin/bash amolofos/automated-workstation-setup
./docker-entrypoint.sh
```
