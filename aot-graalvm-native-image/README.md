# Ahead-of-Time (AOT) with GraalVM native-image

The demo is based on [spring-native](https://github.com/spring-projects-experimental/spring-native) project.

>Make sure the [GraalVM native-image](https://www.graalvm.org/downloads/) is properly configured

Build the application

```
cd spring-native/
```

```
./build.sh
```
**Note:** Building might take significant amount of time

## Check the start-up times with AOT

Make sure there is no other instance running

```
pkill -f 'petclinic'
```

Start few instances

```
cd samples/petclinic-jpa/
```

```
./target/petclinic-jpa -Dserver.port=8080 1>/dev/null & ./time-to-first-response.sh 8080
```
```
./target/petclinic-jpa -Dserver.port=8081 1>/dev/null & ./time-to-first-response.sh 8081
```
