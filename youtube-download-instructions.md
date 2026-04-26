# Инструкция: как скачивать большие видео с YouTube через yt-dlp

Эта инструкция для Windows PowerShell. Инструменты уже установлены:

- `yt-dlp` - скачивает видео с YouTube.
- `ffmpeg` - объединяет видео и звук в один файл.

## 1. Открой PowerShell

Нажми `Win`, напиши `PowerShell`, открой обычный **Windows PowerShell**.

Важно: если PowerShell был открыт до установки `yt-dlp` и `ffmpeg`, закрой его и открой заново.

## 2. Проверь, что все установлено

Вставь в PowerShell:

```powershell
yt-dlp --version
```

Должно показать примерно:

```text
2026.03.17
```

Потом вставь:

```powershell
ffmpeg -version
```

Должно показать строку примерно:

```text
ffmpeg version 8.1...
```

Если обе команды что-то показывают, все готово.

## 3. Создай папку для видео

Например, пусть ролики сохраняются в `C:\YouTube`.

В PowerShell вставь:

```powershell
mkdir C:\YouTube
```

Если такая папка уже есть, ничего страшного.

## 4. Скопируй ссылку на YouTube-видео

Открой YouTube и скопируй ссылку на нужный ролик.

Например:

```text
https://www.youtube.com/watch?v=XXXXXXXXXXX
```

## 5. Скачай видео в максимальном качестве

Вставь такую команду, только замени ссылку в конце на свою:

```powershell
yt-dlp -f "bv*+ba/b" --merge-output-format mkv -P "D:\YouTube" "https://www.youtube.com/watch?v=uW91SdM87JM"
```

Что это значит:

- `-f "bv*+ba/b"` скачивает лучшее видео и лучший звук.
- `--merge-output-format mkv` объединяет их в один файл `.mkv`.
- `-P "D:\YouTube"` сохраняет файл в папку `D:\YouTube`.
- Ссылка в конце должна быть в кавычках.

Для больших и качественных видео `.mkv` обычно самый надежный вариант.

## 6. Если хочешь именно MP4

Используй эту команду вместо предыдущей:

```powershell
yt-dlp -f "bv*[ext=mp4]+ba[ext=m4a]/b[ext=mp4]/b" --merge-output-format mp4 -P "D:\YouTube" "https://www.youtube.com/watch?v=Cm50HZtwDXs"
```

MP4 удобнее для телефонов, телевизоров и простых плееров. Но иногда максимальное качество на YouTube доступно удобнее через `.mkv`.

## 7. Если загрузка оборвалась

Ничего страшного. Просто запусти ту же самую команду еще раз.

`yt-dlp` обычно продолжит загрузку или докачает файл.

## 8. Если нужно скачать плейлист

Скопируй ссылку на плейлист и вставь:

```powershell
yt-dlp -f "bv*+ba/b" --merge-output-format mkv -P "D:\YouTube" "https://www.youtube.com/playlist?list=XXXXXXXXXXX"
```

Если хочешь скачать только одно видео, а ссылка случайно содержит плейлист, добавь `--no-playlist`:

```powershell
yt-dlp --no-playlist -f "bv*+ba/b" --merge-output-format mkv -P "D:\YouTube" "https://www.youtube.com/watch?v=XXXXXXXXXXX"
```

## 9. Самая удобная команда

Начни с этой команды:

```powershell
yt-dlp -f "bv*+ba/b" --merge-output-format mkv -P "D:\YouTube" "ССЫЛКА_НА_ВИДЕО"
```

Пример:

```powershell
yt-dlp -f "bv*+ba/b" --merge-output-format mkv -P "D:\YouTube" "https://www.youtube.com/watch?v=dQw4w9WgXcQ"
```

Тебе нужно заменить только `ССЫЛКА_НА_ВИДЕО` на реальную ссылку.

