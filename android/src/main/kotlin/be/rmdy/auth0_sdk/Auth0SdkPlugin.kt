package be.rmdy.auth0_sdk

import be.rmdy.auth0_sdk.auth0.SDKService
import io.flutter.embedding.engine.plugins.FlutterPlugin
import io.flutter.plugin.common.MethodCall
import io.flutter.plugin.common.MethodChannel
import io.flutter.plugin.common.MethodChannel.MethodCallHandler
import io.flutter.plugin.common.MethodChannel.Result
import io.flutter.plugin.common.PluginRegistry.Registrar

/** Auth0SdkPlugin */
class Auth0SdkPlugin: FlutterPlugin, MethodCallHandler {
  /// The MethodChannel that will the communication between Flutter and native Android
  ///
  /// This local reference serves to register the plugin with the Flutter Engine and unregister it
  /// when the Flutter Engine is detached from the Activity
  private lateinit var channel : MethodChannel

  private val sdkService = SDKService()

  override fun onAttachedToEngine(flutterPluginBinding: FlutterPlugin.FlutterPluginBinding) {
    channel = MethodChannel(flutterPluginBinding.binaryMessenger, "auth0_sdk")
    channel.setMethodCallHandler(this)
  }

  override fun onMethodCall(call: MethodCall, result: Result) {
    if (call.method != "init" && !sdkService.initialized) {
      result.error("1", "Please call init first", "")
    } else {
      executeChannels(call, result)
    }
  }

  private fun executeChannels(call: MethodCall, result: Result) {
    when (call.method) {
      "init" -> {
        val clientId:String = call.argument<String>("clientId")!!
        val domain:String = call.argument<String>("domain")!!
        sdkService.initialize(clientId, domain, object: (Boolean) -> Unit {
          override fun invoke(success: Boolean) {
            if (success) {
              result.success(null)
            }  else {
              result.error("", "Could not init sdk", null)
            }
          }
        } )
      }
      "loginUsernamePassword" -> {
        val username:String = call.argument<String>("username")!!
        val password:String = call.argument<String>("password")!!
        sdkService.loginUsernamePassword(username, password, object: (LoginResult) -> Unit {
          override fun invoke(resultValue: LoginResult) {
            if (resultValue is LoginSuccess) {
              val returnValue: MutableMap<String, String> = mutableMapOf()
              returnValue["idToken"] = resultValue.idToken
              returnValue["refreshToken"] = resultValue.refreshToken ?: ""
              returnValue["accessToken"] = resultValue.accessToken
              result.success(returnValue)
            } else if (resultValue is LoginError) {
              result.error(resultValue.code.toString(), resultValue.message, null)
            }
          }
        })
      }
      else -> {
        result.notImplemented()
      }
    }
  }

  override fun onDetachedFromEngine(binding: FlutterPlugin.FlutterPluginBinding) {
    channel.setMethodCallHandler(null)
  }
}

sealed class LoginResult
data class LoginSuccess(val idToken: String, val accessToken: String, val refreshToken: String?) : LoginResult()
data class LoginError(val code: Int, val message: String) : LoginResult()