# Nurse2 – AI-Powered Nurse Assistant

## Introduction

Nurse2 is an advanced, cross-platform healthcare application engineered to optimize the workflow of nursing professionals and clinical staff. By integrating state-of-the-art artificial intelligence, robust voice recognition, and a secure cloud backend, Nurse2 delivers a comprehensive solution for task management, patient vital recording, and clinical note-taking. The application is architected for reliability, extensibility, and compliance with healthcare standards. **At present, Nurse2 is supported exclusively on Android platforms.**

---
<img width="300" height="630" alt="nurse_screenshot_1" src="https://github.com/user-attachments/assets/e135a888-f14c-4dcf-8489-cfac88c4175c" />
&nbsp;&nbsp;&nbsp;
<img width="300" height="630" alt="nurse_screenshot_2" src="https://github.com/user-attachments/assets/de7c547e-1845-4549-9136-a40623772400" />
&nbsp;&nbsp;&nbsp;
<img width="300" height="630" alt="nurse_screenshot_3" src="https://github.com/user-attachments/assets/f15aead7-2aa5-4da4-8469-7d914b2ebb79" />

---

## Use Case Scenarios

* **Voice-Driven Task Management:** Enables clinical staff to create, edit, and manage reminders and tasks through natural speech, minimizing manual data entry and reducing administrative burden.
* **Automated Patient Vitals Documentation:** Facilitates the recording of patient vital signs via conversational input, with AI-driven extraction and structuring of all relevant clinical data.
* **Real-Time Data Synchronization:** Ensures that all tasks, chats, and notes are instantly synchronized across authorized devices using Firebase Cloud Firestore, supporting collaborative care.
* **Integrated Clinical Notes:** Allows for the creation and management of voice-to-text notes, which can be associated with specific patient conversations for comprehensive documentation.
* **Mobile-First Design:** While the architecture is extensible to other platforms, the current release is fully operational only on Android devices.

---

## Feature Overview

### Voice-Activated Task Management

* **Natural Language Processing:** Users can dictate tasks and reminders, which are transcribed and refined using an AI model to ensure clarity and clinical appropriateness.
* **Contextual Data Extraction:** The system automatically identifies and extracts due dates, times, and patient room numbers from spoken input.
* **Manual Data Entry:** Users retain the ability to add or edit tasks with custom due dates and room numbers through a structured interface.
* **Immediate Feedback:** Real-time transcription and animated feedback provide assurance of accurate data capture.

### Advanced Task Management Interface

* **Comprehensive Task List:** All tasks are presented with completion status, due time, and room number, supporting efficient workflow management.
* **Sorting and Filtering:** Tasks can be sorted by creation date, due time, or room number, and filtered via a robust search interface.
* **Task Lifecycle Management:** Inline editing and deletion are supported, with confirmation dialogs to prevent accidental data loss.
* **Manual Task Addition:** Dialog-driven interface for adding new tasks, with optional due time and room number fields.

### Patient Vitals Recording (Chat Module)

* **Conversational Data Entry:** Patient information can be entered via natural language, either through speech or text.
* **AI-Driven Data Structuring:** The AI model extracts and structures the following vital signs:

  * Patient Name
  * Age
  * Blood Pressure (systolic/diastolic)
  * Heart Rate
  * Respiratory Rate
  * Body Temperature
  * Oxygen Saturation
* **Persistent Chat Sessions:** Each patient conversation is maintained as a discrete chat session, preserving the full clinical context and history.
* **Notes Overlay:** Clinicians can attach, edit, and manage notes for each chat session, supporting comprehensive patient documentation.
* **Session Management:** Chats can be renamed or deleted, with all associated messages and notes managed accordingly.

### Clinical Notes System

* **Voice-to-Text Note Creation:** Notes can be created and edited using either speech or text input, with real-time transcription.
* **Patient-Specific Organization:** Notes are systematically organized by chat session, ensuring clear association with patient records.
* **Full Note Lifecycle:** Notes can be updated, deleted, and managed with immediate synchronization across devices.

### User Interface and User Experience

* **Material 3 Design Principles:** The application adheres to the latest Material Design standards, ensuring a modern, clean, and professional appearance.
* **Adaptive Theming:** Automatic support for light and dark modes, with dynamic color adaptation based on system settings.
* **Advanced Animations:** Utilizes Lottie animations for voice, typing, and transitions, enhancing user engagement and clarity.
* **Responsive Layout:** The interface is designed to function optimally on a wide range of device sizes and orientations (current release: Android only).
* **Accessibility Compliance:** Large touch targets, high-contrast color schemes, and readable fonts are employed to maximize accessibility.

---

## System Architecture and Data Flow

### Frontend

