package be.rmdy.auth0_sdk

import android.app.Activity
import android.content.Context
import be.rmdy.auth0_sdk.auth0.SDKService
import io.flutter.embedding.engine.plugins.FlutterPlugin
import io.flutter.plugin.common.MethodCall
import io.flutter.plugin.common.MethodChannel
import io.flutter.plugin.common.MethodChannel.MethodCallHandler
import io.flutter.plugin.common.MethodChannel.Result
import io.flutter.embedding.engine.plugins.activity.ActivityAware
import io.flutter.embedding.engine.plugins.activity.ActivityPluginBinding

private const val connection_name = "Username-Password-Authentication"

/** Auth0SdkPlugin */
class Auth0SdkPlugin: FlutterPlugin, MethodCallHandler, ActivityAware {
  /// The MethodChannel that will the communication between Flutter and native Android
  ///
  /// This local reference serves to register the plugin with the Flutter Engine and unregister it
  /// when the Flutter Engine is detached from the Activity
  private lateinit var channel : MethodChannel
  private lateinit var context: Context
  private lateinit var activity: Activity

  private val sdkService = SDKService()


  override fun onAttachedToEngine(flutterPluginBinding: FlutterPlugin.FlutterPluginBinding) {
    channel = MethodChannel(flutterPluginBinding.binaryMessenger, "auth0_sdk")
    channel.setMethodCallHandler(this)
    context = flutterPluginBinding.applicationContext
  }

  override fun onAttachedToActivity(binding: ActivityPluginBinding) {
    activity = binding.activity
  }

  override fun onDetachedFromActivity() {}

  override fun onReattachedToActivityForConfigChanges(binding: ActivityPluginBinding) {}

  override fun onDetachedFromActivityForConfigChanges() {}

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
      "loginWithEmailAndPassword" -> {
        val email:String = call.argument<String>("email")!!
        val password:String = call.argument<String>("password")!!
        sdkService.loginWithEmailAndPassword(email, password, object: (LoginResult) -> Unit {
          override fun invoke(resultValue: LoginResult) {
            handleResult(resultValue, result)
          }
        })
      }
      "registerWithEmailAndPassword" -> {
        val email:String = call.argument<String>("email")!!
        val password:String = call.argument<String>("password")!!
        val name:String = call.argument<String>("name")!!
        sdkService.registerWithEmailAndPassword(email, password, name, connection_name, object: (RegisterResult) -> Unit {
          override fun invoke(resultValue: RegisterResult) {
            if (resultValue is RegisterSuccess) {
              val returnValue: MutableMap<String, String> = mutableMapOf()
              returnValue["email"] = resultValue.email
              returnValue["username"] = resultValue.username ?: ""
              returnValue["emailVerified"] = resultValue.emailVerified.toString()
              result.success(returnValue)
            } else if (resultValue is RegisterError) {
              result.error(resultValue.code.toString(), resultValue.message, null)
            }
          }
        })
      }
      "authWithGoogle" -> {
        sdkService.authWithGoogle(activity, object: (LoginResult) -> Unit {
          override fun invoke(resultValue: LoginResult) {
            handleResult(resultValue, result)
          }
        })
      }
      "authWithApple" -> {
        sdkService.authWithApple(activity, object: (LoginResult) -> Unit {
          override fun invoke(resultValue: LoginResult) {
            handleResult(resultValue, result)
          }
        })
      }
      "refreshAccessToken" -> {
        val refreshToken:String = call.argument<String>("refreshToken")!!
        sdkService.refreshAccessToken(refreshToken, object: (LoginResult) -> Unit {
          override fun invoke(resultValue: LoginResult) {
            handleResult(resultValue, result)
          }
        })
      }
      "resetPassword" -> {
        val email: String = call.argument<String>("email")!!
        sdkService.resetPassword(email, connection_name, object: (ResetPasswordResult) -> Unit {
          override fun invoke(resultValue: ResetPasswordResult) {
            if(resultValue is ResetPasswordSuccess) {
              result.success(true)
            }else if(resultValue is ResetPasswordError) {
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

  private fun handleResult(resultValue: LoginResult, result: Result) {
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

  override fun onDetachedFromEngine(binding: FlutterPlugin.FlutterPluginBinding) {
    channel.setMethodCallHandler(null)
  }
}

sealed class LoginResult
data class LoginSuccess(val idToken: String, val accessToken: String, val refreshToken: String?) : LoginResult()
data class LoginError(val code: Int, val message: String) : LoginResult()

sealed class RegisterResult
data class RegisterSuccess(val email: String, val username: String?, val emailVerified: Boolean) : RegisterResult()
data class RegisterError(val code: Int, val message: String) : RegisterResult()

sealed class ResetPasswordResult
data class ResetPasswordSuccess(val success: Boolean): ResetPasswordResult()
data class ResetPasswordError(val code: Int, val message: String) : ResetPasswordResult()