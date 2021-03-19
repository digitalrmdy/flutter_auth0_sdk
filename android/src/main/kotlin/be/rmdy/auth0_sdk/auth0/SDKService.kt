package be.rmdy.auth0_sdk.auth0

import android.content.Context
import be.rmdy.auth0_sdk.LoginError
import be.rmdy.auth0_sdk.LoginResult
import be.rmdy.auth0_sdk.LoginSuccess
import com.auth0.android.Auth0
import com.auth0.android.authentication.AuthenticationAPIClient
import com.auth0.android.authentication.AuthenticationException
import com.auth0.android.callback.Callback
import com.auth0.android.provider.WebAuthProvider
//import com.auth0.android.request.DefaultClient
import com.auth0.android.result.Credentials

class SDKService {

    var initialized = false
    var account:Auth0? = null
    var apiClient: AuthenticationAPIClient? = null

    fun initialize(clientId: String, domain: String, onResult: (Boolean) -> Unit) {
            this.account = Auth0(clientId,  domain)
            // Only enable network traffic logging on production environments!
            //this.account!!.networkingClient = DefaultClient(enableLogging = true)
            this.apiClient =  AuthenticationAPIClient(this.account!!)
            initialized = true
            onResult(true)
    }

    fun loginUsernamePassword(username: String, password: String, onResult: (LoginResult) -> Unit) {
        apiClient?.login(username, password)?.start(object : Callback<Credentials, AuthenticationException> {
            override fun onFailure(error: AuthenticationException) {
                onResult(LoginError(code = error.statusCode, message = error.message ?: "error while logging in with username/password "))
            }

            override fun onSuccess(result: Credentials) {
                onResult(LoginSuccess(idToken = result.idToken, refreshToken = result.refreshToken, accessToken = result.accessToken))
            }
        })
    }

    fun authWithGoogle(context: Context, onResult: (LoginResult) -> Unit){
        authWithSocialProvider(connection = "google-oauth2", context = context, onResult = onResult)
    }

    fun authWithApple(context: Context, onResult: (LoginResult) -> Unit){
        authWithSocialProvider(connection = "apple", context = context, onResult = onResult)
    }

    private fun authWithSocialProvider(connection: String, context: Context, onResult: (LoginResult) -> Unit){
        WebAuthProvider.login(this.account!!)
                .withScope("openid profile email offline_access")
                .withConnection(connection)
                .start(context, object : Callback<Credentials, AuthenticationException> {
                    override fun onFailure(error: AuthenticationException) {
                        onResult(LoginError(code = error.statusCode, message = error.message ?: "error while authenticating with $connection "))
                    }

                    override fun onSuccess(result: Credentials) {
                        onResult(LoginSuccess(idToken = result.idToken, refreshToken = result.refreshToken, accessToken = result.accessToken))
                    }
                })
    }

}