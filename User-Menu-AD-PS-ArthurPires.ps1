Import-Module ActiveDirectory



function MostrarMenu {
    Clear-Host
    Write-Host "+==========================================+"
    Write-Host "      POWERSHELL CONSOLE - USER MENU       "
    Write-Host "+==========================================+"
    Write-Host " 1  - Criar Usuario                        "
    Write-Host " 2  - Resetar Senha                        "
    Write-Host " 3  - Inativar Usuario                     "
    Write-Host " 4  - Reativar Usuario                     "
    Write-Host " 5  - Bloquear Usuario                     "
    Write-Host " 6  - Desbloquear Usuario                  "
    Write-Host "+==========================================+"
    $opcao = Read-Host "Digite o número correspondente à opção desejada"
    if ($opcao -notmatch "^[0-7]$") {
        Write-Host "Erro: Opção inválida! Escolha um número entre 0 e 7." -ForegroundColor Red
        Start-Sleep -Seconds 2
        continue
    }
 return $opcao
}



function SelecionarUnidade {
    do {
        Clear-Host
        $unidades = @{
            "1" = "CORPORATIVO"
            "2" = "UNIDADE B"
            "3" = "UNIDADE C"
            "4" = "UNIDADE D"
            "5" = "UNIDADE E"
            "6" = "UNIDADE F"
            "7" = "UNIDADE G"
            "8" = "UNIDADE H"
            "9" = "UNIDADE I"
            "10" = "UNIDADE J"
        }

        Write-Host "+==========================================+"
        Write-Host "      SELECIONE A UNIDADE DO USUÁRIO       "
        Write-Host "+==========================================+"

        $unidades.Keys | Sort-Object {[int]$_} | ForEach-Object {
            Write-Host " $_ - $($unidades[$_])"
        }
        Write-Host " 0 - Cancelar  "
        Write-Host "+==========================================+"

        $unidade = Read-Host "Escolha a unidade do usuário"

        if ($unidade -match "^\d+$" -and [int]$unidade -ge 0 -and [int]$unidade -le 10) {
            if ($unidade -eq "0") {
                Write-Host "Cancelando..." -ForegroundColor Yellow
                Start-Sleep -Seconds 2
                return $null
            }
            return $unidades[$unidade]
        } else {
            Write-Host "Erro: Opção inválida! Escolha um número entre 0 e 10." -ForegroundColor Red
            Start-Sleep -Seconds 2
        }
    } while ($true)
}



function SelecionarDepartamento {
    param([string]$unidadeSelecionada)
    
    do {
        Clear-Host
        Write-Host "+==========================================+"
        Write-Host "   SELECIONE O DEPARTAMENTO DO USUÁRIO    "
        Write-Host "+==========================================+"

       #UNIDADE A REPRESENTA O CORPORATIVO DA EMPRESA 
        if ($unidadeSelecionada -eq "CORPORATIVO") {
            $departamentos = @{
                "DEP01" = "DEP01 - DEPARTAMENTO A"
                "DEP02" = "DEP02 - DEPARTAMENTO B"
                "DEP03" = "DEP03 - DEPARTAMENTO C"
                "DEP04" = "DEP04 - DEPARTAMENTO D"
                "DEP05" = "DEP05 - DEPARTAMENTO E"
                "DEP06" = "DEP06 - DEPARTAMENTO F"
                "DEP07" = "DEP07 - DEPARTAMENTO G"
                "DEP08" = "DEP08 - DEPARTAMENTO H"
                "DEP09" = "DEP09 - DEPARTAMENTO I"
                "DEP10" = "DEP10 - DEPARTAMENTO J"
            }
        #AS OUTRAS UNIDADES REPRESENTAM AS FILIAIS
        } else {
            $departamentos = @{
                "DEP11" = "DEP11 - ADMINISTRATIVO"
                "DEP12" = "DEP12 - COMERCIAL"
                "DEP13" = "DEP13 - EDUCACIONAL"
                "DEP14" = "DEP14 - GERENCIAL"
                "DEP15" = "DEP15 - OPERACIONAL"
            }
        }
        
        $departamentoLista = $departamentos.Keys | Sort-Object
        for ($i = 0; $i -lt $departamentoLista.Length; $i++) {
            Write-Host " $($i + 1) - $($departamentoLista[$i])"
        }
        Write-Host " 0 - Cancelar   "
        Write-Host "+==========================================+"

        $departamento = Read-Host "Escolha o departamento do usuário"

        if ($departamento -match "^\d+$" -and [int]$departamento -ge 0 -and [int]$departamento -le $departamentoLista.Count) {
            if ($departamento -eq "0") {
                Write-Host "Cancelando..." -ForegroundColor Yellow
                Start-Sleep -Seconds 2
                return $null
            }
            return $departamentoLista[[int]$departamento - 1]
        } else {
            Write-Host "Erro: Opção inválida! Escolha um número válido." -ForegroundColor Red
            Start-Sleep -Seconds 2
        }
    } while ($true)
}



