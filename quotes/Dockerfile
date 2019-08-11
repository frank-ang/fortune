############################
# STEP 1 build executable binary
############################
FROM golang:alpine AS builder
# Install git.
# Git is required for fetching the dependencies.
RUN apk update && apk add --no-cache git

# Set the Current Working Directory inside the container
WORKDIR /app

# Download all dependencies.
COPY go.mod go.sum ./
COPY handler/* ./handler/
COPY main.go ./
RUN go mod download

# Build the Go app for target architecture
ENV GO111MODULE=on
RUN CGO_ENABLED=0 GOOS=linux go build -o quotes 

############################
# STEP 2 build a small image
############################
FROM scratch

# Copy our static executable.
COPY --from=builder /app/quotes /app/quotes

# Binary to run
ENTRYPOINT ["/app/quotes"]

# Expose port 8080 to the outside world
EXPOSE 8080
