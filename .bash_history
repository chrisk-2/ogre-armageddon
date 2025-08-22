cd
# === OGRE UBUNTU BOOTSTRAP ===
set -euxo pipefail
# 0) Fast updates
sudo apt-get update -y
sudo apt-get dist-upgrade -y
# 1) Essentials + security
sudo apt-get install -y   curl wget git jq unzip zip rsync htop net-tools nmap ufw fail2ban   build-essential pkg-config cmake ninja-build   openssh-server ca-certificates gnupg lsb-release   python3 python3-pip python3-venv python3-dev python3-setuptools   ffmpeg vlc gstreamer1.0-tools gstreamer1.0-plugins-{base,good,bad,ugly}   libssl-dev libffi-dev libxml2-dev libxslt1-dev zlib1g-dev   avahi-daemon mdns-scan   minicom screen putty-tools   smartmontools parted dosfstools xz-utils kpartx qemu-user-static binfmt-support
# 2) SSH hardening: move to 2222, key-only
sudo sed -ri 's/^#?Port .*/Port 2222/' /etc/ssh/sshd_config
sudo sed -ri 's/^#?PasswordAuthentication .*/PasswordAuthentication no/' /etc/ssh/sshd_config
sudo sed -ri 's/^#?ChallengeResponseAuthentication .*/ChallengeResponseAuthentication no/' /etc/ssh/sshd_config
sudo sed -ri 's/^#?PermitRootLogin .*/PermitRootLogin no/' /etc/ssh/sshd_config
sudo systemctl enable --now ssh
# 3) Firewall sane defaults + dev ports (2222 ssh, 3000 react, 5000 flask, 8000 misc, 8554 rtsp)
sudo ufw default deny incoming
sudo ufw default allow outgoing
sudo ufw allow 2222/tcp
sudo ufw allow 3000/tcp
sudo ufw allow 5000/tcp
sudo ufw allow 8000/tcp
sudo ufw allow 8554/tcp
yes | sudo ufw enable
# 4) Docker Engine + Compose plugin (Ubuntu repo is fine/stable)
sudo apt-get install -y docker.io docker-buildx-plugin docker-compose-plugin
sudo systemctl enable --now docker
sudo usermod -aG docker "$USER"
# 5) Node.js LTS (via Nodesource 20.x)
curl -fsSL https://deb.nodesource.com/setup_20.x | sudo -E bash -
sudo apt-get install -y nodejs
npm --version
node --version
# 6) Python ergonomics
python3 -m pip install --upgrade pip wheel pipx
python3 -m pipx ensurepath || true
# 7) Fail2ban minimal jail for sshd (protect 2222)
sudo bash -c 'cat >/etc/fail2ban/jail.d/sshd.local <<EOF
[sshd]
enabled = true
port = 2222
maxretry = 5
findtime = 10m
bantime = 1h
EOF'
sudo systemctl restart fail2ban
# 8) Avahi (handy for .local discovery)
sudo systemctl enable --now avahi-daemon
# 9) Serial access & USB permissions (for TTL tools)
sudo usermod -aG dialout "$USER"
sudo usermod -aG plugdev "$USER" || true
echo "=== Bootstrap complete. Reboot recommended to finalize groups ==="
# On this Ubuntu box:
ssh-keygen -t ed25519 -a 100 -f ~/.ssh/id_ed25519 -N ""
eval "$(ssh-agent -s)"
ssh-add ~/.ssh/id_ed25519
cat ~/.ssh/id_ed25519.pub
cat >> ~/.ssh/config <<'EOF'
Host ogre-brain
  HostName 127.0.0.1
  Port 2222
  User ogre
  IdentityFile ~/.ssh/id_ed25519
  ServerAliveInterval 30
  ServerAliveCountMax 6
EOF

