# MangoCare Flutter App

MangoCare (ম্যাঙ্গো-কেয়ার) is a bilingual (English/Bangla) agricultural mobile application that uses a local, offline TensorFlow Lite (`.tflite`) model to diagnose mango leaf diseases via the device camera or gallery, providing instant treatment plans and logging scan history.

---
You can just test the app in a cloud-emulator without installing on your phone. Here is the link:
https://appetize.io/app/b_4tlweuxwgwb6qazyurjuxktubq

*The emulator may take few minutes to reload and then tap and the application will be opened and fully functional*
---


## 🤝 How to Set Up the Project (Complete Guide)

If you are setting up this project for the first time, follow these steps exactly. This guide assumes you are starting from scratch.

### Step 1: Download the Code
1. Make sure you have [Git](https://git-scm.com/downloads) installed.
2. Open a terminal and clone this repository to your computer:
   ```bash
   git clone <your-repository-url>
   ```

### Step 2: Install the Flutter SDK
1. Download the latest **Flutter SDK** from the [official website](https://docs.flutter.dev/get-started/install).
2. Extract the downloaded folder to a permanent location on your hard drive (e.g., `C:\src\flutter`).
3. Add the `flutter\bin` folder to your computer's **System PATH** environment variable so you can run Flutter commands from any terminal.

### Step 3: Install Android Studio (For the Android Tools)
Even if you don't write code in Android Studio, you **must** install it because it provides the tools needed to build an Android app.
1. Download and install [Android Studio](https://developer.android.com/studio).
2. Open it and click through the initial Setup Wizard (choose "Standard" setup). This will automatically download the Android SDK.
3. Once on the Welcome screen, click **More Actions** (or the three dots) > **SDK Manager**.
4. Go to the **SDK Tools** tab and ensure the following are checked and installed:
   * **Android SDK Build-Tools**
   * **Android SDK Command-line Tools (latest)**
   * **Android Emulator**
   * **NDK (Side by side)** *(This is critical for our AI plugins to compile!)*

### Step 4: Install a Code Editor
1. We highly recommend downloading [Visual Studio Code (VS Code)](https://code.visualstudio.com/).
2. Open VS Code, go to the "Extensions" tab on the left, and search for **Flutter**.
3. Install the official Flutter extension (this will automatically install the Dart extension as well).

### Step 5: Enable Developer Mode (Windows Only)
This is a strict requirement for the Camera plugin to work during compilation.
1. Press the Windows Key and type `Developer settings`.
2. Turn the toggle on for **Developer Mode**.
3. This allows Flutter to create symbolic file links, which the camera requires.

### Step 6: Verify Your Setup
Open a brand new terminal and run:
```bash
flutter doctor
```
This command checks your system and tells you if anything is missing. Ensure that Flutter and Android Studio both have green checkmarks. (If it complains about Android licenses, just run `flutter doctor --android-licenses` and press 'y' to accept them).

### 🚀 Running the App (A Beginner's Guide)

Once your system is set up, here is exactly how you start, run, and build the Flutter project.

#### 1. Fetching Dependencies
Before you can run the app for the first time (or after sharing it), you need to download all the external packages. Open a terminal inside the project folder and run:
```bash
flutter pub get
```
* **What it does:** This reads the `pubspec.yaml` file and downloads all the required libraries (like the AI and Camera tools) into your project.

#### 2. Running the App (Debug Mode)
To see the app on your phone or emulator while you are writing code, run:
```bash
flutter run
```
* **What it does:** This compiles a "Debug" version of the app and installs it on your connected device. 
* **When to use it:** Use this 99% of the time during active development.
* **Advanced Feature (Hot Reload):** While the app is running in debug mode, if you change a line of code and save it, you can just press `r` in the terminal. The app will instantly update on your screen without needing to fully restart! This is Flutter's famous "Hot Reload".

#### 3. Building an APK (Release Mode)
When you are completely finished developing and want to send the app to a friend, install it permanently on your phone, or upload it to the Play Store, you need to "build" it.
```bash
flutter build apk --release
```
* **What it does:** This strips out all the debugging tools, optimizes the code, and compiles a highly efficient, standalone Android package (`.apk`).
* **When to use it:** Only use this when you want a final, polished product to distribute.
* **Why it matters:** If you install a Debug app on a phone, it will run extremely slow and have a red "Debug" banner in the corner. A Release build runs at a smooth 60 or 120 FPS because it utilizes the device's hardware acceleration properly.

#### 4. Clearing the Cache (When things break)
Sometimes, if you upgrade Flutter, change native Android code, or experience weird compiler errors, the app will refuse to build.
```bash
flutter clean
```
* **What it does:** This deletes the `build/` folder and forces Flutter to start completely from scratch on the next run.
* **When to use it:** Run this if you get strange errors, or before you ZIP the folder to send to someone else (since it deletes gigabytes of temporary files). Note that you will need to run `flutter pub get` again after cleaning.

---

## 📜 Original Project Architecture & PRD

### Tech Stack & Dependencies
- **Machine Learning:** `tflite_flutter` (for offline inference) and `image` (for image matrix resizing/manipulation).
- **Media:** `camera` (for live viewfinder) and `image_picker` (for gallery uploads).
- **Local Storage:** `sqflite` and `path_provider` (for saving scan history locally).
- **State Management:** `provider` (Keep state management simple and modular).

### Machine Learning Specifications
- **Model Type:** Float16 Quantized TFLite (no embedded preprocessing layers).
- **Input Tensor Shape:** `[1, 256, 256, 3]` (Batch of 1, 256×256 pixels, 3 RGB channels).
- **Preprocessing:** The `TFLiteService` in Dart executes a strict normalization pipeline before inference: resizing to 256x256, and dividing raw pixel RGB values by 255.0 to map them into the `[0.0, 1.0]` range.
- **Hardware Acceleration:** Attempts GPU acceleration (`GpuDelegateV2`), gracefully falling back to CPU execution if the device lacks support.

### Architecture
- `/models` (Data classes for ScanHistory, TreatmentPlan)
- `/services` (TFLite helper class, Database helper class)
- `/providers` (State management for language toggle and history)
- `/screens` (Home, Processing, Results, History, AskExpert)
- `/widgets` (Reusable UI components)
- `/utils` (Constants, color palettes, translations)