* **Framework:** Flutter 3.8.1+
* **User Interface:** Material 3, custom widgets (notably `ChatBubble`), and Lottie animations for enhanced interactivity.
* **State Management:** Utilizes StatefulWidget and setState for local state, with real-time updates from Firestore.
* **Voice Processing:** Employs Cheetah Speech-to-Text for on-device voice recognition, ensuring privacy and low latency.
* **AI Integration:** Communicates with a dedicated HTTP API endpoint for LLM-based natural language processing and data extraction.

### Backend and Services

* **Database:** Firebase Firestore (NoSQL, real-time synchronization, scalable for clinical environments).
* **Cloud Storage:** Firebase Cloud Storage (reserved for future expansion, e.g., file attachments).
* **AI Services:**

  * Cheetah Speech-to-Text API (local and web support for future extensibility)
  * AI model (deployed as a secure HTTP API for NLP tasks)

### Data Flow Diagram

```
Voice Input → Cheetah Speech-to-Text → AI Processing → Firestore Storage → Real-time UI
```

---

## Project Directory Structure

```
lib/
  main.dart            # Application entry point, navigation, and all main screens
  chat_bubble.dart     # Custom chat bubble widget for chat UI
  firebase_options.dart# Firebase configuration (auto-generated)
assets/
  cheetah_model.pv     # Cheetah Speech-to-Text model
  lottie/              # Lottie animation files
android/, ios/, web/   # Platform-specific configurations and assets
pubspec.yaml           # Flutter dependencies and asset declarations
firebase.json          # Firebase hosting and configuration
```

---

## Application Modules and User Flows

### Home Screen

* **Voice Task Creation:** Users initiate task creation by tapping the microphone, dictating the task or reminder, and receiving live transcription feedback.
* **AI-Enhanced Polishing:** The AI model refines the task description for clarity and professionalism.
* **Automated Data Extraction:** The system parses date, time, and room number from the spoken input.
* **Navigation:** Provides direct access to the Tasks and Patient Vitals modules.

### Tasks Screen

* **Task Overview:** Displays all tasks with status indicators, due times, and room numbers.
* **Sorting and Filtering:** Users can sort tasks by creation date, due time, or room number, and filter via a search interface.
* **Task Management:** Supports inline editing and deletion, with confirmation dialogs to ensure data integrity.
* **Manual Task Addition:** Dialog-driven interface for structured task entry.

### Chat Screen (Patient Vitals)

* **Session-Based Conversations:** Each patient interaction is maintained as a persistent chat session, supporting longitudinal documentation.
* **AI-Driven Vital Extraction:** The AI model extracts and structures all relevant vital signs from user input.
* **Flexible Input:** Supports both voice and text input, with real-time transcription and feedback.
* **Notes Overlay:** Enables clinicians to attach, edit, and manage notes for each session.
* **Session Lifecycle Management:** Chats can be renamed or deleted, with all associated data managed accordingly.

---

## Data Model Specifications

### Task Object

```json
{
  "task": "string",
  "completed": "boolean",
  "createdAt": "timestamp",
  "completedAt": "timestamp",
  "updatedAt": "timestamp",
  "dueTime": "timestamp",
  "roomNo": "string"
}
```

### Chat Object

```json
{
  "title": "string",
  "createdAt": "timestamp"
}
```

### Message Object

```json
{
  "text": "string",
  "isUser": "boolean",
  "timestamp": "timestamp"
}
```

### Vital Signs Data

```json
{
  "name": "string",
  "age": "string",
  "blood_pressure": "string",
  "heart_rate": "string",
  "respiratory_rate": "string",
  "temperature": "string",
  "oxygen_saturation": "string"
}
```

---

## Deployment and Installation Guide

### Prerequisites

* Flutter SDK 3.8.1 or higher
* Dart SDK
* Firebase project with Firestore enabled
* Cheetah API access key
* Android device or emulator (current release is Android-only)

### Installation Procedure

1. **Clone the Repository:**

   ```bash
   git clone <repo-url>
   cd nurse2
   ```
2. **Install Dependencies:**

   ```bash
   flutter pub get
   ```
3. **Configure Firebase:**

   * Place `google-services.json` in the `android/app/` directory.
   * For iOS and web, configuration is present but not currently supported in this release.
4. **API Key Configuration:**

   * Insert your Cheetah and AI model API endpoints in the appropriate locations within the codebase.
5. **Run the Application:**

   ```bash
   flutter run
   ```

---

## Privacy, Security, and Compliance

* **Local Voice Processing:** All voice data is processed locally on the device using Cheetah Speech-to-Text, minimizing exposure of sensitive information.
* **Secure Data Storage:** All clinical and operational data is stored in Firebase Firestore.
* **Data Encryption:** Data is encrypted both in transit and at rest, leveraging Firebase’s security infrastructure.
* **Regulatory Compliance:** The application is designed with HIPAA and healthcare privacy standards in mind. For production deployments, further compliance validation is recommended.
