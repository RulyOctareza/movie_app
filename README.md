<p align="center">
  <img src="docs/preview/hero.svg" alt="Movie App — ilustrasi aplikasi katalog film" width="100%">
</p>

<h1 align="center">Movie App — Expert Flutter</h1>

<p align="center">
  <b>Jelajahi film dan serial TV, simpan watchlist untuk ditonton offline.</b><br>
  Clean Architecture · Provider · SQLite
</p>

<p align="center">
  <a href="https://flutter.dev"><img alt="Flutter" src="https://img.shields.io/badge/Flutter-3.x-02569B?logo=flutter&logoColor=white"></a>
  <img alt="Provider" src="https://img.shields.io/badge/State-Provider-5C6BC0">
  <img alt="SQLite" src="https://img.shields.io/badge/Storage-SQLite-00599C?logo=sqlite&logoColor=white">
  <img alt="Arch" src="https://img.shields.io/badge/Architecture-Clean-0D9488">
</p>

---

## ✨ Preview

<p align="center">
  <img src="docs/preview/hero.png" alt="Mockup gelap Movie App" width="90%">
</p>

> **Catatan:** gambar di atas adalah *ilustrasi konsep*, bukan screenshot asli.

---

## 📖 Tentang

Aplikasi katalog film dan TV series dengan pencarian, halaman detail, serta watchlist yang
tersimpan di SQLite sehingga bisa dibuka tanpa internet. Proyek ini dikerjakan untuk
submission **Expert Flutter** Dicoding dengan penekanan pada Clean Architecture dan
pemisahan layer yang jelas.

---

## 🌟 Fitur

- 🎬 **Home film & TV series**
- 🔎 **Pencarian** film dan serial
- 📄 **Detail film**, detail serial, dan detail episode
- 🔖 **Watchlist offline** (SQLite)
- 🖼️ Caching gambar poster
- 🧱 Clean Architecture: `core`, `data`, `domain`, `presentation`
- 💉 Dependency injection dengan `get_it`

---

## 🛠️ Tech Stack

| Area | Pilihan |
|---|---|
| Framework | Flutter |
| State management | Provider |
| Database lokal | `sqflite` |
| HTTP | `http` |
| Functional | `dartz` (Either) |
| DI | `get_it` |
| UI | Google Fonts, cached network image |

---

## 🚀 Menjalankan

```bash
flutter pub get
flutter run
```

---

## 🧪 Testing

```bash
flutter analyze
flutter test
```
