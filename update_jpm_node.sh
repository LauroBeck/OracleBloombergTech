#!/bin/bash
# STARGATE RECTIFICATION: JPM NODE UPDATE
# REPO: LauroBeck/OracleBloombergTech

# Update the local SQL file with correct column names
sed -i 's/ALPHA_DRIVER/STRATEGIC_ALPHA/g' tri_node_strong_buy.sql

# Git Commit and Push
git add tri_node_strong_buy.sql
git commit -m "FIX: Rectify ORA-00904 - Update column name to STRATEGIC_ALPHA"
git push origin main

echo "-------------------------------------------------------"
echo "GITHUB SYNC COMPLETE: JPM NODE PERSISTENCE RECOVERED"
echo "-------------------------------------------------------"
