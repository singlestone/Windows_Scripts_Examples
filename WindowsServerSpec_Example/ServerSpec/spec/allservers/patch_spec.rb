require 'Patch_spec_helper'

describe file('c:\\Windows') do
  it { should be_directory }
  it { should_not be_writable.by('Everyone') }
end

describe group('Guests') do
  it { should exist }
end

describe service('AeLookupSvc') do
   it { should be_installed }
   it { should be_enabled }
   it { should be_running }
   it { should have_start_mode('Automatic') }
end

describe service('BFE') do
   it { should be_installed }
   it { should be_enabled }
   it { should be_running }
   it { should have_start_mode('Automatic') }
end

describe service('BITS') do
   it { should be_installed }
   it { should be_enabled }
   it { should be_running }
   it { should have_start_mode('Automatic') }
end

describe service('CryptSvc') do
   it { should be_installed }
   it { should be_enabled }
   it { should be_running }
   it { should have_start_mode('Automatic') }
end

describe service('DcomLaunch') do
   it { should be_installed }
   it { should be_enabled }
   it { should be_running }
   it { should have_start_mode('Automatic') }
end

describe service('Dhcp') do
   it { should be_installed }
   it { should be_enabled }
   it { should be_running }
   it { should have_start_mode('Automatic') }
end

describe service('Dnscache') do
   it { should be_installed }
   it { should be_enabled }
   it { should be_running }
   it { should have_start_mode('Automatic') }
end

describe service('DPS') do
   it { should be_installed }
   it { should be_enabled }
   it { should be_running }
   it { should have_start_mode('Automatic') }
end

describe service('Eventlog') do
   it { should be_installed }
   it { should be_enabled }
   it { should be_running }
   it { should have_start_mode('Automatic') }
end

describe service('EventSystem') do
   it { should be_installed }
   it { should be_enabled }
   it { should be_running }
   it { should have_start_mode('Automatic') }
end

describe service('gpsvc') do
   it { should be_installed }
   it { should be_enabled }
   it { should be_running }
   it { should have_start_mode('Automatic') }
end

describe service('IKEEXT') do
   it { should be_installed }
   it { should be_enabled }
   it { should be_running }
   it { should have_start_mode('Automatic') }
end

describe service('iphlpsvc') do
   it { should be_installed }
   it { should be_enabled }
   it { should be_running }
   it { should have_start_mode('Automatic') }
end

describe service('KtmRm') do
   it { should be_installed }
   it { should be_enabled }
   it { should be_running }
   it { should have_start_mode('Automatic') }
end

describe service('LanmanServer') do
   it { should be_installed }
   it { should be_enabled }
   it { should be_running }
   it { should have_start_mode('Automatic') }
end

describe service('LanmanWorkstation') do
   it { should be_installed }
   it { should be_enabled }
   it { should be_running }
   it { should have_start_mode('Automatic') }
end

describe service('lmhosts') do
   it { should be_installed }
   it { should be_enabled }
   it { should be_running }
   it { should have_start_mode('Automatic') }
end

describe service('MpsSvc') do
   it { should be_installed }
   it { should be_enabled }
   it { should be_running }
   it { should have_start_mode('Automatic') }
end

describe service('MSDTC') do
   it { should be_installed }
   it { should be_enabled }
   it { should be_running }
   it { should have_start_mode('Automatic') }
end

describe service('netprofm') do
   it { should be_installed }
   it { should be_enabled }
   it { should be_running }
   it { should have_start_mode('Automatic') }
end

describe service('NlaSvc') do
   it { should be_installed }
   it { should be_enabled }
   it { should be_running }
   it { should have_start_mode('Automatic') }
end

describe service('nsi') do
   it { should be_installed }
   it { should be_enabled }
   it { should be_running }
   it { should have_start_mode('Automatic') }
end

describe service('PlugPlay') do
   it { should be_installed }
   it { should be_enabled }
   it { should be_running }
   it { should have_start_mode('Automatic') }
end

describe service('PolicyAgent') do
   it { should be_installed }
   it { should be_enabled }
   it { should be_running }
   it { should have_start_mode('Automatic') }
end

describe service('ProfSvc') do
   it { should be_installed }
   it { should be_enabled }
   it { should be_running }
   it { should have_start_mode('Automatic') }
end

describe service('RemoteRegistry') do
   it { should be_installed }
   it { should be_enabled }
   it { should be_running }
   it { should have_start_mode('Automatic') }
end

describe service('RpcSs') do
   it { should be_installed }
   it { should be_enabled }
   it { should be_running }
   it { should have_start_mode('Automatic') }
end

describe service('SamSs') do
   it { should be_installed }
   it { should be_enabled }
   it { should be_running }
   it { should have_start_mode('Automatic') }
end

describe service('Schedule') do
   it { should be_installed }
   it { should be_enabled }
   it { should be_running }
   it { should have_start_mode('Automatic') }
end

describe service('seclogon') do
   it { should be_installed }
   it { should be_enabled }
   it { should be_running }
   it { should have_start_mode('Automatic') }
end

describe service('SENS') do
   it { should be_installed }
   it { should be_enabled }
   it { should be_running }
   it { should have_start_mode('Automatic') }
end

describe service('slsvc') do
   it { should be_installed }
   it { should be_enabled }
   it { should be_running }
   it { should have_start_mode('Automatic') }
end

describe service('TermService') do
   it { should be_installed }
   it { should be_enabled }
   it { should be_running }
   it { should have_start_mode('Automatic') }
end

describe service('TrustedInstaller') do
   it { should be_installed }
   it { should be_enabled }
   it { should be_running }
   it { should have_start_mode('Automatic') }
end

describe service('W32Time') do
   it { should be_installed }
   it { should be_enabled }
   it { should be_running }
   it { should have_start_mode('Automatic') }
end

describe service('WinHttpAuto-ProxySvc') do
   it { should be_installed }
   it { should be_enabled }
   it { should be_running }
   it { should have_start_mode('Automatic') }
end

describe service('Winmgmt') do
   it { should be_installed }
   it { should be_enabled }
   it { should be_running }
   it { should have_start_mode('Automatic') }
end

describe service('WinRM') do
   it { should be_installed }
   it { should be_enabled }
   it { should be_running }
   it { should have_start_mode('Automatic') }
end

describe service('wuauserv') do
   it { should be_installed }
   it { should be_enabled }
   it { should be_running }
   it { should have_start_mode('Automatic') }
end
