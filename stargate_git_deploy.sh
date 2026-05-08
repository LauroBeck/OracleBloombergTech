#!/bin/bash
# STARGATE GIT DEPLOYMENT | VERSION 2026.05
# TARGET REPO: LauroBeck/OracleBloombergTech

# 1. INITIALIZE & STAGE
git init
git add .
git commit -m "INIT: Stargate Union Joint - 18-Month Bloomberg/Oracle Harvest Logic"

# 2. CONFIGURE REMOTE
git remote add origin https://github.com/LauroBeck/OracleBloombergTech.git
git branch -M main

# 3. PUSH TO MAIN
# Note: Ensure your PAT (Personal Access Token) is configured in your git credential manager
git push -u origin main

echo "-------------------------------------------------------"
echo "DEPLOYMENT SUCCESSFUL: LauroBeck/OracleBloombergTech"
echo "STATUS: PERSISTENT VERSIONING ACTIVE"
echo "-------------------------------------------------------"