function SolicitarNomeUsuario {
    Clear-Host
    Write-Host "+==========================================+"
    Write-Host "         INSIRA OS DADOS DO USUÁRIO         "
    Write-Host "+==========================================+"

    # Solicitação do nome completo com validação de apenas letras
    do {
        $nomeCompleto = Read-Host "Digite o nome completo do usuário"

        # Remove espaços extras no início e no final
        $nomeCompleto = $nomeCompleto.Trim()

        # Verifica se contém apenas letras e espaços
        if ($nomeCompleto -match "^[a-zA-ZÀ-ÿ\s]+$") {
            $partesNome = $nomeCompleto -split "\s+"
            
            if ($partesNome.Count -lt 2) {
                Write-Host "Erro: Digite pelo menos um nome e um sobrenome." -ForegroundColor Red
            }
        } else {
            Write-Host "Erro: O nome deve conter apenas letras e espaços. Não use números ou caracteres especiais." -ForegroundColor Red
            $partesNome = @()  # Resetar array para forçar repetição do loop
        }
    } while ($partesNome.Count -lt 2)

    # Converte o nome para o formato correto (exemplo: Arthur Pires)
    $nomeFormatado = ($partesNome | ForEach-Object { $_.Substring(0,1).ToUpper() + $_.Substring(1).ToLower() }) -join " "

    # Captura o primeiro nome e cria uma lista de sobrenomes na ordem original
    $primeiroNome = $partesNome[0].ToLower()
    $sobrenomes = $partesNome[1..($partesNome.Length - 1)]  # Mantém a ordem original dos sobrenomes

    # Variáveis de controle
    $loginExistente = $null
    $loginConfirmado = $false

    # Loop para tentar os sobrenomes na ordem inversa (do último para o primeiro)
    for ($i = $sobrenomes.Count - 1; $i -ge 0; $i--) {
        $sobrenomeFormatado = $sobrenomes[$i].ToLower()
        $loginTentativa = "{0}.{1}" -f $primeiroNome, $sobrenomeFormatado
        $email = "$loginTentativa@dominio.com"  # Alterar para o seu domínio

        # Verifica se o usuário já existe no AD
        $usuarioExistente = Get-ADUser -Filter {SamAccountName -eq $loginTentativa} -ErrorAction SilentlyContinue

        if (-not $usuarioExistente) {
            $loginConfirmado = $true
            break
        } else {
            $loginExistente = $loginTentativa  # Armazena o login que já existia
        }
    }

    # Se todos os sobrenomes já estiverem em uso, solicita um nome manualmente e verifica se já existe
    if (-not $loginConfirmado) {
        Write-Host "`nTodos os logins possíveis já estão sendo usados no AD!" -ForegroundColor Red

        do {
            $loginTentativa = Read-Host "Digite manualmente um login disponível no formato nome.sobrenome"

            # Validação do formato correto
            if ($loginTentativa -notmatch "^[a-zA-Z]+\.[a-zA-Z]+$") {
                Write-Host "Erro: O login deve estar no formato nome.sobrenome" -ForegroundColor Red
                Start-Sleep -Seconds 2
                continue
            }

            $email = "$loginTentativa@dominio.com"  # Alterar para o seu domínio

            # Verifica se o login manual já existe
            $usuarioExistente = Get-ADUser -Filter {SamAccountName -eq $loginTentativa} -ErrorAction SilentlyContinue

            if ($usuarioExistente) {
                Write-Host "Erro: O login '$loginTentativa' já está em uso. Escolha outro." -ForegroundColor Red
            } else {
                break
            }
        } while ($true)  # Continua pedindo até encontrar um login disponível
    }

    # Se um login existente foi detectado antes de mudar, exibe aviso
    if ($loginExistente) {
        Write-Host "`nO login '$loginExistente' já estava em uso. Mudado para '$loginTentativa'." -ForegroundColor Yellow
        Start-Sleep -Seconds 2
    }

    return @{
        NomeCompleto = $nomeFormatado
        Login        = $loginTentativa
        Email        = $email
    }
}



