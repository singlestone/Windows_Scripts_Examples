require 'serverspec'
require 'winrm'

set :backend, :winrm

user = 'username'
pass = 'password'
endpoint = "http://#{ENV['TARGET_HOST']}:5985/wsman"

winrm = WinRM::WinRMWebService.new(endpoint, :negotiate, :user => user, :pass => pass)

# suppress warnings
winrm.logger.level = :error

winrm.set_timeout 300 # 5 minutes max timeout for any operation
Specinfra.configuration.winrm = winrm

