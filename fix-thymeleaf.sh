#!/bin/bash

# Localiza o arquivo login.html
LOGIN_FILE=$(find src/main/resources/templates -name "login.html" 2>/dev/null | head -1)

if [ -z "$LOGIN_FILE" ]; then
    echo "Erro: Arquivo login.html não encontrado em src/main/resources/templates"
    exit 1
fi

# Verifica a linha 12
LINE_CONTENT=$(sed -n '12p' "$LOGIN_FILE")

if [[ ! "$LINE_CONTENT" =~ th:.*\=\"\ *\" ]]; then
    echo "Erro: Expressão vazia não encontrada na linha 12."
    echo "Conteúdo real da linha 12: '$LINE_CONTENT'"
    echo "Dica: Verifique manualmente se há atributos Thymeleaf vazios"
    exit 2
fi

# Cria backup antes de modificar
cp "$LOGIN_FILE" "$LOGIN_FILE.bak"

# Substituição segura usando delimitadores alternativos
sed -i '12s~th:\([a-zA-Z]\+\)=""~th:\1="${expressao_correta}"~' "$LOGIN_FILE"

echo -e "\n\033[1;32mCorreção aplicada com sucesso!\033[0m"
echo "==========================================="
echo "Arquivo: $LOGIN_FILE"
echo "Backup:  $LOGIN_FILE.bak"
echo "==========================================="
echo -e "\n\033[1;33mAÇÕES NECESSÁRIAS:\033[0m"
echo "1. Edite o arquivo e substitua '\${expressao_correta}' por:"
echo "   - Verificação de erro: '\${param.error != null}'"
echo "   - Mensagem de logout: '\${param.logout != null}'"
echo "   - Acesso negado:      '\${param.accessDenied != null}'"
echo ""
echo "2. Valide a lógica na linha 12:"
echo "   $LINE_CONTENT"