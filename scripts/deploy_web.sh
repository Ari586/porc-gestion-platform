#!/bin/bash
# Script de déploiement pour PigIA Web Dashboard
# Prérequis : Firebase CLI installé (npm install -g firebase-tools)
# Prérequis : Être connecté à Firebase (firebase login)

set -e

echo "🐷 Préparation du déploiement de PigIA..."

# 1. Analyse du code pour détecter des erreurs critiques
echo "🔍 Analyse du code Flutter..."
flutter analyze

# 2. Compilation de l'application Web (avec arbre de secousse désactivé si besoin, 
# mais préférable de garder les options par défaut pour la production)
echo "🏗️ Compilation de l'application Web..."
flutter build web

# 3. Déploiement sur Firebase Hosting
echo "🚀 Déploiement sur Firebase Hosting..."
firebase deploy --only hosting,firestore:rules

echo "✅ Déploiement terminé avec succès !"
