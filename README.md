## Diploma project for EPAM DevOps Internship #24

A light-weight Python/Flask application with MySQL database.
It gets Starwars herous  via API (), stores it in the database and displays on the web page.
For a marketing campaign collect information about Star Wars universe using open API https://swapi.dev/ Store the following data in the local database: character: Name, Gender, homeworld, and other if it is necessary; planet: Name, Gravitation, Climate, and other if it is necessary. Create a report contenting information (see above) about the planet (or planets) with a list of its residents.

CI/CD pipeline and IaC approach are implemented. 

Tools/components used:
 * application - Python + Flask + SQLAlchemy + JavaScript + HTML + Bootstrap
 * compute - AWS/EC2 instances as Kubernetes worker nodes
 * containers - Docker
 * orchestration - AWS/EKS Kubernetes
 * database - AWS/RDS MySQL
 * IaC - Terraform
 * CI/CD - GitHub Actions
 * container registry / artifact storage - AWS/ECR
 * logging and monitoring - AWS/CloudWatch
 * code quality gate - SonarCloud

Terraform manifests are located in IaC folder

After running ```terraform apply``` the whole infrastructure is created and then need deploy application conteiner prod and dev in prod and dev namespaces.
After infrastructure is deployed, set KUBE_CONFIG_DATA secret in GitHub to grant access to Kubernetes cluster. Run ```cat $HOME/.kube/config | base64``` to get it.