chmod 600 ~/.ssh/config
ssh -p 2222 ogre@localhost -o PreferredAuthentications=publickey -o PasswordAuthentication=no true
cd ~/ogre-os
git remote -v
git fetch origin
# If remote has a README/init commit, integrate safely:
git pull --rebase origin main || git pull --rebase origin master || true
# Resolve any conflicts now, then:
git push -u origin HEAD
ls
set -euxo pipefail
# 0) Make sure you have a key
[ -f ~/.ssh/id_ed25519 ] || ssh-keygen -t ed25519 -a 100 -f ~/.ssh/id_ed25519 -N ""
# 1) Authorize it for SSH server (same box, same user)
mkdir -p ~/.ssh
chmod 700 ~/.ssh
touch ~/.ssh/authorized_keys
grep -F -q "$(cat ~/.ssh/id_ed25519.pub)" ~/.ssh/authorized_keys || cat ~/.ssh/id_ed25519.pub >> ~/.ssh/authorized_keys
chmod 600 ~/.ssh/authorized_keys
chown -R "$USER:$USER" ~/.ssh
# 2) Ensure sshd is set to accept keys and pointing to the right file
sudo sed -ri 's/^#?PubkeyAuthentication .*/PubkeyAuthentication yes/' /etc/ssh/sshd_config
sudo sed -ri 's|^#?AuthorizedKeysFile .*|AuthorizedKeysFile %h/.ssh/authorized_keys|' /etc/ssh/sshd_config
sudo systemctl restart ssh
# 3) Test with explicit identity (bypasses agent weirdness)
ssh -p 2222 -i ~/.ssh/id_ed25519 -o IdentitiesOnly=yes -o PreferredAuthentications=publickey -o PasswordAuthentication=no ogre@localhost true && echo "SSH key login OK"
cat >> ~/.ssh/config <<'EOF'
Host ogre-brain
  HostName localhost
  Port 2222
  User ogre
  IdentityFile ~/.ssh/id_ed25519
  IdentitiesOnly yes
  ServerAliveInterval 30
  ServerAliveCountMax 6
EOF

chmod 600 ~/.ssh/config
set -euxo pipefail
# Create keypair if missing
[ -f ~/.ssh/id_ed25519 ] || ssh-keygen -t ed25519 -a 100 -f ~/.ssh/id_ed25519 -N ""
# Authorize your own public key
mkdir -p ~/.ssh
chmod 700 ~/.ssh
grep -F -q "$(cat ~/.ssh/id_ed25519.pub)" ~/.ssh/authorized_keys 2>/dev/null || cat ~/.ssh/id_ed25519.pub >> ~/.ssh/authorized_keys
chmod 600 ~/.ssh/authorized_keys
chown -R "$USER:$USER" ~/.ssh
chmod 755 ~
# Ensure sshd accepts keys and uses the right file
sudo sed -ri 's/^#?PubkeyAuthentication .*/PubkeyAuthentication yes/' /etc/ssh/sshd_config
sudo sed -ri 's|^#?AuthorizedKeysFile .*|AuthorizedKeysFile %h/.ssh/authorized_keys|' /etc/ssh/sshd_config
sudo systemctl restart ssh
# Test with explicit identity
ssh -p 2222 -i ~/.ssh/id_ed25519 -o IdentitiesOnly=yes   -o PreferredAuthentications=publickey -o PasswordAuthentication=no   ogre@localhost true && echo "SSH key login OK"
# A) Print your public key (copy this to GitHub → Settings → SSH and GPG keys)
cat ~/.ssh/id_ed25519.pub
# B) Test GitHub SSH (accept their host key when prompted)
ssh -T git@github.com || true
# C) Global git identity (if not set)
git config --global user.name "Ogre"
git config --global user.email "you@example.com"
# D) Make sure the remote uses SSH (not https)
cd ~/ogre-os
# C) Global git identity (if not set)
git config --global user.name "Ogre"
git config --global user.email "you@example.com"
# D) Make sure the remote uses SSH (not https)
cd ~/ogre-os
git remote remove origin 2>/dev/null || true
git remote add origin git@github.com:chrisk-2/ogre-os.git
# E) Fetch & reconcile remote (safe path)
git fetch origin
git branch -M main 2>/dev/null || true
git pull --rebase origin main || git pull --rebase origin master || true
# Resolve any conflicts if shown, then:
git push -u origin HEAD
# 0) (Optional) sanity: GitHub SSH works?
ssh -T git@github.com || true
# 1) Just clone it
cd ~
git clone git@github.com:chrisk-2/ogre-os.git
cd ~/ogre-os
git remote -v
cd ~/ogre-os
# Make sure your commits show up under your account (use your real GitHub email)
git config --global user.name  "Ogre"
git config --global user.email "chrisk_2@live.com"   # change if needed
# Minimal useful .gitignore
cat > .gitignore <<'EOF'
.venv/
__pycache__/
node_modules/
.DS_Store
dist/
build/
.env
*.log
EOF

# Quick README touch so we can push something
echo -e "\nBootstrapped on $(date -Iseconds)" >> README.md
git add .gitignore README.md
git commit -m "chore: bootstrap .gitignore and README stamp"
git push -u origin main
# Top-level view + sizes
ls -lah /media/ogre/AI
sudo du -h -d1 /media/ogre/AI | sort -h
# 30 most-recent files (helps spot keepers)
sudo find /media/ogre/AI -xdev -type f -printf '%TY-%Tm-%Td %TH:%TM  %p\n' | sort | tail -n 30
