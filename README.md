# Dotfiles

Мои конфигурационные файлы для macOS.

## Установка

1. Установите Homebrew (если еще не установлен):
```bash
/bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)"
```

2. Склонируйте репозиторий:
```bash
git clone <your-repo-url> ~/dots
cd ~/dots
```

3. Запустите скрипт установки:
```bash
./setup.sh
```

4. Перезапустите терминал.

## Что включено

- **brew**: Brewfile со всеми необходимыми пакетами
- **eza**: Конфигурация темы
- **helix**: Настройки текстового редактора
- **starship**: Конфигурация промпта
- **fastfetch**: Конфигурация системной информации
- **zsh**: Конфигурация shell с алиасами и экспортами

## Управление dotfiles

Добавление новых конфигов:
```bash
# Создайте структуру .config в нужной папке
mkdir -p programname/.config/programname
# Переместите конфиг туда
mv ~/.config/programname/config.yml programname/.config/programname/
# Примените stow
stow programname
```

Удаление симлинков:
```bash
stow -D programname
```
