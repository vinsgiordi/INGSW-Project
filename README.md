# INGSW-Project
This repository contains an Android application, developed using Node.js / Express and Flutter, with the intention of creating a platform for managing online auctions. This application was developed as part of the "Software Engineering" course taught by professors Sergio Di Martino, Francesco Cutugno, and Luigi Libero Lucio Starace at the University of Naples "Federico II".

## Overview

**DietiDeals24** is a real-time auction application designed to facilitate buying and selling between users through an auction system. Users can create listings, bid on products, receive real-time notifications, and complete transactions with various payment methods.

The app is built with a microservices architecture, separating the frontend (built with Flutter) and backend (built with Node.js and Express). Both the backend and database are hosted within Docker containers for easier environment management.

## Technologies Used

### Backend
- **Node.js** with **Express.js** for managing APIs and business logic.
- **PostgreSQL** as the relational database to store user, product, and transaction data.
- **Sequelize** as the ORM to manage and interact with the database.
- **Docker** for containerization, simplifying deployment and configuration.
- **Cron Jobs** for automatic auction management.

### Frontend
- **Flutter** for a native-like user interface across different platforms.

## Getting Started

Before starting, ensure you have installed:

1. **Node.js** (recommended version 14 or higher)
2. **Flutter** (version 2.0 or higher) for the frontend
3. **Docker and Docker Compose** to manage containers
4. **DBeaver or pgAdmin** (optional, for database management)

## Installation Instructions

### 1. Clone the Repository

```bash
git clone [https://github.com/vinsgiordi/INGSW-Project.git](https://github.com/vinsgiordi/INGSW-Project.git)
cd INGSW-Project
```

### 2. Backend Setup
Go to the backend directory on your IDE (VSCode or similar)
```bash
cd backend
```
Create a **.env** file in the backend directory with the following environment variables (note .env.example for more information)

### 3. Frontend Setup
Go to the frontend directory on your IDE (It is recommended to use Android Studio for a more comfortable experience)
```bash
cd frontend
```
Navigate within the requests and replace the base url in case you are hosting the server locally.

### 4. Start Docker Containers
Go back to the main directory and use Docker Compose to start the containers:
```bash
docker-compose up --build
```
This command will build and start containers for the backend and the PostgreSQL database.

## Running and Development

### 1. Backend: The backend is started automatically with Docker. If you want to start it manually:
```bash
cd backend
npm start
```
### 2. Frontend: Run the Flutter application:
```bash
cd frontend
flutter clean
flutter pub get
flutter run
```

## Database Management
### Connecting to the Database
You can access the database through DBeaver or pgAdmin using the following connection details (assuming you’ve configured an external port for Docker):
- **Host:** localhost or container IP;
- **Port:** 54320 or similar;
- **User:** your-username;
- **Password:** your-password;
- **Database:** database-name;

## Contributing

Contributions to this repository are welcome! If you have suggestions for improvements, bug fixes, or new features, please open an issue or submit a pull request.

## License

This repository is licensed under the [MIT License](LICENSE).

## Contact

For any inquiries or assistance, feel free to contact [vincenzogiordano99@libero.it](mailto:your-email@example.com).
