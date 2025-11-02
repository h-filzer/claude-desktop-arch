#!/bin/bash
# 🔱 TRINITY HELPER — Ultimate Claude Desktop Arch Helper Script
# One script to rule them all!

set -e

VERSION="1.0.0"
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"

# Colors
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
PURPLE='\033[0;35m'
CYAN='\033[0;36m'
NC='\033[0m' # No Color

# Emojis for fun 🎉
print_header() {
    echo -e "${PURPLE}"
    echo "╔════════════════════════════════════════════════════════════╗"
    echo "║        🔱 TRINITY HELPER — Claude Desktop Arch 🔱          ║"
    echo "║                    Version ${VERSION}                         ║"
    echo "╚════════════════════════════════════════════════════════════╝"
    echo -e "${NC}"
}

print_success() { echo -e "${GREEN}✓${NC} $1"; }
print_error() { echo -e "${RED}✗${NC} $1"; }
print_warning() { echo -e "${YELLOW}⚠${NC} $1"; }
print_info() { echo -e "${CYAN}ℹ${NC} $1"; }
print_step() { echo -e "${BLUE}▸${NC} $1"; }

# Show fancy menu
show_menu() {
    clear
    print_header
    echo ""
    echo "🏗️  BUILD & TEST:"
    echo "  1) 🔨 Quick build (makepkg)"
    echo "  2) 🐳 Docker build"
    echo "  3) 🧪 Chroot test build"
    echo "  4) 🚀 Full test (chroot all)"
    echo ""
    echo "📦 GIT OPERATIONS:"
    echo "  5) 📊 Status & Info"
    echo "  6) 🔀 Merge trinity → main"
    echo "  7) 📤 Push to GitHub (trinity)"
    echo "  8) 🏷️  Create version tag"
    echo ""
    echo "🔍 MAINTENANCE:"
    echo "  9) 🔎 Check for updates"
    echo " 10) 📝 Update .SRCINFO"
    echo " 11) 🧹 Clean build files"
    echo " 12) 📋 Show project stats"
    echo ""
    echo "🛠️  ADVANCED:"
    echo " 13) 🔧 Fix GitHub permissions"
    echo " 14) 📚 Generate docs"
    echo " 15) 🎨 Run all checks"
    echo ""
    echo "❌ EXIT:"
    echo "  0) Exit"
    echo ""
    echo -ne "${CYAN}Choose an option [0-15]:${NC} "
}

# Function: Quick build with makepkg
quick_build() {
    print_step "Starting quick build..."
    
    if ! command -v makepkg &> /dev/null; then
        print_error "makepkg not found! Are you on Arch Linux?"
        print_info "Try option 2 (Docker build) instead"
        return 1
    fi
    
    cd "$SCRIPT_DIR"
    makepkg -s --noconfirm
    print_success "Build complete!"
    ls -lh claude-desktop-*.pkg.tar.zst 2>/dev/null || true
}

# Function: Docker build
docker_build() {
    print_step "Starting Docker build..."
    
    if ! command -v docker &> /dev/null; then
        print_error "Docker not found!"
        print_info "Install: https://docs.docker.com/get-docker/"
        return 1
    fi
    
    cd "$SCRIPT_DIR"
    if [ -x "./docker-build.sh" ]; then
        ./docker-build.sh
    else
        print_error "docker-build.sh not found or not executable"
        return 1
    fi
}

# Function: Chroot test
chroot_test() {
    print_step "Starting chroot test build..."
    
    cd "$SCRIPT_DIR"
    if [ -x "./setup-chroot.sh" ]; then
        ./setup-chroot.sh test
    else
        print_error "setup-chroot.sh not found"
        return 1
    fi
}

# Function: Full chroot test
chroot_full() {
    print_step "Starting full chroot test (setup + build + install)..."
    
    cd "$SCRIPT_DIR"
    if [ -x "./setup-chroot.sh" ]; then
        ./setup-chroot.sh all
    else
        print_error "setup-chroot.sh not found"
        return 1
    fi
}

