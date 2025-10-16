# Small image with Bash explicitly installed
FROM alpine:3.20

# Install bash
RUN apk add --no-cache bash

# Use bash as the default shell for subsequent RUN instructions
SHELL ["/bin/bash", "-lc"]

# Start an interactive shell by default (optional)
CMD ["bash"]

