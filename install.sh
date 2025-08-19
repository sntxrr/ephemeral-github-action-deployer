#!/bin/bash

# Ephemeral Github Actions Deployer - Installation Script
# This script helps you set up the deployment pattern on your system

set -e

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

# Function to print colored output
print_status() {
    echo -e "${BLUE}[INFO]${NC} $1"
}

print_success() {
    echo -e "${GREEN}[SUCCESS]${NC} $1"
}

print_warning() {
    echo -e "${YELLOW}[WARNING]${NC} $1"
}

print_error() {
    echo -e "${RED}[ERROR]${NC} $1"
}

# Function to check if command exists
command_exists() {
    command -v "$1" >/dev/null 2>&1
}

# Function to check if running on macOS
is_macos() {
    [[ "$OSTYPE" == "darwin"* ]]
}

# Function to check if running on Linux
is_linux() {
    [[ "$OSTYPE" == "linux-gnu"* ]]
}

# Function to install dependencies
install_dependencies() {
    print_status "Installing dependencies..."
    
    if is_macos; then
        if ! command_exists brew; then
            print_status "Installing Homebrew..."
            /bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)"
        fi
        
        print_status "Installing packages via Homebrew..."
        brew install node docker docker-compose git
        
    elif is_linux; then
        if command_exists apt-get; then
            print_status "Installing packages via apt..."
            sudo apt-get update
            sudo apt-get install -y curl git
            
            # Install Node.js
            if ! command_exists node; then
                print_status "Installing Node.js..."
                curl -fsSL https://deb.nodesource.com/setup_18.x | sudo -E bash -
                sudo apt-get install -y nodejs
            fi
            
            # Install Docker
            if ! command_exists docker; then
                print_status "Installing Docker..."
                curl -fsSL https://get.docker.com -o get-docker.sh
                sudo sh get-docker.sh
                sudo usermod -aG docker $USER
                print_warning "Docker installed. Please logout and login again for group changes to take effect."
            fi
            
        elif command_exists yum; then
            print_status "Installing packages via yum..."
            sudo yum install -y curl git
            
            # Install Node.js
            if ! command_exists node; then
                print_status "Installing Node.js..."
                curl -fsSL https://rpm.nodesource.com/setup_18.x | sudo bash -
                sudo yum install -y nodejs
            fi
            
        else
            print_error "Unsupported Linux distribution. Please install dependencies manually."
            return 1
        fi
    else
        print_error "Unsupported operating system. Please install dependencies manually."
        return 1
    fi
    
    print_success "Dependencies installed successfully!"
}

# Function to check dependencies
check_dependencies() {
    print_status "Checking dependencies..."
    
    local missing_deps=()
    
    if ! command_exists node; then
        missing_deps+=("node")
    fi
    
    if ! command_exists npm; then
        missing_deps+=("npm")
    fi
    
    if ! command_exists git; then
        missing_deps+=("git")
    fi
    
    if [ ${#missing_deps[@]} -ne 0 ]; then
        print_error "Missing dependencies: ${missing_deps[*]}"
        print_status "Installing missing dependencies..."
        install_dependencies
    else
        print_success "All dependencies are installed!"
    fi
}

# Function to setup project
setup_project() {
    print_status "Setting up project..."
    
    # Install Node.js dependencies
    if [ -f "package.json" ]; then
        print_status "Installing Node.js dependencies..."
        npm install
        print_success "Node.js dependencies installed!"
    fi
    
    # Check if .env file exists
    if [ ! -f ".env" ]; then
        print_status "Creating .env file..."
        cat > .env << EOF
# Environment variables for local development
# Copy this file and update with your values
TAILSCALE_HOST=your-traefik-host
TAILSCALE_IP=100.64.0.0
TARGET_USER=your-username
NTFY_API_KEY=your-ntfy-api-key
EOF
        print_success ".env file created! Please update it with your values."
    fi
    
    # Check if web network exists
    if command_exists docker; then
        if ! docker network ls | grep -q "web"; then
            print_status "Creating 'web' Docker network..."
            docker network create web
            print_success "Docker network 'web' created!"
        else
            print_success "Docker network 'web' already exists!"
        fi
    fi
}

# Function to run validation
run_validation() {
    print_status "Running validation checks..."
    
    if [ -f "Makefile" ]; then
        print_status "Running ShellCheck..."
        if command_exists shellcheck; then
            make shellcheck || print_warning "ShellCheck found issues. Please review."
        else
            print_warning "ShellCheck not installed. Skipping shell script validation."
        fi
        
        print_status "Validating YAML files..."
        if command_exists yamllint; then
            make validate-yaml || print_warning "YAML validation found issues. Please review."
        else
            print_warning "yamllint not installed. Skipping YAML validation."
        fi
        
        print_status "Validating Docker Compose..."
        if command_exists docker-compose; then
            make validate-docker || print_warning "Docker Compose validation found issues. Please review."
        else
            print_warning "docker-compose not installed. Skipping Docker validation."
        fi
    fi
    
    print_success "Validation completed!"
}

# Function to show next steps
show_next_steps() {
    echo
    print_success "Installation completed successfully!"
    echo
    echo "Next steps:"
    echo "1. Update the .env file with your configuration"
    echo "2. Configure GitHub secrets for your repository"
    echo "3. Customize the examples for your environment"
    echo "4. Test the deployment pattern"
    echo
    echo "For detailed instructions, see:"
    echo "- README.md - Main documentation"
    echo "- DEPLOYMENT.md - Complete setup guide"
    echo "- examples/ - Working examples"
    echo
    echo "To start development:"
    echo "  npm run dev          # Start development server"
    echo "  npm run build        # Build for production"
    echo "  make help            # Show available make commands"
    echo
}

# Main installation function
main() {
    echo "🚀 EGAD - Ephemeral GitHub Action Deployer - Installation Script"
    echo "================================================================"
    echo
    
    # Check if running as root
    if [[ $EUID -eq 0 ]]; then
        print_error "This script should not be run as root!"
        exit 1
    fi
    
    # Check dependencies
    check_dependencies
    
    # Setup project
    setup_project
    
    # Run validation
    run_validation
    
    # Show next steps
    show_next_steps
}

# Run main function
main "$@"
