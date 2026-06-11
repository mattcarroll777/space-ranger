FROM ubuntu:24.04

ARG GODOT_VERSION=4.2.2
ENV DEBIAN_FRONTEND=noninteractive

# Install runtime dependencies required by the Godot Linux editor.
RUN apt-get update && apt-get install -y --no-install-recommends \
    ca-certificates \
    wget \
    unzip \
    libx11-6 \
    libxcursor1 \
    libxinerama1 \
    libxrandr2 \
    libxkbcommon0 \
    libxi6 \
    libxext6 \
    libxrender1 \
    libgl1 \
    libasound2t64 \
    libdbus-1-3 \
    libpulse0 \
    libfontconfig1 \
    libfreetype6 \
    && rm -rf /var/lib/apt/lists/*

# Download the Godot editor binary and place it on PATH.
RUN wget -q -O /tmp/godot.zip \
    "https://github.com/godotengine/godot/releases/download/${GODOT_VERSION}-stable/Godot_v${GODOT_VERSION}-stable_linux.x86_64.zip" \
    && unzip -q /tmp/godot.zip -d /opt/godot \
    && rm -f /tmp/godot.zip \
    && mv /opt/godot/Godot_v${GODOT_VERSION}-stable_linux.x86_64 /usr/local/bin/godot \
    && chmod +x /usr/local/bin/godot

WORKDIR /workspace
ENTRYPOINT ["godot"]
CMD ["--editor", "--path", "/workspace", "--rendering-driver", "opengl3", "--audio-driver", "Dummy"]
