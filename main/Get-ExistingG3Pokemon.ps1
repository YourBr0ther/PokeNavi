
# INITALIZATION
Clear-Host
$scriptLocation = "C:\Scripts\PokeNavi"
Set-Location -Path $scriptLocation

# Create proper name casing
$culture = [System.Globalization.CultureInfo]::CurrentCulture

# FUNCTIONs
function Get-PokemonStats {

    param (
        [Parameter(Mandatory = $true)]
        [int]$id
    )

    $url = "https://pokeapi.co/api/v2/pokemon/$id"

    $response = Invoke-RestMethod -Uri $url -Method Get

    return $response

}

# Get the Substructure Order
function Get-PK3SubstructureOrder {
    param (
        [Parameter(Mandatory = $true)]
        [uint32]$PersonalityValue
    )

    $order = $PersonalityValue % 4
    $permutations = @(
        "ABCD", "ABDC", "ACBD", "ACDB", "ADBC", "ADCB",
        "BACD", "BADC", "BCAD", "BCDA", "BDAC", "BDCA",
        "CABD", "CADB", "CBAD", "CBDA", "CDAB", "CDBA",
        "DABC", "DACB", "DBAC", "DBCA", "DCAB", "DCBA"
    )

    return $permutations[$order]
}

# START SCRIPT BODY
try {
    $pokemonExport = ".\testing\Char.pk3"
    if (Test-Path -Path $pokemonExport) { Write-Host "Pokemon exist. Importing now" } else { Write-Host "There was a problem importing the Pokemon" } 
    $pk3Data = [System.IO.File]::ReadAllBytes($pokemonExport)
}
catch { break }

# Get all of the "normalize values from Pokemon API"
$speciesIndex = [BitConverter]::ToUInt16($pk3Data, 32)

$stats = Get-PokemonStats -id $speciesIndex

$s = [ordered]@{

    NationalPokedexNumber = $stats.id
    Species               = $culture.TextInfo.ToTitleCase($stats.species.name)
    Type1                 = $stats.types.type.name
    Type2                 = ""

}

#$tempNickname = $pk3Data[8..17]
#$tempTrainerName = $pk3Data[20..26]
# $gen3CharacterMap = @(
#     ' ', 'À', 'Á', 'Â', 'Ç', 'È', 'É', 'Ê', 'Ë', 'Ì', 'こ', 'Î', 'Ï', 'Ò', 'Ó', 'Ô', 'Œ', 'Ù', 'Ú', 'Û', 'Ñ', 'ß', 'à', 'á', 'ね', 'Ç', 'È', 'é', 'ê', 'ë', 'ì', 'í', 'î', 'ï', 'ò', 'ó', 'ô', 'œ', 'ù', 'ú', 'û', 'ñ', 'º', 'ª', '⒅', '&', '+', 'あ', 'ぃ', 'ぅ', 'ぇ', 'ぉ', 'ゃ', '=', 'ょ', 'が', 'ぎ', 'ぐ', 'げ', 'ご', 'ざ', 'じ', 'ず', 'ぜ', 'ぞ', 'だ', 'ぢ', 'づ', 'で', 'ど', 'ば', 'び', 'ぶ', 'べ', 'ぼ', 'ぱ', 'ぴ', 'ぷ', 'ぺ', 'ぽ', 'っ', '¿', '¡', '⒆', '⒇', 'オ', 'カ', 'キ', 'ク', 'ケ', 'Í', 'コ', 'サ', 'ス', 'セ', 'ソ', 'タ', 'チ', 'ツ', 'テ', 'ト', 'ナ', 'ニ', 'ヌ', 'â', 'ノ', 'ハ', 'ヒ', 'フ', 'ヘ', 'ホ', 'í', 'ミ', 'ム', 'メ', 'モ', 'ヤ', 'ユ', 'ヨ', 'ラ', 'リ', 'ル', 'レ', 'ロ', 'ワ', 'ヲ', 'ン', 'ァ', 'ィ', 'ゥ', 'ェ', 'ォ', 'ャ', 'ュ', 'ョ', 'ガ', 'ギ', 'グ', 'ゲ', 'ゴ', 'ザ', 'ジ', 'ズ', 'ゼ', 'ゾ', 'ダ', 'ヂ', 'ヅ', 'デ', 'ド', 'バ', 'ビ', 'ブ', 'ベ', 'ボ', 'パ', 'ピ', 'プ', 'ペ', 'ポ', 'ッ', '0', '1', '2', '3', '4', '5', '6', '7', '8', '9', '!', '?', '.', '-', '・', '⑬', '“', '”', '‘', '’', '♂', '♀', '$', ',', '⑧', '/', 'A', 'B', 'C', 'D', 'E', 'F', 'G', 'H', 'I', 'J', 'K', 'L', 'M', 'N', 'O', 'P', 'Q', 'R', 'S', 'T', 'U', 'V', 'W', 'X', 'Y', 'Z', 'a', 'b', 'c', 'd', 'e', 'f', 'g', 'h', 'i', 'j', 'k', 'l', 'm', 'n', 'o', 'p', 'q', 'r', 's', 't', 'u', 'v', 'w', 'x', 'y', 'z', '0', ':', 'Ä', 'Ö', 'Ü', 'ä', 'ö', 'ü'
# )
# $nickname = ""
# foreach ($nicknameLetter in $tempNickname) { $nickname += $gen3CharacterMap[$nicknameLetter - 1] }
# $trainerName = ""
# foreach ($trainerLetter in $tempTrainerName) { $trainerName += $gen3CharacterMap[$trainerLetter - 1] }

