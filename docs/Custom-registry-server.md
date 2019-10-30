This document explains how to host a custom registry server (Docker v2) and then
push and pull windows docker images from a client windows machine.

### Requirements

* A linux machine to host the custom registry server (call it shemp and has the
IP addr `10.55.6.120`)

* A windows machine to push/pull the images from the custom registry server
(call it dev-box-vm)

* docker installed on both machines

### Run the server on the linux machine

```bash
docker run -d -p 5000:5000 --restart=always --name registry registry:2
```

This will serve the registry server at `localhost:5000`.

See you can access the catalog of images using localhost or its ip address:

```bash
curl http://10.55.6.120:5000/v2/_catalog
```

For more info, see: https://docs.docker.com/registry/deploying/

Now you have a custom registry server at `10.55.6.120:5000`.


### Use the server from a windows client

##### Pull down the original image from Docker Hub to the dev-box-vm

```
docker pull cloudfoundry/windows2016fs:2019.0.28
```

##### Tag the image with a new name containing hostname/port of the custom registry

```
docker tag cloudfoundry/windows2016fs:2019.0.28 10.55.6.120:5000/windows2016fs-local
```

##### Make sure the registry server is up and running, and accessible

```
curl.exe http://10.55.6.120:5000/v2/_catalog
```

##### Push to the custom registry server - should fail due to an http response (Meh!)

```
docker push 10.55.6.120:5000/windows2016fs-local
```

##### Setup the custom registry server in the docker client config

Write/append the following to `C:\ProgramData\docker\config\daemon.json`.

It should be exactly the same as follows.
Apparently docker is not kind to whitespace changes in json.

```
{
	"insecure-registries": ["10.55.6.120:5000"],
	"allow-nondistributable-artifacts": ["10.55.6.120:5000"]
}

```

**WARNING**: Make sure you are in compliance with any terms that cover
redistributing non-distributable artifacts. Hmm.

```
Restart-Service Docker
```

##### Push with everything ready

```
docker push 10.55.6.120:5000/windows2016fs-local
```


##### Clear up everything to try a pull from the custom registry server

```
docker image remove cloudfoundry/windows2016fs:2019.0.28
docker image remove 10.55.6.120:5000/windows2016fs-local
```

#####  Fresh pull from custom registry server

```
docker pull 10.55.6.120:5000/windows2016fs-local
```


##### Voila

```
docker images
```