function SelecionarCargo {
    param([string]$departamentoSelecionado)

    #Alterar para o nome dos departamentos e os cargos
    $cargosDepartamentos = @{
        "DEP01"  = @("Cargo A", "Cargo B", "Outro (Escrever Manualmente)")
        "DEP02"  = @("Cargo C", "Cargo D", "Outro (Escrever Manualmente)")
        "DEP03"  = @("Cargo E", "Cargo F", "Outro (Escrever Manualmente)")
        "DEP04"  = @("Cargo G", "Cargo H", "Outro (Escrever Manualmente)")
        "DEP05"  = @("Cargo I", "Cargo J", "Outro (Escrever Manualmente)")
        "DEP06"  = @("Cargo K", "Cargo L", "Outro (Escrever Manualmente)")
        "DEP07"  = @("Cargo M", "Cargo N", "Outro (Escrever Manualmente)")
        "DEP08"  = @("Cargo O", "Cargo P", "Outro (Escrever Manualmente)")
        "DEP09"  = @("Cargo Q", "Cargo R", "Outro (Escrever Manualmente)")
        "DEP10" = @("Cargo S", "Cargo T", "Outro (Escrever Manualmente)")
        "DEP11" = @("Cargo U", "Cargo V", "Outro (Escrever Manualmente)")
        "DEP12" = @("Cargo W", "Cargo X", "Outro (Escrever Manualmente)")
        "DEP13" = @("Cargo Y", "Cargo Z", "Outro (Escrever Manualmente)")
        "DEP14" = @("Cargo AA", "Cargo BB", "Outro (Escrever Manualmente)")
        "DEP15" = @("Cargo CC", "Cargo DD", "Outro (Escrever Manualmente)")
    }

    if ($cargosDepartamentos.ContainsKey($departamentoSelecionado)) {
        $cargos = $cargosDepartamentos[$departamentoSelecionado]

        do {
            Clear-Host
            Write-Host "+==========================================+"
            Write-Host "        SELECIONE O CARGO DO USUÁRIO        "
            Write-Host "+==========================================+"

            for ($i = 0; $i -lt $cargos.Length; $i++) {
                Write-Host " $($i + 1) - $($cargos[$i])"
            }
            Write-Host "+==========================================+"

            $cargoOpcao = Read-Host "Escolha o cargo do usuário (Digite um número)"

            # Validação: Verifica se é um número e se está dentro da faixa de opções
            if ($cargoOpcao -match "^\d+$") {
                $cargoOpcao = [int]$cargoOpcao
                if ($cargoOpcao -gt 0 -and $cargoOpcao -le $cargos.Length) {
                    if ($cargoOpcao -eq $cargos.Length) {
                        return Read-Host "Digite o cargo manualmente"
                    } else {
                        return $cargos[$cargoOpcao - 1]
                    }
                }
            }
            Write-Host "Erro: Opção inválida. Digite um número entre 1 e $($cargos.Length)." -ForegroundColor Red
            Start-Sleep -Seconds 2
        } while ($true)
    } else {
        return Read-Host "Digite o cargo"
    }
}



function SolicitarMatricula {
    do {
        Clear-Host
        Write-Host "+==========================================+"
        Write-Host "         DIGITE A MATRÍCULA DO USUÁRIO      "
        Write-Host "+==========================================+"

        $matricula = Read-Host "Digite a matrícula (somente números, mínimo 4 dígitos)"

        # Validação: Apenas números e mínimo de 4 dígitos
        if ($matricula -match "^\d{4,}$") {
            # 🔍 Verifica no Active Directory se a matrícula já está em uso nos campos employeeID e Initials
            $usuarioExistente = Get-ADUser -Filter {employeeID -eq $matricula -or Initials -eq $matricula} -Properties employeeID, Initials -ErrorAction SilentlyContinue

            if ($usuarioExistente) {
                Write-Host "⚠️ Erro: A matrícula '$matricula' já está em uso pelo usuário '$($usuarioExistente.SamAccountName)'!" -ForegroundColor Red
                Write-Host "Escolha outra matrícula." -ForegroundColor Yellow
                Start-Sleep -Seconds 2
            } else {
                return $matricula  # ✅ Se a matrícula não estiver em uso, retorna o valor
            }
        } else {
            Write-Host "⚠️ Erro: A matrícula deve conter apenas números e ter pelo menos 4 dígitos." -ForegroundColor Red
            Start-Sleep -Seconds 2
        }
    } while ($true)
}



function FormatarNome {
    param([string]$nomeCompleto)

    # Remove espaços em branco extras no início e no final
    $nomeCompleto = $nomeCompleto.Trim()

    # Lista de palavras que não devem ter a primeira letra em maiúscula
    $preposicoes = @("dos", "de", "da", "do", "das")

    # Separa o nome em palavras
    $partesNome = $nomeCompleto -split "\s+"

    # Captura o primeiro nome e formata corretamente
    $nome = $partesNome[0].Substring(0,1).ToUpper() + $partesNome[0].Substring(1).ToLower()

    # Captura o restante como sobrenome e aplica formatação correta
    $sobrenome = ($partesNome[1..($partesNome.Length - 1)] | ForEach-Object {
        $palavra = $_.ToLower()
        if ($preposicoes -contains $palavra) {
            $palavra  # Mantém preposições em minúsculas
        } else {
            $palavra.Substring(0,1).ToUpper() + $palavra.Substring(1)  # Primeira letra maiúscula
        }
    }) -join " "

    # Retorna o nome completo formatado corretamente
    return @{
        Nome         = $nome
        Sobrenome    = $sobrenome
        NomeCompleto = "$nome $sobrenome"
    }
}



