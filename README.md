FenixEdu Maven Artifacts
=============

Collection of maven parent poms and archetypes for FenixEdu projects.

### org.fenixedu:fenixedu-project

Core parent pom. Sets the organization, ensures proper deployment configurations, and sets core maven plugin versions

### org.fenixedu:web-library-project

Parent pom for basic java-ee7 web modules. Compile into jars able to be included in a war as web-fragments

### org.fenixedu:fenix-framework-project

web module with fenix-framework dependency, extends web-library-project

### org.fenixedu:web-app-project

Parent pom for web-app projects. Compile into war and includes the fenix-framework's _Base classes
