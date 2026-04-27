@echo off
echo Windows Firewall: 8001 portu icin kural ekleniyor...
netsh advfirewall firewall add rule name="DeLeA Backend 8001" dir=in action=allow protocol=TCP localport=8001
echo Tamamlandi. Telefon artik backend'e baglanabilmeli.
pause
