# Use the official .NET SDK image to build the application
FROM mcr.microsoft.com/dotnet/sdk:8.0-bookworm-slim AS build-env
WORKDIR /app

# Copy the csproj and restore as distinct layers
COPY *.csproj ./
RUN dotnet restore

# Copy the rest of the application and build it
COPY . ./
RUN dotnet publish DotNetFIPSChecker.csproj -c Release -o out


# Now that we built the application, we can copy it all over to the runtime image.
FROM mcr.microsoft.com/dotnet/sdk:8.0-bookworm-slim AS fips-env
COPY --from=build-env /app/out .

# Now, lets prep the image to download the OpenSSL source code and build it.
RUN apt-get update
RUN apt-get install -y --no-install-recommends build-essential
RUN apt-get install -y wget
RUN apt-get install -y libssl-dev
RUN rm -rf /var/lib/apt/lists/*

# Download the OpenSSL source code
# As of this writing, the latest version is 3.0.9
# https://openssl-library.org/source/
RUN wget https://www.openssl.org/source/openssl-3.0.9.tar.gz

# Extract the source code
RUN tar -xf openssl-3.0.9.tar.gz

# Build OpenSSL
RUN ./openssl-3.0.9/Configure enable-fips
RUN make
RUN make install_fips

# DELETE the unneeded tar file.
RUN rm -rf openssl-3.0.9.tar.gz

# set the FIPS mode
RUN openssl fipsinstall -out /usr/local/ssl/fipsmodule.cnf -module /usr/local/lib64/ossl-modules/fips.so

# Copy some files over
RUN mv /usr/local/ssl/fipsmodule.cnf /etc/ssl
RUN ln -s /etc/ssl/fipsmodule.cnf /usr/lib/ssl
RUN cp /usr/local/lib64/ossl-modules/fips.so /etc/ssl

# Update the fips module configuration file.
RUN sed -i 's|^# \.include fipsmodule\.cnf|\.include /usr/local/ssl/fipsmodule\.cnf|' /etc/ssl/openssl.cnf

# Set the FIPS environment variable
ENV OPENSSL_FIPS=1
ENV OPENSSL_CONF=/etc/ssl/openssl.cnf
ENV OPENSSL_CONF_INCLUDE=/etc/ssl/fipsmodule.cnf

# Set the entry point for the Docker container
ENTRYPOINT ["dotnet", "DotNetFIPSChecker.dll"]