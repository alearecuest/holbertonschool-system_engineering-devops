#!/bin/bash
# Script para configurar git global user
git config --global user.email "10653@holbertonstudents.com"
git config --global user.name "Alejandro"
echo "Git configurado correctamente:"
echo "Email: $(git config --global user.email)"
echo "Nombre: $(git config --global user.name)"