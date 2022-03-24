# App/Dynamic Class Data Sharing (CDS) in HotSpot JVM

The demo is based on [spring-petclinic](https://github.com/spring-projects/spring-petclinic) project.

>Make sure the [OpenJDK HotSpot Runtime](https://jdk.java.net/17/) is properly configured

Build the application sources

```
cd spring-petclinic/
```

## App CDS

Build the application sources

```
./mvnw package -DskipTests
```

Create the AppCDS class list

```
java -Xshare:off -XX:DumpLoadedClassList=app-cds.lst -jar target/*.jar
```

Create the AppCDS archive based on the previously created class list

```
java -Xshare:dump -XX:SharedClassListFile=app-cds.lst -XX:SharedArchiveFile=app-cds.jsa -jar target/*.jar
```

Start the application and specify the name of the AppCDS archive as argument

```
java -XX:SharedArchiveFile=app-cds.jsa -jar -Dserver.port=8080 target/*.jar
```

Optionally, you can also start the application with CDS and class loading logging and redirect the output to separate files for further analysis

```
java -Xlog:cds:file=app-cds.log -Xlog:class+load:file=app-cds-class-load.log -XX:SharedArchiveFile=app-cds.jsa -jar -Dserver.port=8080 target/*.jar
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

Once the application properly starts, call the existing endpoints at [localhost:8080](http://localhost:8080/) and press **CTRL+C**.

**Note:** Since only loaded classes will be added to the archive (i.e. classloading happens lazily) you must invoke the functionality of your application to cause all the relevant classes to be loaded.

Start the application and specify the name of the dynamic CDS archive as argument

```
java -XX:SharedArchiveFile=dynamic-cds.jsa -jar -Dserver.port=8080 target/*.jar
```

### Enable CDS and class loading logging for further analysis

Start the application with CDS and class loading logging enabled and redirect the output to separate files for further analysis

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

>Enabling the "thin jar" deployment use case using [spring-boot-thin-layout](https://github.com/spring-projects-experimental/spring-boot-thin-launcher) plugin and repeating all previous steps more classes will be included in the shared archive.

### Compare the start-up times between static base CDS (i.e., default) and dynamic CDS

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

## Two-layers of CDS archives

**Note:** the JVM can use up to two archives.

**Option 1:** Create the dynamic CDS archive using a non-default static CDS (i.e., AppCDS) archive

```
java -XX:SharedArchiveFile=app-cds.jsa -XX:ArchiveClassesAtExit=dynamic-cds.jsa -jar -Dserver.port=8080 target/*.jar
```

**Option 2:** Specify the non-default static CDS (i.e., AppCDS) archive together and the dynamic CDS archive in the same command line

```
java -XX:SharedArchiveFile=app-cds.jsa:dynamic-cds.jsa -jar -Dserver.port=8080 target/*.jar
```