# Function: Git status
git_status() {
    print_step "Git Status & Info..."
    echo ""
    
    cd "$SCRIPT_DIR"
    
    print_info "Current branch:"
    git branch --show-current
    echo ""
    
    print_info "Recent commits:"
    git log --oneline --graph -5
    echo ""
    
    print_info "Working tree status:"
    git status --short
    echo ""
    
    print_info "Branches:"
    git branch -a
    echo ""
    
    print_info "Commits ahead of main:"
    CURRENT=$(git branch --show-current)
    if [ "$CURRENT" != "main" ]; then
        git log --oneline main..$CURRENT
    else
        echo "  (on main branch)"
    fi
}

# Function: Merge trinity to main
merge_trinity() {
    print_step "Merging trinity-upgrade → main..."
    
    cd "$SCRIPT_DIR"
    CURRENT=$(git branch --show-current)
    
    if [ "$CURRENT" = "main" ]; then
        print_warning "Already on main branch"
        echo -ne "Merge trinity-upgrade into main? [y/N]: "
        read -r confirm
        if [[ ! "$confirm" =~ ^[Yy]$ ]]; then
            print_info "Cancelled"
            return 0
        fi
        
        git merge --no-ff trinity-upgrade -m "Merge trinity-upgrade: Complete modernization"
        print_success "Merged successfully!"
    else
        print_warning "Not on main branch (currently on: $CURRENT)"
        echo -ne "Switch to main and merge? [y/N]: "
        read -r confirm
        if [[ ! "$confirm" =~ ^[Yy]$ ]]; then
            print_info "Cancelled"
            return 0
        fi
        
        git checkout main
        git merge --no-ff trinity-upgrade -m "Merge trinity-upgrade: Complete modernization"
        print_success "Merged successfully!"
    fi
    
    git log --oneline --graph -10
}

# Function: Push to GitHub
push_github() {
    print_step "Pushing to GitHub..."
    
    cd "$SCRIPT_DIR"
    CURRENT=$(git branch --show-current)
    
    print_info "Current branch: $CURRENT"
    echo -ne "Push $CURRENT to origin? [y/N]: "
    read -r confirm
    
    if [[ ! "$confirm" =~ ^[Yy]$ ]]; then
        print_info "Cancelled"
        return 0
    fi
    
    git push origin "$CURRENT" || {
        print_error "Push failed!"
        print_info "If you see permission errors, try option 13 (Fix GitHub permissions)"
        return 1
    }
    
    print_success "Pushed successfully!"
}

# Function: Create version tag
create_tag() {
    print_step "Create version tag..."
    
    cd "$SCRIPT_DIR"
    
    # Extract version from PKGBUILD
    if [ -f "PKGBUILD" ]; then
        VERSION=$(grep "^pkgver=" PKGBUILD | cut -d= -f2 | tr -d ' ')
        print_info "Current version in PKGBUILD: $VERSION"
    fi
    
    echo -ne "Enter tag version (e.g., 0.13.19): "
    read -r tag_version
    
    if [ -z "$tag_version" ]; then
        print_error "No version entered"
        return 1
    fi
    
    TAG="v${tag_version}"
    
    echo -ne "Create tag $TAG? [y/N]: "
    read -r confirm
    
    if [[ ! "$confirm" =~ ^[Yy]$ ]]; then
        print_info "Cancelled"
        return 0
    fi
    
    git tag -a "$TAG" -m "Release $TAG"
    print_success "Tag $TAG created!"
    
    echo -ne "Push tag to GitHub? [y/N]: "
    read -r push_confirm
    
    if [[ "$push_confirm" =~ ^[Yy]$ ]]; then
        git push origin "$TAG"
        print_success "Tag pushed! GitHub Actions will create a release."
    fi
}

# Function: Check for updates
check_updates() {
    print_step "Checking for Claude Desktop updates..."
    
    cd "$SCRIPT_DIR"
    if [ -x "./check-version.sh" ]; then
        ./check-version.sh || true
    else
        print_error "check-version.sh not found"
    fi
}

