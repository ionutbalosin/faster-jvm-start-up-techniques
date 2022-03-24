# Shared Classes Cache (SCC) and Dynamic Ahead-of-Time (AOT) in Eclipse OpenJ9 JVM

The demo is based on [spring-petclinic](https://github.com/spring-projects/spring-petclinic) project.

>Make sure the [IBM Semeru Runtime](https://developer.ibm.com/languages/java/semeru-runtimes/downloads/) is properly configured

Build the application sources

```
cd spring-petclinic/
```

```
./mvnw package -DskipTests
```

## Create the SCC

```
java -Xshareclasses:name=scc,cacheDir=. -Xscmx96m -XX:SharedCacheHardLimit=192m -Xquickstart -jar -Dserver.port=8080 target/*.jar
```

**Note:** When "-Xquickstart" mode is enabled all methods are dynamically AOT compiled (supposing that AOT compiler is active as well). This option is recommended when start-up time is an important performance metric.

These command-line options are further detailed below: 
- [-Xshareclasses](https://www.eclipse.org/openj9/docs/xshareclasses)
- [-Xscmx](https://www.eclipse.org/openj9/docs/xscmx)
- [-XX:SharedCacheHardLimit](https://www.eclipse.org/openj9/docs/xxsharedcachehardlimit/)
- [-Xquickstart](https://www.eclipse.org/openj9/docs/xquickstart)

## Print the SCC stats

```
java -Xshareclasses:printStats,name=scc,cacheDir=.
```

## Check the start-up times with SCC

Make sure there is no other instance running

```
pkill -f 'petclinic'
```

Start a few instances with SCC

```
java -Xshareclasses:name=scc,cacheDir=. -Xscmx128m -XX:SharedCacheHardLimit=256m -Xquickstart -jar -Dserver.port=8080 target/*.jar 1>/dev/null & ./time-to-first-response.sh 8080
```
```
java -Xshareclasses:name=scc,cacheDir=. -Xscmx128m -XX:SharedCacheHardLimit=256m -Xquickstart -jar -Dserver.port=8081 target/*.jar 1>/dev/null & ./time-to-first-response.sh 8081
```

## Further References

- [Optimize JVM start-up with Eclipse OpenJ9](https://developer.ibm.com/articles/optimize-jvm-startup-with-eclipse-openjj9)