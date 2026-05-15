STUDENT ASSISTANT APPLICATION SYSTEM
GROUP E DOCUMENTATION
TECHNICAL PROGRAMMING III – TPG316C
1. SYSTEM OVERVIEW
The Student Assistant Application System is a Flutter mobile application developed for the
Information Technology Department to manage Student Assistant applications digitally. The
system replaces manual application processes with a secure and organised mobile solution.

The application allows students to:
• log in securely,
• apply for Student Assistant positions,
• upload supporting documents,
• track application statuses,
• and manage applications.
Administrative users can:
• review applications,
• approve or reject submissions,
• update statuses,
• and remove invalid applications.
3. PURPOSE OF THE APPLICATION
The purpose of the system is to improve the management of Student Assistant applications
within the department.
The system solves problems associated with manual application handling such as:
• lost applications,
• poor tracking,
• slow processing,
• and inefficient communication.
4. APPLICATION SCREENS
4.1 Login Screen
Purpose
Allows users to authenticate before accessing the system.
Features
• Email and password input
• Validation
• Login button
• Authentication using Supabase 
4.2 Student Home Screen
Purpose
Displays all applications submitted by the logged-in student.
Features
• View applications
• View statuses
• Add new application
• Navigation to application details 
4.3 Application Form Screen
Purpose
Allows students to submit Student Assistant applications.
Features
• Module selection
• Academic level selection
• Form validation
• Supporting document upload 
4.4 Application Detail Screen
Purpose
Allows students to manage submitted applications.
Features
• View details
• Edit pending applications
• Delete applications 
4.5 Admin Dashboard
Purpose
Allows administrators to manage all submitted applications.
Features
• Approve applications
• Reject applications
• Delete invalid applications
• Update statuses 
6. STATE MANAGEMENT USING PROVIDER
Provider was used for state management.
The application used:
• ChangeNotifier,
• ChangeNotifierProvider,
• watch(),
• read(),
• and notifyListeners().
Provider automatically rebuilt the user interface whenever application data changed.
Example:
When a student submits an application:
1. Data is sent to the ViewModel.
2. The ViewModel updates Supabase.
3. notifyListeners() refreshes the UI.
7. ROUTING AND NAVIGATION
Flutter Navigator and MaterialPageRoute were used for navigation.
Navigation methods implemented:
• push()
• pop()
• pushReplacement()
The navigation structure allowed users to move smoothly between screens while maintaining
application state.
8. FORM HANDLING AND VALIDATION
Forms were implemented using:
• Form,
• TextFormField,
• and validation methods.
Validation included:
• required fields,
• email validation,
• password validation,
• and controlled selections.
Validation ensured invalid data could not be submitted to the database.
9. SUPABASE IMPLEMENTATION
Supabase was used for:
• authentication,
• database storage,
• and file storage.
Authentication
Supabase Authentication verified user login credentials and controlled access.
Database
Supabase stored:
• applications,
• statuses,
• and user information.
CRUD operations implemented:
• Create
• Read
• Update
• Delete Storage
Supporting documents were uploaded using Supabase Storage.
Row Level Security (RLS)
RLS policies ensured students could only access their own application data.
10. USER INTERFACE DESIGN
The application used Material Design principles to create a modern and user-friendly interface.
Design features included:
• cards,
• icons,
• responsive layouts,
• spacing,
• and consistent colour themes.
The interface improved usability and user experience.
