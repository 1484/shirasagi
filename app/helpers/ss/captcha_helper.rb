module SS::CaptchaHelper
  def show_captcha
    h = []
    h << '<div class="simple-captcha">'
    h << '  <div class="image">'
    h << '    <img src="data:image/jpeg;base64,/9j/4AAQSkZJRgABAQAAAQABAAD/   2wBDAAMCAgICAgMCAgIDAwMDBAYEBAQEBAgGBgUGCQgKCgkICQkKDA8MCgsOCwkJDRENDg8QEBEQCgwSExIQEw8QEBD/2wBDAQMDAwQDBAgEBAgQCwkLEBAQEBAQEBAQEBAQEBAQEBAQEBAQEBAQEBAQEBAQEBAQEBAQEBAQEBAQEBAQEBAQEBD/wAARCAAcAGQDAREAAhEBAxEB/8QAGwABAAICAwAAAAAAAAAAAAAAAAYHBQgBBAn/xAAtEAABAwQBAwMDAwUAAAAAAAABAgQDAAUGBxESITEiCBRRCRNxkTIzQUJDYf/EABoBAQEBAQEBAQAAAAAAAAAAAAACBQQDBgH/xAAoEQACAgECBQUAAwEAAAAAAAABAAIRAwQFUSExEkEGExRxYSIygeH/2gAMAwEAAhEDEQA/APVOiVEqJ4UpKEla1BKR3JJ4Aomto/cDr50rM4bZI/uLrBU9d0as4UyzKRxz1RJCvWP2PatU7NqY+yZ0Bl6E8h/vBj3Bz/GoXH3IfbyzhU4fsM2aRRjla57CpASP+kr7VuD0PucjUTA/Uv8Aj5fJgOLZewvdNqHWbWzT5HdXi5r6yRcGrRo1MzgNljkSLQD6U/r9DWTovT+u15mMURUTRJNC+AfSWWMOrYOF5nj2wMaZZbiz4O7a/j/JDJxwePoR/YiszVaXLo8pw5hUg3GQkLDHG28MBuG1pNN2l9NcciatS8epaoC4WKPAEy+fSonwACf0rqltOpho/nzFQJoX1P0GfciZdo6s/rNbVEqJUSolRKietcrczu9vc2q4QiVq8iXBNGfCkKBBH7GrhOWOQnHqERbqHsLU2L+0DLrXvjWCJ4WVzexWjKrTLOZA/Zyq9JiB/wBqFcEDvyORX22i3HN6lwS27WdYgyhLgRx/C80oDCe+LZvult2NvNHO0NbPbw7vji3tmbYtAXLtUs8ZVDFGlPXJKY+shCRz6SfANZHp+eWO4DukaiJEm+QoHmT0AuubeWuxq7NZ2mk9i7kzzINfz5cp+0x204zHCI1QtW620bVLeWRR4b9TpSlqHHV0KC+OnvWxpRLddLpNNiy+3RySn1smzKwPNR5DxfLqxL+EpEi+jhMd3DYdP6YRq1htKxWU4Y1cIyG6PHsDW7v3gUpckFvYyqEg9SulMsiQAkApSrzXRn2zJuWv+ZLDKXuEdoAJiB4M5Dl+kA/ZDImIR7b6Mr+3jiOumGC3XYNmyqx3rMMxm+dfAyuUbuZnGFr/AAQSkKUsKCVkqKuCVKUa4vWmp1U9RHTZISjix8o2CATysjx9V4a04jVg8y7c18U9KolRKiVEqJUSomB5tqKybBy/G8myh85dNMWcfOY2rsGynfBCZpB/mUgngHsD3rR0u5ZNFgyYcIAMxRPmuA4WxKAkQT4cirXdncbBGxbk4cvnzZoGdugnVzBb0n+ouFHgSL8KX54HHjmvL5uSOm+LAUCbPE8L/B4D+9o7u5iu0fbdrvbWSscryND+F8zTFHL8R0uJDuOKQyRomSDxIEqJI58c12bfvmq27FLDiqjfUXVijXC2Z4ozNln7zE8XuUao7njlseBaOhfyGkcvWOOOD1A89vrWbHUZoG4TI+iW6BYbpjRmK6NYXKy4eoi1vHcjps3khR1tErUVKiTKPUqMKJKQr+I7DtXfum7Zt2lHJn/sBRPGvNcePFmGMY+QbIrKbVEqJUSolRKiVEqJUSolRKiVEqJUSon/2Q==">'
    h << '  </div>'
    h << '  <div class="field">'
    h << '     <input type="text" name="answer[captcha_answer]" id="answer_captcha_answer" />'
    h << '  </div>'
    h << '  <div class="captcha-label">'
    h << "    #{t "simple_captcha.label"}"
    h << '  </div>'
    h << '</div>'
    h.join("\n").html_safe
  end
end