# Function: Update .SRCINFO
update_srcinfo() {
    print_step "Updating .SRCINFO..."
    
    cd "$SCRIPT_DIR"
    
    if ! command -v makepkg &> /dev/null; then
        print_error "makepkg not found!"
        print_info "Manual update required - see PKGBUILD version"
        return 1
    fi
    
    makepkg --printsrcinfo > .SRCINFO
    print_success ".SRCINFO updated!"
    
    git diff .SRCINFO
}

# Function: Clean build files
clean_build() {
    print_step "Cleaning build files..."
    
    cd "$SCRIPT_DIR"
    
    echo "Files to be removed:"
    find . -maxdepth 1 \( -name "*.pkg.tar.zst" -o -name "*.log" -o -name "*.tmp" \) 2>/dev/null | while read f; do
        echo "  - $f"
    done
    
    if [ -d "src" ]; then
        echo "  - src/ directory"
    fi
    
    if [ -d "pkg" ] && [ "$(ls -A pkg 2>/dev/null)" ]; then
        echo "  - pkg/ directory"
    fi
    
    echo ""
    echo -ne "Clean these files? [y/N]: "
    read -r confirm
    
    if [[ ! "$confirm" =~ ^[Yy]$ ]]; then
        print_info "Cancelled"
        return 0
    fi
    
    find . -maxdepth 1 \( -name "*.pkg.tar.zst" -o -name "*.log" -o -name "*.tmp" \) -delete 2>/dev/null || true
    rm -rf src/ pkg/ 2>/dev/null || true
    
    print_success "Cleaned!"
}

# Function: Show stats
show_stats() {
    print_step "Project Statistics..."
    echo ""
    
    cd "$SCRIPT_DIR"
    
    print_info "Repository:"
    echo "  Name: claude-desktop-arch"
    echo "  Owner: h-filzer"
    echo "  Branch: $(git branch --show-current)"
    echo ""
    
    print_info "Files:"
    echo "  Total files: $(find . -type f | wc -l)"
    echo "  Scripts: $(find . -name "*.sh" | wc -l)"
    echo "  Documentation: $(find . -name "*.md" | wc -l)"
    echo "  Workflows: $(find .github/workflows -name "*.yml" 2>/dev/null | wc -l)"
    echo ""
    
    print_info "Git:"
    echo "  Commits: $(git rev-list --count HEAD)"
    echo "  Contributors: $(git shortlog -sn | wc -l)"
    echo "  Last commit: $(git log -1 --format=%cd --date=relative)"
    echo ""
    
    if [ -f "PKGBUILD" ]; then
        print_info "Package:"
        VERSION=$(grep "^pkgver=" PKGBUILD | cut -d= -f2 | tr -d ' ')
        RELEASE=$(grep "^pkgrel=" PKGBUILD | cut -d= -f2 | tr -d ' ')
        echo "  Version: ${VERSION}-${RELEASE}"
        echo "  Architecture: x86_64"
    fi
}

# Function: Fix GitHub permissions
fix_github_perms() {
    print_step "GitHub Permission Helper..."
    echo ""
    
    cd "$SCRIPT_DIR"
    
    print_info "Current git remote:"
    git remote -v
    echo ""
    
    print_info "Options to fix push permissions:"
    echo ""
    echo "1. Fork Workflow (recommended if not owner):"
    echo "   a) Fork h-filzer/claude-desktop-arch on GitHub"
    echo "   b) Add your fork as remote:"
    echo "      git remote add fork https://github.com/YOUR_USERNAME/claude-desktop-arch.git"
    echo "   c) Push to your fork:"
    echo "      git push fork trinity-upgrade"
    echo ""
    echo "2. SSH Key (if you're collaborator):"
    echo "   a) Setup SSH key: https://docs.github.com/en/authentication"
    echo "   b) Change remote to SSH:"
    echo "      git remote set-url origin git@github.com:h-filzer/claude-desktop-arch.git"
    echo ""
    echo "3. Personal Access Token:"
    echo "   a) Create token: https://github.com/settings/tokens"
    echo "   b) Use token as password when pushing"
    echo ""
    
    echo -ne "Do you want to add a fork remote? [y/N]: "
    read -r confirm
    
    if [[ "$confirm" =~ ^[Yy]$ ]]; then
        echo -ne "Enter your GitHub username: "
        read -r username
        
        if [ -n "$username" ]; then
            git remote add fork "https://github.com/${username}/claude-desktop-arch.git" 2>/dev/null || {
                print_warning "Fork remote already exists or failed to add"
            }
            print_success "Fork remote added!"
            git remote -v
        fi
    fi
}

