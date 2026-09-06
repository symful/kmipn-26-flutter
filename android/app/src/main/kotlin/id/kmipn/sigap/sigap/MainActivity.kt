package id.kmipn.sigap.sigap

import io.flutter.embedding.android.FlutterActivity
import android.net.ConnectivityManager
import android.net.Network
import android.net.NetworkCapabilities
import android.net.NetworkRequest
import android.os.Build
import io.flutter.embedding.engine.FlutterEngine
import io.flutter.plugin.common.EventChannel
import io.flutter.plugin.common.MethodChannel

class MainActivity : FlutterActivity() {
    private var networkCallback: ConnectivityManager.NetworkCallback? = null
    override fun configureFlutterEngine(flutterEngine: FlutterEngine) {
        super.configureFlutterEngine(flutterEngine)
        val manager = getSystemService(ConnectivityManager::class.java)
        fun validated(caps: NetworkCapabilities?): Boolean = caps?.hasCapability(NetworkCapabilities.NET_CAPABILITY_INTERNET) == true && caps.hasCapability(NetworkCapabilities.NET_CAPABILITY_VALIDATED)
        var lostNetwork: Network? = null
        fun current(): Boolean {
            val active = manager.activeNetwork ?: return false
            return active != lostNetwork && validated(manager.getNetworkCapabilities(active))
        }
        MethodChannel(flutterEngine.dartExecutor.binaryMessenger, "sigap/internet").setMethodCallHandler { call, result ->
            if (call.method == "isValidated") result.success(current()) else result.notImplemented()
        }
        EventChannel(flutterEngine.dartExecutor.binaryMessenger, "sigap/internet/events").setStreamHandler(object : EventChannel.StreamHandler {
            override fun onListen(arguments: Any?, events: EventChannel.EventSink) {
                networkCallback?.let { manager.unregisterNetworkCallback(it) }
                val callback = object : ConnectivityManager.NetworkCallback() {
                    private var observedNetwork: Network? = manager.activeNetwork
                    override fun onAvailable(network: Network) {
                        runOnUiThread {
                            if (networkCallback !== this) return@runOnUiThread
                            if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.N || network == manager.activeNetwork) {
                                observedNetwork = network
                                if (lostNetwork == network) lostNetwork = null
                                // Availability alone does not prove validated internet.
                                events.success(false)
                            }
                        }
                    }
                    override fun onCapabilitiesChanged(network: Network, caps: NetworkCapabilities) {
                        runOnUiThread {
                            if (networkCallback !== this) return@runOnUiThread
                            if (network == observedNetwork && network != lostNetwork) {
                                events.success(validated(caps))
                            }
                        }
                    }
                    override fun onLost(network: Network) {
                        runOnUiThread {
                            if (networkCallback !== this || network != observedNetwork) return@runOnUiThread
                            lostNetwork = network
                            observedNetwork = null
                            // Android may still return the lost network in activeNetwork here.
                            events.success(false)
                        }
                    }
                }
                networkCallback = callback
                if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.N) manager.registerDefaultNetworkCallback(callback)
                else manager.registerNetworkCallback(NetworkRequest.Builder().addCapability(NetworkCapabilities.NET_CAPABILITY_INTERNET).build(), callback)
                events.success(current())
            }
            override fun onCancel(arguments: Any?) {
                networkCallback?.let { manager.unregisterNetworkCallback(it) }
                networkCallback = null
            }
        })
    }
    override fun cleanUpFlutterEngine(flutterEngine: FlutterEngine) {
        networkCallback?.let { getSystemService(ConnectivityManager::class.java).unregisterNetworkCallback(it) }
        networkCallback = null
        super.cleanUpFlutterEngine(flutterEngine)
    }
}
