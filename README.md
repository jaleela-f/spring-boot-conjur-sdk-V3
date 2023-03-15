# spring-boot-conjur-sdk-V3
Includes changes from migrating Springboot V2 to V3
# Conjur Spring Cloud Config Plugin

The Conjur Spring Cloud Config plugin provides client-sid support for externalized configuration of secrets in a distributed system. The plugin can be 
integrated with existing and new Spring Boot Applications to retrieve secrets from Conjur with no code change. The Authentication parameters to connect to
the Conjur Vault are maintained as externalized properties in the Spring Cloud Config Server.

# Benefits of storing application secrets in CyberArk's vault

* Provides one central location to store and retrieve secrets for applications across all environments.
* Supports the management of static and dynamic secrets such as username and password for remote applications and resources.
* Provides credentials for external services like MySQL, PostgreSQL, Apache Cassandra, Couchbase, MongoDB, Consul, AWS, and more.

<b> Note for Kubernetes users:</b> Customers and users intending to run their Spring Boot based application in Kubernetes are encouraged to follow an alternative to the plugin solution described in this readme. Cyberark offers a Kubernetes native feature 'Push To File' described here. The documentation illustrates a process to assemble spring-boot application.properties files dynamically and avoids the need for any Java code changes in order to draw secrets directly from Conjur.

# Features

* With no code change, the existing application can integrate the Spring Cloud Config Conjur Plugin to the existing application
* Externalize the properties using the Spring cloud Config Server
* API authentication
* Retrieve secrets from the CyberArk Vault and initialize the application properties using @Value annotation

# Limitations

The Spring Cloud Config Conjur plugin does not support creating, updating or removing secrets

# Technical Requirement
--------------------------------------------
| <b> Technology            | <b> Version   |
|---------------------------|---------------|
| Java                      |    11+        |
| Conjur OSS                |    1.9+       |
| Conjur Enterprise         |    12.5+      |
| Conjur SDK (Java)         |    4.0.0      |
| Conjur API (Java)         |    5.1        |
|Spring Cloud Config Server |               |
|Spring Boot                |               |
---------------------------------------------

# Prerequisites
  
  The following are the prerequisites to run the Spring Cloud Config Conjur plugin.
  
  ## Conjur Setup
 
  Conjur (OSS or Enterprise) and the Conjur CLI are installed in the environment and running in the background. If you haven't yet done so, follow the     instructions for installing [OSS](https://www.conjur.org/get-started/quick-start/oss-environment/) and [Enterprise](https://docs.cyberark.com/Product-   Doc/OnlineHelp/AAM-DAP/10.9/en/Content/Get%20Started/install-enterprise.htm)
  
  ## Spring Cloud Config Server
 
  Spring Cloud Config provides server-side and client-side support for externalized configuration in a distributed system.
    * Config Server provides a central place to manage external properties for applicaiton across all environments. Best 
    * Can be integrated with any application running any language including Spring applicaiton as Spring Environment provides mapping to the \n
      property sources.
    * Configuration can be managed across the enviornment while migrating from dev to test and to production, to make sure that applicaitons have\n
      everything they need to run when they migrate.
    * Default storage is the git ,so it easily supports labelled versions of configuration environment as well as being accessible to a wide range
      of tooling for managing the content
    * Support for configuration file security through the encryption/decryption mechanism
  
  ## Spring Cloud Config Setup
  
  Setting up the Config Server involves two step process, installing the Server and Client
  
  ### Spring Cloud Config Server Setup
  
  
#### Git Backend setup
  
The Spring Cloud Config Server can be integrated with different storage mechanism like Git Hub,File System Backend, Vault Backend etc,to access Property files from. \n The default implementation of the Spring Cloud Config Server uses Git. 
In this documentation Git Backend has been used as an repository to store and acces the application properties. Below are the steps to follow  to integrate \n   Spring Cloud Config Server with Git Repository
  