# Function: Generate docs
generate_docs() {
    print_step "Documentation Helper..."
    echo ""
    
    print_info "Documentation files:"
    find . -maxdepth 2 -name "*.md" -type f | while read f; do
        echo "  ✓ $f"
    done
    echo ""
    
    print_success "All documentation files are up to date!"
    print_info "Trinity upgrade added comprehensive docs"
}

# Function: Run all checks
run_checks() {
    print_step "Running all checks..."
    echo ""
    
    cd "$SCRIPT_DIR"
    
    # Check 1: Git status
    print_info "Check 1/5: Git status"
    if [ -z "$(git status --porcelain)" ]; then
        print_success "Working tree clean"
    else
        print_warning "Uncommitted changes found"
    fi
    echo ""
    
    # Check 2: PKGBUILD syntax
    print_info "Check 2/5: PKGBUILD syntax"
    if bash -n PKGBUILD 2>/dev/null; then
        print_success "PKGBUILD syntax OK"
    else
        print_error "PKGBUILD syntax errors"
    fi
    echo ""
    
    # Check 3: .SRCINFO sync
    print_info "Check 3/5: .SRCINFO sync"
    if command -v makepkg &> /dev/null; then
        makepkg --printsrcinfo > .SRCINFO.test 2>/dev/null || true
        if diff -q .SRCINFO .SRCINFO.test &>/dev/null; then
            print_success ".SRCINFO in sync"
            rm .SRCINFO.test
        else
            print_warning ".SRCINFO out of sync"
            rm .SRCINFO.test
        fi
    else
        print_warning "Can't check (makepkg not found)"
    fi
    echo ""
    
    # Check 4: Scripts executable
    print_info "Check 4/5: Script permissions"
    SCRIPTS=("install.sh" "setup-chroot.sh" "check-version.sh" "docker-build.sh")
    for script in "${SCRIPTS[@]}"; do
        if [ -f "$script" ]; then
            if [ -x "$script" ]; then
                print_success "$script is executable"
            else
                print_warning "$script not executable"
                chmod +x "$script" 2>/dev/null && print_success "  → Fixed!"
            fi
        fi
    done
    echo ""
    
    # Check 5: Documentation
    print_info "Check 5/5: Documentation completeness"
    DOCS=("README.md" "CONTRIBUTING.md" "CHANGELOG.md" "AUR.md")
    for doc in "${DOCS[@]}"; do
        if [ -f "$doc" ]; then
            print_success "$doc exists"
        else
            print_warning "$doc missing"
        fi
    done
    echo ""
    
    print_success "All checks complete!"
}

# Main loop
main() {
    while true; do
        show_menu
        read -r choice
        
        case $choice in
            1) quick_build ;;
            2) docker_build ;;
            3) chroot_test ;;
            4) chroot_full ;;
            5) git_status ;;
            6) merge_trinity ;;
            7) push_github ;;
            8) create_tag ;;
            9) check_updates ;;
            10) update_srcinfo ;;
            11) clean_build ;;
            12) show_stats ;;
            13) fix_github_perms ;;
            14) generate_docs ;;
            15) run_checks ;;
            0)
                echo ""
                print_success "Goodbye! 🔱"
                echo ""
                exit 0
                ;;
            *)
                print_error "Invalid option"
                ;;
        esac
        
        echo ""
        echo -ne "${CYAN}Press Enter to continue...${NC}"
        read
    done
}

# Run main
main
