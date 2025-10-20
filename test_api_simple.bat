@echo off
echo.
echo Testing Gemini API Key...
echo.

curl -X POST "https://generativelanguage.googleapis.com/v1beta/models/gemini-1.5-flash:generateContent?key=AIzaSyDmzd-Zccd3zYKxAsipupOzlQyfruHjCQQ" ^
  -H "Content-Type: application/json" ^
  -d "{\"contents\":[{\"parts\":[{\"text\":\"Say hello in one word\"}]}]}"

echo.
echo.
pause

