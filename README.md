# birth_certify

# 🪪 Tokenized Birth Certificate System

[![Made with Flutter](https://img.shields.io/badge/Made%20with-Flutter-blue?logo=flutter&logoColor=white)](https://flutter.dev)
[![State Management: Riverpod](https://img.shields.io/badge/State%20Mgmt-Riverpod-green?logo=riverpod)](https://riverpod.dev)
[![License: MIT](https://img.shields.io/badge/License-MIT-lightgrey.svg)](LICENSE)
[![Web Build](https://img.shields.io/badge/Platform-Web-lightblue.svg)](https://flutter.dev/web)

A modern blockchain-ready **digital birth certificate registration platform** built with **Flutter Web**, following **clean architecture**, using **Riverpod** for scalable state management and **GoRouter** for navigation.

---

## ✨ Features

- 🔐 **Secure Login** & authentication flow
- 📝 **Register Birth Certificates** with parent info & NIN
- 📄 **Paginated Certificate Listing** with CSV export
- 📁 **Upload Supporting Documents** (hospital slips, affidavits)
- 🧠 **Clean Architecture** (UI → Provider → Repository → DataSource)
- 🪙 **Wallet Address Linkage** for blockchain anchoring
- 📐 **Fully Responsive Design** with consistent theming
- 🎨 **Material 3** and **Google Fonts** support

---

## 📁 Folder Structure
lib/
├── core/ # Shared constants, themes, routing
│ ├── constants/
│ ├── router/
│ └── widgets/
├── features/ # Each module has data/domain/presentation
│ ├── auth/
│ ├── certificate/
│ └── registration/
└── main.dart



---

## ⚙️ Tech Stack

| Tool / Library      | Purpose                         |
|---------------------|---------------------------------|
| [Flutter Web](https://flutter.dev/web) | Frontend & UI |
| [Riverpod](https://riverpod.dev) | State Management |
| [GoRouter](https://pub.dev/packages/go_router) | Declarative Routing |
| [Google Fonts](https://pub.dev/packages/google_fonts) | Custom Typography |
| [Material 3](https://m3.material.io) | UI Design Framework |
| [Clean Architecture](https://resocoder.com/clean-architecture-tdd/) | Scalable Structure |

