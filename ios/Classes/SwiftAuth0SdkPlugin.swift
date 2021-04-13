import Flutter
import UIKit
import Auth0

public class SwiftAuth0SdkPlugin: NSObject {
    
    static var channel: FlutterMethodChannel? = nil
    var webAuth: WebAuth? = nil
    var appAuth: Authentication? = nil
    
    public static func register(with registrar: FlutterPluginRegistrar) {
        channel = FlutterMethodChannel(name: "auth0_sdk", binaryMessenger: registrar.messenger())
        let instance = SwiftAuth0SdkPlugin()
        registrar.addMethodCallDelegate(instance, channel: channel!)
    }
}

extension SwiftAuth0SdkPlugin: FlutterPlugin {
    
    private enum MethodChannel: String {
        case initAuth0 = "init"
        case loginWithEmailAndPassword
        case registerWithEmailAndPassword
        case authWithGoogle
        case authWithApple
        case resetPassword
        case refreshAccessToken
    }
    
    public func application(_ app: UIApplication, open url: URL, options: [UIApplication.OpenURLOptionsKey: Any]) -> Bool {
        return Auth0.resumeAuth(url)
    }
    
    public func handle(_ call: FlutterMethodCall, result: @escaping FlutterResult) {
        guard let method = MethodChannel(rawValue: call.method) else {
            result(FlutterMethodNotImplemented)
            return
        }
        switch method {
        case .initAuth0:
            let args = call.arguments as! [String: Any]
            let clientId = args["clientId"] as! String
            let domain = args["domain"] as! String
            webAuth = Auth0.webAuth(clientId: clientId, domain: domain)
            appAuth = Auth0.authentication(clientId: clientId, domain: domain)
            break;
        case .loginWithEmailAndPassword:
            let args = call.arguments as! [String: Any]
            let email = args["email"] as! String
            let password = args["password"] as! String
            appAuth?.login(
                usernameOrEmail: email,
                password: password,
                realm: "Username-Password-Authentication",
                scope: "openid profile email offline_access")
                .start { response in
                    switch response {
                    case .success(let credentials):
                        var responseValues = [String:String]()
                        responseValues["idToken"] = credentials.idToken
                        responseValues["refreshToken"] = credentials.refreshToken
                        responseValues["accessToken"] = credentials.accessToken
                        result(responseValues)
                    case .failure(let error):
                        if (error is AuthenticationError) {
                            let err:AuthenticationError = error as! AuthenticationError
                            result(FlutterError(code: String(err.statusCode), message: err.description, details: ""))
                        }
                    }
                }
            break;
        case .registerWithEmailAndPassword:
            let args = call.arguments as! [String: Any]
            let email = args["email"] as! String
            let password = args["password"] as! String
            let name = args["name"] as! String
            var attributes = [String: String]()
            if (!name.isEmpty) {
                attributes =  ["name": name]
            }
            appAuth?.createUser(
                email: email,
                password: password,
                connection: "Username-Password-Authentication",
                rootAttributes: attributes)
                .start { response in
                    switch response {
                    case .success(let user):
                        var responseValues = [String:String]()
                        responseValues["email"] = user.email
                        responseValues["username"] = user.username
                        responseValues["emailVerified"] = user.verified.description
                        result(responseValues)
                    case .failure(let error):
                        if (error is AuthenticationError) {
                            let err:AuthenticationError = error as! AuthenticationError
                            result(FlutterError(code: String(err.statusCode), message: err.description, details: ""))
                        }
                    }
                }
            break;
        case .authWithGoogle:
            webAuth?.connection("google-oauth2")
                .scope("openid profile email offline_access")
                .useEphemeralSession()
                .start { response in
                    switch response {
                    case .success(let credentials):
                        var responseValues = [String:String]()
                        responseValues["idToken"] = credentials.idToken
                        responseValues["refreshToken"] = credentials.refreshToken
                        responseValues["accessToken"] = credentials.accessToken
                        result(responseValues)
                    case .failure(let error):
                        if (error is WebAuthError) {
                            let err:WebAuthError = error as! WebAuthError
                            result(FlutterError(code: String(err.errorCode), message: err.errorUserInfo["NSLocalizedDescription"] as! String? ?? "Something went wrong", details: ""))
                        }
                    }
                }
            break;
        case .authWithApple:
            webAuth?.connection("apple")
                .scope("openid profile email offline_access")
                .useEphemeralSession()
                .start { response in
                    switch response {
                    case .success(let credentials):
                        var responseValues = [String:String]()
                        responseValues["idToken"] = credentials.idToken
                        responseValues["refreshToken"] = credentials.refreshToken
                        responseValues["accessToken"] = credentials.accessToken
                        result(responseValues)
                    case .failure(let error):
                        if (error is WebAuthError) {
                            let err:WebAuthError = error as! WebAuthError
                            result(FlutterError(code: String(err.errorCode), message: err.errorUserInfo["NSLocalizedDescription"] as! String? ?? "Something went wrong", details: ""))
                        }
                    }
                }
            break;
        case .resetPassword:
            let args = call.arguments as! [String: Any]
            let email = args["email"] as! String
            appAuth?.resetPassword(email: email, connection: "Username-Password-Authentication").start{ response in
                switch response {
                case .success(_):
                    result(true)
                case .failure(let error):
                    if (error is AuthenticationError) {
                        let err:AuthenticationError = error as! AuthenticationError
                        result(FlutterError(code: String(err.statusCode), message: err.description, details: ""))
                    }
                }
            }
            break;
        case .refreshAccessToken:
            let args = call.arguments as! [String: Any]
            let refreshToken = args["refreshToken"] as! String
            appAuth?.renew(withRefreshToken: refreshToken)
                .start { response in
                    switch response {
                    case .success(let credentials):
                        var responseValues = [String:String]()
                        responseValues["idToken"] = credentials.idToken
                        responseValues["refreshToken"] = credentials.refreshToken
                        responseValues["accessToken"] = credentials.accessToken
                        result(responseValues)
                    case .failure(let error):
                        if (error is AuthenticationError) {
                            let err:AuthenticationError = error as! AuthenticationError
                            result(FlutterError(code: String(err.statusCode), message: err.description, details: ""))
                        }
                    }
                }
            break;
        }
    }
}
