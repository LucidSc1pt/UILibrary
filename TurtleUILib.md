# 🐢 Turtle UI Library

Dokumentasi resmi untuk **Turtle UI Library** di Roblox. Library ini mempermudah pembuatan antarmuka pengguna (UI) yang responsif dan fleksibel.

---

## 📌 Quick Start

Gunakan *script* berikut untuk memuat library ke dalam proyek kamu:

```luau
local library = loadstring(game:HttpGet("https://raw.githubusercontent.com/LittenHub/Fuckyouman/refs/heads/main/TurtleUI.lua"))()
```
📑 Table of Contents
 * Creating a Window
 * UI Components
   * Button
   * Toggle
   * Slider
   * Dropdown
   * Color Picker
   * Text Box
   * Label
 * Utilities
   * Notification
   * Destroy UI
 * Change Log



### 🪟 Creating a Window
Membuat jendela UI utama.
```luau
local Window = library:Window({
    Name = "Turtle Hub",
    Size = UDim2.new(0, 500, 0, 400),
    Position = UDim2.new(0.5, -250, 0.5, -200)
})
```
**Parameters**
| Parameter | Type | Default | Description |
|---|---|---|---|
| Name | string | "Window" | Judul utama jendela UI |
| Size | UDim2 | Optional | Ukuran dimensi jendela |
| Position | UDim2 | Optional | Posisi awal jendela di layar |

## 🧩 UI Components
**Button**
Membuat tombol interaktif biasa.
```luau
Window:Button({
    Name = "Click Me",
    Callback = function()
        print("Button clicked!")
    end
})
```
| Parameter | Type | Description |
|---|---|---|
| Name | string | Teks pada tombol |
| Callback | function | Fungsi yang dijalankan saat tombol diklik |

---

**Toggle**
Membuat sakelar ON/OFF.
```luau
Window:Toggle({
    Name = "Auto Farm",
    Default = false,
    Loop = false,
    Callback = function(state)
        print("Toggle State:", state)
    end
})
```
| Parameter | Type | Default | Description |
|---|---|---|---|
| Name | string | - | Label toggle |
| Default | boolean | false | Status awal toggle |
| Loop | boolean | false | Menjalankan looping otomatis selama bernilai true |
| Callback | function | - | Mengembalikan nilai boolean (true/false) |

---

**Slider**
Membuat pengatur nilai angka bergeser.
```luau
Window:Slider({
    Name = "WalkSpeed",
    Min = 16,
    Max = 100,
    Default = 16,
    Increment = 1,
    Callback = function(value)
        print("Slider Value:", value)
    end
})
```
| Parameter | Type | Default | Description |
|---|---|---|---|
| Name | string | "Slider" | Label slider |
| Min | number | 1 | Nilai minimum |
| Max | number | 100 | Nilai maksimum |
| Default | number | Max / 2 | Nilai awal |
| Increment | number | 1 | Kelipatan pergeseran nilai |
| Callback | function | - | Mengembalikan nilai number hasil geseran/input |

---

**Dropdown**
Membuat menu pilihan drop-down yang mendukung mode Single Select maupun Multi Select.
```luau
local dropdown = Window:Dropdown({
    Name = "Select Option",
    Items = {
        "Option 1",
        "Option 2",
        { PlaceHolder = "-- Extra Options --" },
        "Option 3"
    },
    MultiSelect = false,
    Callback = function(selected)
        print("Selected:", selected)
    end
})
```
| Parameter | Type | Default | Description |
|---|---|---|---|
| Name | string | "Dropdown" | Judul/Placeholder utama dropdown |
| Items | table | {} | Daftar item string atau pembatas placeholder |
| MultiSelect | boolean | false | Memungkinkan memilih lebih dari satu item |
| Callback | function | - | Mengembalikan string/nil (single) atau table (multi) |

**Dropdown Methods**
Kamu dapat memanipulasi opsi dropdown secara dinamis setelah dibuat:
-- Menambahkan tombol baru
```luau
dropdown:Button("Option 4")
```
-- Menghapus tombol yang ada
```luau
dropdown:Remove("Option 1")
```
-- Menambahkan pemisah (placeholder)
```luau
dropdown:AddPlaceholder("-- Category 2 --")
```

---

**Color Picker**
Membuat pemilih warna RGB/HSV.
```luau
Window:ColorPicker({
    Name = "ESP Color",
    Default = Color3.fromRGB(255, 0, 0),
    Callback = function(color)
        print("Selected Color:", color)
    end
})
```
| Parameter | Type | Default | Description |
|---|---|---|---|
| Name | string | "Color Picker" | Label pemilih warna |
| Default | Color3 | Color3.fromRGB(255, 255, 255) | Warna awal |
| Callback | function | - | Mengembalikan objek Color3 |

---

**Text Box**
Membuat kolom input teks/angka.
```luau
Window:Box({
    Name = "Target Player",
    Callback = function(text, focusLost)
        if focusLost then
            print("Entered Text:", text)
        end
    end
})
```
| Parameter | Type | Description |
|---|---|---|
| Name | string | Label kolom input |
| Callback | function | Mengembalikan (text: string, focusLost: boolean) |

---

**Label**
Menampilkan teks informasi statis atau berwarna rainbow.
```luau
Window:Label({
    Name = "Status: Active",
    Color = Color3.fromRGB(0, 255, 0) -- Bisa diisi "Rainbow" untuk efek warna bergerak
})
```
| Parameter | Type | Default | Description |
|---|---|---|---|
| Name | string | - | Teks yang ditampilkan |
| Color | Color3 / string | Color3.fromRGB(255, 255, 255) | Warna teks atau pasang "Rainbow" |

## 🛠️ Utilities
**Notification**
Menampilkan notifikasi popup di sudut layar.
```luau
library:Notification({
    Title = "Script Loaded!",
    Content = "Turtle UI has been successfully executed.",
    Time = 5
})
```
| Parameter | Type | Default | Description |
|---|---|---|---|
| Title | string | "Notification" | Judul notifikasi |
| Content | string | "" | Isi pesan |
| Time | number | 5 | Durasi notifikasi muncul (dalam detik) |

---

**Destroy UI**
Menghapus seluruh antarmuka GUI dari memori.
```luau
library:Destroy()
```

# 📜 Change Log
[September 12, 2026]
* Added: Fitur MultiSelect pada komponen Dropdown.
* Added: Pengaturan Loop pada komponen Toggle.
* Added: Pengaturan custom Position dan ukuran X pada Window.
* Added: Sistem antarmuka baru berbasis Scrolling UI.
* Fixed: Memperbaiki bug fungsionalitas dan beberapa perbaikan performa umum.
* Removed: fitur Toggle lama dan menggantinya dengan struktur baru.



[December 22, 2025]
* Refactored: Memperbarui sistem drag/geser pada jendela UI (Window drag function).



[December 15, 2025]
* Added: Menambahkan opsi eksekusi looping pada Toggle.



[September 6, 2025]
* Improved: Menambahkan gaya penulisan panggilan fungsi bergaya Orion & Rayfield Library.



[September 2, 2025]
* Added: Fitur Placeholder teks di dalam daftar Dropdown.



[August 30, 2025]
* Added: Sistem Notification bawaan library.
* Fixed: Memperbaiki ketidaksesuaian pemilihan warna pada komponen ColorPicker.
