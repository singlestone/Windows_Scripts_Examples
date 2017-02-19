$path = "F:\"
$list = Get-ChildItem $path

foreach($item in $list) {
   $name = $item.Name
   Set-Location "$path\$name"
   7z a -tzip "$path\$name.zip" *
   Set-Location $path
}

