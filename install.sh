#!/usr/bin/env bash
set -e

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
NC='\033[0m' # No Color

echo -e "${GREEN}Installing ffff...${NC}"

# Clone the repository
git clone https://github.com/anbe-on/ffff.git ffff-temp
cd ffff-temp

# Install ffff (this will prompt for sudo if needed)
echo -e "${YELLOW}Installing ffff binary (may require sudo)...${NC}"
if ! make install; then
    echo -e "${RED}Failed to install ffff. Trying with sudo...${NC}"
    sudo make install
fi

cd ..
rm -rf ffff-temp

CONFIG="$HOME/.bashrc"

echo -e "${YELLOW}Adding f() function to $CONFIG...${NC}"

# Create the config file if it doesn't exist
if [[ ! -f "$CONFIG" ]]; then
    echo -e "${YELLOW}Creating $CONFIG...${NC}"
    touch "$CONFIG"
fi

# Check if the function already exists
if ! grep -Fq 'f() {' "$CONFIG"; then
    cat << 'EOF' >> "$CONFIG"

# Add this to your .bashrc, .zshrc or equivalent.
# Run 'fff' with 'f' or whatever you decide to name the function.
# added append cd history into bash_history
f() {
    local prev_dir="$PWD"
    local cache_dir="${XDG_CACHE_HOME:-$HOME/.cache}/fff"
    fff "$@"
    local new_dir
    new_dir="$(cat "$cache_dir/.fff_d")"
    if [[ "$new_dir" != "$prev_dir" ]]; then
        cd "$new_dir"
        # Save current history to file
        history -a
        history -s "cd $PWD"
        # Append 'cd <path>' command to history file
        shopt -s histappend
        history -w "$HISTFILE"
    fi
}
EOF
    echo -e "${GREEN}Added f() function to $CONFIG${NC}"
else
    echo -e "${YELLOW}f() function already exists in $CONFIG${NC}"
fi

echo -e "${GREEN}Installation complete!${NC}"
echo -e "${YELLOW}Please run 'source $CONFIG' or restart your terminal to use the 'f' command.${NC}"

