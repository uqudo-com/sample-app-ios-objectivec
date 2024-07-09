//
//  ViewController.m
//  Sample-Objective-C
//
//  Created by NooN on 11/9/23.
//

#import "ViewController.h"
#import "AppDelegate.h"
#import <UqudoSDK/UqudoSDK.h>

@interface ViewController () <UQBuilderControllerDelegate>

@property (strong, nonatomic) UQBuilderController *builderController;
@property (strong, nonatomic) NSString *authorizationToken;
@property (strong, nonatomic) NSString *nonce;

@property (strong, nonatomic) IBOutlet UIButton *startButoon;

@end

@implementation ViewController


- (void)viewDidLoad {
    [super viewDidLoad];
    [self configUI];
}

- (void)configUI {
    self.startButoon.layer.cornerRadius = 8;
}

- (NSString *)createSessionID {
    NSUUID *uuid = [NSUUID UUID];
    NSString *uuidString = [[uuid UUIDString] lowercaseString];
    return [uuidString copy];
}


- (IBAction)onStartEnrollemnt:(UIButton *)sender {
    NSLog(@"onStartEnrollemnt: %@",sender);
    [self performingEnrollment];
}

- (IBAction)TestButton:(UIButton *)sender {
    NSLog(@"TestButton: %@",sender);
}

- (UQScanConfig *)createScanConfig {
    UQScanConfig *scanConfig = [[UQScanConfig alloc] init];
    
    // Disable scanning help page
    scanConfig.disableHelpPage = NO;
    
    // You can choose to manually upload your document instead of having it automatically scanned. Simply upload a PDF of the document's image. If the document is two-sided, make sure the first picture is the front side and the second picture is the back side. Enabling this option will automatically disable the reading step.
    // Upload functionality will be removed in a future release of the SDK
    // scanConfig.enableUpload = NO;

    // Specifies the required match level for facial recognition of this document's scanned picture.
    scanConfig.faceMinimumMatchLevel = 3; // Valid number 1-5
    
    // Enable the user to review and confirmation the document for front side or back side or both.
    [scanConfig enableScanReview:YES backSide:YES];
    
    return scanConfig;
}

- (UQReadingConfig *)createReadingConfig {
    UQReadingConfig *readingConfig = [[UQReadingConfig alloc] init];
    
    // Enable reading for the document, e.g. NFC reading of the chip
    readingConfig.enableReading = YES;
    
    // Specifies the required match level for facial recognition of the picture in the chip for this specific document
    readingConfig.faceMinimumMatchLevel = 3; // Valid number 1-5
    
    // Force the reading part. Users will not be able to skip the reading part. Enrollment builder throws exception if NFC not supported and force reading is enabled.
    [readingConfig forceReading:NO];
    
    // Force the reading part only if NFC is supported. Users will not be able to skip if NFC is supported; otherwise, they will be moved to the next step after scanning.
    // This is a no-op operation and it is the default behavior from version 3.x
    // [readingConfig forceReadingIfSupported:NO];
    
    // Set NFC timeout for document reading. If timeout exceeds, users can skip the NFC step. Only works if force reading is enabled.
    readingConfig.forceReadingTimeout = 30; // Defines the timeout in seconds
    
    return readingConfig;
}

