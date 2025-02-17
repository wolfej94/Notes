# Notes

Notes is a collection of iOS note-taking applications demonstrating different architectural patterns. The repository includes implementations using Model-View-Controller (MVC), Model-View-ViewModel (MVVM), and Model-View-ViewModel-Coordinator (MVVM-C) to illustrate best practices and trade-offs in iOS development.

## Project Structure
The repository is structured as follows:

```
Notes/
│── MVC/
│   ├── NotesAppMVC.xcodeproj
│   ├── ...
│── MVVM/
│   ├── NotesAppMVVM.xcodeproj
│   ├── ...
│── MVVM-C/
│   ├── NotesAppMVVMC.xcodeproj
│   ├── ...
```

## Architectural Patterns

### Model-View-Controller (MVC)
#### Overview
MVC is a widely used architectural pattern that separates the application logic into three main components:
- **Model**: Manages the data and business logic.
- **View**: Handles the user interface.
- **Controller**: Acts as an intermediary between the Model and the View.

#### Pros
✅ Simple and familiar to most iOS developers.
✅ Quick to implement for small projects.
✅ Direct integration with UIKit components.

#### Cons
❌ Often leads to "Massive View Controllers" due to business logic creeping into controllers.
❌ Difficult to maintain and test as the project scales.

### Model-View-ViewModel (MVVM)
#### Overview
MVVM improves upon MVC by introducing a **ViewModel** to better manage data transformation and business logic:
- **Model**: Manages the data and business logic.
- **View**: Handles the user interface.
- **ViewModel**: Acts as an intermediary, preparing data for the View and handling user input logic.

#### Pros
✅ Improved separation of concerns, leading to better maintainability.
✅ Easier to test, since the ViewModel is independent of UIKit.
✅ Works well with SwiftUI and reactive programming (Combine, RxSwift).

#### Cons
❌ More complex than MVC, requiring additional boilerplate code.
❌ Can be overkill for simple applications.

### Model-View-ViewModel-Coordinator (MVVM-C)
#### Overview
MVVM-C extends MVVM by adding a **Coordinator** to handle navigation and app flow, further improving separation of concerns:
- **Model**: Manages the data and business logic.
- **View**: Handles the user interface.
- **ViewModel**: Prepares data for the View and processes user input.
- **Coordinator**: Manages navigation between screens, reducing dependency on ViewControllers for navigation.

#### Pros
✅ Even better separation of concerns, making large projects more manageable.
✅ Simplifies navigation logic by centralizing it in Coordinators.
✅ Makes ViewModels more reusable and testable.

#### Cons
❌ Adds complexity due to the additional Coordinator layer.
❌ Requires more boilerplate code to manage dependencies.

## Getting Started
Clone the repository and open the desired project in Xcode:

```sh
git clone https://github.com/wolfej94/Notes.git
cd Notes/MVVM # or cd Notes/MVC or cd Notes/MVVM-C
open NotesAppMVVM.xcodeproj # or open NotesAppMVC.xcodeproj or open NotesAppMVVMC.xcodeproj
```

## License
Notes is released under the MIT license. See [LICENSE](LICENSE) for details.