function ConfirmarDadosUsuario {
    param(
        [string]$nomeCompleto,
        [string]$matricula,
        [string]$loginTentativa,
        [string]$unidadeSelecionada,
        [string]$departamentoSelecionado,
        [string]$cargo
    )

    do {
        Clear-Host
        Write-Host "+=======================================================+"
        Write-Host "                  CONFIRMAÇÃO DOS DADOS                  " -ForegroundColor Yellow
        Write-Host "+=======================================================+"
        Write-Host " 1 - Nome Completo: $nomeCompleto                        "
        Write-Host " 2 - Matrícula:     $matricula                           "
        Write-Host " 3 - Login:         $loginTentativa                      "
        Write-Host " 4 - Unidade:       $unidadeSelecionada                  "
        Write-Host " 5 - Departamento:  $departamentoSelecionado             "
        Write-Host " 6 - Cargo:         $cargo                               "
        Write-Host "+=======================================================+"

        $confirmacao = Read-Host "Os dados estão corretos? (S para continuar / N para editar)"

        if ($confirmacao -match "^[Ss]$") {
            return @{
                NomeCompleto   = $nomeCompleto
                Matricula      = $matricula
                Login          = $loginTentativa
                Unidade        = $unidadeSelecionada
                Departamento   = $departamentoSelecionado
                Cargo          = $cargo
            }
        } elseif ($confirmacao -match "^[Nn]$") {
            do {
                Clear-Host
                Write-Host "+=======================================================+"
                Write-Host "                EDITAR DADOS DO USUÁRIO                  "
                Write-Host "+=======================================================+"
                Write-Host " 1 - Nome Completo:  $nomeCompleto                      "
                Write-Host " 2 - Matrícula:      $matricula                          "
                Write-Host " 3 - Login:          $loginTentativa                     "
                Write-Host " 4 - Unidade:        $unidadeSelecionada                 "
                Write-Host " 5 - Departamento:   $departamentoSelecionado            "
                Write-Host " 6 - Cargo:          $cargo                              "
                Write-Host " 0 - Concluir edição e confirmar                         "
                Write-Host "+=======================================================+"

                $opcaoEdicao = Read-Host "Digite o número do dado que deseja editar ou 0 para concluir"

                switch ($opcaoEdicao) {
                    '1' { 
                        $nomeCompleto = Read-Host "Digite o nome completo do usuário" 
                        $nomeCorrigido = FormatarNome -nomeCompleto $nomeCompleto
                        $nomeCompleto = $($nomeCorrigido.NomeCompleto)
                    }
                    '2' { 
                        do {
                            $matricula = Read-Host "Digite a matrícula (somente números, mínimo 4 dígitos)"

                            # Verifica se a matrícula segue o formato correto
                            if ($matricula -notmatch "^\d{4,}$") {
                                Write-Host "⚠️ Erro: A matrícula deve conter apenas números e ter pelo menos 4 dígitos." -ForegroundColor Red
                                Start-Sleep -Seconds 2
                                continue
                            }

                            # 🔍 Verifica no Active Directory se a matrícula já está em uso nos campos employeeID e Initials
                            $usuarioExistente = Get-ADUser -Filter {employeeID -eq $matricula -or Initials -eq $matricula} -Properties employeeID, Initials -ErrorAction SilentlyContinue

                            if ($usuarioExistente) {
                                Write-Host "⚠️ Erro: A matrícula '$matricula' já está em uso pelo usuário '$($usuarioExistente.SamAccountName)'!" -ForegroundColor Red
                                Write-Host "Escolha outra matrícula." -ForegroundColor Yellow
                                Start-Sleep -Seconds 2
                            } else {
                                break  # Se a matrícula estiver disponível, sai do loop
                            }
                        } while ($true)
                    }
                    '3' { 
                        do {
                            $loginTentativa = Read-Host "Digite o login no formato nome.sobrenome"

                            # Validação do formato correto
                            if ($loginTentativa -notmatch "^[a-zA-Z]+\.[a-zA-Z]+$") {
                                Write-Host "Erro: O login deve estar no formato nome.sobrenome" -ForegroundColor Red
                                Start-Sleep -Seconds 2
                                continue
                            }

                            # Verifica se o login já existe no Active Directory
                            $usuarioExistente = Get-ADUser -Filter {SamAccountName -eq $loginTentativa} -ErrorAction SilentlyContinue

                            if ($usuarioExistente) {
                                Write-Host "Erro: O login '$loginTentativa' já existe no AD! Escolha outro." -ForegroundColor Red
                                Start-Sleep -Seconds 2
                            } else {
                                break
                            }
                        } while ($true)
                    }
                    '4' { 
                        $unidadeSelecionada = Read-Host "Digite a unidade do usuário" 
                    }
                    '5' { 
                        $departamentoSelecionado = Read-Host "Digite o departamento do usuário" 
                    }
                    '6' { 
                        $cargo = Read-Host "Digite o cargo do usuário" 
                    }
                    '0' { 
                        Write-Host "Finalizando edição..." -ForegroundColor Yellow
                        Start-Sleep -Seconds 2
                        break 
                    }
                    default { 
                        Write-Host "Opção inválida! Escolha um número de 0 a 6." -ForegroundColor Red
                        Start-Sleep -Seconds 2 
                    }
                }

            } while ($opcaoEdicao -ne '0')
        } else {
            Write-Host "Opção inválida! Digite S para confirmar ou N para editar." -ForegroundColor Yellow
            Start-Sleep -Seconds 2
        }
    } while ($true)
}



