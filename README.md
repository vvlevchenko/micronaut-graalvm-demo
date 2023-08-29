
<h2>Run/debug the Micronaut application in native (no JVM) mode inside docker container</h2>


1. Run maven target `mvn package -Dpackaging=docker-native` to build native application
   profile: `graalvm`
  
   So, we have as a result this command:  
   
2. Copy and edit target/Dockerfile:
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
RUN native-image @/home/app/graalvm-native-image.args -H:Class=${CLASS_NAME} -H:Name=application -cp "/home/app/libs/*:/home/app/classes/"
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
3. Run build image on new Dockerfile.debug

4. Extract application and application.debug into `target` or your output directory

5. Check that `application` is executable `chmod 755 target/application`

6. Configure run configuration:

7. Executable: target/application

8. Use classpath module: `demo`

9. Run on target: Docker
   Dockerfile: target/Dockerfile.debug
   Optional:
      Image tag: gdbserver
      Run options: add `-p 8080:8080`
10. Set break point

11. Press debug on your new created run configuration
 

