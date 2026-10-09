class ApiConstants {
  ApiConstants._();
  // API Base Url
  static const String apiBaseUrl = '';

  // use with emulator

  static String baseUrl = String.fromEnvironment(
    apiBaseUrl,
    defaultValue: 'http://10.0.2.2:8080/api',
  );

  // use with real device

  //   static String baseUrl = String.fromEnvironment(
  //     apiBaseUrl,
  //     defaultValue: 'http://192.168.1.37:8080/api',
  //   );

  // static String baseUrl = String.fromEnvironment(
  //   apiBaseUrl,
  //   defaultValue: 'http://192.168.1.32:8080/api',
  // );

  //static const String baseUrl = 'http://10.0.2.2:8080/api';

  // auth
  static const String login = '/auth/login';
  static const String logout = '/auth/logout';
  static const String register = '/auth/register';
  static const String forgotPassword = '/auth/forgot-password';
  static const String resetPassword = '/auth/reset-password';

  // profile
  static const String userProfile = '/user-profiles/me';
  static const String loginHstory = '/user-profiles/me/login-history';

  // vehicle
  static const String vehicles = '/vehicles';
  static const String brands = '/brands';

  static String vehicleById(int id) => '/vehicles/$id';
  static String updateVehicle(int id) => '/vehicles/$id';
  static String deleteVehicle(int id) => '/vehicles/$id';
  static String vehicleBookedDates(int id) => '/vehicles/$id/booked-dates';

  //

  // image
  static const String vehicleImages = '/vehicle-images';

  static String vehicleImageById(int id) => '/vehicle-images/$id';
  static String updateVehicleImage(int id) => '/vehicle-images/$id';
  static String deleteVehicleImage(int id) => '/vehicle-images/$id';

  // service
  static const String services = '/services';

  static String serviceById(int id) => '/services/$id';
  static String updateServices(int id) => '/services/$id';
  static String deleteServices(int id) => '/services/$id';

  // review
  static const String reviews = '/reviews';
  static const String myReviews = '/reviews/my-reviews';

  static String reviewById(int id) => '/reviews/$id';
  static String updateReview(int id) => '/reviews/$id';
  static String deleteReview(int id) => '/reviews/$id';

  static String reviewsVehicle(int vehicleId) => '/reviews/vehicle/$vehicleId';
  static String coutReviews(int vehicleId) =>
      '/reviews/vehicle/$vehicleId/count';

  // reservervation
  static const String reservervations = '/reservervations';
  static const String myReservervations = '/reservervations/my-reservervations';

  static String reservervationsById(int id) => '/reservervations/$id';
  static String updateReservervation(int id) => '/reservervations/$id';
  static String deleteReservervation(int id) => '/reservervations/$id';
  static String cancelReservervation(int id) => '/reservervations/$id/cancel';
  static String changeReservervation(int id) => '/reservervations/$id/status';

  // rental
  static const String rentals = '/rentals/';
  static const String myRental = '/rentals/my-rentals';

  static String rentalById(int id) => '/rentals/$id';
  static String updateRental(int id) => '/rentals/$id';
  static String deleteRental(int id) => '/rentals/$id';

  static String pachRental(int id) => '/rentals/$id/status';

  // maintenance record
  static const String maintenanceRecords = '/maintenance-records';

  static String maintenanceRecordById(int id) => '/maintenance-records/$id';
  static String updateMaintenanceRecord(int id) => '/maintenance-records/$id';
  static String deleteMaintenanceRecord(int id) => '/maintenance-records/$id';

  // location
  static const String locations = '/locations';

  static String locationById(int id) => '/locations/$id';
  static String updateLocation(int id) => '/locations/$id';
  static String deleteLocation(int id) => '/locations/$id';

  // invoice
  static const String invoices = '/invoices';
  static const String myInvoices = '/invoices/my-invoices';

  static String invoiceById(int id) => '/invoices/$id';
  static String updateInvoice(int id) => '/invoices/$id';
  static String deleteInvoice(int id) => '/invoices/$id';

  // inspection
  static const String inspections = '/inspections';
  static const String typeInspections = '/inspections/type';

  static String rentalInspectionById(int rentalId) =>
      '/inspections/rental/$rentalId';

  static String inspectionById(int id) => '/inspections/$id';
  static String updateInspection(int id) => '/inspections/$id';
  static String deleteInspection(int id) => '/inspections/$id';

  // attachment
  static const String attachments = '/attachments';
  static const String attachmentsUpload = '/attachments/upload';

  static String attachmentById(int id) => '/attachments/$id';
  static String updateAttachment(int id) => '/attachments/$id';
  static String deleteAttachment(int id) => '/attachments/$id';

  // bakong
  static const String qrImage = '/v1/bakong/qr-image';
  static const String generateQr = '/v1/bakong/generate-qr';
  static const String checkTransaction = '/v1/bakong/check-transaction';

  // rental document
  static const String rentalDocuments = '/rental-documents';
  static String uploadRentalDocuments(int rentalId) =>
      '/retal-documents/$rentalId/upload';
  static String rentalDocumentById(int id) => '/rental-documents/$id';
  static String updateRentalDocument(int id) => '/rental-documents/$id';
  static String deleteRentalDocument(int id) => '/rental-documents/$id';

  static String rentalDocumentRental(int rentalId) =>
      '/rental-documents/rental/$rentalId';

  static const String myRentalDocument = '/rental-documents/my-rental-document';

  // notification
  static const String inboxMe = '/notifications/me/inbox';
  static String notify(int userId) => '/notifications/$userId/notify';
  static const String device = '/notifications/device';

  // favorite
  static const String favorite = '/favorites';
  static String favoriteById(int vehicleId) => '/favorites/$vehicleId';
  static String deleteFavorite(int vehicleId) => '/favorites/$vehicleId';
}
