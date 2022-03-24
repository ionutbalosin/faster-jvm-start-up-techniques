# App/Dynamic Class Data Sharing (CDS) with Docker

The demo is based on [spring-petclinic](https://github.com/spring-projects/spring-petclinic) project.

**Note:** This uses the [Docker multi-stage build](https://docs.docker.com/develop/develop-images/multistage-build/) approach to copy the AppCDS to the BUILD Docker imagine

Build and launch the application Docker container (this could take a significant amount of time because no cache is used)

```
cd spring-petclinic/
```

```
./bootstrap.sh
```

Or just launch the application Docker container (this assumes there is an already built image):

```
./bootstrap.sh --launch
```
