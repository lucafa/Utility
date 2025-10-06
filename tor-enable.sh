#!/usr/bin/env bash
# tor-all-via-tor.sh
# Instrada tutto il traffico IPv4 tramite Tor (Debian/Ubuntu).
# USO: sudo ./tor-all-via-tor.sh {install|start|stop|status}
set -euo pipefail

# --- Configurazione (modifica se necessario) ---
TOR_USER="debian-tor"         # utente tor su Debian/Ubuntu (può essere "tor" su altre distro)
TRANS_PORT="9040"             # TransPort (TCP) di Tor
DNS_PORT="5353"               # DNSPort (UDP) di Tor
TORRC_PATH="/etc/tor/torrc"
IPTABLES_BACKUP="/root/iptables.tor.backup"
ALLOW_LOCALNETS=("127.0.0.0/8" "10.0.0.0/8" "172.16.0.0/12" "192.168.0.0/16") # reti locali da esentare
VIRT_NETWORK="10.192.0.0/10"  # VirtualAddrNetworkIPv4

# --- helper output ---
info(){ echo -e "\e[1;34m[*]\e[0m $*"; }
warn(){ echo -e "\e[1;33m[!]\e[0m $*"; }
err(){ echo -e "\e[1;31m[-]\e[0m $*"; }

# --- funzioni ---
install_deps(){
  info "Installazione dipendenze: tor, torsocks, iptables-persistent (richiede sudo)..."
  apt update
  DEBIAN_FRONTEND=noninteractive apt install -y tor torsocks iptables-persistent || {
    warn "Installazione automatica fallita. Installa manualmente: tor torsocks iptables-persistent"
  }
  # assicurati che il file rules.v4 esista
  mkdir -p /etc/iptables
  touch /etc/iptables/rules.v4
  info "Configurazione tor e riavvio..."
  configure_tor
  systemctl enable --now tor
}

configure_tor(){
  info "Backup del torrc se non esiste .orig"
  if [ -f "${TORRC_PATH}" ] && [ ! -f "${TORRC_PATH}.orig" ]; then
    cp -n "${TORRC_PATH}" "${TORRC_PATH}.orig"
  fi

  cat > "${TORRC_PATH}" <<EOF
# torrc generato dallo script tor-all-via-tor.sh
RunAsDaemon 1
User ${TOR_USER}
Log notice file /var/log/tor/notices.log

VirtualAddrNetworkIPv4 ${VIRT_NETWORK}
AutomapHostsOnResolve 1

# DNS via Tor
DNSPort 127.0.0.1:${DNS_PORT}

# Transparent proxy (per redirect TCP)
TransPort 127.0.0.1:${TRANS_PORT}

# SOCKS per compatibilità (9050 default)
SocksPort 127.0.0.1:9050
EOF

  info "Riavvio tor per caricare la configurazione..."
  systemctl restart tor
  sleep 1
}

save_iptables(){
  info "Backup regole iptables in ${IPTABLES_BACKUP}"
  iptables-save > "${IPTABLES_BACKUP}"
  # prova a scrivere in rules.v4 (iptables-persistent)
  if [ -d "/etc/iptables" ]; then
    iptables-save > /etc/iptables/rules.v4 || warn "Non è stato possibile scrivere /etc/iptables/rules.v4"
  fi
}

restore_iptables(){
  if [ -f "${IPTABLES_BACKUP}" ]; then
    info "Ripristino regole iptables da ${IPTABLES_BACKUP}"
    iptables-restore < "${IPTABLES_BACKUP}"
  else
    warn "Nessun backup trovato (${IPTABLES_BACKUP}). Le tabelle iptables sono state resettate."
    iptables -t nat -F || true
    iptables -F || true
  fi
}

