FROM eclipse-temurin:17-jre-alpine

LABEL maintainer="NovaFlow Team"
LABEL description="NovaFlow Generic Action Runner - API execution sidecar service"

# Create non-root user
RUN addgroup -g 1001 -S novaflow && \
    adduser -u 1001 -S novaflow -G novaflow

# Create directories for file operations
RUN mkdir -p /data/input /data/output /tmp && \
    chown -R novaflow:novaflow /data /tmp

WORKDIR /app

# Copy application JAR
COPY --chown=novaflow:novaflow target/api-action-runner-1.0.0.jar app.jar

# Switch to non-root user
USER novaflow

# Expose default port
EXPOSE 8095

# Health check
HEALTHCHECK --interval=30s --timeout=10s --start-period=30s --retries=3 \
    CMD wget --no-verbose --tries=1 --spider http://localhost:8095/actuator/health || exit 1

# Run application
ENTRYPOINT ["java", \
    "-XX:+UseContainerSupport", \
    "-XX:MaxRAMPercentage=75.0", \
    "-Djava.security.egd=file:/dev/./urandom", \
    "-jar", "app.jar"]
