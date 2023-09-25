
<h2>Run/debug the Micronaut application in native (no JVM) mode inside docker container</h2>

We build our native application  with maven using docker-native packaging. 
Then build docker debug graalvm image with coping there built classes and dependencies. 
Then we take from this docker image the "application" executable file and run debug using it on docker target.

1. Run maven target `mvn package -Dpackaging=docker-native` to build native application, profile: `graalvm`

2. Copy target/Dockerfile, name it `Debug.dockerfile` and place it into the same `target` folder.  
Change it:
   ```Dockerfile
   # GraalVM image based on some image, here on Oracle Linux 9
   ARG BASE_IMAGE="ghcr.io/graalvm/native-image-community:17-ol9"
   # because on dependencies on system libraies it's better to reuse same image for run
   ARG BASE_IMAGE_RUN="oraclelinux:9"
   
   FROM ${BASE_IMAGE} AS builder
   WORKDIR /home/app
   COPY classes /home/app/classes
   COPY dependency/* /home/app/libs/
   COPY *.args /home/app/graalvm-native-image.args
   #Here main class of your server application
   ARG CLASS_NAME="example.micronaut.Application"
   RUN native-image @/home/app/graalvm-native-image.args -H:Class=${CLASS_NAME} -g -H:Name=application -cp "/home/app/libs/*:/home/app/classes/"
   FROM ${BASE_IMAGE_RUN}
   ARG EXTRA_CMD=""
   RUN if [[ -n "${EXTRA_CMD}" ]] ; then eval ${EXTRA_CMD} ; fi
   
   COPY --from=builder /home/app/application /app/application
   #copy debug info of application
   COPY --from=builder /home/app/application.debug /app/application.debug
   
   #install gdbserver to debug
   RUN dnf install -y gdb-gdbserver
   ARG PORT=8080
   EXPOSE ${PORT}
   ```
3. Run "Build image" for `Debug.dockerfile`(click on the gutter ->Build image)
4. Configure `GraalVM Native Image` run configuration:
   - Executable: `target/application`
   - Use classpath module: `demo`
   - Run on target: Docker
     - Dockerfile: `target/Debug.dockerfile` 
     - Optional:
       - Image tag: gdbserver 
       - Run options: add `-p 8080:8080`
       
5. Set break point to `UserController` class, `random` get method
6. Press "Debug" on the created `GraalVM Native Image` run configuration
7. Go to http://localhost:8080/users/random to stop on this endpoint.
 

Troubleshooting
https://youtrack.jetbrains.com/issue/IDEA-331760/ It is not possible to set breakpoints for some classes/methods
...