- (UQEnrollmentBuilder *)createEnrollmentBuilder:(NSString *)authorizationToken {

    // Config the enrollment builder
    UQEnrollmentBuilder *enrollmentBuilder = [[UQEnrollmentBuilder alloc] init];
    
    // Retrieve the authorization token using oauth2 client credentials grant type. You can obtain your client credentials by navigating to the "Credentials" tab located in the "Development" section of our Uqudo Customer Portal Note: Don’t perform this operation inside your mobile application but only from your backend
    // For more information please check https://docs.uqudo.com/docs/uqudo-api/authorisation
    
    enrollmentBuilder.authorizationToken = authorizationToken;
    
    // Nonce is provided by the customer's mobile application when the SDK is initiated. Ensuring the customer's mobile application has undertaken the process is helpful. It should be generated on the server side.
    enrollmentBuilder.nonce = self.nonce;
    
    // Required during the enrolment process using a QR code, see QR code App. Note: make sure to create always a new session id when you trigger the SDK flow
    // The SDK will generate sessionID if the sessionID is empty
    enrollmentBuilder.sessionID = [self createSessionID];
    
    // Required during the enrolment process using a QR code
    // UUID v4 that represents the user identifier for recurrent usage of the SDK for the same user. This is related to the type of license agreement with Uqudo. Please note that if the UUID v4 is malformed it is simply ignored
    enrollmentBuilder.userIdentifier = [NSUUID UUID];
    
    
    // Enabling this option allows the SDK provide partial data along with the SessionStatus object if the user or SDK terminates the session prematurely. However, it's essential to remember that you can only expect some data if the user has completed at least the scanning step.
    enrollmentBuilder.returnDataForIncompleteSession = YES;
    
    
    // Add document if no document, the UQExceptionMissingDocument throw
    UQDocumentConfig *passportDocument = [self createPassportDocument];
    // If reading enable but document is not supported reading the SDK will throw kExceptionReasonDocumentNotSupportReading.
    // If document is not supported enrollment the SDK will throw kExceptionReasonDocumentEnrollmentNotSupport.
    [enrollmentBuilder add:passportDocument];
    
    // Enabling face recognition
    if ([passportDocument isSupportFaceRecognition]) {
        enrollmentBuilder.facialRecognitionConfig = [self createFacialRecognitionConfig];
    }

    // Background Check Configuration id needed
    // Begin enableBackgroundCheck config.
    /*// Uncomment if needed
    [enrollmentBuilder enableBackgroundCheck:YES // Disable consent option for the user
                                        type:RDC // Sets the background check type RDC or DOW_JONES
                                  monitoring:YES // Enable continuous monitoring.
                                    skipView:YES]; // If enabled, the step will be skipped, and the SDK will trigger the background check without any user interaction.
    */// Uncomment if needed
    // End enableBackgroundCheck config.
    
    // This feature requires an additional permission and must be explicitly requested
    
    // Enable third party lookup (Government database). See the supported documents and the data returned in Lookup Object
    // Begin enableLookup config.
    //[enrollmentBuilder enableLookup]; // Uncomment if needed
    // End enableLookup config.
    
    // Enable third party lookup (Government database) filtered by document type. For instance, if your KYC process includes more than one document, you can decide to perform the lookup only for one single document.
    // Begin enableLookup filtered by document type config.
    //[enrollmentBuilder enableLookup:[list of lookup document]]; // Uncomment if needed
    // End enableLookup filtered by document type config.
    
    return enrollmentBuilder;
}

- (UQFacialRecognitionConfig *)createFacialRecognitionConfig {
    UQFacialRecognitionConfig *config = [[UQFacialRecognitionConfig alloc] init];
    
    // Enable facial recognition
    config.enableFacialRecognition = YES;
    
    // Enabling this option allows to have closed eyes during facial recognition.
    config.allowClosedEyes = YES;
    
    // Enabling this option allows you to enroll your face for account recovery. For more information, refer to the Account Recovery Flow.
    // This is used for the Account Recovery flow that has been deprecated since version 3.0.0.
    // config.enrollFace = YES;
    
    // Defines the minimum match level that the facial recognition has to meet for scanned pictures
    config.scanMinimumMatchLevel = 3;
    
    // Defines the minimum match level that the facial recognition has to meet for pictures from the chip (e.g. NFC)
    config.readMinimumMatchLevel = 3;
    
    // Enabling this option allows for the obfuscation of the background in audit trail images, leaving only the face visible. It is beneficial when privacy concerns arise due to the background of the selfie shared in the SDK result. This feature offers two types of obfuscation:
    //    1. FILLED: This option entirely replaces the experience.
    //    2. BLURRED: This option heavily blurs the background, ensuring that objects in the scene are not recognizable. However, it still provides a perception of the environment surrounding the user, allowing for validation of the reality of the image. If privacy is a concern, we recommend using this option.
    config.obfuscationType = FILLED;
    
    // Specify the maximum number of failed facial recognition attempts allowed before ending the session. Note that only values between 1 and 3 will be considered.
    config.maxAttempts = 1;
    
    return config;
}


- (UQDocumentConfig *)createPassportDocument {
    @try {
        
        // Create document type Passport
        UQDocumentConfig *passportDoc = [[UQDocumentConfig alloc] initWithDocumentType:PASSPORT];
        
        // Enabling this option allows to scan expired documents
        passportDoc.disableExpiryValidation = YES;
        
        // Enabling this option allows age verification and if the calculated age from the document is below the defined age, the scan fails and shows a message to the user. Age must be higher than 0 to be considered.
        passportDoc.enableAgeVerification = YES;
        
        // Add scan configuration
        passportDoc.scan = [self createScanConfig];
        
        // Add reading configuration
        passportDoc.reading = [self createReadingConfig];
        
        return passportDoc;
    }
    @catch (NSException *exception) {
        NSLog(@"name : %@\nreason : %@\ncallStackSymbols : %@", exception.name, exception.reason, exception.callStackSymbols);
        [self alertCatchException:exception];
    }
}