function CriarUsuario {
    param(
        [string]$NomeCompleto,
        [string]$Nome,
        [string]$Sobrenome,
        [string]$Matricula,
        [string]$LoginTentativa,
        [string]$UnidadeSelecionada,
        [string]$DepartamentoSelecionado,
        [string]$Cargo
    )

    Clear-Host
    Write-Host "+=======================================================+"
    Write-Host "                    CRIANDO USUÁRIO...                   " -ForegroundColor Green
    Write-Host "+=======================================================+"
    Write-Host " Nome Completo: $NomeCompleto                             "
    Write-Host " Nome:          $Nome                                    "                         
    Write-Host " Sobrenome:     $Sobrenome                               "
    Write-Host " Matrícula:     $Matricula                               "
    Write-Host " Login:         $LoginTentativa                          "
    Write-Host " Unidade:       $UnidadeSelecionada                      "
    Write-Host " Departamento:  $DepartamentoSelecionado                 "
    Write-Host " Cargo:         $Cargo                                   "
    Write-Host "+=======================================================+"

    # 🔍 Definição da OU Dinâmica
    $Dominio = "DC=empresa,DC=com"  # 🔄 Substituir pelo domínio real da empresa
    $OUUsuarios = "OU=USUARIOS,OU=EMPRESA"  # 🔄 Substituir pelo caminho correto no AD

    if ($UnidadeSelecionada -eq "Corporativo") {
        # Se a unidade for SEDE, a estrutura de OU segue um padrão específico
        $OU = "OU=$DepartamentoSelecionado,$OUUsuarios,OU=Corporativo,$Dominio"
    } else {
        # Para todas as outras unidades, usa-se este formato
        $UnidadeFormatada = $UnidadeSelecionada -replace "\s", ""  # Remove espaços
        $OU = "OU=$DepartamentoSelecionado,$OUUsuarios,OU=$UnidadeFormatada,$Dominio"
    }

    Write-Host "`n🌍 Unidade Organizacional (OU) atribuída: $OU" -ForegroundColor Cyan

    # 🔐 Gerando uma senha temporária segura
    $SenhaPadrao = "Senha@" + (Get-Random -Minimum 1000 -Maximum 9999)
    $SenhaSecure = ConvertTo-SecureString -AsPlainText $SenhaPadrao -Force

    # 🔵 COMANDO PARA CRIAR USUÁRIO NO ACTIVE DIRECTORY (Descomentar ao ativar)
    <#
    New-ADUser `
        -Name "$Nome $Sobrenome" `
        -GivenName $Nome `
        -Surname $Sobrenome `
        -SamAccountName $LoginTentativa `
        -UserPrincipalName "$LoginTentativa@empresa.com" `  # 🔄 Substituir domínio correto
        -DisplayName "$Nome $Sobrenome" `
        -EmailAddress "$LoginTentativa@empresa.com" `  # 🔄 Substituir domínio correto
        -Title $Cargo `
        -Department $DepartamentoSelecionado `
        -Office $UnidadeSelecionada `
        -EmployeeID $Matricula `
        -Path $OU `
        -AccountPassword $SenhaSecure `
        -Enabled $true `
        -PasswordNeverExpires $false `
        -ChangePasswordAtLogon $true `
        -PassThru
    #>

    # 🔹 Associando usuário a grupos padrão (personalizar conforme necessário)
    $GruposPadrao = @("Grupo_Padrao1", "Grupo_Padrao2")  # 🔄 Modificar conforme necessário
    foreach ($Grupo in $GruposPadrao) {
        # Add-ADGroupMember -Identity $Grupo -Members $LoginTentativa
        Write-Host "🔵 Usuário adicionado ao grupo: $Grupo" -ForegroundColor Cyan
    }

    Write-Host "`n✅ Usuário criado com sucesso! Senha temporária: $SenhaPadrao" -ForegroundColor Green
    Write-Host "🔵 O usuário deve alterar a senha no primeiro login."
    
    Start-Sleep -Seconds 10
}



