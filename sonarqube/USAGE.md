# Usage

This document describes the required steps to scan an existing project with SonarQube.

# Add sonar-project.properties file

This file needs to be located in the root of the repository you want to have analysed. For example:

```
# Project Key (required)
sonar.projectKey=test-spring-boot

# Project Name (optional, this is what is shown in the main list)
sonar.projectName=test-spring-boot

# Comma-separated paths to directories with sources (required)
sonar.sources=src

# Forced Language (optional)
sonar.language=java

# Encoding of the source files (optional but recommended as default is ASCII)
sonar.sourceEncoding=UTF-8

# Plugin-specific settings
sonar.java.binaries=build/classes
sonar.java.libraries=build/libs
sonar.junit.reportPaths=build/test-results/test
sonar.jacoco.reportPaths=build/jacoco/test.exec
```

The general settings are documented at https://docs.sonarqube.org/display/SONAR/Analysis+Parameters. Plugin-specific parameters can be found in the docs for each plugin, e.g. https://docs.sonarqube.org/display/PLUG/Java+Plugin+and+Bytecode.

# Run scanner as part of Jenkins pipeline

In the `Jenkinsfile`, insert the following after the `build` stage:
```
stage('analyse') {
  if ("master".equals(branchToBuild)) {
    def scannerHome = tool 'SonarScanner'
    withSonarQubeEnv('SonarServerConfig') {
      sh "${scannerHome}/bin/sonar-scanner"
    }
  } else {
    echo "skipping analyse stage on non-master pipelines"
  }
}
```

For now, it is recommended to analyse only on master as the Community Edition of SonarQube that we are using is not aware of branches. Only the (paid) Developer Edition has this concept.

That's it - you have successfully integrated SonarQube with your project!

# Optional steps

## Enabling code coverage for Gradle based components

In your `build.gradle`, add:

```
... truncated ...

apply plugin: 'jacoco'

... truncated ...

jacoco {
  toolVersion = "0.8.1"
}
```

## Scanning locally: SonarLint IDE Plugin for analyzing while coding

The team behind SonarQube also published SonarLint, a plugin currently available for IntelliJ, Eclipse, Visual Studio, VS Code and Atom that lets you scan while coding in your IDE. It also integrates with a SonarQube Server, so that you can scan with the servers rule settings.
For further information please see https://www.sonarlint.org/intellij/howto.html. For the server connected mode, the SonarQube URL has to be set to you sonarqube installation.

## Add sonarqube and jacoco in build.gradle file

Add the following missing lines (see code comments): check lines starting with **classpath**, **apply** and **jacoco**
```
buildscript {
    ext {
...
    }
    repositories {
...
    }
    dependencies {
...
        # This dependency is only required if you want a local sonarqube
        classpath("org.sonarsource.scanner.gradle:sonarqube-gradle-plugin:2.6.2")
    }
}
...
apply plugin: "jacoco"

# This dependency is only required if you want a local sonarqube
apply plugin: 'org.sonarqube'
...

jacoco {
    toolVersion = "0.8.1"
}
```

## Scanning locally: Local SonarQube Docker Container

Be aware that this does not connect you with the SonarQube Server in OpenShift, therefore you might have other rule settings locally than the ones set on server. That said, here's what you need to do on your host to have a local SonarQube instance:

```
docker pull sonarqube
docker run -d --name sonarqube -p 9000:9000 -p 9092:9092 sonarqube
./gradlew sonarqube
```

Running these commands will let you see at http://localhost:9000 your project reports, for any branch. Please, note that you are not running with an embedded database in this case, so it is only for temporary testing, do not expect historic report.