apply_rules(){
  info "Abilito IP forwarding..."
  sysctl -w net.ipv4.ip_forward=1 || warn "Impossibile abilitare IP forwarding (permission denied)"

  save_iptables

  info "Pulizia regole NAT/Filter temporanee..."
  iptables -t nat -F || true
  iptables -F || true

  # Evita di toccare loopback
  iptables -t nat -A PREROUTING -i lo -j RETURN

  # Escludi reti locali dalla redirezione
  for net in "${ALLOW_LOCALNETS[@]}"; do
    iptables -t nat -A PREROUTING -d "$net" -j RETURN
  done

  # DNS (UDP 53) -> Tor DNSPort
  iptables -t nat -A PREROUTING -p udp --dport 53 -j REDIRECT --to-ports ${DNS_PORT}

  # TCP SYN -> TransPort di Tor
  iptables -t nat -A PREROUTING -p tcp --syn -j REDIRECT --to-ports ${TRANS_PORT}

  # Gestione traffico locale (OUTPUT) - per processi locali
  iptables -t nat -A OUTPUT -o lo -j RETURN
  for net in "${ALLOW_LOCALNETS[@]}"; do
    iptables -t nat -A OUTPUT -d "$net" -j RETURN
  done

  # Evita loop (non redirigere il traffico di Tor stesso)
  iptables -t nat -A OUTPUT -m owner --uid-owner ${TOR_USER} -j RETURN

  # Redirect DNS locale e TCP verso Tor
  iptables -t nat -A OUTPUT -p udp --dport 53 -j REDIRECT --to-ports ${DNS_PORT}
  iptables -t nat -A OUTPUT -p tcp --syn -j REDIRECT --to-ports ${TRANS_PORT}

  # Filter basics per non bloccare Tor
  iptables -A INPUT -i lo -j ACCEPT || true
  iptables -A INPUT -m state --state ESTABLISHED,RELATED -j ACCEPT || true
  iptables -A OUTPUT -m owner --uid-owner ${TOR_USER} -j ACCEPT || true

  info "Regole applicate. Provo a salvare in /etc/iptables/rules.v4 (se presente)..."
  iptables-save > /etc/iptables/rules.v4 || warn "Non è stato possibile salvare /etc/iptables/rules.v4"
}

flush_rules(){
  info "Rimozione regole create dallo script e ripristino backup..."
  # svuota NAT e filter usati
  iptables -t nat -F || true
  iptables -F || true
  # disabilita forwarding (il valore viene riportato a 0)
  sysctl -w net.ipv4.ip_forward=0 || true
  restore_iptables
}

check_tor_ports(){
  info "Controllo porte Tor (Socks, TransPort, DNSPort)..."
  ss -ltnp | egrep -w "9050|${TRANS_PORT}" || true
  ss -lunp | egrep -w "127.0.0.1:${DNS_PORT}" || true
}

status(){
  info "Stato servizio tor:"
  systemctl status tor --no-pager || true
  echo
  info "Socket in ascolto (ss):"
  check_tor_ports
  echo
  info "Regole nat (iptables -t nat -S):"
  iptables -t nat -S || true
  echo
  info "Regole filter (iptables -S):"
  iptables -S || true
}

# --- main ---
case "${1:-}" in
  install)
    install_deps
    ;;
  start)
    info "Avvio tor (se non in esecuzione)..."
    systemctl start tor || { err "Impossibile avviare tor"; exit 1; }
    sleep 1
    if ! systemctl is-active --quiet tor; then
      err "Tor non è in esecuzione: vedi i log con: sudo journalctl -u tor -n 80 --no-pager"
      exit 1
    fi
    info "Controllo porte e applico regole iptables..."
    # rendi sure torrc contiene le porte desiderate
    if ! grep -q "TransPort" "${TORRC_PATH}" 2>/dev/null; then
      warn "torrc non contiene TransPort/DNSPort: rigenero la config"
      configure_tor
      sleep 1
    fi
    check_tor_ports
    apply_rules
    info "Ora il traffico IPv4 dovrebbe essere instradato attraverso Tor (eccetto reti locali)."
    info "Verifica l'IP pubblico con: curl -sS https://check.torproject.org/api/ip || true"
    ;;
  stop)
    info "Fermando routing Tor e ripristinando regole..."
    flush_rules
    systemctl stop tor || true
    info "Fatto."
    ;;
  status)
    status
    ;;
  *)
    cat <<USAGE
Uso: sudo $0 {install|start|stop|status}

install  - installa dipendenze (tor, torsocks, iptables-persistent) e configura tor
start    - avvia tor e applica regole iptables per redirect trasparente (TUTTO il traffico IPv4)
stop     - rimuove regole e ferma tor (ripristina backup iptables se presente)
status   - mostra stato servizio tor e regole iptables
USAGE
    ;;
esac

exit 0
