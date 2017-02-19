Import-module -force '.\Modules\Password_Management.psm1'


Export-Local_Password 'password' "/\Passwords\Passwords.txt" "password_export"
