# Fedota Design and Architecture

[Federated learning](https://ai.googleblog.com/2017/04/federated-learning-collaborative.html) is privacy-preserving model training in
heterogeneous, distributed networks. It is a way of collaboratively training a machine learning model using the distributed data on end devices without the need to export sensitive user data to a centralized location.

Fedota is a federated learning (FL) platform that helps researchers and machine learning enthusiasts to come up with innovative solutions to modern day problems by giving them access to train their models on private and sensitive data which is usually hard to get. The platform encourages data owners to participate by
getting personalized benefits of learning from their data without the need for them
to lose control over their private data.

There are two types of users involved:
1. Problem Setter: These are researchers working on various machine learning
problems who may need private user data or data which is not readily available
to them for accomplishing these tasks. A problem setter is responsible for
creating a new problem on the platform and describing format of the data to be
used by end clients for running a given FL task. The problem setter also works
on the model to be trained on these end devices.
2. Data Holders: Data holders can participate in federated learning tasks released
by different problem setters. They can be individuals with the required data for
training a given model or larger organizations like hospitals using medical data for allowing researchers to work on accurate machine learning models. They
are responsible for ensuring that the data is in the format as specified by the
problem setters. They can participate in a particular round of federated learning
by using the docker image for the client devices and passing the formatted data
as a parameter while running the container. The model is loaded and trained
locally on the end device and a checkpoint update is sent to fedota servers for
aggregating the updates sent from different clients.

The architecture of Fedota consists of 3 components
- Webserver
- Federated Learning (FL) infrastructure (Coordinator and selector)
- Clients
<image src="diagrams/fedota-infra.png" width="700">

[Webserver](https://github.com/fedota/fl-webserver) is responsible for interacting with entities or users (problem setters and data holders) that use the platform. For each FL problem, an [Coordinator](https://github.com/fedota/fl-coordinator) service and some [Selector](https://github.com/fedota/fl-selector) services are spawned by the Webserver and all of them are isolated from services of another FL problem. The [Client](https://github.com/fedota/fl-client) software is run by data holders for the Fl problem and interacts with the respective FL infrastructure for carrying out the training in the federated setting.

Details can be found in the respective repositories.

## Setup and Usage

Refer [USAGE.md](USAGE.md)