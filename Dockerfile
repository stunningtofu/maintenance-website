FROM nginx:1.27.0-alpine

ARG GITHUB_REPOSITORY="unknown"

LABEL org.opencontainers.image.title="Maintenance Website" \
      org.opencontainers.image.description="Professional maintenance landing page" \
      org.opencontainers.image.source="https://github.com/${GITHUB_REPOSITORY}"

# Copy the custom configuration and content
COPY nginx.conf /etc/nginx/conf.d/default.conf
COPY index.html /usr/share/nginx/html/

# Install curl for healthcheck and configure non-root user permissions
RUN apk add --no-cache curl && \
    touch /var/run/nginx.pid && \
    chown -R nginx:nginx /var/run/nginx.pid /var/cache/nginx /var/log/nginx /etc/nginx/conf.d /usr/share/nginx/html

# Switch to the non-root user
USER nginx

# Health check
HEALTHCHECK --interval=30s --timeout=5s --start-period=5s --retries=3 \
    CMD curl -f http://localhost:8080/health || exit 1

# Expose the non-privileged port
EXPOSE 8080

CMD ["nginx", "-g", "daemon off;"]