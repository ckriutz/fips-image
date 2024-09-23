# fips-image
A Dockerfile that will create a FIPS Complient image. Contained in this is a simple console application that will attempt to use the md5 hash.

If this container is FIPS complient, it should not run successfully.

## Expectations
This application is used to test a FIPS complient docker image for dotnet appliations.


## Verification
✅ Running the verify command inside the container
```
# openssl fipsinstall -verify -module /usr/local/lib64/ossl-modules/fips.so -in /etc/ssl/fipsmodule.cnf;
```
returns the result:
```
VERIFY PASSED
```

Running the project to see if it will generate an md5 hash fails.


## Resources:
https://github.com/openssl/openssl/blob/master/README-FIPS.md

https://github.com/bradynpoulsen/openssl-fips-debian-docker

https://github.com/arhea/docker-fips-library