$personalityValue = [BitConverter]::ToUInt32($($pk3Data[0..3]), 0)
$substructureOrder = Get-PK3SubstructureOrder -PersonalityValue $personalityValue

Write-Host "Order: $substructureOrder"

$d = $pk3Data[31..81]

$i = 0
foreach ($letter in [char[]]$substructureOrder) {

    if ($letter -eq "A") { $gOffset = $i }
    if ($letter -eq "B") { $aOffset = $i }
    if ($letter -eq "C") { $eOffset = $i }
    if ($letter -eq "D") { $mOffset = $i }

    $i += 13
}

$moves = [ordered]@{

    "Move 1"    = "$($d[$($aOffset+0)])"
    "Move 2"    = "$($d[$($aOffset+2)])"
    "Move 3"    = "$($d[$($aOffset+4)])"
    "Move 4"    = "$($d[$($aOffset+6)])"
    "Move 1 PP" = "$($d[$($aOffset+8)])"
    "Move 2 PP" = "$($d[$($aOffset+9)])"
    "Move 3 PP" = "$($d[$($aOffset+10)])"
    "Move 4 PP" = "$($d[$($aOffset+11)])"
    
}
                
$growth = [ordered]@{
    
    "Species"    = "$($d[$($gOffset+0)..$($gOffset+1)])"
    "Item Held"  = "$($d[$($gOffset+2)..$($gOffset+3)])"
    "Experience" = "$([BitConverter]::ToUInt32($($d[$($gOffset+4)..$($gOffset+7)]), 0))"
    "PP Bonus"   = "$($d[$($gOffset+8)..$($gOffset+9)])"
    "Friendship" = "$($d[$($gOffset+10)])"
    "Unknown"    = "$($d[$($gOffset+11)..$($gOffset+12)])"
    
}
        
$EVs = [ordered]@{
    
    "HP EV"              = "$($d[$($eOffset+0)])"
    "Attack EV"          = "$($d[$($eOffset+1)])"
    "Defense EV"         = "$($d[$($eOffset+2)])"
    "Speed EV"           = "$($d[$($eOffset+3)])"
    "Special Attack EV"  = "$($d[$($eOffset+4)])"
    "Special Defense EV" = "$($d[$($eOffset+5)])"
    
}
        
$ivBytes = $d[$($mOffset+4)..$($mOffset+7)]
$ivValue = [BitConverter]::ToUInt32($ivBytes, 0)
$miscellanoeous = [ordered]@{
            
    "Pokerus Status"     = "$($d[$($mOffset+0)])"
    "Met Location"       = "$($d[$($mOffset+1)])"
    "Origins Info"       = "$($d[$($mOffset+2)..$($mOffset+3)])"
    "HP IV"              = "$($ivValue -band 0x1F)"
    "Attack IV"          = "$(($ivValue -shr 5) -band 0x1F)"
    "Defense IV"         = "$(($ivValue -shr 10) -band 0x1F)"
    "Speed IV"           = "$(($ivValue -shr 15) -band 0x1F)"
    "Special Attack IV"  = "$(($ivValue -shr 20) -band 0x1F)"
    "Special Defense IV" = "$(($ivValue -shr 25) -band 0x1F)"
    
}

$moves
$growth
$EVs
$miscellanoeous

# Write-Host "Growth: $gOffset"
# Write-Host "Attack: $aOffset"
# Write-Host "EVs: $eOffset"
# Write-Host "Misc: $mOffset"

$pokemon = [PSCustomObject]@{
    NationalPokedexNumber = $s.NationalPokedexNumber
    Species               = $s.Species
    Type1                 = $s.Type1
    Type2                 = $s.Type2
    BaseStats             = @{
        HP             = 0
        Attack         = 0
        Defense        = 0
        SpecialAttack  = 0
        SpecialDefense = 0
        Speed          = 0
    }
    Abilities             = @('', '')
    Moves                 = @('', '', '', '')
    Level                 = $pk3Data[84]
    ExperiencePoints      = 0
    IndividualValues      = @{
        HP             = 0
        Attack         = 0
        Defense        = 0
        SpecialAttack  = 0
        SpecialDefense = 0
        Speed          = 0
    }
    EffortValues          = @{
        HP             = 0
        Attack         = 0
        Defense        = 0
        SpecialAttack  = 0
        SpecialDefense = 0
        Speed          = 0
    }
    Nature                = ''
    HeldItem              = ''
    Gender                = ''
    OriginalTrainer       = @{
        Name      = $trainerName
        TrainerID = [BitConverter]::ToUInt16($pk3Data, 4)
        SecretID  = 0
    }
    Friendship            = 0
    Nickname              = $nickname
    ShinyStatus           = $false
    BallCaught            = ''
    Ribbons               = @('', '')
    Markings              = @('', '')
}

#$pokemon