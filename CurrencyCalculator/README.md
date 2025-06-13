#  CurrencyCalculatorApp

A currency conversion app that allows a user to view a given amount in a given currency converted into other currencies.


## Architecture

The project follows Clean Architecture principles with three main layers:

### 1. Data Layer
- **Repositories**: Provide clean interfaces for accessing and managing data over data sources
  - `CurrenciesRepository`: Manages currency data
  - `QuotesRepository`: Manages quote data
- **DataSources**: Contain interfaces responsible for fetching data from various sources
  - `RemoteDataSource`: Handles network API communication
  - `LocalDataSource`: Manages local data storage

### 2. Domain Layer
- **Entities**: Represent core business objects with their properties
  - `Currency`: Represent a currency
  - `Quote`: Represent a quote
- **UseCases**: Contains application-specific business rules and logic, interacting between entities and data sources
  - `CalculateQuotesUseCase`: Calculates quotes
  - `GetCurrenciesUseCase`: Retrieves currencies
  - `GetQuotesUseCase`: Retrieves quotes

### 3. Presentation Layer
- **Views**: Represent individual screens in the application
  - `CurrencyCalculatorView`: Represents the main screen of currency calculator
- **ViewModels**: Handle user inputs and events, coordinating with other components to update UI 
  - `CurrencyCalculatorViewModel`: Manages the presentation logic of CurrencyCalculatorView  


## Technical Details

### Dependencies
- Async/await
- Combine
- CoreData
- SwiftUI
- URLSession

### Unit Testing
- Data sources testing
- Repositories testing
- Use cases testing
- ViewModel testing


## Requirements

- iOS 15.0+
- Xcode 15.1+
- Swift 5.9+
