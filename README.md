# Exter Library

Exter Library adalah Roblox GUI library yang bisa dipakai secara universal (mirip gaya pemakaian Rayfield), jadi siapa pun bisa `loadstring` lalu langsung bikin UI.

## Tujuan
- API ringan dan reusable untuk banyak script.
- Bisa dipakai lintas project/executor yang support `loadstring` + `game:HttpGet`.
- Mudah dibagikan karena cukup 1 file library.

## Cara Pakai (Universal)

> Ganti URL di bawah ke raw file yang kamu host sendiri (GitHub raw / CDN kamu).

```lua
local ExterLibrary = loadstring(game:HttpGet("https://raw.githubusercontent.com/SOBING4413/Exter-Library/main/ExterLibrary"))()

local Window = ExterLibrary:Window({
    Name = "Exter Demo",
    Bind = Enum.KeyCode.RightControl
})

local MainTab = Window:Tab({
    Name = "Main",
    Icon = "home"
})

MainTab:Button({
    Name = "Test Notify",
    Callback = function()
        ExterLibrary:Notify({
            Name = "Exter Library",
            Content = "GUI berhasil jalan.",
            Time = 3
        })
    end
})
```

## Contoh Gaya Rayfield

Kalau kamu pengen nuansa pemanggilan seperti:

```lua
local Rayfield = loadstring(game:HttpGet('https://sirius.menu/rayfield'))()
```

maka di Exter Library cukup:

```lua
local RayfieldStyle = loadstring(game:HttpGet("https://raw.githubusercontent.com/SOBING4413/Exter-Library/main/ExterLibrary"))()
```

Karena file sekarang mengembalikan API publik library (alias `ExterLibrary`), jadi bebas dinamain variabel apa pun di sisi user script.

## Catatan Distribusi
- Simpan file library di URL raw yang publik.
- Pakai versi branch/tag yang stabil saat dibagikan.
- Jika update breaking change, sebaiknya sediakan changelog.

## Lisensi
Repo ini sudah menyertakan file `LICENSE`. Ikuti ketentuan lisensi tersebut saat redistribusi.
