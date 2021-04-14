package be.rmdy.auth0_sdk.auth0

import android.content.Context
import android.util.Log
import be.rmdy.auth0_sdk.*
import com.auth0.android.Auth0
import com.auth0.android.authentication.AuthenticationAPIClient
import com.auth0.android.authentication.AuthenticationException
import com.auth0.android.callback.Callback
import com.auth0.android.provider.WebAuthProvider
import com.auth0.android.result.Credentials
import com.auth0.android.result.DatabaseUser

class SDKService {

    var initialized = false
    var account: Auth0? = null
    var apiClient: AuthenticationAPIClient? = null
    var scheme: String? = null

    fun initialize(clientId: String, domain: String, scheme: String, onResult: (Boolean) -> Unit) {
        this.account = Auth0(clientId, domain)
        this.scheme = scheme;
        // Only enable network traffic logging on production environments!
        //this.account!!.networkingClient = DefaultClient(enableLogging = true)
        this.apiClient = AuthenticationAPIClient(this.account!!)
        initialized = true
        onResult(true)
    }

    fun loginWithEmailAndPassword(email: String, password: String, onResult: (LoginResult) -> Unit) {
        apiClient?.login(email, password)?.setScope("openid profile email offline_access")?.start(object :
                Callback<Credentials, AuthenticationException> {
            override fun onFailure(error: AuthenticationException) {
                onResult(LoginError(code = error.statusCode, message = error.message
                        ?: "error while logging in with username/password "))
            }

            override fun onSuccess(result: Credentials) {
                onResult(LoginSuccess(idToken = result.idToken, refreshToken = result.refreshToken, accessToken = result.accessToken))
            }
        })
    }

    fun registerWithEmailAndPassword(email: String, password: String, name: String, connection: String, onResult: (RegisterResult) -> Unit) {
        val metadata: MutableMap<String, String> = HashMap()
        if (name.isNotBlank()) {
            metadata["name"] = name
        }
        apiClient?.createUser(email = email, password = password, connection = connection)?.addParameters(metadata)?.start(object :
                Callback<DatabaseUser, AuthenticationException> {
            override fun onFailure(error: AuthenticationException) {
                onResult(RegisterError(code = error.statusCode, message = error.message
                        ?: "error while registering with username/password "))
            }

            override fun onSuccess(result: DatabaseUser) {
                onResult(RegisterSuccess(email = result.email, username = result.username, emailVerified = result.isEmailVerified))
            }
        })
    }

    fun authWithGoogle(context: Context, onResult: (LoginResult) -> Unit) {
        authWithSocialProvider(connection = "google-oauth2", context = context, onResult = onResult)
    }

    fun authWithApple(context: Context, onResult: (LoginResult) -> Unit) {
        authWithSocialProvider(connection = "apple", context = context, onResult = onResult)
    }

    private fun authWithSocialProvider(connection: String, context: Context, onResult: (LoginResult) -> Unit) {
        WebAuthProvider.login(this.account!!)
                .withScheme(this.scheme!!)
                .withScope("openid profile email offline_access")
                .withConnection(connection)
                .start(context, object : Callback<Credentials, AuthenticationException> {
                    override fun onFailure(error: AuthenticationException) {
                        onResult(LoginError(code = error.statusCode, message = error.message
                                ?: "error while authenticating with $connection "))
                    }

                    override fun onSuccess(result: Credentials) {
                        onResult(LoginSuccess(idToken = result.idToken, refreshToken = result.refreshToken, accessToken = result.accessToken))
                    }
                })
    }

    fun resetPassword(email: String, connection: String, onResult: (ResetPasswordResult) -> Unit) {
        apiClient?.resetPassword(email = email, connection = connection)?.start(object : Callback<Void?, AuthenticationException> {
            override fun onFailure(error: AuthenticationException) {
                onResult(ResetPasswordError(code = error.statusCode, message = error.message
                        ?: "error while resetting password"))
            }

            override fun onSuccess(result: Void?) {
                onResult(ResetPasswordSuccess(success = true))
            }
        })
    }

    fun refreshAccessToken(refreshToken: String, onResult: (LoginResult) -> Unit) {
        apiClient?.renewAuth(refreshToken)?.start(object : Callback<Credentials, AuthenticationException> {
            override fun onFailure(error: AuthenticationException) {
                onResult(LoginError(code = error.statusCode, message = error.message
                        ?: "error while refreshing accessToken"))
            }

            override fun onSuccess(result: Credentials) {
                onResult(LoginSuccess(idToken = result.idToken, refreshToken = result.refreshToken, accessToken = result.accessToken))
            }
        })
    }

}