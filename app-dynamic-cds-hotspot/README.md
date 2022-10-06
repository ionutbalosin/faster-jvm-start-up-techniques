# App/Dynamic Class Data Sharing (CDS) in HotSpot JVM

The demo is based on [spring-petclinic](https://github.com/spring-projects/spring-petclinic) project

>Make sure the [OpenJDK HotSpot Runtime](https://jdk.java.net/17/) is properly configured

Build the application sources

```
cd spring-petclinic/
```

## AppCDS

**Note:** I will refer to the AppCDS archive as a _static archive_

Build the application sources

```
./mvnw package -DskipTests
```

Create the AppCDS class list

```
java -Xshare:off -XX:DumpLoadedClassList=static-cds.lst -jar target/*.jar
```

Create the AppCDS archive based on the previously created class list

```
java -Xshare:dump -XX:SharedClassListFile=static-cds.lst -XX:SharedArchiveFile=static-cds.jsa -jar target/*.jar
```

Start the application and specify the name of the AppCDS archive as argument

```
java -XX:SharedArchiveFile=static-cds.jsa -jar -Dserver.port=8080 target/*.jar
```

### Enable CDS and class load logging for further analysis

Optionally, you can also start the application with CDS and class load logging enabled and redirect the output to separate files for further analysis

```
java -Xlog:cds:file=static-cds.log -Xlog:class+load:file=static-cds-class-load.log -XX:SharedArchiveFile=static-cds.jsa -jar -Dserver.port=8080 target/*.jar
```

## Dynamic CDS

### Create the dynamic CDS archive

Build the application sources

```
./mvnw package -DskipTests
```

Create the dynamic CDS archive

```
java -XX:ArchiveClassesAtExit=dynamic-cds.jsa -jar -Dserver.port=8080 target/*.jar
```

Once the application properly starts, call the existing endpoints at [localhost:8080](http://localhost:8080/) and press **CTRL+C**

**Note:** Since only loaded classes will be added to the archive (i.e., classloading happens lazily) you must invoke the functionality of your application to cause all the relevant classes to be loaded

Start the application and specify the name of the dynamic CDS archive as argument

```
java -Xlog:cds -XX:SharedArchiveFile=dynamic-cds.jsa -jar -Dserver.port=8080 target/*.jar
```

### Enable CDS and class load logging for further analysis

Optionally, you can also start the application with CDS and class load logging enabled and redirect the output to separate files for further analysis

```
java -Xlog:cds:file=dynamic-cds.log -Xlog:class+load:file=dynamic-cds-class-load.log -XX:SharedArchiveFile=dynamic-cds.jsa -jar -Dserver.port=8080 target/*.jar
```

Once the application properly starts press **CTRL+C**

Check the CDS logs

```
cat dynamic-cds.log
```

Count the total number of shared classes

```
cat dynamic-cds-class-load.log | grep "shared objects file" | wc -l
```

Count the total number of *Spring framework* shared classes

```
cat dynamic-cds-class-load.log | grep "shared objects file" | grep "org.springframework" | wc -l
```

>Enabling the "thin jar" deployment use case using [spring-boot-thin-layout](https://github.com/spring-projects-experimental/spring-boot-thin-launcher) plugin and repeating all previous steps more classes will be included in the shared archive

### Compare the start-up times between static base CDS (i.e., default) and dynamic CDS archives

Make sure there is no other instance running

```
pkill -f 'petclinic'
```

Start a few instances with static base CDS

```
java -jar -Dserver.port=8080 target/*.jar 1>/dev/null & ./time-to-first-response.sh 8080
```
```
java -jar -Dserver.port=8081 target/*.jar 1>/dev/null & ./time-to-first-response.sh 8081
```

Start a few instances with dynamic CDS

```
java -XX:SharedArchiveFile=dynamic-cds.jsa -jar -Dserver.port=8082 target/*.jar 1>/dev/null & ./time-to-first-response.sh 8082
```

```
java -XX:SharedArchiveFile=dynamic-cds.jsa -jar -Dserver.port=8083 target/*.jar 1>/dev/null & ./time-to-first-response.sh 8083
```

## Two layers of CDS archives

HotSpot JVM can use up to two archives

### Option 1: create the dynamic CDS archive based on an AppCDS archive (instead of the default static CDS)

```
java -XX:SharedArchiveFile=static-cds.jsa -XX:ArchiveClassesAtExit=dynamic-cds.jsa -jar -Dserver.port=8080 target/*.jar
```

Then, start the application using the previously created archive

```
java -XX:SharedArchiveFile=dynamic-cds.jsa -jar -Dserver.port=8080 target/*.jar
```

### Option 2: chain the AppCDS archive and the dynamic CDS archive in the same command line

```
java -XX:SharedArchiveFile=static-cds.jsa:dynamic-cds.jsa -jar -Dserver.port=8080 target/*.jar
```

**Note:** the separator on Windows is _\;_ (backslash semicolon) instead of _:_ (colon)