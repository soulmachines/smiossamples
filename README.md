#  SMDarwin Sample Projects

This workspace shows how to use the Soul Machines iOS SDK and pull the library into your own projects. It also shows some of the basic SDK functionality for reference.

## Project Setup

Open the workspace in Xcode, and update the target to either `SMSwiftSample` or `SMObjectiveCSample`. The project should automatically import dependencies via Swift Package Manager. After this process has completed, run the project.

### Objective-C Project

The Objective-C sample requires a dependency installed via [Carthage](https://github.com/Carthage/Carthage). The command required for execution can be found below.

```console
foo@bar dir % cd SMObjectiveCSample
foo@bar dir % sh carthage_build.sh update --platform ios
```

## Minimum requirements

SMDarwin supports iOS 11 and above.
SMDarwin 1.0.4 and above depend on [WebRTC_iOS](https://github.com/soulmachines/WebRTC_iOS).

## Importing the library

### Swift Packages

Add the SMDarwin repository `git@github.com:soulmachines/SMDarwin.git` via Swift Package Manager, along with the following dependencies:
* `git@github.com:soulmachines/WebRTC_iOS.git` from `1.0.0`,
* `https://github.com/daltoniam/Starscream.git` from `4.0.0`, and
* `https://github.com/Flight-School/AnyCodable` from `0.4.0`

Alternatively, to integrate via a Package.swift manifest instead of Xcode, you can add SMDarwin and its dependencies to the dependencies array of your package with the following:
```swift
dependencies: [
    .package(url: "git@github.com:soulmachines/SMDarwin.git", from "1.0.4"),
    .package(url: "git@github.com:soulmachines/WebRTC_iOS.git", from: "1.0.0"),
    .package(url: "https://github.com/daltoniam/Starscream.git", from: "4.0.0"),
    .package(url: "https://github.com/Flight-School/AnyCodable", from: "0.4.0")
]
```

### CocoaPods 

Add the SoulMachines-Specs repo to your CocoaPods installation

```console
pod repo add SoulMachines-Specs git@github.com:soulmachines/SoulMachines-Specs.git
```

Add the following source to your `podfile`:
```gem
source 'https://github.com/CocoaPods/Specs.git'
source 'git@github.com:soulmachines/SoulMachines-Specs.git'
```

Next add the following pods to the `podfile`:
```gem
pod 'SMDarwin', '~> 1.0.4'
pod 'WebRTC_iOS', '~> 1.0.0'
pod 'Starscream', '~> 4.0.0'
pod 'AnyCodable-FlightSchool', '~> 0.4.0'
```

Run the following commands to download the libraries and integrate into the xcode project.
```console
foo@bar dir $ pod install
```

### Carthage 

TK: Carthage does not currently support distributing prebuilt xcframeworks.

### Direct

Download the SMDarwin repository `https://github.com/soulmachines/SMDarwin.git` and add `SMDarwin.xcframework` to your project. Also download the WebRTC repository `https://github.com/soulmachines/WebRTC_iOS.git` and add `WebRTC.xcframework` to your project.

Install the following dependencies from their git repositories. If instructions are not available, they should be able to be built as an archive or added as subprojects to the active workspace.
* [Starscream](https://github.com/daltoniam/Starscream)
* [AnyCodable](https://github.com/Flight-School/AnyCodable)

## Using the library

Import the library by using `import SMDarwin` or `#import <SMDarwin/SMDarwin.h>`. Further information can be found in the documentation packaged with the SDK.

## Initialising the Logger

The SDK includes a `LoggingCenter` that supports several log types. If this isn't initialised, it will use the `Null` logger by default, discarding any SDK level logs. Additional options are:
* `File`, which will to the provided filename in the documents directory,
* `Console`, which will output to the terminal, and
* `Callback`, which will pipe the log string to the provided callback.

The default log level is `Error`. This reports only error level messages, however the following options are also available:
* `Warning`: Reports warnings in addition to `Error` level messages.
* `Info`: Reports information messages, in addition to `Warning` and `Error` messages.

```swift
let error = LoggingCenter.loggingCenter.set(logType: .Console)
LoggingCenter.loggingCenter.set(logSeverity: .Warning)

if error != nil {
    debugPrint("Error encountered setting up the logging center: \(error.debugDescription)")
}
```

```objective-c
CompletionError* error = [LoggingCenter.loggingCenter setWithLogType:LogTypeConsole filename:nil callback:nil];
LoggingCenter.loggingCenter setLogSeverity:LogSeverityWarning];

if (nil != error)
{
    NSLog(@"Encountered error setting up the logging center: %@", error);
}
```

## Create and connect the Scene

Create a *Scene* object with the requested *UserMediaOptions*. After creating the Scene, set the view in which to render the remote stream, and an optional view in which to render the local stream.

```swift
let scene = SceneFactory.create(userMediaOptions: .MicrophoneAndCamera)
scene.set(remoteView: self.remoteView, localView: self.localView)
```

```objective-c
Scene *scene = [SceneFactory createWithUserMediaOptions: UserMediaOptionsMicrophoneAndCamera];
[scene setWithRemoteView:self.remoteView localView:self.localView];
```

### Connect to a Digital Human (DH) server using a valid web-socket URL and a valid JWT.

Establish a connection by providing the server url from your Persona connection configuration, and a JWT constructed from the Private Key and Key Name also found in the Persona connection configuration. Provide optional `userText` to send a message to the Orchestration server during connection, and a `RetryOptions` object specifying the number of connection attempts and the delay between attempting a connection, should the connection encounter an error.

```swift
self.scene?.connect(url: serverUrl, userText: nil, accessToken: jwt, retryOptions: RetryOptions())
```

```objective-c
[self.scene connectWithUrl: serverUrl userText: nil accessToken:jwt retryOptions:[[RetryOptions alloc] init]]
```

### Connection Result

All asynchronous methods provide a method of subscribing to the result of the function. This will return a `Completion` object, containing an optional `error` and an optional `result`. The result can be cast to the type specified in the documentation of each call for validation.

Here is an example of a subscription to the `Scene` connection result.

```swift
self.scene?.connect(url: serverUrl, userText: nil, accessToken: jwt, retryOptions: RetryOptions()).subscribe(completion in {
    if let connectError = completion.error {
        debugPrint("Error connecting to scene: \(connectError.debugDescription)")
        return
    }

    if let _ = completion.result as? SessionInfo {
        debugPrint("Successful scene connection.")
    }
})
```

```objective-c
[[self.scene connectWithUrl:(serverUrl ? serverUrl : @"") userText:nil accessToken:jwt retryOptions:[[RetryOptions alloc] init]] subscribeWithCompletion:^ (Completion* completion) {
    if (completion.error != nil)
    {
        NSLog(@"Error connecting to scene: %@", completion.error.debugDescription);
        return;
    }
    
    if (completion.result != nil)
    {
        NSLog(@"Successful scene connection.");
    }
}];
```

## Register event listeners on the Scene

The `Scene` and `Persona` APIs also provide the ability to register event listeners that may be necessary for further interaction with the Digital Human. The pattern for these is `add({type}EventListener: )`, and `remove({type}EventListener:)`. For both of these methods, an object inheriting the appropriate event listener is passed as the parameter.

Below is an example of a `DisconnectedEventListener`.

```swift
class Sample: DisconnectedEventListener {
    //...

    //Adding the listener
    func addListener() {
        self.scene?.add(disconnectedEventListener: self)
    }

    //Listener methods
    func onDisconnect(reason: String) {
        debugPrint("Scene disconnected with reason: \(reason)")
    }
}
```

```objective-c

@interface Sample<DisconnectedEventListener>
//...
    
//Adding the listener
-(void) addListener
{
    [self.scene addWithDisconnectedListener:self];
}

//Listener methods
-(void) onDisconnectedWithReason:(NSString *)reason
{
    NSLog(@"Scene disconnected with reason: %@", reason);
}
```

## Scene Messages

One way of interacting with the Digital Human is to utilise Scene Messaging. Adding a `SceneMessageListener` to the `Scene` using the `scene?.add(messageListener: )` API will notify the listener when Scene messages are received. 

Below is an example of the SceneMessageListener, and more information can be found in the documentation supplied with the SDK.

```swift
class Sample: SceneMessageListener {
    //...

    //Adding the listener
    func addListener() {
        self.scene?.add(messageListener: self)
    }

    //Listener methods
    func on(stateMessage: SceneEventMessage) {
        if let body = stateMessage.body as? StateEventBody {
            debugPrint("State message persona component: \(body.persona)")
        }
    }
    
    func on(recognizeResultsMessage: SceneEventMessage) {
        if let body = recognizeResultsMessage.body as? RecognizeResultsEventBody {
            debugPrint("Recognize results data: \(body.results)")
        }
    }
    
    func on(conversationResultMessage: SceneEventMessage) {
        if let body = conversationResultMessage.body as? ConversationResultEventBody {
            debugPrint("Conversation result output: \(body.output)")
        }
    }
    
    func on(userText: String) {
        debugPrint("Listener received userText content: \(userText)")
    }
}
```

```objective-c
@interface Sample<SceneMessageListener>
//...

//Adding the listener
-(void) addListener
{
    [self.scene addWithSceneMessageListener:self];
}

//Listener methods
-(void) onStateMessageWithSceneEventMessage:(SceneEvent *)sceneEventMessage
{
    NSLog(@"State message persona component: %@", ((StateEventBody *)sceneEventMessage.body).persona);
}

-(void) onRecognizeResultsMessageWithSceneEventMessage:(SceneEvent *)sceneEventMessage
{
    NSLog(@"Recognize results data: %@", ((RecognizeResultsEventBody *)sceneEventMessage.body).results);
}

-(void) onConversationResultMessageWithSceneEventMessage:(SceneEvent *)sceneEventMessage
{
    NSLog(@"Conversation result output: %@", ((ConversationResultEventBody *)sceneEventMessage.body).output);
}

-(void) onUserTextEventWithUserText:(NSString *)userText
{
    NSLog(@"Listener received userText content: %@", userText);
}
```

## Persona API

A `Persona` instance is the API used to interact with Digital Humans. After establishing a successful `Scene` connection and the initial state has been established, the `Persona` instance can be obtained from the `scene?.getPersonas()` API. 

Below is an example of a `persona?.animateToNamedCameraWithOrbitPan(param:)` call. All available API calls can be found in the documentation supplied with the SDK. 

```swift
if let persona = self.scene?.getPersonas().first {
    let animation = NamedCameraAnimationParam(cameraName: "CloseUp", time: 1, orbitDegX: 10, orbitDegY: 10, panDeg: 2, tiltDeg: 0)
    persona.animateToNamedCameraWithOrbitPan(param: animation)
}
```

```objective-c
id<Persona> persona = [[self.scene getPersonas] firstObject];
NamedCameraAnimationParam *param = [[NamedCameraAnimationParam alloc] initWithCameraName:@"CloseUp" orbitDegX:@10 orbitDegY:@10 panDeg:@2 tiltDeg:@0 time:@1];
[persona animateToNamedCameraWithOrbitPanWithParam:param];
```

## Enabling background tasks

To maintain a connection when the App is backgrounded, the `Background Modes` Capability should be added in the `Signing and Capabilities` project settings. Once this is enabled, the following `Modes` should be added:
* Voice over IP, and 
* Audio, Airplay, and Picture in Picture.

If electing not to maintain connections when backgrounded, then the Application should call `scene?.disconnect()` on the `didEnterBackground` event.

Note that to maintain the call during the use of other Apps, CallKit functionality should be integrated within applications utilising this SDK.

## Distribution

The functionality within SMDarwin will request both microphone and camera access. While connections can function without these permissions (through sending messages to the `Persona` using `conversationSend(text: String, variables: VariablesModel?, optionalArgs: ConversationOptionalArgs?)`), it is a requirement of Apps submitted to the App Store that do request these permissions contain both the `NSMicrophoneUsageDescription` and `NSCameraUsageDescription` in the `Info.plist` file. If these are not present, the binary will be rejected.

When uploading to AppStoreConnect, simulator frameworks should be removed from the archive. This can be done with the script below, or other such options.

```sh
echo "Target architectures: $ARCHS"

APP_PATH="${TARGET_BUILD_DIR}/${WRAPPER_NAME}"

find "$APP_PATH" -name '*.framework' -type d | while read -r FRAMEWORK
do
FRAMEWORK_EXECUTABLE_NAME=$(defaults read "$FRAMEWORK/Info.plist" CFBundleExecutable)
FRAMEWORK_EXECUTABLE_PATH="$FRAMEWORK/$FRAMEWORK_EXECUTABLE_NAME"
echo "Executable is $FRAMEWORK_EXECUTABLE_PATH"
echo $(lipo -info "$FRAMEWORK_EXECUTABLE_PATH")

FRAMEWORK_TMP_PATH="$FRAMEWORK_EXECUTABLE_PATH-tmp"

# remove simulator's archs if location is not simulator's directory
case "${TARGET_BUILD_DIR}" in
*"iphonesimulator")
    echo "No need to remove archs"
    ;;
*)
    if $(lipo "$FRAMEWORK_EXECUTABLE_PATH" -verify_arch "i386") ; then
    lipo -output "$FRAMEWORK_TMP_PATH" -remove "i386" "$FRAMEWORK_EXECUTABLE_PATH"
    echo "i386 architecture removed"
    rm "$FRAMEWORK_EXECUTABLE_PATH"
    mv "$FRAMEWORK_TMP_PATH" "$FRAMEWORK_EXECUTABLE_PATH"
    fi
    if $(lipo "$FRAMEWORK_EXECUTABLE_PATH" -verify_arch "x86_64") ; then
    lipo -output "$FRAMEWORK_TMP_PATH" -remove "x86_64" "$FRAMEWORK_EXECUTABLE_PATH"
    echo "x86_64 architecture removed"
    rm "$FRAMEWORK_EXECUTABLE_PATH"
    mv "$FRAMEWORK_TMP_PATH" "$FRAMEWORK_EXECUTABLE_PATH"
    fi
    ;;
esac

echo "Completed for executable $FRAMEWORK_EXECUTABLE_PATH"
echo $(lipo -info "$FRAMEWORK_EXECUTABLE_PATH")

done

```
