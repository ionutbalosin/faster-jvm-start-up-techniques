# Faster JVM Start-up Techniques

Techniques about how to improve the JVM start-up time for any application running on the JVM.

Please use this tutorial in conjunction with my presentation slides [Techniques for a faster JVM start-up](https://ionutbalosin.com/talks)


>Please visit my [web site](https://ionutbalosin.com/) if you are interested in further performance or software architecture-related articles.

>Please check my [training catalog](https://ionutbalosin.com/training) if you are interested in specialized training for your company.


## Content
#### [App/Dynamic Class Data Sharing (CDS) in HotSpot JVM](app-dynamic-cds-hotspot/README.md)
#### [Shared Classes Cache (SCC) and Dynamic Ahead-of-Time (AOT) in Eclipse OpenJ9 JVM](scc-dynamic-aot-openj9/README.md)
#### [Ahead-of-Time (AOT) with GraalVM native-image](aot-graalvm-native-image/README.md)
#### [App/Dynamic Class Data Sharing (CDS) with Docker](docker/README.md)

## Projects in scope

### spring-petclinic project

```
git clone git@github.com:spring-projects/spring-petclinic.git
```

Additional files are needed for the multi-stage Dockerfile but also to measure the application start-up time

```
cp ./additional-scripts/* ./spring-petclinic
```

### spring-native project

```
git clone git@github.com:spring-projects-experimental/spring-native.git
```

Additional file is needed to measure the application start-up time

```
cp ./additional-scripts/time-to-first-response.sh ./spring-native/samples/petclinic-jpa
```

## Disable Address Space Layout Randomization (ASLR)

For comparable results (especially in the case of App/Dynamic CDS), please make sure [ASLR](https://en.wikipedia.org/wiki/Address_space_layout_randomization) is disabled. 
For further details check [JEP 310: Application Class-Data Sharing](https://openjdk.java.net/jeps/310)

```
sudo sh -c "echo 0 > /proc/sys/kernel/randomize_va_space"
```

## Check the process memory

### Resident Set Size (RSS) / Proportional Set Size (PSS)

When multiple JVM instances are running on the same host and the archives are shared, the overall memory is implicitly reduced. To measure it I recommend looking at the [RSS](https://en.wikipedia.org/wiki/Resident_set_size) and [PSS](https://en.wikipedia.org/wiki/Proportional_set_size) of each process by using the [pmap](https://www.labcorner.de/cheat-sheet-understanding-the-pmap1-output/) command (known to provide the most accurate information) .

Assuming there are 2 running processes and PIDs were incrementally assigned

```
pmap -X `pgrep -f petclinic | sed -n -e '1p'` |  sed -n -e '2p;$p'
```
```
pmap -X `pgrep -f petclinic | sed -n -e '2p'` |  sed -n -e '2p;$p'
```

### Heap and Metaspace statistics (in HotSpot JVM)

```
java -Xlog:cds -Xlog:gc+heap+exit -jar -Dserver.port=8080 target/*.jar
``` 
```
java -Xlog:cds -Xlog:gc+heap+exit -jar -XX:SharedArchiveFile=dynamic-cds.jsa -Dserver.port=8080 target/*.jar
``` 

Once the application properly starts press **CTRL+C**.

**Note:** Check the used/committed memory