function ExecutarCriacaoUsuario {
    # 🛑 Resetar variáveis ANTES de iniciar para evitar reuso acidental
    $unidadeSelecionada = $null
    $departamento = $null
    $dadosUsuario = $null
    $nomeCompleto = $null
    $login = $null
    $cargo = $null
    $matricula = $null
    $nomeCorrigido = $null
    $nomeCompletoCorrigido = $null

    # 🏢 SELECIONANDO UNIDADE (Obrigatório)
    while (-not $unidadeSelecionada) {
        $unidadeSelecionada = SelecionarUnidade
        if (-not $unidadeSelecionada) {
            Write-Host "⚠️ Nenhuma unidade selecionada. Voltando ao menu..." -ForegroundColor Yellow
            Start-Sleep -Seconds 2
            return  # Volta ao menu principal
        }
    }

    # 🏢 SELECIONANDO DEPARTAMENTO (Obrigatório)
    while (-not $departamento) {
        $departamento = SelecionarDepartamento -unidadeSelecionada $unidadeSelecionada
        if (-not $departamento) {
            Write-Host "⚠️ Nenhum departamento selecionado. Voltando ao menu..." -ForegroundColor Yellow
            Start-Sleep -Seconds 2
            return  # Volta ao menu principal
        }
    }

    # 📝 SOLICITANDO NOME DO USUÁRIO (Obrigatório)
    while (-not $dadosUsuario) {
        $dadosUsuario = SolicitarNomeUsuario
        if (-not $dadosUsuario) {
            Write-Host "⚠️ Nome do usuário não informado. Voltando ao menu..." -ForegroundColor Yellow
            Start-Sleep -Seconds 2
            return  # Volta ao menu principal
        }
    }

    $nomeCompleto = $dadosUsuario.NomeCompleto
    $login = $dadosUsuario.Login

    # 📌 SELECIONANDO CARGO (Obrigatório)
    while (-not $cargo) {
        $cargo = SelecionarCargo -departamentoSelecionado $departamento
        if (-not $cargo) {
            Write-Host "⚠️ Cargo não selecionado. Voltando ao menu..." -ForegroundColor Yellow
            Start-Sleep -Seconds 2
            return  # Volta ao menu principal
        }
    }

    # 🔢 SOLICITANDO MATRÍCULA (Obrigatório) -> MELHOR VERIFICAÇÃO
 
        $matricula = SolicitarMatricula
        if (-not $matricula -or $matricula -match "^\s*$") {
            Write-Host "⚠️ Matrícula inválida ou vazia. Voltando ao menu..." -ForegroundColor Yellow
            Start-Sleep -Seconds 2
            return  # Volta ao menu principal
        }


    # 🔤 FORMATANDO NOME
    $nomeCorrigido = FormatarNome -nomeCompleto $nomeCompleto
    $nomeCompletoCorrigido = $($nomeCorrigido.NomeCompleto)

    # ✅ CONFIRMANDO OS DADOS DO USUÁRIO
   
        $dadosUsuario = ConfirmarDadosUsuario `
            -nomeCompleto $nomeCompletoCorrigido `
            -matricula $matricula `
            -loginTentativa $login `
            -unidadeSelecionada $unidadeSelecionada `
            -departamentoSelecionado $departamento `
            -cargo $cargo

        if (-not $dadosUsuario) {
            Write-Host "⚠️ Confirmação cancelada. Voltando ao menu..." -ForegroundColor Yellow
            Start-Sleep -Seconds 2
            return  # Volta ao menu principal
        }
   

    # 🔄 FORMATANDO NOME NOVAMENTE
    $nomecompletoeditado = FormatarNome -nomeCompleto $dadosUsuario.NomeCompleto

    # 🚀 CRIANDO USUÁRIO
    CriarUsuario `
        -NomeCompleto $dadosUsuario.NomeCompleto `
        -nome $nomecompletoeditado.Nome `
        -sobrenome $nomecompletoeditado.Sobrenome `
        -matricula $dadosUsuario.Matricula `
        -loginTentativa $dadosUsuario.Login `
        -unidadeSelecionada $dadosUsuario.Unidade `
        -departamentoSelecionado $dadosUsuario.Departamento `
        -cargo $dadosUsuario.Cargo
}



function GerarSenhaAleatoria {
    param([int]$tamanho = 10)
    $caracteres = 'abcdefghijklmnopqrstuvwxyzABCDEFGHIJKLMNOPQRSTUVWXYZ0123456789!@#$%^&*()'
    return -join ((1..$tamanho) | ForEach-Object { $caracteres[(Get-Random -Maximum $caracteres.Length)] })
}



function ResetarSenhaUsuario {
    do {
        Clear-Host
        Write-Host "+==========================================+"
        Write-Host "          RESETAR SENHA DO USUÁRIO         " -ForegroundColor Yellow
        Write-Host "+==========================================+"

        # Solicitar login do usuário
        $login = Read-Host "Digite o login do usuário (formato nome.sobrenome)"

        # Validar o formato do login
        if ($login -notmatch "^[a-zA-Z]+\.[a-zA-Z]+$") {
            Write-Host "⚠️ Erro: O login deve estar no formato nome.sobrenome" -ForegroundColor Red
            Start-Sleep -Seconds 2
            continue
        }

        # Buscar usuário no AD pelo SamAccountName (login)
        $usuario = Get-ADUser -Filter {SamAccountName -eq $login} -Properties DisplayName, EmailAddress, Title, Department -ErrorAction SilentlyContinue

        if (-not $usuario) {
            Write-Host "⚠️ Erro: Usuário '$login' não encontrado no Active Directory." -ForegroundColor Red
            Start-Sleep -Seconds 2
            continue
        }

        # Exibir informações do usuário
        Clear-Host
        Write-Host "+==========================================+"
        Write-Host "        INFORMAÇÕES DO USUÁRIO              " -ForegroundColor Yellow
        Write-Host "+==========================================+"
        Write-Host " Nome:        $($usuario.DisplayName)       "
        Write-Host " Login:       $($usuario.SamAccountName)    "
        Write-Host " Email:       $($usuario.EmailAddress)      "
        Write-Host " Cargo:       $($usuario.Title)             "
        Write-Host " Departamento: $($usuario.Department)       "
        Write-Host "+==========================================+"

        # Solicitar confirmação
        $confirmacao = Read-Host "Deseja resetar a senha deste usuário? (S para confirmar / N para cancelar)"

        if ($confirmacao -match "^[Nn]$") {
            Write-Host "⚠️ Operação cancelada. Voltando ao menu..." -ForegroundColor Yellow
            Start-Sleep -Seconds 2
            return
        }

        # Gerar nova senha aleatória
        $novaSenha = GerarSenhaAleatoria -tamanho 10

        
        try {
            # Resetar senha do usuário no AD
            Set-ADAccountPassword -Identity $usuario.SamAccountName -NewPassword (ConvertTo-SecureString -AsPlainText $novaSenha -Force) -Reset

            # Forçar o usuário a alterar a senha no próximo login
            Set-ADUser -Identity $usuario.SamAccountName -ChangePasswordAtLogon $true
        } catch {
            Write-Host "❌ Erro ao redefinir a senha: $_" -ForegroundColor Red
            return
        }
        

        Write-Host "✅ Senha redefinida com sucesso! (Simulação)" -ForegroundColor Green
        Write-Host "A nova senha temporária seria: $novaSenha" -ForegroundColor Cyan
        Write-Host "O usuário precisaria alterá-la no próximo login. (Simulação)" -ForegroundColor Yellow

        Start-Sleep -Seconds 5

        # Finaliza a função e retorna ao menu principal
        return

    } while ($true)
}



