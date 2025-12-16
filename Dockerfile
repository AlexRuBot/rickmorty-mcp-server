# Build stage
FROM swift:5.9-jammy as builder

WORKDIR /build

COPY Package.swift .
COPY Sources ./Sources

RUN swift package resolve
RUN swift build -c release --static-swift-stdlib

# Runtime stage
FROM ubuntu:jammy

RUN apt-get update && apt-get install -y \
    ca-certificates \
    && rm -rf /var/lib/apt/lists/*

RUN useradd --user-group --create-home --system --skel /dev/null --home-dir /app vapor

WORKDIR /app

COPY --from=builder --chown=vapor:vapor /build/.build/release/RickMortyMCP /app/

USER vapor:vapor

EXPOSE 3000

HEALTHCHECK --interval=30s --timeout=3s --start-period=5s --retries=3 \
    CMD curl --fail http://localhost:3000/health || exit 1

ENTRYPOINT ["./RickMortyMCP"]
