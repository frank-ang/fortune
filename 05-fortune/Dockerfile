############################
# STEP 1 build dependencies into a builder container
############################
FROM golang:alpine AS builder
# Install git.
# Git is required for fetching the dependencies.
RUN apk update && apk add --no-cache git

# Set the Current Working Directory inside the container
WORKDIR /app

# Download all dependencies.
# populate the Golang module cache based on the go.{mod,sum} files. 
COPY go.mod go.sum ./
# Because of how the layer caching system works in Docker, the go mod download 
# command will _ only_ be re-run when the go.mod or go.sum file change 
RUN go mod download

############################
# STEP 2 build the service using the builder container
############################
FROM builder AS service_builder
# Here we copy the rest of the source code
COPY handler/* ./handler/
COPY main.go ./
# Now, Build the Go app for target architecture
ENV GO111MODULE=on
RUN CGO_ENABLED=0 GOOS=linux go build -o fortune
# Add certs to enable trust AWS API endpoints
RUN apk --update add ca-certificates

############################
# STEP 3 copy executable into a small image
############################
FROM scratch

# Copy certs
COPY --from=service_builder /etc/ssl/certs/ca-certificates.crt /etc/ssl/certs/ca-certificates.crt

# Copy our static executable.
COPY --from=service_builder /app/fortune /app/fortune

# Binary to run
ENTRYPOINT ["/app/fortune"]

# Expose port 80 to the outside world
EXPOSE 80