function DesativarUsuario {
    do {
        Clear-Host
        Write-Host "+==========================================+"
        Write-Host "         DESATIVAR USUÁRIO DO AD           " -ForegroundColor Yellow
        Write-Host "+==========================================+"

        # Solicitar login do usuário
        $login = Read-Host "Digite o login do usuário (formato nome.sobrenome)"

        # Validar o formato do login
        if ($login -notmatch "^[a-zA-Z]+\.[a-zA-Z]+$") {
            Write-Host "⚠️ Erro: O login deve estar no formato nome.sobrenome" -ForegroundColor Red
            Start-Sleep -Seconds 2
            continue
        }

        # Buscar usuário no AD pelo SamAccountName (login)
        $usuario = Get-ADUser -Filter {SamAccountName -eq $login} -Properties DisplayName, EmailAddress, Title, Department, Enabled -ErrorAction SilentlyContinue

        if (-not $usuario) {
            Write-Host "⚠️ Erro: Usuário '$login' não encontrado no Active Directory." -ForegroundColor Red
            Start-Sleep -Seconds 2
            continue
        }

        # Verificar se o usuário já está desativado
        if (-not $usuario.Enabled) {
            Write-Host "⚠️ Usuário '$login' já está desativado!" -ForegroundColor Yellow
            Start-Sleep -Seconds 2
            return
        }

        # Exibir informações do usuário
        Clear-Host
        Write-Host "+==========================================+"
        Write-Host "        INFORMAÇÕES DO USUÁRIO              " -ForegroundColor Yellow
        Write-Host "+==========================================+"
        Write-Host " Nome:        $($usuario.DisplayName)       "
        Write-Host " Login:       $($usuario.SamAccountName)    "
        Write-Host " Email:       $($usuario.EmailAddress)      "
        Write-Host " Cargo:       $($usuario.Title)             "
        Write-Host " Departamento: $($usuario.Department)       "
        Write-Host " Status:      Ativo                          "
        Write-Host "+==========================================+"

        # Solicitar confirmação
        $confirmacao = Read-Host "Deseja desativar este usuário? (S para confirmar / N para cancelar)"

        if ($confirmacao -match "^[Nn]$") {
            Write-Host "⚠️ Operação cancelada. Voltando ao menu..." -ForegroundColor Yellow
            Start-Sleep -Seconds 2
            return
        }

        

        
        try {
            # Desativar o usuário no AD (AccountDisabled = $true)
            Disable-ADAccount -Identity $usuario.SamAccountName
        } catch {
            Write-Host "❌ Erro ao desativar o usuário: $_" -ForegroundColor Red
            return
        }
        

        Write-Host "✅ Usuário desativado com sucesso! (Simulação)" -ForegroundColor Green
        Start-Sleep -Seconds 5

        # Finaliza a função e retorna ao menu principal
        return

    } while ($true)
}



function ReativarUsuario {
    do {
        Clear-Host
        Write-Host "+==========================================+"
        Write-Host "         REATIVAR USUÁRIO NO AD            " -ForegroundColor Yellow
        Write-Host "+==========================================+"

        # Solicitar login do usuário
        $login = Read-Host "Digite o login do usuário (formato nome.sobrenome)"

        # Validar o formato do login
        if ($login -notmatch "^[a-zA-Z]+\.[a-zA-Z]+$") {
            Write-Host "⚠️ Erro: O login deve estar no formato nome.sobrenome" -ForegroundColor Red
            Start-Sleep -Seconds 2
            continue
        }

        # Buscar usuário no AD pelo SamAccountName (login)
        $usuario = Get-ADUser -Filter {SamAccountName -eq $login} -Properties DisplayName, EmailAddress, Title, Department, Enabled -ErrorAction SilentlyContinue

        if (-not $usuario) {
            Write-Host "⚠️ Erro: Usuário '$login' não encontrado no Active Directory." -ForegroundColor Red
            Start-Sleep -Seconds 2
            continue
        }

        # Verificar se o usuário já está ativo
        if ($usuario.Enabled) {
            Write-Host "⚠️ Usuário '$login' já está ativo!" -ForegroundColor Yellow
            Start-Sleep -Seconds 2
            return
        }

        # Exibir informações do usuário
        Clear-Host
        Write-Host "+==========================================+"
        Write-Host "        INFORMAÇÕES DO USUÁRIO              " -ForegroundColor Yellow
        Write-Host "+==========================================+"
        Write-Host " Nome:        $($usuario.DisplayName)       "
        Write-Host " Login:       $($usuario.SamAccountName)    "
        Write-Host " Email:       $($usuario.EmailAddress)      "
        Write-Host " Cargo:       $($usuario.Title)             "
        Write-Host " Departamento: $($usuario.Department)       "
        Write-Host " Status:      Inativo                        "
        Write-Host "+==========================================+"

        # Solicitar confirmação
        $confirmacao = Read-Host "Deseja reativar este usuário? (S para confirmar / N para cancelar)"

        if ($confirmacao -match "^[Nn]$") {
            Write-Host "⚠️ Operação cancelada. Voltando ao menu..." -ForegroundColor Yellow
            Start-Sleep -Seconds 2
            return
        }

       

        
        try {
            # Reativar o usuário no AD (AccountDisabled = $false)
            Enable-ADAccount -Identity $usuario.SamAccountName
        } catch {
            Write-Host "❌ Erro ao reativar o usuário: $_" -ForegroundColor Red
            return
        }
        

        Write-Host "✅ Usuário reativado com sucesso! (Simulação)" -ForegroundColor Green
        Start-Sleep -Seconds 5

        # Finaliza a função e retorna ao menu principal
        return

    } while ($true)
}