- (void)performingEnrollment {
    @try {
        AppDelegate *appDelegate = (AppDelegate *)[[UIApplication sharedApplication] delegate];
        
        NSLog(@"accessToken: %@",appDelegate.accessToken);

        // Config the main builder. UQBuilderController is singleton since we already inititate build in AppDelegate, net time we will call defaultBuilder
        self.builderController = [UQBuilderController defaultBuilder];
        self.builderController.delegate = self;
        
        // Pass an instance of app viewcontroller
        self.builderController.appViewController = self;
        
        // Define appearance mode. Available options are LIGHT, DARK, and SYSTEM.
        [self.builderController setAppearanceMode:LIGHT];
        
        // Config the enrollment builder
        UQEnrollmentBuilder *enrollmentBuilder = [self createEnrollmentBuilder:appDelegate.accessToken];

        
        // Add enrollment to main builder
        [self.builderController setEnrollment:enrollmentBuilder];
        
        // Start enrollment flow
        // AccessToken reuire, if no token the UQExceptionInvalidToken will throw
        [self.builderController performEnrollment];
        
    }
    @catch (NSException *exception) {
        NSLog(@"name : %@\nreason : %@\ncallStackSymbols : %@",exception.name, exception.reason, exception.callStackSymbols);
        [self alertCatchException:exception];
    }
    
}

#pragma mark - UQBuilderControllerDelegate


- (void)didEnrollmentIncompleteWithStatus:(UQSessionStatus *)status {
    NSLog(@"statusCode:  %ld\nstatusTask: %ld\nstatusMessage: %@", status.statusCode,  status.statusTask,  status.message);
    dispatch_async(dispatch_get_main_queue(), ^(void){
        NSString *statusCode = @"";
        NSString *statusTask = @"";
        NSString *statusMessage = status.message;
        switch (status.statusCode) {
            case USER_CANCEL:
                statusCode = @"USER_CANCEL";
                break;
            case SESSION_EXPIRED:
                statusCode = @"SESSION_EXPIRED";
                break;
            case UNEXPECTED_ERROR:
                statusCode = @"UNEXPECTED_ERROR";
                break;
            case SESSION_INVALIDATED_CHIP_VALIDATION_FAILED:
                statusCode = @"SESSION_INVALIDATED_CHIP_VALIDATION_FAILED";
                break;
            case SESSION_INVALIDATED_FACE_RECOGNITION_TOO_MANY_ATTEMPTS:
                statusCode = @"SESSION_INVALIDATED_FACE_RECOGNITION_TOO_MANY_ATTEMPTS";
                break;
            case SESSION_INVALIDATED_READING_NOT_SUPPORTED:
                statusCode = @"SESSION_INVALIDATED_READING_NOT_SUPPORTED";
                break;
            case SESSION_INVALIDATED_READING_INVALID_DOCUMENT:
                statusCode = @"SESSION_INVALIDATED_READING_INVALID_DOCUMENT";
                break;
            default:
                statusCode = @"UNDEFINE";
                break;
        }
        
        
        switch (status.statusTask) {
            case SCAN:
                statusTask = @"Scanning";
                break;
            case READING:
                statusTask = @"NFC Reading";
                break;
            case FACE:
                statusTask = @"Facial recognition";
                break;
                
            case BACKGROUND_CHECK:
                statusTask = @"Background check";
                break;
            default:
                statusTask = @"Undefine";
                break;
        }
        
        NSString *alertMessage = [NSString stringWithFormat:@"Error: %@\nTask : %@\nInfo : %@", statusCode, statusTask, statusMessage];
        [self showEnrollmentErrorAlert:alertMessage];
    });
}

- (void)didEnrollmentCompleteWithInfo:(NSString *)jwsString {
    NSLog(@"Enrollmen Info: %@", jwsString);
    [self performSegueWithIdentifier:@"enrollmentComplete"
                              sender:self];
}

#pragma mark - Alert
- (void)alertCatchException:(NSException *)exception {
    
    UIAlertController *controller = [UIAlertController alertControllerWithTitle:nil
                                                                        message:exception.reason
                                                                 preferredStyle:UIAlertControllerStyleAlert];
    
    UIAlertAction *button1 = [UIAlertAction actionWithTitle:@"Continue"
                                                      style:UIAlertActionStyleDefault
                                                    handler:^(UIAlertAction * action) {
        
        return;
    }];
    
    [controller addAction:button1];
    [self presentViewController:controller
                       animated:YES
                     completion:nil];
}


- (void)showEnrollmentErrorAlert:(NSString *)errorInfo {
    
    UIAlertController *controller = [UIAlertController alertControllerWithTitle:nil
                                                                        message:errorInfo
                                                                 preferredStyle:UIAlertControllerStyleAlert];
    
    UIAlertAction *button1 = [UIAlertAction actionWithTitle:@"Continue"
                                                      style:UIAlertActionStyleDefault
                                                    handler:^(UIAlertAction *action) {
        
    }];
    
    [controller addAction:button1];
    [self presentViewController:controller
                       animated:YES
                     completion:nil];
}

@end
