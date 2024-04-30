#!/bin/bash

# Define the installation directory
INSTALL_DIR="/opt/correct_script.server"

# GitHub repository details
REPO="iyubondyrev/correct_script.server"

# GitHub API URL for the latest release
API_URL="https://api.github.com/repos/$REPO/releases/latest"

# GGUF Model URL
MODEL_URL="https://huggingface.co/iyubondyrev/phi_3_mini_quantized/resolve/main/phi_3_mini_q2.gguf?download=true"

# Create installation directory
echo "Creating installation directory at $INSTALL_DIR..."
sudo mkdir -p "$INSTALL_DIR"
sudo chown $(whoami) "$INSTALL_DIR"

# Fetch the latest release data from GitHub
echo "Fetching latest release from GitHub..."
release_data=$(curl -s "$API_URL")

# Parse the release data to get the asset download URLs
server_jar_url=$(echo "$release_data" | grep "browser_download_url" | grep "correct_script.server.jar" | cut -d '"' -f 4)
config_url=$(echo "$release_data" | grep "browser_download_url" | grep "config.yaml" | cut -d '"' -f 4)
initial_prompt_url=$(echo "$release_data" | grep "browser_download_url" | grep "initial_prompt.txt" | cut -d '"' -f 4)
server_script_url=$(echo "$release_data" | grep "browser_download_url" | grep "correct_script-server.sh" | cut -d '"' -f 4)

# Download files
echo "Downloading server artifacts..."
curl -L "$server_jar_url" -o "$INSTALL_DIR/correct_script.server.jar"
curl -L "$config_url" -o "$INSTALL_DIR/config.yaml"
curl -L "$initial_prompt_url" -o "$INSTALL_DIR/initial_prompt.txt"
curl -L "$server_script_url" -o "$INSTALL_DIR/correct_script-server.sh"

# Ask user if they want to download the GGUF model
echo "Do you want to download the GGUF model for the server? (yes/no)"
read download_model

if [ "$download_model" = "yes" ]; then
    echo "Downloading GGUF model..."
    curl -L "$MODEL_URL" -o "$INSTALL_DIR/phi_3_mini_q2.gguf"
fi

# Make the server script executable and rename it
echo "Making server script executable..."
chmod +x "$INSTALL_DIR/correct_script-server.sh"
mv "$INSTALL_DIR/correct_script-server.sh" "$INSTALL_DIR/correct_script-server"

# Add to PATH by placing a symlink in /usr/local/bin
echo "Adding server script to PATH..."
sudo ln -s "$INSTALL_DIR/correct_script-server" /usr/local/bin/correct_script-server

mkdir /var/log/correct_script.server

echo "Installation completed successfully."
echo "You can find everything in $INSTALL_DIR."