function BloquearUsuario {
    Clear-Host
    Write-Host "+============================================+"
    Write-Host "          🔒 BLOQUEAR USUÁRIO                 "
    Write-Host "+============================================+"

    # Solicitar login do usuário
    $login = Read-Host "Digite o login do usuário (exemplo: arthur.pires)"

    # Buscar usuário no AD
    $usuario = Get-ADUser -Filter {SamAccountName -eq $login} -Properties Name, SamAccountName, EmailAddress, Title, Department, LockedOut -ErrorAction SilentlyContinue

    if (-not $usuario) {
        Write-Host "⚠️ Usuário '$login' não encontrado no Active Directory!" -ForegroundColor Red
        Start-Sleep -Seconds 3
        return
    }

    # Exibir informações do usuário
    Write-Host "`n🔎 Informações do usuário encontrado:"
    Write-Host "----------------------------------------"
    Write-Host "📛 Nome:        $($usuario.Name)"
    Write-Host "🔑 Login:       $($usuario.SamAccountName)"
    Write-Host "📧 E-mail:      $($usuario.EmailAddress)"
    Write-Host "💼 Cargo:       $($usuario.Title)"
    Write-Host "🏢 Departamento: $($usuario.Department)"
    Write-Host "🔒 Já está bloqueado? $($usuario.LockedOut)" -ForegroundColor Yellow
    Write-Host "----------------------------------------"

    # Confirmar bloqueio
    $confirmacao = Read-Host "Deseja bloquear este usuário? (S/N)"
    if ($confirmacao -match "^[Ss]$") {
        # COMANDO PARA BLOQUEAR 
        Lock-ADAccount -Identity $usuario.SamAccountName

        Write-Host "✅ Usuário '$login' bloqueado com sucesso! 🔒" -ForegroundColor Green
    } else {
        Write-Host "🚫 Operação cancelada!" -ForegroundColor Yellow
    }

    Start-Sleep -Seconds 3
}



function DesbloquearUsuario {
    Clear-Host
    Write-Host "+============================================+"
    Write-Host "          🔓 DESBLOQUEAR USUÁRIO              "
    Write-Host "+============================================+"

    # Solicitar login do usuário
    $login = Read-Host "Digite o login do usuário (exemplo: arthur.pires)"

    # Buscar usuário no AD
    $usuario = Get-ADUser -Filter {SamAccountName -eq $login} -Properties Name, SamAccountName, EmailAddress, Title, Department, LockedOut -ErrorAction SilentlyContinue

    if (-not $usuario) {
        Write-Host "⚠️ Usuário '$login' não encontrado no Active Directory!" -ForegroundColor Red
        Start-Sleep -Seconds 3
        return
    }

    # Exibir informações do usuário
    Write-Host "`n🔎 Informações do usuário encontrado:"
    Write-Host "----------------------------------------"
    Write-Host "📛 Nome:        $($usuario.Name)"
    Write-Host "🔑 Login:       $($usuario.SamAccountName)"
    Write-Host "📧 E-mail:      $($usuario.EmailAddress)"
    Write-Host "💼 Cargo:       $($usuario.Title)"
    Write-Host "🏢 Departamento: $($usuario.Department)"
    Write-Host "🔒 Está bloqueado? $($usuario.LockedOut)" -ForegroundColor Red
    Write-Host "----------------------------------------"

    # Confirmar desbloqueio
    if (-not $usuario.LockedOut) {
        Write-Host "✅ O usuário '$login' já está desbloqueado!" -ForegroundColor Green
        Start-Sleep -Seconds 3
        return
    }

    $confirmacao = Read-Host "Deseja desbloquear este usuário? (S/N)"
    if ($confirmacao -match "^[Ss]$") {
        # COMANDO PARA DESBLOQUEAR 
        Unlock-ADAccount -Identity $usuario.SamAccountName

        Write-Host "✅ Usuário '$login' desbloqueado com sucesso! 🔓" -ForegroundColor Green
    } else {
        Write-Host "🚫 Operação cancelada!" -ForegroundColor Yellow
    }

    Start-Sleep -Seconds 3
}


do {
    $opcao = MostrarMenu

    switch ($opcao) {
        '1' { ExecutarCriacaoUsuario }
        '2' { ResetarSenhaUsuario }
        '3' { DesativarUsuario }
        '4' { ReativarUsuario }
        '5' { BloquearUsuario }
        '6' { DesbloquearUsuario }
        '0' { exit }  # Se houver opção para sair
    }
} while ($true)