#### Configure Repository

  Below are the steps to create a .properties file and to initialize the Git Repository

  1. Check if git is installed in sytem with the below command, if not download the Git [here]https://git-scm.com/downloads
  
  ```
  $ git --version
  
  ```
  Should return the version of the Git ,if already installed.
  
  2. Create a folder in local environment, to store the <file-name>.properties file that will be used by the application
  Property files can created one for each environment (Dev,Test, Prod)
  
  ```
  $> mkdir example-repo
  
  ````
  
  3. Change to the directory and create a properties file
  
  ```
  $> cd example-repo
  $ example-repo > vi exampleService.properties
  
  ```
  Enter the below properties in the exampleService.properties
  
  ```
  exampleService.properties
  CONJUR.ACCOUNT = <Account to connect>
  CONJUR.APPLIANCE_URL = <Conjur instance to connect>
  CONJUR.AUTHN_LOGIN = <User /host identity>
  CONJUR.API_KEY = <User/host API Key/password>
  CONJUR.AUTHN_TOKEN_FILE = <Path to token file containing API key> -optional
  CONJUR.CERT_FILE = <Path to certificate file>
  CONJUR.SSL_CERTIFICATE = <Certificate content>
  
  ```
  
  4. Initializing the Git
  
  The below commands will be used to initialize Git in the configuration folder and commit the property files to the Git
  
  ```
  $> cd example-repo
  $ example-repo> git init
  $ example-repo> git add .
  $ example-repo> git commit -m "Initial commit"
  
  ```
  5. Creating property file for different environment
  
  Properties file can created for different environment from Dev to Prod 
  exampleService-dev.properties
  exampleService-uat.properties 
  exampleService-prod.properties
  
  6. The local Git repository is created only for Dev/Test deployment. To work on the Production deployment , Repository needs to be more secured \n 
  and created in remote location.
  
  Spring Cloud Config Server provides a HTTP resource based API for extenral configuration by Key/Value pair or .yml file
  @EnableConfigServer annotation will be used to embed the server into the Spring Boot Application
  
  ### Example code:
  #### Step 1:
  ```
  @EnableConfigServer
  @SpringBootApplication
  public class ConfigServerApplication {
	
	public static void main(String[] args) {
		SpringApplication.run(ConfigServerApplication.class, args);
	}
	

}
 ```
  #### Step 2: Create bootstrap.properties file in the <b> /resource</b> folder
  
  bootstrap.properties
  ```
  server.port= <port to connect to the server>
  spring.profiles.active= <environment dev/stage/test/prod>
  spring.cloud.config.server.native.search-locations= <location of the storage where the configuration file is maintained,\n
                                                      by default its Git>
  spring.cloud.config.server.git.clone-on-start= <specify 'true' to refresh the config server on server startup>
  spring.application.name=<point to the properties file for that particular application>
  ```
  
 #### pom.xml
 Following dependency needs to be included for Spring Cloud Config Server to be started 
  
  ```
  <dependency>
    <groupId>org.springframework.boot</groupId>
    <artifactId>spring-boot-starter-web</artifactId>
  </dependency>
  <dependency>
    <groupId>org.springframework.cloud</groupId>
    <artifactId>spring-cloud-starter-config</artifactId>
  </dependency>
  <dependency>
    <groupId>org.springframework.cloud</groupId>
    <artifactId>spring-cloud-config-server</artifactId>
  </dependency>
  <dependency>
    <groupId>org.springframework.boot</groupId>
    <artifactId>spring-boot-starter-actuator</artifactId>
  </dependency>
  ```
  
  ## Client Plugin Usage
  
  Client Plugin can be used with existing Spring Boot application or new Spring Boot application using the below 
  
  
  
  
  
  
  
  
  
  
  
  
  
  


 
  
  
  
  
 
 
  
  
  
  
  
  
  
  
  
  
  
  
  
  
  
