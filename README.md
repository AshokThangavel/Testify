# Testify - Unit Test Viewer & Report Downloader

**Testify** is a simple and intuitive web application to help developers run unit tests, view detailed results, and download test reports in HTML format.

Supported IRIS version: >=2024

The key features include:

* Select unit test classes from a dropdown.
* Run tests directly from the interface.
* See a detailed breakdown of test results with statuses and execution times.
* Download the test report as a clean HTML file for further analysis or record keeping.

## Features

* **Test Class Selection:** Choose from available unit test classes via a dropdown.
* **Run Tests:** Execute tests and get immediate feedback.
* **Test Results Panel:** Displays passed/failed status, detailed assertions, logs, and timing info.
* **Download Report:** Save the test results as an HTML report with one click.

## ⚙️ Installation

### Clone the Repository
```bash
git clone https://github.com/AshokThangavel/Testify.git
cd Testify
````

### Running the Application with Docker

Build and start the app using Docker Compose:

```bash
docker-compose up --build
```

### Stopping the Application

To stop and remove the running containers:

```bash
docker-compose down
```

## Technical details

1. Extend your test case class **`Testify.UnitTest.TestCases`** so that, by default, the results are displayed on the screen.

## Usage

1. Goto http://localhost:52773/csp/user/Testify.Home.cls
2. Select a test class from the dropdown on the left panel.
3. Click the **Run Test** button.
4. The right panel will populate with the test execution results.
5. If desired, click the **Download** link to save the test report as an HTML file.
6. View all the test results by click **View All test results**

## Example Screenshot

### Test Results & Report Download
<img width="1216" height="720" alt="image" src="https://github.com/user-attachments/assets/4227ff67-e5d1-4667-bef9-9d569079bf88" />

---

## License

MIT License © 2025 Testify Contributors
