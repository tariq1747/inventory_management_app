# Inventory Management App

A fully functional, offline-first Inventory Management App built with Flutter and SQLite.

## Features

### 📦 Inventory Management
- Add, edit, delete products
- Product fields: Name, SKU/Barcode, Category, Purchase/Selling Price, Quantity, Supplier, Low-stock threshold
- Stock in/out tracking with automatic low-stock alerts
- Barcode/QR code scanning
- Search, filter, and sort products

### 🧾 Billing & Invoice System
- Create customer bills with multiple products
- Auto-calculate: Subtotal, Discount, Tax (GST configurable), Grand total
- Auto stock deduction after invoice creation
- Printable invoice support with PDF export
- Support for Bluetooth & normal printers
- Custom invoice design with shop name & logo

### 📊 Reports & Analytics
- Graphical representation with bar, line, and pie charts
- Monthly sales, purchase, and profit charts
- Product-wise sales charts
- Profit & Loss calculation (Daily, Monthly, Yearly)
- Total revenue, COGS, Expenses, Gross/Net profit

### 🎨 UI/UX
- Clean, modern dashboard
- Total stock value, today's sales, monthly profit, low-stock alerts
- Light & dark theme support
- Tablet & mobile responsive design

## Tech Stack

- **Flutter** (latest stable)
- **State Management**: GetX
- **Local Database**: SQLite with sqflite
- **PDF Generation**: pdf package
- **Charts**: fl_chart
- **Barcode Scanning**: mobile_scanner
- **Printing**: printing package

## Database Schema

### Tables
- `products` - Product information
- `categories` - Product categories
- `suppliers` - Supplier information
- `customers` - Customer information
- `invoices` - Invoice headers
- `invoice_items` - Invoice line items
- `stock_movements` - Stock in/out tracking
- `expenses` - Business expenses

## Setup Instructions

### Prerequisites
- Flutter SDK (latest stable version)
- Android Studio / VS Code with Flutter extensions
- Android/iOS device or emulator

### Installation

1. **Clone or download the project**
   ```bash
   cd /path/to/your/workspace
   # Copy the project files to your workspace
   ```

2. **Install dependencies**
   ```bash
   flutter pub get
   ```

3. **Run the app**
   ```bash
   flutter run
   ```

### Permissions

The app requires the following permissions:
- **Camera**: For barcode/QR code scanning
- **Storage**: For saving PDF invoices (Android)

Permissions are already configured in:
- `android/app/src/main/AndroidManifest.xml`
- `ios/Runner/Info.plist`

## Project Structure

```
lib/
├── controllers/          # GetX controllers
│   ├── dashboard_controller.dart
│   ├── invoice_controller.dart
│   └── product_controller.dart
├── database/             # Database helper
│   └── database_helper.dart
├── models/               # Data models
│   ├── category.dart
│   ├── customer.dart
│   ├── expense.dart
│   ├── invoice.dart
│   ├── invoice_item.dart
│   ├── invoice_item.dart
│   ├── product.dart
│   ├── stock_movement.dart
│   └── supplier.dart
├── repositories/         # Data access layer
│   ├── category_repository.dart
│   ├── customer_repository.dart
│   ├── expense_repository.dart
│   ├── invoice_repository.dart
│   ├── product_repository.dart
│   ├── stock_movement_repository.dart
│   └── supplier_repository.dart
├── services/             # Business logic services
│   ├── barcode_service.dart
│   └── pdf_service.dart
├── utils/                # Utilities and themes
│   └── themes.dart
└── views/                # UI screens
    ├── dashboard_view.dart
    ├── invoice_form_view.dart
    ├── invoices_view.dart
    ├── product_form_view.dart
    ├── products_view.dart
    └── reports_view.dart
```

## Key Features Implementation

### Offline-First Architecture
- All data stored locally in SQLite database
- No internet connection required
- Data persists across app restarts

### Barcode Scanning
- Uses `mobile_scanner` package
- Supports QR codes and various barcode formats
- Integrated into product creation/editing

### PDF Invoice Generation
- Uses `pdf` package for PDF creation
- Custom invoice template with shop branding
- Print support via `printing` package

### Charts & Analytics
- Uses `fl_chart` for various chart types
- Real-time data visualization
- Profit & Loss calculations

### State Management
- GetX for reactive state management
- Controllers for business logic
- Repository pattern for data access

## Usage

1. **Dashboard**: View key metrics and low-stock alerts
2. **Products**: Manage inventory, add/edit products, scan barcodes
3. **Invoices**: Create bills, manage customers, generate PDFs
4. **Reports**: View analytics, charts, and profit/loss statements

## Development Notes

- The app uses repository pattern for clean data access
- GetX controllers handle business logic and state
- SQLite database with proper relationships and indexing
- Responsive design works on mobile and tablet
- Dark/light theme support

## Future Enhancements

- Cloud backup/sync capabilities
- Multi-language support
- Advanced reporting with date ranges
- Inventory forecasting
- Supplier management with purchase orders
- Customer loyalty programs

## License

This project is for educational and commercial use.
