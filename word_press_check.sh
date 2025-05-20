#!/bin/bash

FILE="ips.txt"

while read -r ip; do
    echo -e "\n🔍 Sprawdzam IP: $ip"

    # Reverse IP Lookup przez HackerTarget API
    domains=$(curl -s "https://api.hackertarget.com/reverseiplookup/?q=$ip")

    # Obsługa błędów API
    if echo "$domains" | grep -qiE "error|no records"; then
        echo "❌ Brak domen lub błąd dla IP $ip"
        continue
    fi

    echo "✅ Znalezione domeny:"
    echo "$domains" | sed 's/^/   - /'

    # Iteruj po każdej znalezionej domenie
    while read -r domain; do
        for proto in http https; do
            echo "➡️  Sprawdzam: $proto://$domain"
            page=$(curl -s --max-time 5 "$proto://$domain")

            if echo "$page" | grep -qiE "wp-content|wp-login|wp-includes"; then
                echo "🟢 WordPress wykryty na: $proto://$domain"
                break
            else
                echo "❌ Brak oznak WordPressa na: $proto://$domain"
            fi
        done
    done <<< "$domains"

done < "$FILE"
